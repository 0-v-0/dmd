/**
 * Interface for CodeView symbol debug info generation
 *
 * Compiler implementation of the
 * $(LINK2 https://www.dlang.org, D programming language).
 *
 * Copyright:   Copyright (C) 1985-1998 by Symantec
 *              Copyright (C) 2000-2026 by The D Language Foundation, All Rights Reserved
 * Authors:     $(LINK2 https://www.digitalmars.com, Walter Bright)
 * License:     $(LINK2 https://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Source:      $(LINK2 https://github.com/dlang/dmd/blob/master/compiler/src/dmd/backend/cgcv.d, backend/cgcv.c)
 */

/* Header for cgcv.c    */

module dmd.backend.cgcv;

// Online documentation: https://dlang.org/phobos/dmd_backend_cgcv.html

import dmd.backend.cc : Classsym, Symbol;
import dmd.backend.type;

public import dmd.backend.cv8;
public import dmd.backend.dwarfdbginf : dwarf_outsym;

import core.stdc.stdio;
import core.stdc.stdlib;
import core.stdc.string;

import dmd.backend.cc;
import dmd.backend.cdef;
import dmd.backend.cgcv;
import dmd.backend.code;
import dmd.backend.x86.code_x86;
import dmd.backend.cv4;
import dmd.backend.dvec;
import dmd.backend.el;
import dmd.backend.global : err_nomem;
import dmd.backend.debugprint : tym_str;
import dmd.backend.symbol : symbol_print, symbol_reset, globsym;
import dmd.backend.mem;
import dmd.backend.obj;
import dmd.backend.symbol;
import dmd.backend.ty;
import dmd.backend.type;

import dmd.backend.barray;

import dmd.common.outbuffer;

import dmd.backend.dvarstats;

nothrow:
@safe:

/* =================== Added for MARS compiler ========================= */

alias idx_t = uint;        // type of type index

/* Data structure for a type record     */

struct debtyp_t
{
  align(1):
    uint prev;          // previous debtyp_t with same hash
    ushort length;      // length of following array
    ubyte[2] data;      // variable size array
}

struct Cgcv
{
    uint signature;
    idx_t deb_offset;   // offset added to type index
    uint sz_idx;        // size of stored type index
    int LCFDoffset;
    int LCFDpointer;
    int FD_code;        // frame for references to code
}

__gshared Cgcv cgcv;

@trusted
void TOWORD(ubyte* a, uint b)
{
    *cast(ushort*)a = cast(ushort)b;
}

@trusted
void TOLONG(ubyte* a, uint b)
{
    *cast(uint*)a = b;
}

@trusted
void TOIDX(ubyte* a, uint b)
{
    if (cgcv.sz_idx == 4)
        TOLONG(a,b);
    else
        TOWORD(a,b);
}

enum DEBSYM = 5;               // segment of symbol info
enum DEBTYP = 6;               // segment of type info

@trusted
void TOOFFSET(void* p, targ_size_t value)
{
    switch (_tysize[TYnptr])
    {
        case 2: *cast(ushort*)p = cast(ushort)value; break;
        case 4: *cast(uint*)  p = cast(uint)  value; break;
        case 8: *cast(ulong*) p = cast(ulong) value; break;
        default:
            assert(0);
    }
}

__gshared
{
private char* ftdbname = null;


/* Dynamic array of debtyp_t's  */
private Barray!(debtyp_t*) debtyp;

private vec_t debtypvec;     // vector of used entries
enum DEBTYPVECDIM = 16_001;   //8009 //3001     // dimension of debtypvec (should be prime)

enum DEBTYPHASHDIM = 1009;
private uint[DEBTYPHASHDIM] debtyphash;

private OutBuffer* reset_symbuf; // Keep pointers to reset symbols

@trusted
idx_t DEB_NULL() { return cgcv.deb_offset; }        // index of null debug type record

/* This limitation is because of 4K page sizes
 * in optlink/cv/cvhashes.asm
 */
enum CVIDMAX = (0xFF0-20);   // the -20 is picked by trial and error

enum LOCATsegrel = 0xC000;

/* Unfortunately, the fixup stuff is different for EASY OMF and Microsoft */
enum EASY_LCFDoffset  =      (LOCATsegrel | 0x1404);
enum EASY_LCFDpointer =      (LOCATsegrel | 0x1800);

enum LCFD32offset     =      (LOCATsegrel | 0x2404);
enum LCFD32pointer    =      (LOCATsegrel | 0x2C00);
enum LCFD16pointer    =      (LOCATsegrel | 0x0C00);
}

enum MARS = true;

/******************************************
 * Return number of bytes consumed in OBJ file by a name.
 */

@trusted
int cv_stringbytes(const(char)* name)
{
    int len = cast(int)strlen(name);
    return len + 1;
}

/******************************************
 * Stuff a namestring into p.
 * Returns:
 *      number of bytes consumed
 */

@trusted
int cv_namestring(ubyte* p, const(char)* name, int length = -1)
{
    size_t len = (length >= 0) ? length : strlen(name);
    size_t numBytesWritten = len + ((length < 0) ? 1 : 0);
    memcpy(p, name, numBytesWritten);
    if(config.flags2 & CFG2gms)
    {
        for(int i = 0; i < len; i++)
        {
            if(p[i] == '.')
                p[i] = '@';
        }
    }
    return cast(int)numBytesWritten;
}

/***********************************
 * Allocate a debtyp_t.
 */
@trusted
debtyp_t* debtyp_alloc(uint length)
{
    //printf("len = %u, x%x\n", length, length);
    // length+2 must lie on 4 byte boundary
    uint pad = ((length + 2 + 3) & ~3) - (length + 2);
    length += pad;

    if (length > ushort.max)
        err_nomem();

    const len = debtyp_t.sizeof - debtyp_t.data.sizeof + length;
    debtyp_t* d;
debug
{
    d = cast(debtyp_t*) mem_malloc(len /*+ 1*/);
    memset(d, 0xAA, len);
//    (cast(char*)d)[len] = 0x2E;
}
else
{
    d = cast(debtyp_t*) malloc(debtyp_t.sizeof - (d.data).sizeof + length);
    if (!d)
        err_nomem();
}
    d.length = cast(ushort)length;
    if (pad)
    {
        __gshared const ubyte[3] padx = [0xF3, 0xF2, 0xF1];
        memcpy(d.data.ptr + length - pad, padx.ptr + 3 - pad, pad);
    }
    //printf("debtyp_alloc(%d) = %p\n", length, d);
    return d;
}

/***********************************
 * Free a debtyp_t.
 */

@trusted
private void debtyp_free(debtyp_t* d)
{
    //printf("debtyp_free(length = %d, %p)\n", d.length, d);
    //fflush(stdout);
debug
{
    assert(d.length <= ushort.max);
    uint len = debtyp_t.sizeof - (d.data).sizeof + d.length;
//    assert((cast(char*)d)[len] == 0x2E);
    memset(d, 0x55, len);
    mem_free(d);
}
else
{
    free(d);
}
}

/***********************************
 * Search for debtyp_t in debtyp[]. If it is there, return the index
 * of it, and free d. Otherwise, add it.
 * Returns:
 *      index in debtyp[]
 */

@trusted
idx_t cv_debtyp(debtyp_t* d)
{
    uint hashi;

    assert(d);
    const length = d.length;
    //printf("length = %3d\n",length);
    if (length)
    {
        uint hash = length;
        if (length >= uint.sizeof)
        {
            // Hash consists of the sum of the first 4 bytes with the last 4 bytes
            union U { ubyte* cp; uint* up; }
            U un;
            un.cp = d.data.ptr;
            hash += *un.up;
            un.cp += length - uint.sizeof;
            hash += *un.up;
        }
        hashi = hash % DEBTYPHASHDIM;
        hash %= DEBTYPVECDIM;
//printf(" hashi = %d", hashi);

        if (vec_testbit(hash,debtypvec))
        {
//printf(" test");
            // Threaded list is much faster
            for (uint u = debtyphash[hashi]; u; u = debtyp[u].prev)
            //for (uint u = debtyp.length; u--; )
            {
                if (length == debtyp[u].length &&
                    memcmp(d.data.ptr,debtyp[u].data.ptr,length) == 0)
                {   debtyp_free(d);
//printf(" match %d\n",u);
                    return u + cgcv.deb_offset;
                }
            }
        }
        else
            vec_setbit(hash,debtypvec);
    }
    else
        hashi = 1;
//printf(" add   %d\n",debtyp.length);
    d.prev = debtyphash[hashi];
    debtyphash[hashi] = cast(uint)debtyp.length;

    /* It's not already in the array, so add it */
    debtyp.push(d);

    return cast(uint)debtyp.length - 1 + cgcv.deb_offset;
}

@trusted
idx_t cv_numdebtypes()
{
    return cast(idx_t)debtyp.length;
}

/****************************
 * Store a null record at DEB_NULL.
 */

@trusted
void cv_init()
{
    //printf("cv_init()\n");

    // Initialize statics
    debtyp.setLength(0);
    if (!ftdbname)
        ftdbname = cast(char*)"symc.tdb".ptr;

    memset(&cgcv,0,cgcv.sizeof);
    cgcv.sz_idx = 2;
    cgcv.LCFDoffset = LCFD32offset;
    cgcv.LCFDpointer = LCFD16pointer;

    debtypvec = vec_calloc(DEBTYPVECDIM);
    memset(debtyphash.ptr,0,debtyphash.sizeof);

    if (reset_symbuf)
    {
        Symbol** p = cast(Symbol**)reset_symbuf.buf;
        const size_t n = reset_symbuf.length() / (Symbol*).sizeof;
        for (size_t i = 0; i < n; ++i)
            symbol_reset(*p[i]);
        reset_symbuf.reset();
    }
    else
    {
        reset_symbuf = cast(OutBuffer*) calloc(1, OutBuffer.sizeof);
        if (!reset_symbuf)
            err_nomem();
        reset_symbuf.reserve(10 * (Symbol*).sizeof);
    }

    /* Reset for different OBJ file formats     */
    if (I32 || I64)
    {
        // Adjust values in old CV tables for 32 bit ints
        dttab[TYenum] = dttab[TYlong];
        dttab[TYint]  = dttab[TYlong];
        dttab[TYuint] = dttab[TYulong];

        // Adjust Codeview 4 values for 32 bit ints and 32 bit pointer offsets
        dttab4[TYenum] = 0x74;
        dttab4[TYint]  = 0x74;
        dttab4[TYuint] = 0x75;
        if (I64)
        {
            dttab4[TYptr]  = 0x600;
            dttab4[TYnptr] = 0x600;
            dttab4[TYsptr] = 0x600;
            dttab4[TYimmutPtr] = 0x600;
            dttab4[TYsharePtr] = 0x600;
            dttab4[TYrestrictPtr] = 0x600;
            dttab4[TYfgPtr] = 0x600;
        }
        else
        {
            dttab4[TYptr]  = 0x400;
            dttab4[TYsptr] = 0x400;
            dttab4[TYnptr] = 0x400;
            dttab4[TYimmutPtr] = 0x400;
            dttab4[TYsharePtr] = 0x400;
            dttab4[TYrestrictPtr] = 0x400;
            dttab4[TYfgPtr] = 0x400;
        }
        dttab4[TYcptr] = 0x400;
        dttab4[TYfptr] = 0x500;

        if (config.flags & CFGeasyomf)
        {   cgcv.LCFDoffset  = EASY_LCFDoffset;
            cgcv.LCFDpointer = EASY_LCFDpointer;
            assert(config.fulltypes == CVOLD);
        }
        else
            cgcv.LCFDpointer = LCFD32pointer;

        if (config.exe & EX_flat)
            cgcv.FD_code = 0x10;
    }

    // Put out signature indicating CV8 format
    cgcv.signature = 4;
    cgcv.deb_offset = 0x1000;
    cgcv.sz_idx = 4;
    // figure out rest later
}

/////////////////////////// CodeView 4 ///////////////////////////////

/***********************************
 * Return number of bytes required to store a numeric leaf.
 */

uint cv4_numericbytes(uint value)
{   uint u;

    if (value < 0x8000)
        u = 2;
    else if (value < 0x10000)
        u = 4;
    else
        u = 6;
    return u;
}

/********************************
 * Store numeric leaf.
 * Must use exact same number of bytes as cv4_numericbytes().
 */

@trusted
void cv4_storenumeric(ubyte* p, uint value)
{
    if (value < 0x8000)
        TOWORD(p,value);
    else if (value < 0x10000)
    {   TOWORD(p,LF_USHORT);
        p += 2;
        TOWORD(p,value);
    }
    else
    {   TOWORD(p,LF_ULONG);
        *cast(targ_ulong*)(p + 2) = cast(uint) value;
    }
}

/***********************************
 * Return number of bytes required to store a signed numeric leaf.
 * Params:
 *   value = value to store
 * Returns:
 *   number of bytes required for storing value
 */
uint cv4_signednumericbytes(int value)
{
    uint u;
    if (value >= 0 && value < 0x8000)
        u = 2;
    else if (value == cast(short)value)
        u = 4;
    else
        u = 6;
    return u;
}

/********************************
 * Store signed numeric leaf.
 * Must use exact same number of bytes as cv4_signednumericbytes().
 * Params:
 *   p = address where to store value
 *   value = value to store
 */
@trusted
void cv4_storesignednumeric(ubyte* p, int value)
{
    if (value >= 0 && value < 0x8000)
        TOWORD(p, value);
    else if (value == cast(short)value)
    {
        TOWORD(p, LF_SHORT);
        TOWORD(p + 2, value);
    }
    else
    {
        TOWORD(p,LF_LONG);
        TOLONG(p + 2, value);
    }
}

/*********************************
 * Generate a type index for a parameter list.
 */

@trusted
idx_t cv4_arglist(type* t,uint* pnparam)
{
    idx_t paramidx;
    debtyp_t* d;

    // Compute nparam, number of parameters
    uint nparam = 0;
    if (t.Tparamtypes)
        nparam = cast(uint)(*t.Tparamtypes).length;
    *pnparam = nparam;

    // Construct an LF_ARGLIST of those parameters
    if (nparam == 0)
    {
        d = debtyp_alloc(2 + 4 + 4);
        TOWORD(d.data.ptr,LF_ARGLIST_V2);
        TOLONG(d.data.ptr + 2,1);
        TOLONG(d.data.ptr + 6,0);
        paramidx = cv_debtyp(d);
    }
    else
    {
        d = debtyp_alloc(2 + 4 + nparam * 4);
        TOWORD(d.data.ptr,LF_ARGLIST_V2);
        TOLONG(d.data.ptr + 2,nparam);

        foreach (u; 0 .. nparam)
        {
            auto p = (*t.Tparamtypes)[u];
            TOLONG(d.data.ptr + 6 + u * 4,cv4_typidx(p.Ptype));
        }
        paramidx = cv_debtyp(d);
    }
    return paramidx;
}

@trusted
private uint cv4_fwdenum(type* t)
{
    Symbol* s = t.Ttag;

    // write a forward reference enum record that is enough for the linker to
    // fold with original definition from EnumDeclaration
    uint bty = dttab4[tybasic(t.Tnext.Tty)];
    const id = prettyident(s);
    uint len = 14;
    debtyp_t* d = debtyp_alloc(len + cv_stringbytes(id));
    TOWORD(d.data.ptr, LF_ENUM_V3);
    TOLONG(d.data.ptr + 2, 0);    // count
    TOWORD(d.data.ptr + 4, 0x80); // property : forward reference
    TOLONG(d.data.ptr + 6, bty);  // memtype
    TOLONG(d.data.ptr + 10, 0);   // fieldlist

    cv_namestring(d.data.ptr + len, id);
    s.Stypidx = cv_debtyp(d);
    return s.Stypidx;
}

/************************************************
 * Return 'calling convention' type of function.
 */

ubyte cv4_callconv(type* t)
{   ubyte call;

    switch (tybasic(t.Tty))
    {
        case TYffunc:   call = 1;       break;
        case TYfpfunc:  call = 3;       break;
        case TYf16func: call = 3;       break;
        case TYfsfunc:  call = 8;       break;
        case TYnsysfunc: call = 9;      break;
        case TYfsysfunc: call = 10;     break;
        case TYnfunc:   call = 0;       break;
        case TYnpfunc:  call = 2;       break;
        case TYnsfunc:  call = 7;       break;
        case TYifunc:   call = 1;       break;
        case TYjfunc:   call = 2;       break;
        case TYmfunc:   call = 11;      break;  // this call
        default:
            assert(0);
    }
    return call;
}

/**********************************************
 * Return type index for the type of a symbol.
 */
private uint cv4_symtypidx(Symbol* s)
{
    return cv4_typidx(s.Stype);
}

/***********************************
 * Return CV4 type index for a type.
 */

@trusted
uint cv4_typidx(type* t)
{   uint typidx;
    uint u;
    uint key;
    debtyp_t* d;
    targ_size_t size;
    tym_t tymnext;
    type* tv;

    //printf("cv4_typidx(%p)\n",t);
    if (!t)
        return dttab4[TYint];           // assume int
    type_debug(t);
    uint next = cv4_typidx(t.Tnext);
    tym_t tycv = t.Tty;
    tym_t tym = tybasic(tycv);
    tycv &= mTYconst | mTYvolatile | mTYimmutable;
    uint attribute = 0;
L1:
    uint dt = dttab4[tym];
    switch (tym)
    {
        case TYllong:
            if (t.Tnext)
                goto Ldelegate;
            assert(dt);
            typidx = dt;
            break;

        case TYullong:
            if (t.Tnext)
                goto Ldarray;
            assert(dt);
            typidx = dt;
            break;

        case TYvoid:
        case TYnoreturn:
        case TYchar:
        case TYschar:
        case TYuchar:
        case TYchar16:
        case TYshort:
        case TYushort:
        case TYint:
        case TYuint:
        case TYulong:
        case TYlong:
        case TYfloat:
        case TYdouble:
        case TYdouble_alias:
        case TYreal:
        case TYifloat:
        case TYidouble:
        case TYireal:
        case TYcfloat:
        case TYcdouble:
        case TYcreal:
        case TYbool:
        case TYwchar_t:
        case TYdchar:
            assert(dt);
            typidx = dt;
            break;

        case TYnptr:
        case TYimmutPtr:
        case TYsharePtr:
        case TYrestrictPtr:
            if (t.Tkey)
                goto Laarray;
            goto Lptr;
        case TYsptr:
        case TYcptr:
        case TYfgPtr:
        Lptr:
                        attribute |= I32 ? 10 : 0;      goto L2;

        case TYfptr:
        case TYvptr:    attribute |= I32 ? 11 : 1;      goto L2;
        case TYhptr:    attribute |= 2; goto L2;

        L2:
            if ((next < 0x100) && !(attribute & 0xE0)) // basic type?
                typidx = next | dt;
            else
            {
                if (tycv & (mTYconst | mTYimmutable))
                    attribute |= 0x400;
                if (tycv & mTYvolatile)
                    attribute |= 0x200;
                tycv = 0;
                d = debtyp_alloc(10);
                TOWORD(d.data.ptr,LF_POINTER_V2);
                TOLONG(d.data.ptr + 2,next);
                // see https://github.com/Microsoft/microsoft-pdb/blob/master/include/cvinfo.h#L1514
                // add size and pointer type (PTR_64 or PTR_NEAR32)
                attribute |= (I64 ? (8 << 13) | 0xC : (4 << 13) | 0xA);
                // convert reference to r-value reference to remove & from type display in debugger
                if (attribute & 0x20)
                    attribute |= 0x80;
                TOLONG(d.data.ptr + 6,attribute);
                typidx = cv_debtyp(d);
            }
            break;

        Ldarray:
            typidx = cv8_darray(t, next);
            break;

        Laarray:
            key = cv4_typidx(t.Tkey);
            typidx = cv8_daarray(t, key, next);
            break;

        Ldelegate:
            typidx = cv8_ddelegate(t, next);
            break;

        case TYcent:
            if (t.Tnext)
                goto Ldelegate;
            assert(dt);
            typidx = dt;
            break;

        case TYucent:
            if (t.Tnext)
                goto Ldarray;
            assert(dt);
            typidx = dt;
            break;

        case TYarray:
        {   if (t.Tflags & TF.sizeunknown)
                size = 0;               // don't complain if don't know size
            else
                size = type_size(t);
        Larray:
            u = cv4_numericbytes(cast(uint)size);
            uint idxtype = I32 ? 0x12 : 0x11;  // T_LONG : T_SHORT
            if (I64)
                idxtype = 0x23;                    // T_UQUAD
            if(next == dttab4[TYvoid])    // do not encode void[n], this confuses the debugger
                next = dttab4[TYuchar];   // use ubyte instead

            d = debtyp_alloc(10 + u + 1);
            TOWORD(d.data.ptr,LF_ARRAY_V3);
            TOLONG(d.data.ptr + 2,next);
            TOLONG(d.data.ptr + 6,idxtype);
            d.data.ptr[10 + u] = 0;             // no name
            cv4_storenumeric(d.data.ptr + 10,cast(uint)size);
            typidx = cv_debtyp(d);
            break;
        }

        case TYffunc:
        case TYfpfunc:
        case TYf16func:
        case TYfsfunc:
        case TYnsysfunc:
        case TYfsysfunc:
        case TYnfunc:
        case TYnpfunc:
        case TYnsfunc:
        case TYmfunc:
        case TYjfunc:
        case TYifunc:
        {
            uint nparam;
            ubyte call = cv4_callconv(t);
            idx_t paramidx = cv4_arglist(t,&nparam);

            // Construct an LF_PROCEDURE
            d = debtyp_alloc(2 + 4 + 1 + 1 + 2 + 4);
            TOWORD(d.data.ptr,LF_PROCEDURE_V2);
            TOLONG(d.data.ptr + 2,next);       // return type
            d.data.ptr[6] = call;
            d.data.ptr[7] = 0;                 // reserved
            TOWORD(d.data.ptr + 8,nparam);
            TOLONG(d.data.ptr + 10,paramidx);

            typidx = cv_debtyp(d);
            break;
        }

        case TYstruct:
        {
            typidx = cv8_fwdref(t.Ttag);
            break;
        }

        case TYenum:
            typidx = cv4_fwdenum(t);
            break;

        case TYref:
        case TYnref:
            attribute |= 0x20;          // indicate reference pointer
            tym = TYnptr;               // convert to C data type
            goto L1;                    // and try again

        case TYnullptr:
            tym = TYnptr;
            next = cv4_typidx(tstypes[TYvoid]);  // rewrite as void*
            t = tspvoid;
            goto L1;

        // vector types
        case TYfloat4:  size = 16; next = dttab4[TYfloat];  goto Larray;
        case TYdouble2: size = 16; next = dttab4[TYdouble]; goto Larray;
        case TYschar16: size = 16; next = dttab4[TYschar];  goto Larray;
        case TYuchar16: size = 16; next = dttab4[TYuchar];  goto Larray;
        case TYshort8:  size = 16; next = dttab4[TYshort];  goto Larray;
        case TYushort8: size = 16; next = dttab4[TYushort]; goto Larray;
        case TYlong4:   size = 16; next = dttab4[TYlong];   goto Larray;
        case TYulong4:  size = 16; next = dttab4[TYulong];  goto Larray;
        case TYllong2:  size = 16; next = dttab4[TYllong];  goto Larray;
        case TYullong2: size = 16; next = dttab4[TYullong]; goto Larray;

        case TYfloat8:   size = 32; next = dttab4[TYfloat];  goto Larray;
        case TYdouble4:  size = 32; next = dttab4[TYdouble]; goto Larray;
        case TYschar32:  size = 32; next = dttab4[TYschar];  goto Larray;
        case TYuchar32:  size = 32; next = dttab4[TYuchar];  goto Larray;
        case TYshort16:  size = 32; next = dttab4[TYshort];  goto Larray;
        case TYushort16: size = 32; next = dttab4[TYushort]; goto Larray;
        case TYlong8:    size = 32; next = dttab4[TYlong];   goto Larray;
        case TYulong8:   size = 32; next = dttab4[TYulong];  goto Larray;
        case TYllong4:   size = 32; next = dttab4[TYllong];  goto Larray;
        case TYullong4:  size = 32; next = dttab4[TYullong]; goto Larray;

        case TYfloat16:  size = 64; next = dttab4[TYfloat];  goto Larray;
        case TYdouble8:  size = 64; next = dttab4[TYdouble]; goto Larray;
        case TYschar64:  size = 64; next = dttab4[TYschar];  goto Larray;
        case TYuchar64:  size = 64; next = dttab4[TYuchar];  goto Larray;
        case TYshort32:  size = 64; next = dttab4[TYshort];  goto Larray;
        case TYushort32: size = 64; next = dttab4[TYushort]; goto Larray;
        case TYlong16:   size = 64; next = dttab4[TYlong];   goto Larray;
        case TYulong16:  size = 64; next = dttab4[TYulong];  goto Larray;
        case TYllong8:   size = 64; next = dttab4[TYllong];  goto Larray;
        case TYullong8:  size = 64; next = dttab4[TYullong]; goto Larray;

        default:
            debug
            printf("%s\n", tym_str(tym));

            assert(0);
    }

    // Add in const and/or volatile modifiers
    if (tycv & (mTYconst | mTYimmutable | mTYvolatile))
    {   uint modifier;

        modifier = (tycv & (mTYconst | mTYimmutable)) ? 1 : 0;
        modifier |= (tycv & mTYvolatile) ? 2 : 0;
        d = debtyp_alloc(8);
        TOWORD(d.data.ptr,LF_MODIFIER_V2);
        TOLONG(d.data.ptr + 2,typidx);
        TOWORD(d.data.ptr + 6,modifier);
        typidx = cv_debtyp(d);
    }

    assert(typidx);
    return typidx;
}

/******************************************
 * Write out symbol s.
 */

@trusted
private void cv4_outsym(Symbol* s)
{
    uint len;
    type* t;
    uint length;
    uint u;
    tym_t tym;
    const(char)* id;
    ubyte* debsym = null;
    ubyte[64] buf = void;

    //printf("cv4_outsym(%s)\n",s.Sident.ptr);
    symbol_debug(s);
    if (s.Sflags & SFLnodebug)
        return;
    t = s.Stype;
    type_debug(t);
    tym = tybasic(t.Tty);
    if (tyfunc(tym) && s.Sclass != SC.typedef_)
    {   int framedatum,targetdatum,fd;
        char idfree;
        idx_t typidx;

        if (s != funcsym_p)
            return;
        id = s.prettyIdent ? s.prettyIdent : s.Sident.ptr;
        len = cv_stringbytes(id);

        // Length of record
        length = 2 + 2 + 4 * 3 + _tysize[TYint] * 4 + 2 + cgcv.sz_idx + 1;
        debsym = (length + len <= (buf).sizeof) ? buf.ptr : cast(ubyte*) malloc(length + len);
        if (!debsym)
            err_nomem();
        memset(debsym,0,length + len);

        // Symbol type
        u = (s.Sclass == SC.static_) ? S_LPROC16 : S_GPROC16;
        if (I32)
            u += S_GPROC32 - S_GPROC16;
        TOWORD(debsym + 2,u);

        if (config.fulltypes == CV4)
        {
            // Offsets
            if (I32)
            {   TOLONG(debsym + 16,cast(uint)s.Ssize);           // proc length
                TOLONG(debsym + 20,cast(uint)cgstate.startoffset);        // debug start
                TOLONG(debsym + 24,cast(uint)cgstate.retoffset);          // debug end
                u = 28;                                 // offset to fixup
            }
            else
            {   TOWORD(debsym + 16,cast(uint)s.Ssize);           // proc length
                TOWORD(debsym + 18,cast(uint)cgstate.startoffset);        // debug start
                TOWORD(debsym + 20,cast(uint)cgstate.retoffset);          // debug end
                u = 22;                                 // offset to fixup
            }
            length += cv_namestring(debsym + u + _tysize[TYint] + 2 + cgcv.sz_idx + 1,id);
            typidx = cv4_symtypidx(s);
            TOIDX(debsym + u + _tysize[TYint] + 2,typidx);     // proc type
            debsym[u + _tysize[TYint] + 2 + cgcv.sz_idx] = tyfarfunc(tym) ? 4 : 0;
            TOWORD(debsym,length - 2);
        }
        else
        {
            // Offsets
            if (I32)
            {   TOLONG(debsym + 16 + cgcv.sz_idx,cast(uint)s.Ssize);             // proc length
                TOLONG(debsym + 20 + cgcv.sz_idx,cast(uint)cgstate.startoffset);  // debug start
                TOLONG(debsym + 24 + cgcv.sz_idx,cast(uint)cgstate.retoffset);            // debug end
                u = 28;                                         // offset to fixup
            }
            else
            {   TOWORD(debsym + 16 + cgcv.sz_idx,cast(uint)s.Ssize);             // proc length
                TOWORD(debsym + 18 + cgcv.sz_idx,cast(uint)cgstate.startoffset);  // debug start
                TOWORD(debsym + 20 + cgcv.sz_idx,cast(uint)cgstate.retoffset);            // debug end
                u = 22;                                         // offset to fixup
            }
            u += cgcv.sz_idx;
            length += cv_namestring(debsym + u + _tysize[TYint] + 2 + 1,id);
            typidx = cv4_symtypidx(s);
            TOIDX(debsym + 16,typidx);                  // proc type
            debsym[u + _tysize[TYint] + 2] = tyfarfunc(tym) ? 4 : 0;
            TOWORD(debsym,length - 2);
        }

        uint soffset = cast(uint)Offset(DEBSYM);
        objmod.write_bytes(SegData[DEBSYM],debsym[0 .. length]);

        // Put out fixup for function start offset
        objmod.reftoident(DEBSYM,soffset + u,s,0,CF.seg | CF.off);
    }
    else
    {   targ_size_t base;
        int reg;
        uint fd;
        uint idx1,idx2;
        uint value;
        uint fixoff;
        idx_t typidx;

        typidx = cv4_typidx(t);
        id = s.prettyIdent ? s.prettyIdent : prettyident(s);
        len = cast(uint)strlen(id);
        debsym = (39 + IDOHD + len <= (buf).sizeof) ? buf.ptr : cast(ubyte*) malloc(39 + IDOHD + len);
        if (!debsym)
            err_nomem();
        switch (s.Sclass)
        {
            case SC.parameter:
            case SC.regpar:
                if (s.Sfl == FL.reg)
                {
                    s.Sfl = FL.para;
                    cv4_outsym(s);
                    s.Sfl = FL.reg;
                    goto case_register;
                }
                base = cgstate.Para.size - cgstate.BPoff;    // cancel out add of BPoff
                goto L1;

            case SC.auto_:
                if (s.Sfl == FL.reg)
                    goto case_register;
            case_auto:
                base = cgstate.Auto.size;
            L1:
                if (s.Sscope) // local variables moved into the closure cannot be emitted directly
                    goto Lret;
                TOWORD(debsym + 2,I32 ? S_BPREL32 : S_BPREL16);
                if (config.fulltypes == CV4)
                {   TOOFFSET(debsym + 4,s.Soffset + base + cgstate.BPoff);
                    TOIDX(debsym + 4 + _tysize[TYint],typidx);
                }
                else
                {   TOOFFSET(debsym + 4 + cgcv.sz_idx,s.Soffset + base + cgstate.BPoff);
                    TOIDX(debsym + 4,typidx);
                }
                length = 2 + 2 + _tysize[TYint] + cgcv.sz_idx;
                length += cv_namestring(debsym + length,id);
                TOWORD(debsym,length - 2);
                break;

            case SC.bprel:
                base = -cgstate.BPoff;
                goto L1;

            case SC.fastpar:
                if (s.Sfl != FL.reg)
                {   base = cgstate.Fast.size;
                    goto L1;
                }
                goto case_register;

            case SC.register:
                if (s.Sfl != FL.reg)
                    goto case_auto;
                goto case_register;

            case SC.pseudo:
            case_register:
                TOWORD(debsym + 2,S_REGISTER);
                reg = cv_regnum(s);
                TOIDX(debsym + 4,typidx);
                TOWORD(debsym + 4 + cgcv.sz_idx,reg);
                length = 2 * 3 + cgcv.sz_idx;
                length += 1 + cv_namestring(debsym + length,id);
                TOWORD(debsym,length - 2);
                break;

            case SC.extern_:
            case SC.comdef:
                // Common blocks have a non-zero Sxtrnnum and an UNKNOWN seg
                if (!(s.Sxtrnnum && s.Sseg == UNKNOWN)) // if it's not really a common block
                {
                        goto Lret;
                }
                goto case;
            case SC.global:
            case SC.comdat:
                u = S_GDATA16;
                goto L2;

            case SC.static_:
            case SC.locstat:
                u = S_LDATA16;
            L2:
                if (I32)
                    u += S_GDATA32 - S_GDATA16;
                TOWORD(debsym + 2,u);
                if (config.fulltypes == CV4)
                {
                    fixoff = 4;
                    length = 2 + 2 + _tysize[TYint] + 2;
                    TOOFFSET(debsym + fixoff,s.Soffset);
                    TOWORD(debsym + fixoff + _tysize[TYint],0);
                    TOIDX(debsym + length,typidx);
                }
                else
                {
                    fixoff = 8;
                    length = 2 + 2 + _tysize[TYint] + 2;
                    TOOFFSET(debsym + fixoff,s.Soffset);
                    TOWORD(debsym + fixoff + _tysize[TYint],0);        // segment
                    TOIDX(debsym + 4,typidx);
                }
                length += cgcv.sz_idx;
                length += cv_namestring(debsym + length,id);
                TOWORD(debsym,length - 2);
                assert(length <= 40 + len);

                if (s.Sseg == UNKNOWN || s.Sclass == SC.comdat) // if common block
                {
                    if (config.exe & EX_flat)
                    {
                        fd = 0x16;
                        idx1 = DGROUPIDX;
                        idx2 = s.Sxtrnnum;
                    }
                    else
                    {
                        fd = 0x26;
                        idx1 = idx2 = s.Sxtrnnum;
                    }
                }
                else if (s.ty() & (mTYfar | mTYcs))
                {
                    fd = 0x04;
                    idx1 = idx2 = SegData[s.Sseg].segidx;
                }
                else
                {   fd = 0x14;
                    idx1 = DGROUPIDX;
                    idx2 = SegData[s.Sseg].segidx;
                }
                /* Because of the linker limitations, the length cannot
                 * exceed 0x1000.
                 * See optlink\cv\cvhashes.asm
                 */
                assert(length <= 0x1000);
                if (idx2 != 0)
                {
                    assert(0);
                }
                goto Lret;

static if (1)
{
            case SC.typedef_:
                s.Stypidx = typidx;
                reset_symbuf.write((&s)[0 .. 1]);
                goto L4;

            case SC.struct_:
                if (s.Sstruct.Sflags & STRnotagname)
                    goto Lret;
                goto L4;

            case SC.enum_:
            L4:
                // Output a 'user-defined type' for the tag name
                TOWORD(debsym + 2,S_UDT);
                TOIDX(debsym + 4,typidx);
                length = 2 + 2 + cgcv.sz_idx;
                length += cv_namestring(debsym + length,id);
                TOWORD(debsym,length - 2);
                break;

            case SC.const_:
                // The only constants are enum members
                value = cast(uint)el_tolong(s.Svalue);
                TOWORD(debsym + 2,S_CONST);
                TOIDX(debsym + 4,typidx);
                length = 4 + cgcv.sz_idx;
                cv4_storenumeric(debsym + length,value);
                length += cv4_numericbytes(value);
                length += cv_namestring(debsym + length,id);
                TOWORD(debsym,length - 2);
                break;
}
            default:
                goto Lret;
        }
        assert(length <= 40 + len);
        objmod.write_bytes(SegData[DEBSYM],debsym[0 .. length]);
    }
Lret:
    if (debsym != buf.ptr)
        free(debsym);
}


/******************************************
 * Write out symbol table for current function.
 */

@trusted
private void cv4_func(Funcsym* s, ref symtab_t symtab)
{
    int endarg;

    cv4_outsym(s);              // put out function symbol
    __gshared Funcsym* sfunc;
    __gshared int cntOpenBlocks;
    sfunc = s;
    cntOpenBlocks = 0;

    struct cv4
    {
    nothrow:
        // record for CV record S_BLOCK32
        struct block32_data
        {
            ushort len;
            ushort id;
            uint pParent;
            uint pEnd;
            uint length;
            uint offset;
            ushort seg;
            ubyte[2] name;
        }


        static void endArgs()
        {
            __gshared ushort[2] endargs = [ 2, S_ENDARG ];
            objmod.write_bytes(SegData[DEBSYM],endargs[]);
        }
        static void beginBlock(Symbol* sa, int offset, int length)
        {
            if (++cntOpenBlocks >= 255)
                return; // optlink does not like more than 255 scope blocks

            uint soffset = cast(uint)Offset(DEBSYM);
            // parent and end to be filled by linker
            block32_data block32 = { (block32_data).sizeof - 2, S_BLOCK32, 0, 0, length, 0, 0, [ 0, '\0' ] };
            objmod.write_bytes(SegData[DEBSYM], (&block32)[0 .. 1]);
            size_t offOffset = cast(char*)&block32.offset - cast(char*)&block32;
            objmod.reftoident(DEBSYM, soffset + offOffset, sfunc, offset + sfunc.Soffset, CF.seg | CF.off);
        }
        static void endBlock()
        {
            if (cntOpenBlocks-- >= 255)
                return; // optlink does not like more than 255 scope blocks

            __gshared ushort[2] endargs = [ 2, S_END ];
            objmod.write_bytes(SegData[DEBSYM],endargs[]);
        }
    }

    varStats_writeSymbolTable(sfunc, symtab, &cv4_outsym, &cv4.endArgs, &cv4.beginBlock, &cv4.endBlock);

    // Put out function return record
    if (1)
    {
        ubyte[2+2+2+1+1+4] sreturn;
        ushort flags;
        ubyte style;
        tym_t ty;
        tym_t tyret;
        uint u;

        u = 2+2+1;
        ty = tybasic(s.ty());

        flags = tyrevfunc(ty) ? 0 : 1;
        flags |= typfunc(ty) ? 0 : 2;
        TOWORD(sreturn.ptr + 4,flags);

        tyret = tybasic(s.Stype.Tnext.Tty);
        switch (tyret)
        {
            case TYvoid:
            default:
                style = 0;
                break;

            case TYbool:
            case TYchar:
            case TYschar:
            case TYuchar:
                sreturn[7] = 1;
                sreturn[8] = 1;         // AL
                goto L1;

            case TYwchar_t:
            case TYchar16:
            case TYshort:
            case TYushort:
                goto case_ax;

            case TYint:
            case TYuint:
            case TYsptr:
            case TYcptr:
            case TYnullptr:
            case TYnptr:
            case TYnref:
                if (I32)
                    goto case_eax;
                else
                    goto case_ax;

            case TYfloat:
            case TYifloat:
                if (config.exe & EX_flat)
                    goto case_st0;
                goto case;

            case TYlong:
            case TYulong:
            case TYdchar:
                if (I32)
                    goto case_eax;
                else
                    goto case_dxax;

            case TYfptr:
            case TYhptr:
                if (I32)
                    goto case_edxeax;
                else
                    goto case_dxax;

            case TYvptr:
                if (I32)
                    goto case_edxebx;
                else
                    goto case_dxbx;

            case TYdouble:
            case TYidouble:
            case TYdouble_alias:
                if (config.exe & EX_flat)
                    goto case_st0;
                if (I32)
                    goto case_edxeax;
                else
                    goto case_axbxcxdx;

            case TYllong:
            case TYullong:
                assert(I32);
                goto case_edxeax;

            case TYreal:
            case TYireal:
                goto case_st0;

            case TYcfloat:
            case TYcdouble:
            case TYcreal:
                goto case_st01;

            case_ax:
                sreturn[7] = 1;
                sreturn[8] = 9;         // AX
                goto L1;

            case_eax:
                sreturn[7] = 1;
                sreturn[8] = 17;        // EAX
                goto L1;


            case_dxax:
                sreturn[7] = 2;
                sreturn[8] = 11;        // DX
                sreturn[9] = 9;         // AX
                goto L1;

            case_dxbx:
                sreturn[7] = 2;
                sreturn[8] = 11;        // DX
                sreturn[9] = 12;        // BX
                goto L1;

            case_axbxcxdx:
                sreturn[7] = 4;
                sreturn[8] = 9;         // AX
                sreturn[9] = 12;        // BX
                sreturn[10] = 10;       // CX
                sreturn[11] = 11;       // DX
                goto L1;

            case_edxeax:
                sreturn[7] = 2;
                sreturn[8] = 19;        // EDX
                sreturn[9] = 17;        // EAX
                goto L1;

            case_edxebx:
                sreturn[7] = 2;
                sreturn[8] = 19;        // EDX
                sreturn[9] = 20;        // EBX
                goto L1;

            case_st0:
                sreturn[7] = 1;
                sreturn[8] = 128;       // ST0
                goto L1;

            case_st01:
                sreturn[7] = 2;
                sreturn[8] = 128;       // ST0 (imaginary)
                sreturn[9] = 129;       // ST1 (real)
                goto L1;

            L1:
                style = 1;
                u += sreturn[7] + 1;
                break;
        }
        sreturn[6] = style;

        TOWORD(sreturn.ptr,u);
        TOWORD(sreturn.ptr + 2,S_RETURN);
        objmod.write_bytes(SegData[DEBSYM],sreturn[0 .. u + 2]);
    }

    // Put out end scope
    {   __gshared ushort[2] endproc = [ 2,S_END ];

        objmod.write_bytes(SegData[DEBSYM],endproc[]);
    }
}
//////////////////////////////////////////////////////////

/******************************************
 * Write out data to .OBJ file.
 */

@trusted
void cv_term()
{
    //printf("cv_term(): debtyp.length = %d\n",debtyp.length);

    segidx_t typeseg = objmod.seg_debugT();

    objmod.write_bytes(SegData[typeseg],(&cgcv.signature)[0 .. 1]);
    for (uint u = 0; u < debtyp.length; u++)
    {   debtyp_t* d = debtyp[u];

        objmod.write_bytes(SegData[typeseg],(cast(void*)d)[uint.sizeof .. uint.sizeof + 2 + d.length]);
        debtyp_free(d);
    }

    // debtyp.dtor();  // save for later
    vec_free(debtypvec);
    debtypvec = null;
}

/******************************************
 * Write out symbol table for current function.
 */

@trusted
void cv_outsym(Symbol* s)
{
    //printf("cv_outsym('%s')\n",s.Sident.ptr);
    symbol_debug(s);
    if (s.Sflags & SFLnodebug)
        return;

    cv8_outsym(s);
}

/******************************************
 * Return cv type index for a type.
 */

@trusted
uint cv_typidx(type* t)
{   uint ti;

    //printf("cv_typidx(%p)\n",t);
    ti = cv4_typidx(t);
    return ti;
}

/// Map to Codeview 1 type in debugger record
private
__gshared ubyte[TYMAX] dttab =
[
    TYbool    : 0x80,
    TYchar    : 0x80,
    TYschar   : 0x80,
    TYuchar   : 0x84,
    TYchar8   : 0x84,
    TYchar16  : 0x85,
    TYshort   : 0x81,
    TYwchar_t : 0x85,
    TYushort  : 0x85,

    TYenum    : 0x81,
    TYint     : 0x85,
    TYuint    : 0x85,

    TYlong    : 0x82,
    TYulong   : 0x86,
    TYdchar   : 0x86,
    TYllong   : 0x82,
    TYullong  : 0x86,
    TYcent    : 0x82,
    TYucent   : 0x86,
    TYfloat   : 0x88,
    TYdouble  : 0x89,
    TYdouble_alias : 0x89,
    TYreal : 0x89,

    TYifloat   : 0x88,
    TYidouble  : 0x89,
    TYireal : 0x89,

    TYcfloat   : 0x88,
    TYcdouble  : 0x89,
    TYcreal : 0x89,

    TYfloat4  : 0x00,
    TYdouble2 : 0x00,
    TYschar16 : 0x00,
    TYuchar16 : 0x00,
    TYshort8  : 0x00,
    TYushort8 : 0x00,
    TYlong4   : 0x00,
    TYulong4  : 0x00,
    TYllong2  : 0x00,
    TYullong2 : 0x00,

    TYfloat8  : 0x00,
    TYdouble4 : 0x00,
    TYschar32 : 0x00,
    TYuchar32 : 0x00,
    TYshort16 : 0x00,
    TYushort16 : 0x00,
    TYlong8   : 0x00,
    TYulong8  : 0x00,
    TYllong4  : 0x00,
    TYullong4 : 0x00,

    TYfloat16 : 0x00,
    TYdouble8 : 0x00,
    TYschar64 : 0x00,
    TYuchar64 : 0x00,
    TYshort32 : 0x00,
    TYushort32 : 0x00,
    TYlong16  : 0x00,
    TYulong16 : 0x00,
    TYllong8  : 0x00,
    TYullong8 : 0x00,

    TYnullptr : 0x20,
    TYnptr    : 0x20,
    TYref     : 0x00,
    TYvoid    : 0x85,
    TYnoreturn : 0x85, // same as TYvoid
    TYstruct  : 0x00,
    TYarray   : 0x78,
    TYnfunc   : 0x63,
    TYnpfunc  : 0x74,
    TYnsfunc  : 0x63,
    TYptr     : 0x20,
    TYmfunc   : 0x64,
    TYjfunc   : 0x74,
    TYhfunc   : 0x00,
    TYnref    : 0x00,

    TYsptr     : 0x20,
    TYcptr     : 0x20,
    TYf16ptr   : 0x40,
    TYfptr     : 0x40,
    TYhptr     : 0x40,
    TYvptr     : 0x40,
    TYimmutPtr : 0x20,
    TYsharePtr : 0x20,
    TYrestrictPtr : 0x20,
    TYfgPtr    : 0x20,
    TYffunc    : 0x64,
    TYfpfunc   : 0x73,
    TYfsfunc   : 0x64,
    TYf16func  : 0x63,
    TYnsysfunc : 0x63,
    TYfsysfunc : 0x64,
    TYfref     : 0x00,

    TYifunc    : 0x64,
];

/// Map to Codeview 4 type in debugger record
__gshared ushort[TYMAX] dttab4 =
[
    TYbool    : 0x30,
    TYchar    : 0x70,
    TYschar   : 0x10,
    TYuchar   : 0x20,
    TYchar8   : 0x20,
    TYchar16  : 0x21,
    TYshort   : 0x11,
    TYwchar_t : 0x71,
    TYushort  : 0x21,

    TYenum    : 0x72,
    TYint     : 0x72,
    TYuint    : 0x73,

    TYlong    : 0x12,
    TYulong   : 0x22,
    TYdchar   : 0x7b, // UTF32
    TYllong   : 0x13,
    TYullong  : 0x23,
    TYcent    : 0x603,
    TYucent   : 0x603,
    TYfloat   : 0x40,
    TYdouble  : 0x41,
    TYdouble_alias : 0x41,
    TYreal : 0x42,

    TYifloat   : 0x40,
    TYidouble  : 0x41,
    TYireal : 0x42,

    TYcfloat   : 0x50,
    TYcdouble  : 0x51,
    TYcreal : 0x52,

    TYfloat4  : 0x00,
    TYdouble2 : 0x00,
    TYschar16 : 0x00,
    TYuchar16 : 0x00,
    TYshort8  : 0x00,
    TYushort8 : 0x00,
    TYlong4   : 0x00,
    TYulong4  : 0x00,
    TYllong2  : 0x00,
    TYullong2 : 0x00,

    TYfloat8  : 0x00,
    TYdouble4 : 0x00,
    TYschar32 : 0x00,
    TYuchar32 : 0x00,
    TYshort16 : 0x00,
    TYushort16 : 0x00,
    TYlong8   : 0x00,
    TYulong8  : 0x00,
    TYllong4  : 0x00,
    TYullong4 : 0x00,

    TYfloat16 : 0x00,
    TYdouble8 : 0x00,
    TYschar64 : 0x00,
    TYuchar64 : 0x00,
    TYshort32 : 0x00,
    TYushort32 : 0x00,
    TYlong16  : 0x00,
    TYulong16 : 0x00,
    TYllong8  : 0x00,
    TYullong8 : 0x00,

    TYnullptr : 0x100,
    TYnptr    : 0x100,
    TYref     : 0x00,
    TYvoid    : 0x03,
    TYnoreturn : 0x03, // same as TYvoid
    TYstruct  : 0x00,
    TYarray   : 0x00,
    TYnfunc   : 0x00,
    TYnpfunc  : 0x00,
    TYnsfunc  : 0x00,
    TYptr     : 0x100,
    TYmfunc   : 0x00,
    TYjfunc   : 0x00,
    TYhfunc   : 0x00,
    TYnref    : 0x00,

    TYsptr     : 0x100,
    TYcptr     : 0x100,
    TYf16ptr   : 0x200,
    TYfptr     : 0x200,
    TYhptr     : 0x300,
    TYvptr     : 0x200,
    TYimmutPtr : 0x100,
    TYsharePtr : 0x100,
    TYrestrictPtr : 0x100,
    TYfgPtr    : 0x100,
    TYffunc    : 0x00,
    TYfpfunc   : 0x00,
    TYfsfunc   : 0x00,
    TYf16func  : 0x00,
    TYnsysfunc : 0x00,
    TYfsysfunc : 0x00,
    TYfref     : 0x00,

    TYifunc    : 0x00,
];
