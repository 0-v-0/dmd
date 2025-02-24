/**
$(RED Warning:
      This binding is out-of-date and does not allow use on non-Windows platforms. Use `etc.c.odbc.sql` instead.)

 * Windows API header module
 *
 * Translated from MinGW Windows headers
 *
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Source: $(DRUNTIMESRC core/sys/windows/_sql.d)
 */

deprecated ("The ODBC 3.5 modules are deprecated. Please use the ODBC4 modules in the `etc.c.odbc` package.")
module core.sys.windows.sql;
version (Windows):

public import core.sys.windows.sqltypes;
import core.sys.windows.windef;

enum ODBCVER = 0x0351;

enum SQL_ACCESSIBLE_PROCEDURES=20;
enum SQL_ACCESSIBLE_TABLES=19;
enum SQL_ALL_TYPES=0;
enum SQL_ALTER_TABLE=86;
enum SQL_API_SQLALLOCCONNECT=1;
enum SQL_API_SQLALLOCENV=2;
enum SQL_API_SQLALLOCSTMT=3;
enum SQL_API_SQLBINDCOL=4;
enum SQL_API_SQLCANCEL=5;
enum SQL_API_SQLCOLUMNS=40;
enum SQL_API_SQLCONNECT=7;
enum SQL_API_SQLDATASOURCES=57;
enum SQL_API_SQLDESCRIBECOL=8;
enum SQL_API_SQLDISCONNECT=9;
enum SQL_API_SQLERROR=10;
enum SQL_API_SQLEXECDIRECT=11;
enum SQL_API_SQLEXECUTE=12;
enum SQL_API_SQLFETCH=13;
enum SQL_API_SQLFREECONNECT=14;
enum SQL_API_SQLFREEENV=15;
enum SQL_API_SQLFREESTMT=16;
enum SQL_API_SQLGETCONNECTOPTION=42;
enum SQL_API_SQLGETCURSORNAME=17;
enum SQL_API_SQLGETDATA=43;
enum SQL_API_SQLGETFUNCTIONS=44;
enum SQL_API_SQLGETINFO=45;
enum SQL_API_SQLGETSTMTOPTION=46;
enum SQL_API_SQLGETTYPEINFO=47;
enum SQL_API_SQLNUMRESULTCOLS=18;
enum SQL_API_SQLPARAMDATA=48;
enum SQL_API_SQLPREPARE=19;
enum SQL_API_SQLPUTDATA=49;
enum SQL_API_SQLROWCOUNT=20;
enum SQL_API_SQLSETCONNECTOPTION=50;
enum SQL_API_SQLSETCURSORNAME=21;
enum SQL_API_SQLSETPARAM=22;
enum SQL_API_SQLSETSTMTOPTION=51;
enum SQL_API_SQLSPECIALCOLUMNS=52;
enum SQL_API_SQLSTATISTICS=53;
enum SQL_API_SQLTABLES=54;
enum SQL_API_SQLTRANSACT=23;

enum SQL_CB_DELETE=0;
enum SQL_CB_CLOSE=1;
enum SQL_CB_PRESERVE=2;

enum SQL_CHAR=1;
enum SQL_CLOSE=0;
enum SQL_COMMIT=0;
enum SQL_CURSOR_COMMIT_BEHAVIOR=23;
enum SQL_DATA_AT_EXEC=-2;
enum SQL_DATA_SOURCE_NAME=2;
enum SQL_DATA_SOURCE_READ_ONLY=25;
enum SQL_DBMS_NAME=17;
enum SQL_DBMS_VER=18;
enum SQL_DECIMAL=3;
enum SQL_DEFAULT_TXN_ISOLATION=26;
enum SQL_DOUBLE=8;
enum SQL_DROP=1;
enum SQL_ERROR=-1;

enum SQL_FD_FETCH_NEXT=1;
enum SQL_FD_FETCH_FIRST=2;
enum SQL_FD_FETCH_LAST=4;
enum SQL_FD_FETCH_PRIOR=8;
enum SQL_FD_FETCH_ABSOLUTE=16;
enum SQL_FD_FETCH_RELATIVE=32;

enum SQL_FETCH_ABSOLUTE=5;
enum SQL_FETCH_DIRECTION=8;
enum SQL_FETCH_FIRST=2;
enum SQL_FETCH_LAST=3;
enum SQL_FETCH_NEXT=1;
enum SQL_FETCH_PRIOR=4;
enum SQL_FETCH_RELATIVE=6;
enum SQL_FLOAT=6;
enum SQL_GD_ANY_COLUMN=1;
enum SQL_GD_ANY_ORDER=2;
enum SQL_GETDATA_EXTENSIONS=81;
enum SQL_IC_LOWER=2;
enum SQL_IC_MIXED=4;
enum SQL_IC_SENSITIVE=3;
enum SQL_IC_UPPER=1;
enum SQL_IDENTIFIER_CASE=28;
enum SQL_IDENTIFIER_QUOTE_CHAR=29;

enum SQL_INDEX_ALL=1;
enum SQL_INDEX_CLUSTERED=1;
enum SQL_INDEX_HASHED=2;
enum SQL_INDEX_OTHER=3;
enum SQL_INDEX_UNIQUE=0;

enum SQL_INTEGER=4;
enum SQL_INTEGRITY=73;
enum SQL_INVALID_HANDLE=-2;

enum SQL_MAX_CATALOG_NAME_LEN=34;
enum SQL_MAX_COLUMN_NAME_LEN=30;
enum SQL_MAX_COLUMNS_IN_GROUP_BY=97;
enum SQL_MAX_COLUMNS_IN_INDEX=98;
enum SQL_MAX_COLUMNS_IN_ORDER_BY=99;
enum SQL_MAX_COLUMNS_IN_SELECT=100;
enum SQL_MAX_COLUMNS_IN_TABLE=101;
enum SQL_MAX_CURSOR_NAME_LEN=31;
enum SQL_MAX_INDEX_SIZE=102;
enum SQL_MAX_MESSAGE_LENGTH=512;
enum SQL_MAX_ROW_SIZE=104;
enum SQL_MAX_SCHEMA_NAME_LEN=32;
enum SQL_MAX_STATEMENT_LEN=105;
enum SQL_MAX_TABLE_NAME_LEN=35;
enum SQL_MAX_TABLES_IN_SELECT=106;
enum SQL_MAX_USER_NAME_LEN=107;

enum SQL_MAXIMUM_CATALOG_NAME_LENGTH=SQL_MAX_CATALOG_NAME_LEN;
enum SQL_MAXIMUM_COLUMN_NAME_LENGTH=SQL_MAX_COLUMN_NAME_LEN;
enum SQL_MAXIMUM_COLUMNS_IN_GROUP_BY=SQL_MAX_COLUMNS_IN_GROUP_BY;
enum SQL_MAXIMUM_COLUMNS_IN_INDEX=SQL_MAX_COLUMNS_IN_INDEX;
enum SQL_MAXIMUM_COLUMNS_IN_ORDER_BY=SQL_MAX_COLUMNS_IN_ORDER_BY;
enum SQL_MAXIMUM_COLUMNS_IN_SELECT=SQL_MAX_COLUMNS_IN_SELECT;
enum SQL_MAXIMUM_CURSOR_NAME_LENGTH=SQL_MAX_CURSOR_NAME_LEN;
enum SQL_MAXIMUM_INDEX_SIZE=SQL_MAX_INDEX_SIZE;
enum SQL_MAXIMUM_ROW_SIZE=SQL_MAX_ROW_SIZE;
enum SQL_MAXIMUM_SCHEMA_NAME_LENGTH=SQL_MAX_SCHEMA_NAME_LEN;
enum SQL_MAXIMUM_STATEMENT_LENGTH=SQL_MAX_STATEMENT_LEN;
enum SQL_MAXIMUM_TABLES_IN_SELECT=SQL_MAX_TABLES_IN_SELECT;
enum SQL_MAXIMUM_USER_NAME_LENGTH=SQL_MAX_USER_NAME_LEN;

enum SQL_NC_HIGH=0;
enum SQL_NC_LOW=1;
enum SQL_NEED_DATA=99;
enum SQL_NO_NULLS=0;
enum SQL_NTS=-3;
enum LONG SQL_NTSL=-3;
enum SQL_NULL_COLLATION=85;
enum SQL_NULL_DATA=-1;
enum SQL_NULL_HDBC=0;
enum SQL_NULL_HENV=0;
enum SQL_NULL_HSTMT=0;
enum SQL_NULLABLE=1;
enum SQL_NULLABLE_UNKNOWN=2;
enum SQL_NUMERIC=2;
enum SQL_ORDER_BY_COLUMNS_IN_SELECT=90;
enum SQL_PC_PSEUDO=2;
enum SQL_PC_UNKNOWN=0;
enum SQL_REAL=7;
enum SQL_RESET_PARAMS=3;
enum SQL_ROLLBACK=1;
enum SQL_SCCO_LOCK=2;
enum SQL_SCCO_OPT_ROWVER=4;
enum SQL_SCCO_OPT_VALUES=8;
enum SQL_SCCO_READ_ONLY=1;
enum SQL_SCOPE_CURROW=0;
enum SQL_SCOPE_SESSION=2;
enum SQL_SCOPE_TRANSACTION=1;
enum SQL_SCROLL_CONCURRENCY=43;
enum SQL_SEARCH_PATTERN_ESCAPE=14;
enum SQL_SERVER_NAME=13;
enum SQL_SMALLINT=5;
enum SQL_SPECIAL_CHARACTERS=94;
enum SQL_STILL_EXECUTING=2;
//MACRO #define SQL_SUCCEEDED(rc) (((rc)&(~1))==0)

enum SQL_SUCCESS=0;
enum SQL_SUCCESS_WITH_INFO=1;

enum SQL_TC_ALL=2;
enum SQL_TC_DDL_COMMIT=3;
enum SQL_TC_DDL_IGNORE=4;
enum SQL_TC_DML=1;
enum SQL_TC_NONE=0;


enum SQL_TXN_CAPABLE=46;
enum SQL_TXN_ISOLATION_OPTION=72;
enum SQL_TXN_READ_COMMITTED=2;
enum SQL_TXN_READ_UNCOMMITTED=1;
enum SQL_TXN_REPEATABLE_READ=4;
enum SQL_TXN_SERIALIZABLE=8;

enum SQL_TRANSACTION_CAPABLE=SQL_TXN_CAPABLE;
enum SQL_TRANSACTION_ISOLATION_OPTION=SQL_TXN_ISOLATION_OPTION;
enum SQL_TRANSACTION_READ_COMMITTED=SQL_TXN_READ_COMMITTED;
enum SQL_TRANSACTION_READ_UNCOMMITTED=SQL_TXN_READ_UNCOMMITTED;
enum SQL_TRANSACTION_REPEATABLE_READ=SQL_TXN_REPEATABLE_READ;
enum SQL_TRANSACTION_SERIALIZABLE=SQL_TXN_SERIALIZABLE;

enum SQL_UNBIND=2;
enum SQL_UNKNOWN_TYPE=0;
enum SQL_USER_NAME=47;
enum SQL_VARCHAR=12;

static if (ODBCVER >= 0x0200) {
enum SQL_AT_ADD_COLUMN  = 1;
enum SQL_AT_DROP_COLUMN = 2;
}

static if (ODBCVER >= 0x0201) {
enum SQL_OJ_LEFT               =  1;
enum SQL_OJ_RIGHT              =  2;
enum SQL_OJ_FULL               =  4;
enum SQL_OJ_NESTED             =  8;
enum SQL_OJ_NOT_ORDERED        = 16;
enum SQL_OJ_INNER              = 32;
enum SQL_OJ_ALL_COMPARISON_OPS = 64;
}

static if (ODBCVER >= 0x0300) {
enum SQL_AM_CONNECTION=1;
enum SQL_AM_NONE=0;
enum SQL_AM_STATEMENT=2;
enum SQL_API_SQLALLOCHANDLE=1001;
enum SQL_API_SQLBINDPARAM=1002;
enum SQL_API_SQLCLOSECURSOR=1003;
enum SQL_API_SQLCOLATTRIBUTE=6;
enum SQL_API_SQLCOPYDESC=1004;
enum SQL_API_SQLENDTRAN=1005;
enum SQL_API_SQLFETCHSCROLL=1021;
enum SQL_API_SQLFREEHANDLE=1006;
enum SQL_API_SQLGETCONNECTATTR=1007;
enum SQL_API_SQLGETDESCFIELD=1008;
enum SQL_API_SQLGETDESCREC=1009;
enum SQL_API_SQLGETDIAGFIELD=1010;
enum SQL_API_SQLGETDIAGREC=1011;
enum SQL_API_SQLGETENVATTR=1012;
enum SQL_API_SQLGETSTMTATTR=1014;
enum SQL_API_SQLSETCONNECTATTR=1016;
enum SQL_API_SQLSETDESCFIELD=1017;
enum SQL_API_SQLSETDESCREC=1018;
enum SQL_API_SQLSETENVATTR=1019;
enum SQL_API_SQLSETSTMTATTR=1020;
enum SQL_ARD_TYPE=-99;
enum SQL_AT_ADD_CONSTRAINT=8;
enum SQL_ATTR_APP_PARAM_DESC=10011;
enum SQL_ATTR_APP_ROW_DESC=10010;
enum SQL_ATTR_AUTO_IPD=10001;
enum SQL_ATTR_CURSOR_SCROLLABLE=-1;
enum SQL_ATTR_CURSOR_SENSITIVITY=-2;
enum SQL_ATTR_IMP_PARAM_DESC=10013;
enum SQL_ATTR_IMP_ROW_DESC=10012;
enum SQL_ATTR_METADATA_ID=10014;
enum SQL_ATTR_OUTPUT_NTS=10001;
enum SQL_CATALOG_NAME=10003;
enum SQL_CODE_DATE=1;
enum SQL_CODE_TIME=2;
enum SQL_CODE_TIMESTAMP=3;
enum SQL_COLLATION_SEQ=10004;
enum SQL_CURSOR_SENSITIVITY=10001;
enum SQL_DATE_LEN=10;
enum SQL_DATETIME=9;
enum SQL_DEFAULT=99;

enum SQL_DESC_ALLOC_AUTO=1;
enum SQL_DESC_ALLOC_USER=2;
enum SQL_DESC_ALLOC_TYPE=1099;
enum SQL_DESC_COUNT=1001;
enum SQL_DESC_TYPE=1002;
enum SQL_DESC_LENGTH=1003;
enum SQL_DESC_OCTET_LENGTH_PTR=1004;
enum SQL_DESC_PRECISION=1005;
enum SQL_DESC_SCALE=1006;
enum SQL_DESC_DATETIME_INTERVAL_CODE=1007;
enum SQL_DESC_NULLABLE=1008;
enum SQL_DESC_INDICATOR_PTR=1009;
enum SQL_DESC_DATA_PTR=1010;
enum SQL_DESC_NAME=1011;
enum SQL_DESC_UNNAMED=1012;
enum SQL_DESC_OCTET_LENGTH=1013;

enum SQL_DESCRIBE_PARAMETER=10002;

enum SQL_DIAG_ALTER_DOMAIN=3;
enum SQL_DIAG_ALTER_TABLE=4;
enum SQL_DIAG_CALL=7;
enum SQL_DIAG_CLASS_ORIGIN=8;
enum SQL_DIAG_CONNECTION_NAME=10;
enum SQL_DIAG_CREATE_ASSERTION=6;
enum SQL_DIAG_CREATE_CHARACTER_SET=8;
enum SQL_DIAG_CREATE_COLLATION=10;
enum SQL_DIAG_CREATE_DOMAIN=23;
enum SQL_DIAG_CREATE_INDEX=-1;
enum SQL_DIAG_CREATE_SCHEMA=64;
enum SQL_DIAG_CREATE_TABLE=77;
enum SQL_DIAG_CREATE_TRANSLATION=79;
enum SQL_DIAG_CREATE_VIEW=84;
enum SQL_DIAG_DELETE_WHERE=19;
enum SQL_DIAG_DROP_ASSERTION=24;
enum SQL_DIAG_DROP_CHARACTER_SET=25;
enum SQL_DIAG_DROP_COLLATION=26;
enum SQL_DIAG_DROP_DOMAIN=27;
enum SQL_DIAG_DROP_INDEX=(-2);
enum SQL_DIAG_DROP_SCHEMA=31;
enum SQL_DIAG_DROP_TABLE=32;
enum SQL_DIAG_DROP_TRANSLATION=33;
enum SQL_DIAG_DROP_VIEW=36;
enum SQL_DIAG_DYNAMIC_DELETE_CURSOR=38;
enum SQL_DIAG_DYNAMIC_FUNCTION=7;
enum SQL_DIAG_DYNAMIC_FUNCTION_CODE=12;
enum SQL_DIAG_DYNAMIC_UPDATE_CURSOR=81;
enum SQL_DIAG_GRANT=48;
enum SQL_DIAG_INSERT=50;
enum SQL_DIAG_MESSAGE_TEXT=6;
enum SQL_DIAG_NATIVE=5;
enum SQL_DIAG_NUMBER=2;
enum SQL_DIAG_RETURNCODE=1;
enum SQL_DIAG_REVOKE=59;
enum SQL_DIAG_ROW_COUNT=3;
enum SQL_DIAG_SELECT_CURSOR=85;
enum SQL_DIAG_SERVER_NAME=11;
enum SQL_DIAG_SQLSTATE=4;
enum SQL_DIAG_SUBCLASS_ORIGIN=9;
enum SQL_DIAG_UNKNOWN_STATEMENT=0;
enum SQL_DIAG_UPDATE_WHERE=82;

enum SQL_FALSE=0;
enum SQL_HANDLE_DBC=2;
enum SQL_HANDLE_DESC=4;
enum SQL_HANDLE_ENV=1;
enum SQL_HANDLE_STMT=3;
enum SQL_INSENSITIVE=1;
enum SQL_MAX_CONCURRENT_ACTIVITIES=1;
enum SQL_MAX_DRIVER_CONNECTIONS=0;
enum SQL_MAX_IDENTIFIER_LEN=10005;
enum SQL_MAXIMUM_CONCURRENT_ACTIVITIES=SQL_MAX_CONCURRENT_ACTIVITIES;
enum SQL_MAXIMUM_DRIVER_CONNECTIONS=SQL_MAX_DRIVER_CONNECTIONS;
enum SQL_MAXIMUM_IDENTIFIER_LENGTH=SQL_MAX_IDENTIFIER_LEN;
enum SQL_NAMED=0;
enum SQL_NO_DATA=100;
enum SQL_NONSCROLLABLE=0;
enum SQL_NULL_HANDLE=0L;
enum SQL_NULL_HDESC=0;
enum SQL_OJ_CAPABILITIES=115;
enum SQL_OUTER_JOIN_CAPABILITIES=SQL_OJ_CAPABILITIES;
enum SQL_PC_NON_PSEUDO=1;

enum SQL_PRED_NONE=0;
enum SQL_PRED_CHAR=1;
enum SQL_PRED_BASIC=2;

enum SQL_ROW_IDENTIFIER=1;
enum SQL_SCROLLABLE=1;
enum SQL_SENSITIVE=2;
enum SQL_TIME_LEN=8;
enum SQL_TIMESTAMP_LEN=19;
enum SQL_TRUE=1;
enum SQL_TYPE_DATE=91;
enum SQL_TYPE_TIME=92;
enum SQL_TYPE_TIMESTAMP=93;
enum SQL_UNNAMED=1;
enum SQL_UNSPECIFIED=0;
enum SQL_XOPEN_CLI_YEAR=10000;
}//#endif /* ODBCVER >= 0x0300 */

extern (Windows) {
    deprecated {
        SQLRETURN SQLAllocConnect(SQLHENV, SQLHDBC*);
        SQLRETURN SQLAllocEnv(SQLHENV*);
        SQLRETURN SQLAllocStmt(SQLHDBC, SQLHSTMT*);
        SQLRETURN SQLError(SQLHENV, SQLHDBC, SQLHSTMT, SQLCHAR*, SQLINTEGER*, SQLCHAR*, SQLSMALLINT, SQLSMALLINT*);
        SQLRETURN SQLFreeConnect(SQLHDBC);
        SQLRETURN SQLFreeEnv(SQLHENV);
        SQLRETURN SQLSetParam(SQLHSTMT, SQLUSMALLINT, SQLSMALLINT, SQLSMALLINT, SQLULEN, SQLSMALLINT, SQLPOINTER, SQLLEN*);
        SQLRETURN SQLGetConnectOption(SQLHDBC, SQLUSMALLINT, SQLPOINTER);
        SQLRETURN SQLGetStmtOption(SQLHSTMT, SQLUSMALLINT, SQLPOINTER);
        SQLRETURN SQLSetConnectOption(SQLHDBC, SQLUSMALLINT, SQLULEN);
        SQLRETURN SQLSetStmtOption(SQLHSTMT, SQLUSMALLINT, SQLROWCOUNT);
    }
    SQLRETURN SQLBindCol(SQLHSTMT, SQLUSMALLINT, SQLSMALLINT, SQLPOINTER, SQLLEN, SQLLEN*);
    SQLRETURN SQLCancel(SQLHSTMT);
    SQLRETURN SQLConnect(SQLHDBC, SQLCHAR*, SQLSMALLINT, SQLCHAR*, SQLSMALLINT, SQLCHAR*, SQLSMALLINT);
    SQLRETURN SQLDescribeCol(SQLHSTMT, SQLUSMALLINT, SQLCHAR*, SQLSMALLINT, SQLSMALLINT*, SQLSMALLINT*, SQLULEN*, SQLSMALLINT*, SQLSMALLINT*);
    SQLRETURN SQLDisconnect(SQLHDBC);
    SQLRETURN SQLExecDirect(SQLHSTMT, SQLCHAR*, SQLINTEGER);
    SQLRETURN SQLExecute(SQLHSTMT);
    SQLRETURN SQLFetch(SQLHSTMT);
    SQLRETURN SQLFreeStmt(SQLHSTMT, SQLUSMALLINT);
    SQLRETURN SQLGetCursorName(SQLHSTMT, SQLCHAR*, SQLSMALLINT, SQLSMALLINT*);
    SQLRETURN SQLNumResultCols(SQLHSTMT, SQLSMALLINT*);
    SQLRETURN SQLPrepare(SQLHSTMT, SQLCHAR*, SQLINTEGER);
    SQLRETURN SQLRowCount(SQLHSTMT, SQLLEN*);
    SQLRETURN SQLSetCursorName(SQLHSTMT, SQLCHAR*, SQLSMALLINT);
    SQLRETURN SQLTransact(SQLHENV, SQLHDBC, SQLUSMALLINT);
    SQLRETURN SQLColumns(SQLHSTMT, SQLCHAR*, SQLSMALLINT, SQLCHAR*, SQLSMALLINT, SQLCHAR*, SQLSMALLINT, SQLCHAR*, SQLSMALLINT);
    SQLRETURN SQLGetData(SQLHSTMT, SQLUSMALLINT, SQLSMALLINT, SQLPOINTER, SQLLEN, SQLLEN*);
    SQLRETURN SQLGetFunctions(SQLHDBC, SQLUSMALLINT, SQLUSMALLINT*);
    SQLRETURN SQLGetInfo(SQLHDBC, SQLUSMALLINT, SQLPOINTER, SQLSMALLINT, SQLSMALLINT*);
    SQLRETURN SQLGetTypeInfo(SQLHSTMT, SQLSMALLINT);
    SQLRETURN SQLParamData(SQLHSTMT, SQLPOINTER*);
    SQLRETURN SQLPutData(SQLHSTMT, SQLPOINTER, SQLLEN);
    SQLRETURN SQLSpecialColumns(SQLHSTMT, SQLUSMALLINT, SQLCHAR*, SQLSMALLINT, SQLCHAR*, SQLSMALLINT, SQLCHAR*, SQLSMALLINT, SQLUSMALLINT, SQLUSMALLINT);
    SQLRETURN SQLStatistics(SQLHSTMT, SQLCHAR*, SQLSMALLINT, SQLCHAR*, SQLSMALLINT, SQLCHAR*, SQLSMALLINT, SQLUSMALLINT, SQLUSMALLINT);
    SQLRETURN SQLTables(SQLHSTMT, SQLCHAR*, SQLSMALLINT, SQLCHAR*, SQLSMALLINT, SQLCHAR*, SQLSMALLINT, SQLCHAR*, SQLSMALLINT);
    SQLRETURN SQLDataSources(SQLHENV, SQLUSMALLINT, SQLCHAR*, SQLSMALLINT, SQLSMALLINT*, SQLCHAR*, SQLSMALLINT, SQLSMALLINT*);

    static if (ODBCVER >= 0x0300) {
        SQLRETURN SQLAllocHandle(SQLSMALLINT, SQLHANDLE, SQLHANDLE*);
        SQLRETURN SQLBindParam(SQLHSTMT, SQLUSMALLINT, SQLSMALLINT, SQLSMALLINT, SQLULEN, SQLSMALLINT, SQLPOINTER, SQLLEN*);
        SQLRETURN SQLCloseCursor(SQLHSTMT);
        SQLRETURN SQLColAttribute(SQLHSTMT, SQLUSMALLINT, SQLUSMALLINT, SQLPOINTER, SQLSMALLINT, SQLSMALLINT*, SQLPOINTER);
        SQLRETURN SQLCopyDesc(SQLHDESC, SQLHDESC);
        SQLRETURN SQLEndTran(SQLSMALLINT, SQLHANDLE, SQLSMALLINT);
        SQLRETURN SQLFetchScroll(SQLHSTMT, SQLSMALLINT, SQLROWOFFSET);
        SQLRETURN SQLFreeHandle(SQLSMALLINT, SQLHANDLE);
        SQLRETURN SQLGetConnectAttr(SQLHDBC, SQLINTEGER, SQLPOINTER, SQLINTEGER, SQLINTEGER*);
        SQLRETURN SQLGetDescField(SQLHDESC, SQLSMALLINT, SQLSMALLINT, SQLPOINTER, SQLINTEGER, SQLINTEGER*);
        SQLRETURN SQLGetDescRec(SQLHDESC, SQLSMALLINT, SQLCHAR*, SQLSMALLINT, SQLSMALLINT*,
          SQLSMALLINT*, SQLSMALLINT*, SQLLEN*, SQLSMALLINT*, SQLSMALLINT*, SQLSMALLINT*);
        SQLRETURN SQLGetDiagField(SQLSMALLINT, SQLHANDLE, SQLSMALLINT, SQLSMALLINT, SQLPOINTER, SQLSMALLINT, SQLSMALLINT*);
        SQLRETURN SQLGetDiagRec(SQLSMALLINT, SQLHANDLE, SQLSMALLINT, SQLCHAR*, SQLINTEGER*, SQLCHAR*, SQLSMALLINT, SQLSMALLINT*);
        SQLRETURN SQLGetEnvAttr(SQLHENV, SQLINTEGER, SQLPOINTER, SQLINTEGER, SQLINTEGER*);
        SQLRETURN SQLGetStmtAttr(SQLHSTMT, SQLINTEGER, SQLPOINTER, SQLINTEGER, SQLINTEGER*);
        SQLRETURN SQLSetConnectAttr(SQLHDBC, SQLINTEGER, SQLPOINTER, SQLINTEGER);
        SQLRETURN SQLSetDescField(SQLHDESC, SQLSMALLINT, SQLSMALLINT, SQLPOINTER, SQLINTEGER);
        SQLRETURN SQLSetDescRec(SQLHDESC, SQLSMALLINT, SQLSMALLINT, SQLSMALLINT, SQLLEN, SQLSMALLINT,
            SQLSMALLINT, SQLPOINTER, SQLLEN*, SQLLEN*);
        SQLRETURN SQLSetEnvAttr(SQLHENV, SQLINTEGER, SQLPOINTER, SQLINTEGER);
        SQLRETURN SQLSetStmtAttr(SQLHSTMT, SQLINTEGER, SQLPOINTER, SQLINTEGER);
    }/* (ODBCVER >= 0x0300) */
}
