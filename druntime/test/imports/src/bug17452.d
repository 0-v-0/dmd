import core.sys.windows.winsock2;

version (Windows)
{
    static assert(FD_READ_BIT == 0);
    static assert(FD_CONNECT_BIT == 4);
    static assert(FD_MAX_EVENTS == 10);
    static assert(FD_CONNECT == 1 << FD_CONNECT_BIT);
    static assert(FD_ALL_EVENTS == (1 << FD_MAX_EVENTS) - 1);
    static assert(AF_BTH == 32);
    static assert(SO_GROUP_ID == 0x2001);
    static assert(IPPROTO_ICMPV6 == 58);
    static assert(MSG_PARTIAL == 0x8000);
    static assert(SIO_GET_QOS == (IOC_INOUT | IOC_WS2 | 7));
    static assert(SOCK_NOTIFY_EVENTS_ALL == 0xC7);
}
