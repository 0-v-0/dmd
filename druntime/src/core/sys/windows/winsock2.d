/*
    Written by Christopher E. Miller
    $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
*/


module core.sys.windows.winsock2;
version (Windows):

pragma(lib, "ws2_32");

import core.sys.windows.basetsd, core.sys.windows.basetyps;
import core.sys.windows.windef, core.sys.windows.winbase, core.sys.windows.winnt;

extern(Windows):
nothrow:

alias SOCKET = size_t;
alias socklen_t = int;

enum SOCKET INVALID_SOCKET = cast(SOCKET)~0;
enum int SOCKET_ERROR = -1;

enum WSADESCRIPTION_LEN = 256;
enum WSASYS_STATUS_LEN = 128;

struct WSADATA
{
    ushort wVersion;
    ushort wHighVersion;
    char[WSADESCRIPTION_LEN + 1] szDescription = 0;
    char[WSASYS_STATUS_LEN + 1] szSystemStatus = 0;
    ushort iMaxSockets;
    ushort iMaxUdpDg;
    char* lpVendorInfo;
}
alias LPWSADATA = WSADATA*;


enum int IOCPARM_MASK =  0x7F;
enum int IOC_VOID =      0x20000000;
enum int IOC_OUT =       0x40000000;
enum int IOC_IN =        cast(int)0x80000000;
enum int IOC_INOUT =     IOC_IN | IOC_OUT;
enum int FIONREAD =      cast(int)(IOC_OUT | ((uint.sizeof & IOCPARM_MASK) << 16) | (102 << 8) | 127);
enum int FIONBIO =       cast(int)(IOC_IN | ((uint.sizeof & IOCPARM_MASK) << 16) | (102 << 8) | 126);
enum int FIOASYNC =      cast(int)(IOC_IN | ((uint.sizeof & IOCPARM_MASK) << 16) | (102 << 8) | 125);
enum int SIOCSHIWAT =    cast(int)(IOC_IN | ((uint.sizeof & IOCPARM_MASK) << 16) | (115 << 8) | 0);
enum int SIOCGHIWAT =    cast(int)(IOC_OUT | ((uint.sizeof & IOCPARM_MASK) << 16) | (115 << 8) | 1);
enum int SIOCSLOWAT =    cast(int)(IOC_IN | ((uint.sizeof & IOCPARM_MASK) << 16) | (115 << 8) | 2);
enum int SIOCGLOWAT =    cast(int)(IOC_OUT | ((uint.sizeof & IOCPARM_MASK) << 16) | (115 << 8) | 3);
enum int SIOCATMARK =    cast(int)(IOC_OUT | ((uint.sizeof & IOCPARM_MASK) << 16) | (115 << 8) | 7);

enum NI_MAXHOST = 1025;
enum NI_MAXSERV = 32;

enum: int
{
    FD_READ_BIT = 0,
    FD_WRITE_BIT = 1,
    FD_OOB_BIT = 2,
    FD_ACCEPT_BIT = 3,
    FD_CONNECT_BIT = 4,
    FD_CLOSE_BIT = 5,
    FD_QOS_BIT = 6,
    FD_GROUP_QOS_BIT = 7,
    FD_ROUTING_INTERFACE_CHANGE_BIT = 8,
    FD_ADDRESS_LIST_CHANGE_BIT = 9,
    FD_MAX_EVENTS = 10,

    FD_READ = 1 << FD_READ_BIT,
    FD_WRITE = 1 << FD_WRITE_BIT,
    FD_OOB = 1 << FD_OOB_BIT,
    FD_ACCEPT = 1 << FD_ACCEPT_BIT,
    FD_CONNECT = 1 << FD_CONNECT_BIT,
    FD_CLOSE = 1 << FD_CLOSE_BIT,
    FD_QOS = 1 << FD_QOS_BIT,
    FD_GROUP_QOS = 1 << FD_GROUP_QOS_BIT,
    FD_ROUTING_INTERFACE_CHANGE = 1 << FD_ROUTING_INTERFACE_CHANGE_BIT,
    FD_ADDRESS_LIST_CHANGE = 1 << FD_ADDRESS_LIST_CHANGE_BIT,
    FD_ALL_EVENTS = (1 << FD_MAX_EVENTS) - 1,
}

alias WSAEVENT = HANDLE;
alias LPWSAEVENT = LPHANDLE;
alias WSAOVERLAPPED = OVERLAPPED;
alias LPWSAOVERLAPPED = OVERLAPPED*;
alias LPWSAOVERLAPPED_COMPLETION_ROUTINE = void function(DWORD, DWORD, LPWSAOVERLAPPED, DWORD) nothrow @nogc;

enum WSA_IO_PENDING = ERROR_IO_PENDING;
enum WSA_IO_INCOMPLETE = ERROR_IO_INCOMPLETE;
enum WSA_INVALID_HANDLE = ERROR_INVALID_HANDLE;
enum WSA_INVALID_PARAMETER = ERROR_INVALID_PARAMETER;
enum WSA_NOT_ENOUGH_MEMORY = ERROR_NOT_ENOUGH_MEMORY;
enum WSA_OPERATION_ABORTED = ERROR_OPERATION_ABORTED;

enum WSAEVENT WSA_INVALID_EVENT = null;
enum WSA_MAXIMUM_WAIT_EVENTS = MAXIMUM_WAIT_OBJECTS;
enum WSA_WAIT_FAILED = WAIT_FAILED;
enum WSA_WAIT_EVENT_0 = WAIT_OBJECT_0;
enum WSA_WAIT_IO_COMPLETION = WAIT_IO_COMPLETION;
enum WSA_WAIT_TIMEOUT = WAIT_TIMEOUT;
enum WSA_INFINITE = INFINITE;

@nogc
{
int WSAStartup(ushort wVersionRequested, LPWSADATA lpWSAData);
@trusted int WSACleanup();
@trusted SOCKET socket(int af, int type, int protocol);
int ioctlsocket(SOCKET s, int cmd, uint* argp);
int bind(SOCKET s, const(sockaddr)* name, socklen_t namelen);
int connect(SOCKET s, const(sockaddr)* name, socklen_t namelen);
@trusted int listen(SOCKET s, int backlog);
SOCKET accept(SOCKET s, sockaddr* addr, socklen_t* addrlen);
@trusted int closesocket(SOCKET s);
@trusted int shutdown(SOCKET s, int how);
int getpeername(SOCKET s, sockaddr* name, socklen_t* namelen);
int getsockname(SOCKET s, sockaddr* name, socklen_t* namelen);
int send(SOCKET s, const(void)* buf, int len, int flags);
int sendto(SOCKET s, const(void)* buf, int len, int flags, const(sockaddr)* to, socklen_t tolen);
int recv(SOCKET s, void* buf, int len, int flags);
int recvfrom(SOCKET s, void* buf, int len, int flags, sockaddr* from, socklen_t* fromlen);
int getsockopt(SOCKET s, int level, int optname, void* optval, socklen_t* optlen);
int setsockopt(SOCKET s, int level, int optname, const(void)* optval, socklen_t optlen);
uint inet_addr(const char* cp);
int select(int nfds, fd_set* readfds, fd_set* writefds, fd_set* errorfds, const(timeval)* timeout);
char* inet_ntoa(in_addr ina);
hostent* gethostbyname(const char* name);
hostent* gethostbyaddr(const(void)* addr, int len, int type);
protoent* getprotobyname(const char* name);
protoent* getprotobynumber(int number);
servent* getservbyname(const char* name, const char* proto);
servent* getservbyport(int port, const char* proto);
}

enum: int
{
    NI_NOFQDN =          0x01,
    NI_NUMERICHOST =     0x02,
    NI_NAMEREQD =        0x04,
    NI_NUMERICSERV =     0x08,
    NI_DGRAM  =          0x10,
}

@nogc
{
int gethostname(const char* name, int namelen);
int getaddrinfo(const(char)* nodename, const(char)* servname, const(addrinfo)* hints, addrinfo** res);
void freeaddrinfo(addrinfo* ai);
int getnameinfo(const(sockaddr)* sa, socklen_t salen, char* host, uint hostlen, char* serv, uint servlen, int flags);
}

enum WSABASEERR = 10000;

enum: int
{
    /*
     * Windows Sockets definitions of regular Microsoft C error constants
     */
    WSAEINTR = (WSABASEERR+4),
    WSAEBADF = (WSABASEERR+9),
    WSAEACCES = (WSABASEERR+13),
    WSAEFAULT = (WSABASEERR+14),
    WSAEINVAL = (WSABASEERR+22),
    WSAEMFILE = (WSABASEERR+24),

    /*
     * Windows Sockets definitions of regular Berkeley error constants
     */
    WSAEWOULDBLOCK = (WSABASEERR+35),
    WSAEINPROGRESS = (WSABASEERR+36),
    WSAEALREADY = (WSABASEERR+37),
    WSAENOTSOCK = (WSABASEERR+38),
    WSAEDESTADDRREQ = (WSABASEERR+39),
    WSAEMSGSIZE = (WSABASEERR+40),
    WSAEPROTOTYPE = (WSABASEERR+41),
    WSAENOPROTOOPT = (WSABASEERR+42),
    WSAEPROTONOSUPPORT = (WSABASEERR+43),
    WSAESOCKTNOSUPPORT = (WSABASEERR+44),
    WSAEOPNOTSUPP = (WSABASEERR+45),
    WSAEPFNOSUPPORT = (WSABASEERR+46),
    WSAEAFNOSUPPORT = (WSABASEERR+47),
    WSAEADDRINUSE = (WSABASEERR+48),
    WSAEADDRNOTAVAIL = (WSABASEERR+49),
    WSAENETDOWN = (WSABASEERR+50),
    WSAENETUNREACH = (WSABASEERR+51),
    WSAENETRESET = (WSABASEERR+52),
    WSAECONNABORTED = (WSABASEERR+53),
    WSAECONNRESET = (WSABASEERR+54),
    WSAENOBUFS = (WSABASEERR+55),
    WSAEISCONN = (WSABASEERR+56),
    WSAENOTCONN = (WSABASEERR+57),
    WSAESHUTDOWN = (WSABASEERR+58),
    WSAETOOMANYREFS = (WSABASEERR+59),
    WSAETIMEDOUT = (WSABASEERR+60),
    WSAECONNREFUSED = (WSABASEERR+61),
    WSAELOOP = (WSABASEERR+62),
    WSAENAMETOOLONG = (WSABASEERR+63),
    WSAEHOSTDOWN = (WSABASEERR+64),
    WSAEHOSTUNREACH = (WSABASEERR+65),
    WSAENOTEMPTY = (WSABASEERR+66),
    WSAEPROCLIM = (WSABASEERR+67),
    WSAEUSERS = (WSABASEERR+68),
    WSAEDQUOT = (WSABASEERR+69),
    WSAESTALE = (WSABASEERR+70),
    WSAEREMOTE = (WSABASEERR+71),

    /*
     * Extended Windows Sockets error constant definitions
     */
    WSASYSNOTREADY = (WSABASEERR+91),
    WSAVERNOTSUPPORTED = (WSABASEERR+92),
    WSANOTINITIALISED = (WSABASEERR+93),

    /* Authoritative Answer: Host not found */
    WSAHOST_NOT_FOUND = (WSABASEERR+1001),
    HOST_NOT_FOUND = WSAHOST_NOT_FOUND,

    /* Non-Authoritative: Host not found, or SERVERFAIL */
    WSATRY_AGAIN = (WSABASEERR+1002),
    TRY_AGAIN = WSATRY_AGAIN,

    /* Non recoverable errors, FORMERR, REFUSED, NOTIMP */
    WSANO_RECOVERY = (WSABASEERR+1003),
    NO_RECOVERY = WSANO_RECOVERY,

    /* Valid name, no data record of requested type */
    WSANO_DATA = (WSABASEERR+1004),
    NO_DATA = WSANO_DATA,

    /* no address, look for MX record */
    WSANO_ADDRESS = WSANO_DATA,
    NO_ADDRESS = WSANO_ADDRESS
}

/*
 * Windows Sockets errors redefined as regular Berkeley error constants
 */
enum: int
{
    EWOULDBLOCK = WSAEWOULDBLOCK,
    EINPROGRESS = WSAEINPROGRESS,
    EALREADY = WSAEALREADY,
    ENOTSOCK = WSAENOTSOCK,
    EDESTADDRREQ = WSAEDESTADDRREQ,
    EMSGSIZE = WSAEMSGSIZE,
    EPROTOTYPE = WSAEPROTOTYPE,
    ENOPROTOOPT = WSAENOPROTOOPT,
    EPROTONOSUPPORT = WSAEPROTONOSUPPORT,
    ESOCKTNOSUPPORT = WSAESOCKTNOSUPPORT,
    EOPNOTSUPP = WSAEOPNOTSUPP,
    EPFNOSUPPORT = WSAEPFNOSUPPORT,
    EAFNOSUPPORT = WSAEAFNOSUPPORT,
    EADDRINUSE = WSAEADDRINUSE,
    EADDRNOTAVAIL = WSAEADDRNOTAVAIL,
    ENETDOWN = WSAENETDOWN,
    ENETUNREACH = WSAENETUNREACH,
    ENETRESET = WSAENETRESET,
    ECONNABORTED = WSAECONNABORTED,
    ECONNRESET = WSAECONNRESET,
    ENOBUFS = WSAENOBUFS,
    EISCONN = WSAEISCONN,
    ENOTCONN = WSAENOTCONN,
    ESHUTDOWN = WSAESHUTDOWN,
    ETOOMANYREFS = WSAETOOMANYREFS,
    ETIMEDOUT = WSAETIMEDOUT,
    ECONNREFUSED = WSAECONNREFUSED,
    ELOOP = WSAELOOP,
    ENAMETOOLONG = WSAENAMETOOLONG,
    EHOSTDOWN = WSAEHOSTDOWN,
    EHOSTUNREACH = WSAEHOSTUNREACH,
    ENOTEMPTY = WSAENOTEMPTY,
    EPROCLIM = WSAEPROCLIM,
    EUSERS = WSAEUSERS,
    EDQUOT = WSAEDQUOT,
    ESTALE = WSAESTALE,
    EREMOTE = WSAEREMOTE
}

enum: int
{
    EAI_NONAME    = WSAHOST_NOT_FOUND,
}

int WSAGetLastError() @trusted @nogc;


enum: int
{
    AF_UNSPEC =     0,

    AF_UNIX =       1,
    AF_INET =       2,
    AF_IMPLINK =    3,
    AF_PUP =        4,
    AF_CHAOS =      5,
    AF_NS =         6,
    AF_IPX =        AF_NS,
    AF_ISO =        7,
    AF_OSI =        AF_ISO,
    AF_ECMA =       8,
    AF_DATAKIT =    9,
    AF_CCITT =      10,
    AF_SNA =        11,
    AF_DECnet =     12,
    AF_DLI =        13,
    AF_LAT =        14,
    AF_HYLINK =     15,
    AF_APPLETALK =  16,
    AF_NETBIOS =    17,
    AF_VOICEVIEW =  18,
    AF_FIREFOX =    19,
    AF_UNKNOWN1 =   20,
    AF_BAN =        21,
    AF_ATM =        22,
    AF_INET6 =      23,
    AF_CLUSTER =    24,
    AF_12844 =      25,
    AF_IRDA =       26,
    AF_NETDES =     28,
    AF_TCNPROCESS = 29,
    AF_TCNMESSAGE = 30,
    AF_ICLFXBM =    31,
    AF_BTH =        32,

    AF_MAX =        33,


    PF_UNSPEC     = AF_UNSPEC,

    PF_UNIX =       AF_UNIX,
    PF_INET =       AF_INET,
    PF_IMPLINK =    AF_IMPLINK,
    PF_PUP =        AF_PUP,
    PF_CHAOS =      AF_CHAOS,
    PF_NS =         AF_NS,
    PF_IPX =        AF_IPX,
    PF_ISO =        AF_ISO,
    PF_OSI =        AF_OSI,
    PF_ECMA =       AF_ECMA,
    PF_DATAKIT =    AF_DATAKIT,
    PF_CCITT =      AF_CCITT,
    PF_SNA =        AF_SNA,
    PF_DECnet =     AF_DECnet,
    PF_DLI =        AF_DLI,
    PF_LAT =        AF_LAT,
    PF_HYLINK =     AF_HYLINK,
    PF_APPLETALK =  AF_APPLETALK,
    PF_VOICEVIEW =  AF_VOICEVIEW,
    PF_FIREFOX =    AF_FIREFOX,
    PF_UNKNOWN1 =   AF_UNKNOWN1,
    PF_BAN =        AF_BAN,
    PF_ATM =        AF_ATM,
    PF_INET6 =      AF_INET6,
    PF_BTH =        AF_BTH,

    PF_MAX        = AF_MAX,
}


enum: int
{
    SOL_SOCKET = 0xFFFF,
    SOMAXCONN = 0x7FFFFFFF,
}


enum: int
{
    SO_DEBUG =        0x0001,
    SO_ACCEPTCONN =   0x0002,
    SO_REUSEADDR =    0x0004,
    SO_KEEPALIVE =    0x0008,
    SO_DONTROUTE =    0x0010,
    SO_BROADCAST =    0x0020,
    SO_USELOOPBACK =  0x0040,
    SO_LINGER =       0x0080,
    SO_DONTLINGER =   ~SO_LINGER,
    SO_OOBINLINE =    0x0100,
    SO_SNDBUF =       0x1001,
    SO_RCVBUF =       0x1002,
    SO_SNDLOWAT =     0x1003,
    SO_RCVLOWAT =     0x1004,
    SO_SNDTIMEO =     0x1005,
    SO_RCVTIMEO =     0x1006,
    SO_ERROR =        0x1007,
    SO_TYPE =         0x1008,
    SO_GROUP_ID =     0x2001,
    SO_GROUP_PRIORITY = 0x2002,
    SO_MAX_MSG_SIZE = 0x2003,
    SO_PROTOCOL_INFOA = 0x2004,
    SO_PROTOCOL_INFOW = 0x2005,
    PVD_CONFIG =      0x3001,
    SO_CONDITIONAL_ACCEPT = 0x3002,
    SO_EXCLUSIVEADDRUSE = ~SO_REUSEADDR,

    TCP_NODELAY =    1,

    IP_OPTIONS                  = 1,

    IP_HDRINCL                  = 2,
    IP_TOS                      = 3,
    IP_TTL                      = 4,
    IP_MULTICAST_IF             = 9,
    IP_MULTICAST_TTL            = 10,
    IP_MULTICAST_LOOP           = 11,
    IP_ADD_MEMBERSHIP           = 12,
    IP_DROP_MEMBERSHIP          = 13,
    IP_DONTFRAGMENT             = 14,
    IP_ADD_SOURCE_MEMBERSHIP    = 15,
    IP_DROP_SOURCE_MEMBERSHIP   = 16,
    IP_BLOCK_SOURCE             = 17,
    IP_UNBLOCK_SOURCE           = 18,
    IP_PKTINFO                  = 19,

    IPV6_UNICAST_HOPS =    4,
    IPV6_MULTICAST_IF =    9,
    IPV6_MULTICAST_HOPS =  10,
    IPV6_MULTICAST_LOOP =  11,
    IPV6_ADD_MEMBERSHIP =  12,
    IPV6_DROP_MEMBERSHIP = 13,
    IPV6_JOIN_GROUP =      IPV6_ADD_MEMBERSHIP,
    IPV6_LEAVE_GROUP =     IPV6_DROP_MEMBERSHIP,
    IPV6_V6ONLY = 27,
}


/// Default FD_SETSIZE value.
/// In C/C++, it is redefinable by #define-ing the macro before #include-ing
/// winsock.h. In D, use the $(D FD_CREATE) function to allocate a $(D fd_set)
/// of an arbitrary size.
enum int FD_SETSIZE = 64;


struct fd_set_custom(uint SETSIZE)
{
    uint fd_count;
    SOCKET[SETSIZE] fd_array;
}

alias fd_set = fd_set_custom!FD_SETSIZE;

// Removes.
void FD_CLR(SOCKET fd, fd_set* set) pure @nogc
{
    uint c = set.fd_count;
    SOCKET* start = set.fd_array.ptr;
    SOCKET* stop = start + c;

    for (; start != stop; start++)
    {
        if (*start == fd)
            goto found;
    }
    return; //not found

    found:
    for (++start; start != stop; start++)
    {
        *(start - 1) = *start;
    }

    set.fd_count = c - 1;
}


// Tests.
int FD_ISSET(SOCKET fd, const(fd_set)* set) pure @nogc
{
const(SOCKET)* start = set.fd_array.ptr;
const(SOCKET)* stop = start + set.fd_count;

    for (; start != stop; start++)
    {
        if (*start == fd)
            return true;
    }
    return false;
}


// Adds.
void FD_SET(SOCKET fd, fd_set* set) pure @nogc
{
    uint c = set.fd_count;
    set.fd_array.ptr[c] = fd;
    set.fd_count = c + 1;
}


// Resets to zero.
void FD_ZERO(fd_set* set) pure @nogc
{
    set.fd_count = 0;
}


/// Creates a new $(D fd_set) with the specified capacity.
fd_set* FD_CREATE(uint capacity) pure
{
    // Take into account alignment (SOCKET may be 64-bit and require 64-bit alignment on 64-bit systems)
    size_t size = (fd_set_custom!1).sizeof - SOCKET.sizeof + (SOCKET.sizeof * capacity);
    auto data = new ubyte[size];
    auto set = cast(fd_set*)data.ptr;
    FD_ZERO(set);
    return set;
}

struct linger
{
    ushort l_onoff;
    ushort l_linger;
}

struct WSABUF
{
    ULONG len;
    CHAR* buf;
}
alias LPWSABUF = WSABUF*;

alias SERVICETYPE = ULONG;

enum : ULONG
{
    SERVICETYPE_NOTRAFFIC = 0x00000000,
    SERVICETYPE_BESTEFFORT = 0x00000001,
    SERVICETYPE_CONTROLLEDLOAD = 0x00000002,
    SERVICETYPE_GUARANTEED = 0x00000003,
    SERVICETYPE_NETWORK_UNAVAILABLE = 0x00000004,
    SERVICETYPE_GENERAL_INFORMATION = 0x00000005,
    SERVICETYPE_NOCHANGE = 0x00000006,
    SERVICETYPE_NONCONFORMING = 0x00000009,
    SERVICETYPE_NETWORK_CONTROL = 0x0000000A,
    SERVICETYPE_QUALITATIVE = 0x0000000D,
    SERVICE_BESTEFFORT = 0x80010000,
    SERVICE_CONTROLLEDLOAD = 0x80020000,
    SERVICE_GUARANTEED = 0x80040000,
    SERVICE_QUALITATIVE = 0x80200000,
    SERVICE_NO_TRAFFIC_CONTROL = 0x81000000,
    SERVICE_NO_QOS_SIGNALING = 0x40000000,
    QOS_NOT_SPECIFIED = 0xFFFFFFFF,
    POSITIVE_INFINITY_RATE = 0xFFFFFFFE,
}

struct FLOWSPEC
{
    ULONG TokenRate;
    ULONG TokenBucketSize;
    ULONG PeakBandwidth;
    ULONG Latency;
    ULONG DelayVariation;
    SERVICETYPE ServiceType;
    ULONG MaxSduSize;
    ULONG MinimumPolicedSize;
}
alias PFLOWSPEC = FLOWSPEC*;
alias LPFLOWSPEC = FLOWSPEC*;

struct QOS
{
    FLOWSPEC SendingFlowspec;
    FLOWSPEC ReceivingFlowspec;
    WSABUF ProviderSpecific;
}
alias LPQOS = QOS*;

enum : int
{
    CF_ACCEPT = 0x0000,
    CF_REJECT = 0x0001,
    CF_DEFER = 0x0002,
}

alias GROUP = uint;

enum : int
{
    SG_UNCONSTRAINED_GROUP = 0x01,
    SG_CONSTRAINED_GROUP = 0x02,
}

struct WSANETWORKEVENTS
{
    int lNetworkEvents;
    int[FD_MAX_EVENTS] iErrorCode;
}
alias LPWSANETWORKEVENTS = WSANETWORKEVENTS*;

enum MAX_PROTOCOL_CHAIN = 7;
enum BASE_PROTOCOL = 1;
enum LAYERED_PROTOCOL = 0;
enum WSAPROTOCOL_LEN = 255;

struct WSAPROTOCOLCHAIN
{
    int ChainLen;
    DWORD[MAX_PROTOCOL_CHAIN] ChainEntries;
}
alias LPWSAPROTOCOLCHAIN = WSAPROTOCOLCHAIN*;

struct WSAPROTOCOL_INFOA
{
    DWORD dwServiceFlags1;
    DWORD dwServiceFlags2;
    DWORD dwServiceFlags3;
    DWORD dwServiceFlags4;
    DWORD dwProviderFlags;
    GUID ProviderId;
    DWORD dwCatalogEntryId;
    WSAPROTOCOLCHAIN ProtocolChain;
    int iVersion;
    int iAddressFamily;
    int iMaxSockAddr;
    int iMinSockAddr;
    int iSocketType;
    int iProtocol;
    int iProtocolMaxOffset;
    int iNetworkByteOrder;
    int iSecurityScheme;
    DWORD dwMessageSize;
    DWORD dwProviderReserved;
    CHAR[WSAPROTOCOL_LEN + 1] szProtocol;
}
alias LPWSAPROTOCOL_INFOA = WSAPROTOCOL_INFOA*;

struct WSAPROTOCOL_INFOW
{
    DWORD dwServiceFlags1;
    DWORD dwServiceFlags2;
    DWORD dwServiceFlags3;
    DWORD dwServiceFlags4;
    DWORD dwProviderFlags;
    GUID ProviderId;
    DWORD dwCatalogEntryId;
    WSAPROTOCOLCHAIN ProtocolChain;
    int iVersion;
    int iAddressFamily;
    int iMaxSockAddr;
    int iMinSockAddr;
    int iSocketType;
    int iProtocol;
    int iProtocolMaxOffset;
    int iNetworkByteOrder;
    int iSecurityScheme;
    DWORD dwMessageSize;
    DWORD dwProviderReserved;
    WCHAR[WSAPROTOCOL_LEN + 1] szProtocol;
}
alias LPWSAPROTOCOL_INFOW = WSAPROTOCOL_INFOW*;

version (Unicode)
{
    alias WSAPROTOCOL_INFO = WSAPROTOCOL_INFOW;
    alias LPWSAPROTOCOL_INFO = LPWSAPROTOCOL_INFOW;
}
else
{
    alias WSAPROTOCOL_INFO = WSAPROTOCOL_INFOA;
    alias LPWSAPROTOCOL_INFO = LPWSAPROTOCOL_INFOA;
}

alias LPCONDITIONPROC = int function(LPWSABUF, LPWSABUF, LPQOS, LPQOS, LPWSABUF, LPWSABUF, GROUP*, DWORD_PTR) nothrow @nogc;


struct protoent
{
    char* p_name;
    char** p_aliases;
    short p_proto;
}


struct servent
{
    char* s_name;
    char** s_aliases;

    version (Win64)
    {
        char* s_proto;
        short s_port;
    }
    else version (Win32)
    {
        short s_port;
        char* s_proto;
    }
}


/+
union in6_addr
{
    private union _u_t
    {
        ubyte[16] Byte;
        ushort[8] Word;
    }
    _u_t u;
}


struct in_addr6
{
    ubyte[16] s6_addr;
}
+/

@safe pure @nogc
{
    ushort htons(ushort x);
    uint htonl(uint x);
    ushort ntohs(ushort x);
    uint ntohl(uint x);
}


enum: int
{
    SOCK_STREAM =     1,
    SOCK_DGRAM =      2,
    SOCK_RAW =        3,
    SOCK_RDM =        4,
    SOCK_SEQPACKET =  5,
    FROM_PROTOCOL_INFO = -1,
}


enum: int
{
    IPPROTO_IP =    0,
    IPPROTO_HOPOPTS = 0,
    IPPROTO_ICMP =  1,
    IPPROTO_IGMP =  2,
    IPPROTO_GGP =   3,
    IPPROTO_IPV4 =  4,
    IPPROTO_ST =    5,
    IPPROTO_TCP =   6,
    IPPROTO_CBT =   7,
    IPPROTO_EGP =   8,
    IPPROTO_IGP =   9,
    IPPROTO_PUP =   12,
    IPPROTO_UDP =   17,
    IPPROTO_IDP =   22,
    IPPROTO_RDP =   27,
    IPPROTO_IPV6 =  41,
    IPPROTO_ROUTING = 43,
    IPPROTO_FRAGMENT = 44,
    IPPROTO_ESP = 50,
    IPPROTO_AH = 51,
    IPPROTO_ICMPV6 = 58,
    IPPROTO_NONE = 59,
    IPPROTO_DSTOPTS = 60,
    IPPROTO_ND =    77,
    IPPROTO_ICLFXBM = 78,
    IPPROTO_PIM = 103,
    IPPROTO_PGM = 113,
    IPPROTO_L2TP = 115,
    IPPROTO_SCTP = 132,
    IPPROTO_RAW =   255,

    IPPROTO_MAX =   256,
}

enum: int
{
    IPPORT_ECHO = 7,
    IPPORT_DISCARD = 9,
    IPPORT_SYSTAT = 11,
    IPPORT_DAYTIME = 13,
    IPPORT_NETSTAT = 15,
    IPPORT_FTP = 21,
    IPPORT_TELNET = 23,
    IPPORT_SMTP = 25,
    IPPORT_TIMESERVER = 37,
    IPPORT_NAMESERVER = 42,
    IPPORT_WHOIS = 43,
    IPPORT_MTP = 57,
    IPPORT_TFTP = 69,
    IPPORT_RJE = 77,
    IPPORT_FINGER = 79,
    IPPORT_TTYLINK = 87,
    IPPORT_SUPDUP = 95,
    IPPORT_EXECSERVER = 512,
    IPPORT_LOGINSERVER = 513,
    IPPORT_CMDSERVER = 514,
    IPPORT_EFSSERVER = 520,
    IPPORT_BIFFUDP = 512,
    IPPORT_WHOSERVER = 513,
    IPPORT_ROUTESERVER = 520,
    IPPORT_RESERVED = 1024,
}


enum: int
{
    MSG_OOB =        0x1,
    MSG_PEEK =       0x2,
    MSG_DONTROUTE =  0x4,
    MSG_WAITALL =    0x8,
    MSG_INTERRUPT =  0x10,
    MSG_PUSH_IMMEDIATE = 0x20,
    MSG_MAXIOVLEN =  16,
    MSG_PARTIAL =    0x8000,
}


enum: int
{
    SD_RECEIVE =  0,
    SD_SEND =     1,
    SD_BOTH =     2,
}


enum: uint
{
    INADDR_ANY =        0,
    INADDR_LOOPBACK =   0x7F000001,
    INADDR_BROADCAST =  0xFFFFFFFF,
    INADDR_NONE =       0xFFFFFFFF,
    ADDR_ANY =          INADDR_ANY,
}

enum: uint
{
    IN_CLASSA_NET =   0xFF000000,
    IN_CLASSA_HOST =  0x00FFFFFF,
    IN_CLASSA_MAX =   128,
    IN_CLASSB_NET =   0xFFFF0000,
    IN_CLASSB_HOST =  0x0000FFFF,
    IN_CLASSB_MAX =   65536,
    IN_CLASSC_NET =   0xFFFFFF00,
    IN_CLASSC_HOST =  0x000000FF,
    IN_CLASSD_NET =   0xF0000000,
    IN_CLASSD_HOST =  0x0FFFFFFF,
}

enum: int
{
    IN_CLASSA_NSHIFT = 24,
    IN_CLASSB_NSHIFT = 16,
    IN_CLASSC_NSHIFT = 8,
    IN_CLASSD_NSHIFT = 28,
    MAXGETHOSTSTRUCT = 1024,
}

bool IN_CLASSA(uint i) @nogc nothrow pure @safe { return (i & 0x8000_0000U) == 0; }
bool IN_CLASSB(uint i) @nogc nothrow pure @safe { return (i & 0xC000_0000U) == 0x8000_0000U; }
bool IN_CLASSC(uint i) @nogc nothrow pure @safe { return (i & 0xE000_0000U) == 0xC000_0000U; }
bool IN_CLASSD(uint i) @nogc nothrow pure @safe { return (i & 0xF000_0000U) == 0xE000_0000U; }
bool IN_MULTICAST(uint i) @nogc nothrow pure @safe { return IN_CLASSD(i); }


enum: int
{
    AI_PASSIVE = 0x1, // Socket address will be used in bind() call
    AI_CANONNAME = 0x2, // Return canonical name in first ai_canonname
    AI_NUMERICHOST = 0x4, // Nodename must be a numeric address string
    AI_NUMERICSERV = 0x8, // Servicename must be a numeric port number
    AI_DNS_ONLY = 0x10, // Restrict queries to unicast DNS only (no LLMNR, netbios, etc.)
    AI_FORCE_CLEAR_TEXT = 0x20, // Force clear text DNS query
    AI_BYPASS_DNS_CACHE = 0x40, // Bypass DNS cache
    AI_RETURN_TTL = 0x80, // Return record TTL
    AI_ALL = 0x0100, // Query both IP6 and IP4 with AI_V4MAPPED
    AI_ADDRCONFIG = 0x0400, // Resolution only if global address configured
    AI_V4MAPPED = 0x0800, // On v6 failure, query v4 and convert to V4MAPPED format
    AI_NON_AUTHORITATIVE = 0x04000, // LUP_NON_AUTHORITATIVE
    AI_SECURE = 0x08000, // LUP_SECURE
    AI_RETURN_PREFERRED_NAMES = 0x010000, // LUP_RETURN_PREFERRED_NAMES
    AI_FQDN = 0x00020000, // Return the FQDN in ai_canonname
    AI_FILESERVER = 0x00040000, // Resolving fileserver name resolution
    AI_DISABLE_IDN_ENCODING = 0x00080000, // Disable Internationalized Domain Names handling
    AI_SECURE_WITH_FALLBACK = 0x00100000, // Forces clear text fallback if the secure DNS query fails
    AI_EXCLUSIVE_CUSTOM_SERVERS = 0x00200000, // Use exclusively the custom DNS servers
    AI_RETURN_RESPONSE_FLAGS = 0x10000000, // Requests extra information about the DNS results
    AI_REQUIRE_SECURE = 0x20000000, // Forces the DNS query to be done over seucre protocols
    AI_RESOLUTION_HANDLE = 0x40000000, // Request resolution handle
    AI_EXTENDED = 0x80000000, // Indicates this is extended ADDRINFOEX(2/..) struct
}


struct timeval
{
    int tv_sec;
    int tv_usec;
}


union in_addr
{
    private union _S_un_t
    {
        private struct _S_un_b_t
        {
            ubyte s_b1, s_b2, s_b3, s_b4;
        }
        _S_un_b_t S_un_b;

        private struct _S_un_w_t
        {
            ushort s_w1, s_w2;
        }
        _S_un_w_t S_un_w;

        uint S_addr;
    }
    _S_un_t S_un;

    uint s_addr;

    struct
    {
        ubyte s_net, s_host;

        union
        {
            ushort s_imp;

            struct
            {
                ubyte s_lh, s_impno;
            }
        }
    }
}


union in6_addr
{
    private union _in6_u_t
    {
        ubyte[16] u6_addr8;
        ushort[8] u6_addr16;
        uint[4] u6_addr32;
    }
    _in6_u_t in6_u;

    ubyte[16] s6_addr8;
    ushort[8] s6_addr16;
    uint[4] s6_addr32;

    alias s6_addr = s6_addr8;
}


enum in6_addr IN6ADDR_ANY = { s6_addr8: [0] };
enum in6_addr IN6ADDR_LOOPBACK = { s6_addr8: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1] };
//alias IN6ADDR_ANY_INIT = IN6ADDR_ANY;
//alias IN6ADDR_LOOPBACK_INIT = IN6ADDR_LOOPBACK;

enum int INET_ADDRSTRLEN = 16;
enum int INET6_ADDRSTRLEN = 46;




struct sockaddr
{
    short sa_family;
    ubyte[14] sa_data;
}
alias SOCKADDR = sockaddr;
alias PSOCKADDR = SOCKADDR*, LPSOCKADDR = SOCKADDR*;

struct sockaddr_storage
{
    short     ss_family;
    char[6]   __ss_pad1 = void;
    long      __ss_align;
    char[112] __ss_pad2 = void;
}
alias SOCKADDR_STORAGE = sockaddr_storage;
alias PSOCKADDR_STORAGE = SOCKADDR_STORAGE*;

struct sockaddr_in
{
    short sin_family = AF_INET;
    ushort sin_port;
    in_addr sin_addr;
    ubyte[8] sin_zero;
}
alias SOCKADDR_IN = sockaddr_in;
alias PSOCKADDR_IN = SOCKADDR_IN*, LPSOCKADDR_IN = SOCKADDR_IN*;


struct sockaddr_in6
{
    short sin6_family = AF_INET6;
    ushort sin6_port;
    uint sin6_flowinfo;
    in6_addr sin6_addr;
    uint sin6_scope_id;
}


struct addrinfo
{
    int ai_flags;
    int ai_family;
    int ai_socktype;
    int ai_protocol;
    size_t ai_addrlen;
    char* ai_canonname;
    sockaddr* ai_addr;
    addrinfo* ai_next;
}

struct SOCKET_ADDRESS
{
    LPSOCKADDR lpSockaddr;
    INT iSockaddrLength;
}
alias PSOCKET_ADDRESS = SOCKET_ADDRESS*;
alias LPSOCKET_ADDRESS = SOCKET_ADDRESS*;

struct CSADDR_INFO
{
    SOCKET_ADDRESS LocalAddr;
    SOCKET_ADDRESS RemoteAddr;
    INT iSocketType;
    INT iProtocol;
}
alias PCSADDR_INFO = CSADDR_INFO*;
alias LPCSADDR_INFO = CSADDR_INFO*;

struct SOCKET_ADDRESS_LIST
{
    INT iAddressCount;
    SOCKET_ADDRESS[1] Address;
}
alias PSOCKET_ADDRESS_LIST = SOCKET_ADDRESS_LIST*;
alias LPSOCKET_ADDRESS_LIST = SOCKET_ADDRESS_LIST*;

struct BLOB
{
    ULONG cbSize;
    BYTE* pBlobData;
}
alias PBLOB = BLOB*;
alias LPBLOB = BLOB*;

struct AFPROTOCOLS
{
    INT iAddressFamily;
    INT iProtocol;
}
alias PAFPROTOCOLS = AFPROTOCOLS*;
alias LPAFPROTOCOLS = AFPROTOCOLS*;

enum WSAECOMPARATOR
{
    COMP_EQUAL = 0,
    COMP_NOTLESS,
}
alias PWSAECOMPARATOR = WSAECOMPARATOR*;
alias LPWSAECOMPARATOR = WSAECOMPARATOR*;

struct WSAVERSION
{
    DWORD dwVersion;
    WSAECOMPARATOR ecHow;
}
alias PWSAVERSION = WSAVERSION*;
alias LPWSAVERSION = WSAVERSION*;

struct WSAQUERYSETA
{
    DWORD dwSize;
    LPSTR lpszServiceInstanceName;
    LPGUID lpServiceClassId;
    LPWSAVERSION lpVersion;
    LPSTR lpszComment;
    DWORD dwNameSpace;
    LPGUID lpNSProviderId;
    LPSTR lpszContext;
    DWORD dwNumberOfProtocols;
    LPAFPROTOCOLS lpafpProtocols;
    LPSTR lpszQueryString;
    DWORD dwNumberOfCsAddrs;
    LPCSADDR_INFO lpcsaBuffer;
    DWORD dwOutputFlags;
    LPBLOB lpBlob;
}
alias PWSAQUERYSETA = WSAQUERYSETA*;
alias LPWSAQUERYSETA = WSAQUERYSETA*;

struct WSAQUERYSETW
{
    DWORD dwSize;
    LPWSTR lpszServiceInstanceName;
    LPGUID lpServiceClassId;
    LPWSAVERSION lpVersion;
    LPWSTR lpszComment;
    DWORD dwNameSpace;
    LPGUID lpNSProviderId;
    LPWSTR lpszContext;
    DWORD dwNumberOfProtocols;
    LPAFPROTOCOLS lpafpProtocols;
    LPWSTR lpszQueryString;
    DWORD dwNumberOfCsAddrs;
    LPCSADDR_INFO lpcsaBuffer;
    DWORD dwOutputFlags;
    LPBLOB lpBlob;
}
alias PWSAQUERYSETW = WSAQUERYSETW*;
alias LPWSAQUERYSETW = WSAQUERYSETW*;

version (Unicode)
{
    alias WSAQUERYSET = WSAQUERYSETW;
    alias PWSAQUERYSET = PWSAQUERYSETW;
    alias LPWSAQUERYSET = LPWSAQUERYSETW;
}
else
{
    alias WSAQUERYSET = WSAQUERYSETA;
    alias PWSAQUERYSET = PWSAQUERYSETA;
    alias LPWSAQUERYSET = LPWSAQUERYSETA;
}

enum WSAESETSERVICEOP
{
    RNRSERVICE_REGISTER = 0,
    RNRSERVICE_DEREGISTER,
    RNRSERVICE_DELETE,
}
alias PWSAESETSERVICEOP = WSAESETSERVICEOP*;
alias LPWSAESETSERVICEOP = WSAESETSERVICEOP*;

struct WSANSCLASSINFOA
{
    LPSTR lpszName;
    DWORD dwNameSpace;
    DWORD dwValueType;
    DWORD dwValueSize;
    LPVOID lpValue;
}
alias PWSANSCLASSINFOA = WSANSCLASSINFOA*;
alias LPWSANSCLASSINFOA = WSANSCLASSINFOA*;

struct WSANSCLASSINFOW
{
    LPWSTR lpszName;
    DWORD dwNameSpace;
    DWORD dwValueType;
    DWORD dwValueSize;
    LPVOID lpValue;
}
alias PWSANSCLASSINFOW = WSANSCLASSINFOW*;
alias LPWSANSCLASSINFOW = WSANSCLASSINFOW*;

struct WSASERVICECLASSINFOA
{
    LPGUID lpServiceClassId;
    LPSTR lpszServiceClassName;
    DWORD dwCount;
    LPWSANSCLASSINFOA lpClassInfos;
}
alias PWSASERVICECLASSINFOA = WSASERVICECLASSINFOA*;
alias LPWSASERVICECLASSINFOA = WSASERVICECLASSINFOA*;

struct WSASERVICECLASSINFOW
{
    LPGUID lpServiceClassId;
    LPWSTR lpszServiceClassName;
    DWORD dwCount;
    LPWSANSCLASSINFOW lpClassInfos;
}
alias PWSASERVICECLASSINFOW = WSASERVICECLASSINFOW*;
alias LPWSASERVICECLASSINFOW = WSASERVICECLASSINFOW*;

struct WSANAMESPACE_INFOA
{
    GUID NSProviderId;
    DWORD dwNameSpace;
    WINBOOL fActive;
    DWORD dwVersion;
    LPSTR lpszIdentifier;
}
alias PWSANAMESPACE_INFOA = WSANAMESPACE_INFOA*;
alias LPWSANAMESPACE_INFOA = WSANAMESPACE_INFOA*;

struct WSANAMESPACE_INFOW
{
    GUID NSProviderId;
    DWORD dwNameSpace;
    WINBOOL fActive;
    DWORD dwVersion;
    LPWSTR lpszIdentifier;
}
alias PWSANAMESPACE_INFOW = WSANAMESPACE_INFOW*;
alias LPWSANAMESPACE_INFOW = WSANAMESPACE_INFOW*;

enum WSACOMPLETIONTYPE
{
    NSP_NOTIFY_IMMEDIATELY = 0,
    NSP_NOTIFY_HWND,
    NSP_NOTIFY_EVENT,
    NSP_NOTIFY_PORT,
    NSP_NOTIFY_APC,
}
alias PWSACOMPLETIONTYPE = WSACOMPLETIONTYPE*;
alias LPWSACOMPLETIONTYPE = WSACOMPLETIONTYPE*;

struct WSACOMPLETION
{
    WSACOMPLETIONTYPE Type;
    union Parameters_t
    {
        struct WindowMessage_t
        {
            HWND hWnd;
            UINT uMsg;
            WPARAM context;
        }
        WindowMessage_t WindowMessage;

        struct Event_t
        {
            LPWSAOVERLAPPED lpOverlapped;
        }
        Event_t Event;

        struct Apc_t
        {
            LPWSAOVERLAPPED lpOverlapped;
            LPWSAOVERLAPPED_COMPLETION_ROUTINE lpfnCompletionProc;
        }
        Apc_t Apc;

        struct Port_t
        {
            LPWSAOVERLAPPED lpOverlapped;
            HANDLE hPort;
            ULONG_PTR Key;
        }
        Port_t Port;
    }
    Parameters_t Parameters;
}
alias PWSACOMPLETION = WSACOMPLETION*;
alias LPWSACOMPLETION = WSACOMPLETION*;

struct WSANAMESPACE_INFOEXA
{
    GUID NSProviderId;
    DWORD dwNameSpace;
    WINBOOL fActive;
    DWORD dwVersion;
    LPSTR lpszIdentifier;
    BLOB ProviderSpecific;
}
alias PWSANAMESPACE_INFOEXA = WSANAMESPACE_INFOEXA*;
alias LPWSANAMESPACE_INFOEXA = WSANAMESPACE_INFOEXA*;

struct WSANAMESPACE_INFOEXW
{
    GUID NSProviderId;
    DWORD dwNameSpace;
    WINBOOL fActive;
    DWORD dwVersion;
    LPWSTR lpszIdentifier;
    BLOB ProviderSpecific;
}
alias PWSANAMESPACE_INFOEXW = WSANAMESPACE_INFOEXW*;
alias LPWSANAMESPACE_INFOEXW = WSANAMESPACE_INFOEXW*;

struct WSAQUERYSET2A
{
    DWORD dwSize;
    LPSTR lpszServiceInstanceName;
    LPWSAVERSION lpVersion;
    LPSTR lpszComment;
    DWORD dwNameSpace;
    LPGUID lpNSProviderId;
    LPSTR lpszContext;
    DWORD dwNumberOfProtocols;
    LPAFPROTOCOLS lpafpProtocols;
    LPSTR lpszQueryString;
    DWORD dwNumberOfCsAddrs;
    LPCSADDR_INFO lpcsaBuffer;
    DWORD dwOutputFlags;
    LPBLOB lpBlob;
}
alias PWSAQUERYSET2A = WSAQUERYSET2A*;
alias LPWSAQUERYSET2A = WSAQUERYSET2A*;

struct WSAQUERYSET2W
{
    DWORD dwSize;
    LPWSTR lpszServiceInstanceName;
    LPWSAVERSION lpVersion;
    LPWSTR lpszComment;
    DWORD dwNameSpace;
    LPGUID lpNSProviderId;
    LPWSTR lpszContext;
    DWORD dwNumberOfProtocols;
    LPAFPROTOCOLS lpafpProtocols;
    LPWSTR lpszQueryString;
    DWORD dwNumberOfCsAddrs;
    LPCSADDR_INFO lpcsaBuffer;
    DWORD dwOutputFlags;
    LPBLOB lpBlob;
}
alias PWSAQUERYSET2W = WSAQUERYSET2W*;
alias LPWSAQUERYSET2W = WSAQUERYSET2W*;

struct WSAMSG
{
    LPSOCKADDR name;
    INT namelen;
    LPWSABUF lpBuffers;
    DWORD dwBufferCount;
    WSABUF Control;
    DWORD dwFlags;
}
alias PWSAMSG = WSAMSG*;
alias LPWSAMSG = WSAMSG*;

struct OVERLAPPED_ENTRY
{
    ULONG_PTR lpCompletionKey;
    LPOVERLAPPED lpOverlapped;
    ULONG_PTR Internal;
    DWORD dwNumberOfBytesTransferred;
}
alias LPOVERLAPPED_ENTRY = OVERLAPPED_ENTRY*;

struct SOCK_NOTIFY_REGISTRATION
{
    SOCKET socket;
    PVOID completionKey;
    UINT16 eventFilter;
    UINT8 operation;
    UINT8 triggerFlags;
    DWORD registrationResult;
}


struct hostent
{
    char* h_name;
    char** h_aliases;
    short h_addrtype;
    short h_length;
    char** h_addr_list;


    char* h_addr() @safe pure nothrow @nogc
    {
        return h_addr_list[0];
    }
}

int WSAIoctl(SOCKET s, uint dwIoControlCode,
    void* lpvInBuffer, uint cbInBuffer,
    void* lpvOutBuffer, uint cbOutBuffer,
    uint* lpcbBytesReturned,
    LPWSAOVERLAPPED lpOverlapped, LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine) @nogc;


enum IOC_UNIX = 0x00000000;
enum IOC_WS2 = 0x08000000;
enum IOC_PROTOCOL = 0x10000000;
enum IOC_VENDOR = 0x18000000;
enum int SIO_ASSOCIATE_HANDLE = IOC_IN | IOC_WS2 | 1;
enum int SIO_ENABLE_CIRCULAR_QUEUEING = IOC_VOID | IOC_WS2 | 2;
enum int SIO_FIND_ROUTE = IOC_OUT | IOC_WS2 | 3;
enum int SIO_FLUSH = IOC_VOID | IOC_WS2 | 4;
enum int SIO_GET_BROADCAST_ADDRESS = IOC_OUT | IOC_WS2 | 5;
enum int SIO_GET_EXTENSION_FUNCTION_POINTER = IOC_INOUT | IOC_WS2 | 6;
enum int SIO_GET_QOS = IOC_INOUT | IOC_WS2 | 7;
enum int SIO_GET_GROUP_QOS = IOC_INOUT | IOC_WS2 | 8;
enum int SIO_MULTIPOINT_LOOPBACK = IOC_IN | IOC_WS2 | 9;
enum int SIO_MULTICAST_SCOPE = IOC_IN | IOC_WS2 | 10;
enum int SIO_SET_QOS = IOC_IN | IOC_WS2 | 11;
enum int SIO_SET_GROUP_QOS = IOC_IN | IOC_WS2 | 12;
enum int SIO_TRANSLATE_HANDLE = IOC_INOUT | IOC_WS2 | 13;
enum int SIO_ROUTING_INTERFACE_QUERY = IOC_INOUT | IOC_WS2 | 20;
enum int SIO_ROUTING_INTERFACE_CHANGE = IOC_IN | IOC_WS2 | 21;
enum int SIO_ADDRESS_LIST_QUERY = IOC_OUT | IOC_WS2 | 22;
enum int SIO_ADDRESS_LIST_CHANGE = IOC_VOID | IOC_WS2 | 23;
enum int SIO_QUERY_TARGET_PNP_HANDLE = IOC_OUT | IOC_WS2 | 24;
enum int SIO_ADDRESS_LIST_SORT = IOC_INOUT | IOC_WS2 | 25;
enum int SIO_NSP_NOTIFY_CHANGE = IOC_IN | IOC_WS2 | 25;
enum SIO_KEEPALIVE_VALS = IOC_IN | IOC_VENDOR | 4;

/* Argument structure for SIO_KEEPALIVE_VALS */
struct tcp_keepalive
{
    uint onoff;
    uint keepalivetime;
    uint keepaliveinterval;
}


struct pollfd
{
    SOCKET  fd;        // Socket handle
    short   events;    // Requested events to monitor
    short   revents;   // Returned events indicating status
}
alias WSAPOLLFD = pollfd;
alias PWSAPOLLFD = pollfd*;
alias LPWSAPOLLFD = pollfd*;

enum: short {
    POLLRDNORM = 0x0100,
    POLLRDBAND = 0x0200,
    POLLIN = (POLLRDNORM | POLLRDBAND),
    POLLPRI = 0x0400,

    POLLWRNORM = 0x0010,
    POLLOUT = (POLLWRNORM),
    POLLWRBAND = 0x0020,

    POLLERR = 0x0001,
    POLLHUP = 0x0002,
    POLLNVAL = 0x0004
}

int WSAPoll(LPWSAPOLLFD fdArray, uint fds, int timeout) @nogc;

enum : DWORD
{
    PFL_MULTIPLE_PROTO_ENTRIES = 0x00000001,
    PFL_RECOMMENDED_PROTO_ENTRY = 0x00000002,
    PFL_HIDDEN = 0x00000004,
    PFL_MATCHES_PROTOCOL_ZERO = 0x00000008,
    PFL_NETWORKDIRECT_PROVIDER = 0x00000010,
    XP1_CONNECTIONLESS = 0x00000001,
    XP1_GUARANTEED_DELIVERY = 0x00000002,
    XP1_GUARANTEED_ORDER = 0x00000004,
    XP1_MESSAGE_ORIENTED = 0x00000008,
    XP1_PSEUDO_STREAM = 0x00000010,
    XP1_GRACEFUL_CLOSE = 0x00000020,
    XP1_EXPEDITED_DATA = 0x00000040,
    XP1_CONNECT_DATA = 0x00000080,
    XP1_DISCONNECT_DATA = 0x00000100,
    XP1_SUPPORT_BROADCAST = 0x00000200,
    XP1_SUPPORT_MULTIPOINT = 0x00000400,
    XP1_MULTIPOINT_CONTROL_PLANE = 0x00000800,
    XP1_MULTIPOINT_DATA_PLANE = 0x00001000,
    XP1_QOS_SUPPORTED = 0x00002000,
    XP1_INTERRUPT = 0x00004000,
    XP1_UNI_SEND = 0x00008000,
    XP1_UNI_RECV = 0x00010000,
    XP1_IFS_HANDLES = 0x00020000,
    XP1_PARTIAL_MESSAGE = 0x00040000,
    XP1_SAN_SUPPORT_SDP = 0x00080000,
    JL_SENDER_ONLY = 0x01,
    JL_RECEIVER_ONLY = 0x02,
    JL_BOTH = 0x04,
    WSA_FLAG_OVERLAPPED = 0x01,
    WSA_FLAG_MULTIPOINT_C_ROOT = 0x02,
    WSA_FLAG_MULTIPOINT_C_LEAF = 0x04,
    WSA_FLAG_MULTIPOINT_D_ROOT = 0x08,
    WSA_FLAG_MULTIPOINT_D_LEAF = 0x10,
    WSA_FLAG_ACCESS_SYSTEM_SECURITY = 0x40,
    WSA_FLAG_NO_HANDLE_INHERIT = 0x80,
    WSA_FLAG_REGISTERED_IO = 0x100,
    LUP_DEEP = 0x0001,
    LUP_CONTAINERS = 0x0002,
    LUP_NOCONTAINERS = 0x0004,
    LUP_NEAREST = 0x0008,
    LUP_RETURN_NAME = 0x0010,
    LUP_RETURN_TYPE = 0x0020,
    LUP_RETURN_VERSION = 0x0040,
    LUP_RETURN_COMMENT = 0x0080,
    LUP_RETURN_ADDR = 0x0100,
    LUP_RETURN_BLOB = 0x0200,
    LUP_RETURN_ALIASES = 0x0400,
    LUP_RETURN_QUERY_STRING = 0x0800,
    LUP_RETURN_ALL = 0x0FF0,
    LUP_RES_SERVICE = 0x8000,
    LUP_FLUSHCACHE = 0x1000,
    LUP_FLUSHPREVIOUS = 0x2000,
    LUP_NON_AUTHORITATIVE = 0x4000,
    LUP_SECURE = 0x8000,
    LUP_RETURN_PREFERRED_NAMES = 0x10000,
    LUP_DNS_ONLY = 0x20000,
    LUP_ADDRCONFIG = 0x100000,
    LUP_DUAL_ADDR = 0x200000,
    LUP_FILESERVER = 0x400000,
    LUP_DISABLE_IDN_ENCODING = 0x00800000,
    LUP_API_ANSI = 0x01000000,
    LUP_RESOLUTION_HANDLE = 0x80000000,
    RESULT_IS_ALIAS = 0x0001,
    NS_ALL = 0,
    NS_SAP = 1,
    NS_NDS = 2,
    NS_PEER_BROWSE = 3,
    NS_SLP = 5,
    NS_DHCP = 6,
    NS_TCPIP_LOCAL = 10,
    NS_TCPIP_HOSTS = 11,
    NS_DNS = 12,
    NS_NETBT = 13,
    NS_WINS = 14,
    NS_NLA = 15,
    NS_BTH = 16,
    NS_NBP = 20,
    NS_MS = 30,
    NS_STDA = 31,
    NS_NTDS = 32,
    NS_EMAIL = 37,
    NS_PNRPNAME = 38,
    NS_PNRPCLOUD = 39,
    NS_X500 = 40,
    NS_NIS = 41,
    NS_NISPLUS = 42,
    NS_WRQ = 50,
    NS_NETDES = 60,
}

enum : int
{
    BIGENDIAN = 0x0000,
    LITTLEENDIAN = 0x0001,
    SECURITY_PROTOCOL_NONE = 0x0000,
    SOCK_NOTIFY_REGISTER_EVENT_NONE = 0x00,
    SOCK_NOTIFY_REGISTER_EVENT_IN = 0x01,
    SOCK_NOTIFY_REGISTER_EVENT_OUT = 0x02,
    SOCK_NOTIFY_REGISTER_EVENT_HANGUP = 0x04,
    SOCK_NOTIFY_EVENT_IN = SOCK_NOTIFY_REGISTER_EVENT_IN,
    SOCK_NOTIFY_EVENT_OUT = SOCK_NOTIFY_REGISTER_EVENT_OUT,
    SOCK_NOTIFY_EVENT_HANGUP = SOCK_NOTIFY_REGISTER_EVENT_HANGUP,
    SOCK_NOTIFY_EVENT_ERR = 0x40,
    SOCK_NOTIFY_EVENT_REMOVE = 0x80,
    SOCK_NOTIFY_OP_NONE = 0x00,
    SOCK_NOTIFY_OP_ENABLE = 0x01,
    SOCK_NOTIFY_OP_DISABLE = 0x02,
    SOCK_NOTIFY_OP_REMOVE = 0x04,
    SOCK_NOTIFY_TRIGGER_ONESHOT = 0x01,
    SOCK_NOTIFY_TRIGGER_PERSISTENT = 0x02,
    SOCK_NOTIFY_TRIGGER_LEVEL = 0x04,
    SOCK_NOTIFY_TRIGGER_EDGE = 0x08,
}

enum
{
    SOCK_NOTIFY_REGISTER_EVENTS_ALL = SOCK_NOTIFY_REGISTER_EVENT_IN | SOCK_NOTIFY_REGISTER_EVENT_OUT | SOCK_NOTIFY_REGISTER_EVENT_HANGUP,
    SOCK_NOTIFY_EVENTS_ALL = SOCK_NOTIFY_REGISTER_EVENTS_ALL | SOCK_NOTIFY_EVENT_ERR | SOCK_NOTIFY_EVENT_REMOVE,
    SOCK_NOTIFY_TRIGGER_ALL = SOCK_NOTIFY_TRIGGER_ONESHOT | SOCK_NOTIFY_TRIGGER_PERSISTENT | SOCK_NOTIFY_TRIGGER_LEVEL | SOCK_NOTIFY_TRIGGER_EDGE,
}

@nogc
{
void WSASetLastError(int iError);
WINBOOL WSAIsBlocking();
int WSAUnhookBlockingHook();
FARPROC WSASetBlockingHook(FARPROC lpBlockFunc);
int WSACancelBlockingCall();
HANDLE WSAAsyncGetServByName(HWND hWnd, uint wMsg, const char* name, const char* proto, char* buf, int buflen);
HANDLE WSAAsyncGetServByPort(HWND hWnd, uint wMsg, int port, const char* proto, char* buf, int buflen);
HANDLE WSAAsyncGetProtoByName(HWND hWnd, uint wMsg, const char* name, char* buf, int buflen);
HANDLE WSAAsyncGetProtoByNumber(HWND hWnd, uint wMsg, int number, char* buf, int buflen);
HANDLE WSAAsyncGetHostByName(HWND hWnd, uint wMsg, const char* name, char* buf, int buflen);
HANDLE WSAAsyncGetHostByAddr(HWND hWnd, uint wMsg, const char* addr, int len, int type, char* buf, int buflen);
int WSACancelAsyncRequest(HANDLE hAsyncTaskHandle);
int WSAAsyncSelect(SOCKET s, HWND hWnd, uint wMsg, int lEvent);
SOCKET WSAAccept(SOCKET s, sockaddr* addr, LPINT addrlen, LPCONDITIONPROC lpfnCondition, DWORD_PTR dwCallbackData);
WINBOOL WSACloseEvent(WSAEVENT hEvent);
int WSAConnect(SOCKET s, const(sockaddr)* name, int namelen, LPWSABUF lpCallerData, LPWSABUF lpCalleeData, LPQOS lpSQOS, LPQOS lpGQOS);
WSAEVENT WSACreateEvent();
int WSADuplicateSocketA(SOCKET s, DWORD dwProcessId, LPWSAPROTOCOL_INFOA lpProtocolInfo);
int WSADuplicateSocketW(SOCKET s, DWORD dwProcessId, LPWSAPROTOCOL_INFOW lpProtocolInfo);
int WSAEnumNetworkEvents(SOCKET s, WSAEVENT hEventObject, LPWSANETWORKEVENTS lpNetworkEvents);
int WSAEnumProtocolsA(LPINT lpiProtocols, LPWSAPROTOCOL_INFOA lpProtocolBuffer, LPDWORD lpdwBufferLength);
int WSAEnumProtocolsW(LPINT lpiProtocols, LPWSAPROTOCOL_INFOW lpProtocolBuffer, LPDWORD lpdwBufferLength);
int WSAEventSelect(SOCKET s, WSAEVENT hEventObject, int lNetworkEvents);
WINBOOL WSAGetOverlappedResult(SOCKET s, LPWSAOVERLAPPED lpOverlapped, LPDWORD lpcbTransfer, WINBOOL fWait, LPDWORD lpdwFlags);
WINBOOL WSAGetQOSByName(SOCKET s, LPWSABUF lpQOSName, LPQOS lpQOS);
int WSAHtonl(SOCKET s, uint hostlong, uint* lpnetlong);
int WSAHtons(SOCKET s, ushort hostshort, ushort* lpnetshort);
SOCKET WSAJoinLeaf(SOCKET s, const(sockaddr)* name, int namelen, LPWSABUF lpCallerData, LPWSABUF lpCalleeData, LPQOS lpSQOS, LPQOS lpGQOS, DWORD dwFlags);
int WSANtohl(SOCKET s, uint netlong, uint* lphostlong);
int WSANtohs(SOCKET s, ushort netshort, ushort* lphostshort);
int WSARecv(SOCKET s, LPWSABUF lpBuffers, DWORD dwBufferCount, LPDWORD lpNumberOfBytesRecvd, LPDWORD lpFlags, LPWSAOVERLAPPED lpOverlapped, LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine);
int WSARecvDisconnect(SOCKET s, LPWSABUF lpInboundDisconnectData);
int WSARecvFrom(SOCKET s, LPWSABUF lpBuffers, DWORD dwBufferCount, LPDWORD lpNumberOfBytesRecvd, LPDWORD lpFlags, sockaddr* lpFrom, LPINT lpFromlen, LPWSAOVERLAPPED lpOverlapped, LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine);
WINBOOL WSAResetEvent(WSAEVENT hEvent);
int WSASend(SOCKET s, LPWSABUF lpBuffers, DWORD dwBufferCount, LPDWORD lpNumberOfBytesSent, DWORD dwFlags, LPWSAOVERLAPPED lpOverlapped, LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine);
int WSASendDisconnect(SOCKET s, LPWSABUF lpOutboundDisconnectData);
int WSASendTo(SOCKET s, LPWSABUF lpBuffers, DWORD dwBufferCount, LPDWORD lpNumberOfBytesSent, DWORD dwFlags, const(sockaddr)* lpTo, int iTolen, LPWSAOVERLAPPED lpOverlapped, LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine);
WINBOOL WSASetEvent(WSAEVENT hEvent);
SOCKET WSASocketA(int af, int type, int protocol, LPWSAPROTOCOL_INFOA lpProtocolInfo, GROUP g, DWORD dwFlags);
SOCKET WSASocketW(int af, int type, int protocol, LPWSAPROTOCOL_INFOW lpProtocolInfo, GROUP g, DWORD dwFlags);
DWORD WSAWaitForMultipleEvents(DWORD cEvents, const(WSAEVENT)* lphEvents, WINBOOL fWaitAll, DWORD dwTimeout, WINBOOL fAlertable);
INT WSAAddressToStringA(LPSOCKADDR lpsaAddress, DWORD dwAddressLength, LPWSAPROTOCOL_INFOA lpProtocolInfo, LPSTR lpszAddressString, LPDWORD lpdwAddressStringLength);
INT WSAAddressToStringW(LPSOCKADDR lpsaAddress, DWORD dwAddressLength, LPWSAPROTOCOL_INFOW lpProtocolInfo, LPWSTR lpszAddressString, LPDWORD lpdwAddressStringLength);
INT WSAStringToAddressA(LPSTR AddressString, INT AddressFamily, LPWSAPROTOCOL_INFOA lpProtocolInfo, LPSOCKADDR lpAddress, LPINT lpAddressLength);
INT WSAStringToAddressW(LPWSTR AddressString, INT AddressFamily, LPWSAPROTOCOL_INFOW lpProtocolInfo, LPSOCKADDR lpAddress, LPINT lpAddressLength);
INT WSALookupServiceBeginA(LPWSAQUERYSETA lpqsRestrictions, DWORD dwControlFlags, LPHANDLE lphLookup);
INT WSALookupServiceBeginW(LPWSAQUERYSETW lpqsRestrictions, DWORD dwControlFlags, LPHANDLE lphLookup);
INT WSALookupServiceNextA(HANDLE hLookup, DWORD dwControlFlags, LPDWORD lpdwBufferLength, LPWSAQUERYSETA lpqsResults);
INT WSALookupServiceNextW(HANDLE hLookup, DWORD dwControlFlags, LPDWORD lpdwBufferLength, LPWSAQUERYSETW lpqsResults);
INT WSANSPIoctl(HANDLE hLookup, DWORD dwControlCode, LPVOID lpvInBuffer, DWORD cbInBuffer, LPVOID lpvOutBuffer, DWORD cbOutBuffer, LPDWORD lpcbBytesReturned, LPWSACOMPLETION lpCompletion);
INT WSALookupServiceEnd(HANDLE hLookup);
INT WSAInstallServiceClassA(LPWSASERVICECLASSINFOA lpServiceClassInfo);
INT WSAInstallServiceClassW(LPWSASERVICECLASSINFOW lpServiceClassInfo);
INT WSARemoveServiceClass(LPGUID lpServiceClassId);
INT WSAGetServiceClassInfoA(LPGUID lpProviderId, LPGUID lpServiceClassId, LPDWORD lpdwBufSize, LPWSASERVICECLASSINFOA lpServiceClassInfo);
INT WSAGetServiceClassInfoW(LPGUID lpProviderId, LPGUID lpServiceClassId, LPDWORD lpdwBufSize, LPWSASERVICECLASSINFOW lpServiceClassInfo);
INT WSAEnumNameSpaceProvidersA(LPDWORD lpdwBufferLength, LPWSANAMESPACE_INFOA lpnspBuffer);
INT WSAEnumNameSpaceProvidersW(LPDWORD lpdwBufferLength, LPWSANAMESPACE_INFOW lpnspBuffer);
INT WSAEnumNameSpaceProvidersExA(LPDWORD lpdwBufferLength, LPWSANAMESPACE_INFOEXA lpnspBuffer);
INT WSAEnumNameSpaceProvidersExW(LPDWORD lpdwBufferLength, LPWSANAMESPACE_INFOEXW lpnspBuffer);
INT WSAGetServiceClassNameByClassIdA(LPGUID lpServiceClassId, LPSTR lpszServiceClassName, LPDWORD lpdwBufferLength);
INT WSAGetServiceClassNameByClassIdW(LPGUID lpServiceClassId, LPWSTR lpszServiceClassName, LPDWORD lpdwBufferLength);
INT WSASetServiceA(LPWSAQUERYSETA lpqsRegInfo, WSAESETSERVICEOP essoperation, DWORD dwControlFlags);
INT WSASetServiceW(LPWSAQUERYSETW lpqsRegInfo, WSAESETSERVICEOP essoperation, DWORD dwControlFlags);
INT WSAProviderConfigChange(LPHANDLE lpNotificationHandle, LPWSAOVERLAPPED lpOverlapped, LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine);
WINBOOL WSAConnectByList(SOCKET s, PSOCKET_ADDRESS_LIST SocketAddressList, LPDWORD LocalAddressLength, LPSOCKADDR LocalAddress, LPDWORD RemoteAddressLength, LPSOCKADDR RemoteAddress, const(timeval)* timeout, LPWSAOVERLAPPED Reserved);
WINBOOL WSAConnectByNameA(SOCKET s, LPSTR nodename, LPSTR servicename, LPDWORD LocalAddressLength, LPSOCKADDR LocalAddress, LPDWORD RemoteAddressLength, LPSOCKADDR RemoteAddress, const(timeval)* timeout, LPWSAOVERLAPPED Reserved);
WINBOOL WSAConnectByNameW(SOCKET s, LPWSTR nodename, LPWSTR servicename, LPDWORD LocalAddressLength, LPSOCKADDR LocalAddress, LPDWORD RemoteAddressLength, LPSOCKADDR RemoteAddress, const(timeval)* timeout, LPWSAOVERLAPPED Reserved);
int WSASendMsg(SOCKET s, LPWSAMSG lpMsg, DWORD dwFlags, LPDWORD lpNumberOfBytesSent, LPWSAOVERLAPPED lpOverlapped, LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine);
DWORD ProcessSocketNotifications(HANDLE completionPort, UINT32 registrationCount, SOCK_NOTIFY_REGISTRATION* registrationInfos, UINT32 timeoutMs, ULONG completionCount, OVERLAPPED_ENTRY* completionPortEntries, UINT32* receivedEntryCount);
}
