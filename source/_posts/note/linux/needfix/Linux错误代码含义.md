---
title: Linux错误代码含义
date: 2020-5-25
updated: 2020-5-26
categories:
  - note
abbrlink: f4b4ff58
---
# Linux错误代码含义



|       名称        |  值   |                    描述                    |
| :-------------: | :--: | :--------------------------------------: |
|      EPERM      |  1   |                  操作不允许                   |
|     ENOENT      |  2   |                 无此文件或目录                  |
|      ESRCH      |  3   |                   无此进程                   |
|      EINTR      |  4   |                  中断系统调用                  |
|       EIO       |  5   |                  I/O 错误                  |
|      ENXIO      |  6   |                 无此设备或地址                  |
|      E2BIG      |  7   |                  参数列表过长                  |
|     ENOEXEC     |  8   |                  执行文件错误                  |
|      EBADF      |  9   |                  错误的文件数                  |
|     ECHILD      |  10  |                   无子进程                   |
|     EAGAIN      |  11  |                  再尝试一下                   |
|     ENOMEM      |  12  |                   内存溢出                   |
|     EACCES      |  13  |                  要求被否定                   |
|     EFAULT      |  14  |                   错误地址                   |
|     ENOTBLK     |  15  |                  块设备请求                   |
|      EBUSY      |  16  |                 设备或者资源忙                  |
|     EEXIST      |  17  |                   文件存在                   |
|      EXDEV      |  18  |            Cross-device link             |
|     ENODEV      |  19  |                   无此设备                   |
|     ENOTDIR     |  20  |                 不是一个目录文件                 |
|     EISDIR      |  21  |                 I是一个目录文件                 |
|     EINVAL      |  22  |                  无效的参数                   |
|     ENFILE      |  23  |                  文件表溢出                   |
|     EMFILE      |  24  |                  打开文件过多                  |
|     ENOTTY      |  25  |                不是一个TTY设备                 |
|     ETXTBSY     |  26  |                   文件忙                    |
|      EFBIG      |  27  |                   文件过大                   |
|     ENOSPC      |  28  |                此设备上没有空间了                 |
|     ESPIPE      |  29  |                  无效的偏移                   |
|      EROFS      |  30  |                  只读文件系统                  |
|     EMLINK      |  31  |                   链接过多                   |
|      EPIPE      |  32  |                  错误的管道                   |
|      EDOM       |  33  |       Math argument out of domain        |
|     ERANGE      |  34  |      Math result not representable       |
|     EDEADLK     |  35  |      Resource deadlock would occur       |
|  ENAMETOOLONG   |  36  |                  文件名过长                   |
|     ENOLCK      |  37  |        No record locks available         |
|     ENOSYS      |  38  |                  函数没有实现                  |
|    ENOTEMPTY    |  39  |                   目录非空                   |
|      ELOOP      |  40  |   Too many symbolic links encountered    |
|   EWOULDBLOCK   |  41  |              Same as EAGAIN              |
|     ENOMSG      |  42  |        No message of desired type        |
|      EIDRM      |  43  |            Identifier removed            |
|     ECHRNG      |  44  |       Channel number out of range        |
|    EL2NSYNC     |  45  |         Level 2 not synchronized         |
|     EL3HLT      |  46  |              Level 3 halted              |
|     EL3RST      |  47  |              Level 3 reset               |
|     ELNRNG      |  48  |         Link number out of range         |
|     EUNATCH     |  49  |       Protocol driver not attached       |
|     ENOCSI      |  50  |        No CSI structure available        |
|     EL2HLT      |  51  |              Level 2 halted              |
|      EBADE      |  52  |             Invalid exchange             |
|      EBADR      |  53  |        Invalid request descriptor        |
|     EXFULL      |  54  |              Exchange full               |
|     ENOANO      |  55  |                 No anode                 |
|     EBADRQC     |  56  |           Invalid request code           |
|     EBADSLT     |  57  |               Invalid slot               |
|    EDEADLOCK    |  ?-  |             Same as EDEADLK              |
|     EBFONT      |  59  |           Bad font file format           |
|     ENOSTR      |  60  |           Device not a stream            |
|     ENODATA     |  61  |            No data available             |
|      ETIME      |  62  |              Timer expired               |
|      ENOSR      |  63  |         Out of streams resources         |
|     ENONET      |  64  |      Machine is not on the network       |
|     ENOPKG      |  65  |          Package not installed           |
|     EREMOTE     |  66  |             Object is remote             |
|     ENOLINK     |  67  |          Link has been severed           |
|      EADV       |  68  |             Advertise error              |
|     ESRMNT      |  69  |              Srmount error               |
|      ECOMM      |  70  |       Communication error on send        |
|     EPROTO      |  71  |              Protocol error              |
|    EMULTIHOP    |  72  |            Multihop attempted            |
|     EDOTDOT     |  73  |            RFS specific error            |
|     EBADMSG     |  74  |            Not a data message            |
|    EOVERFLOW    |  75  |  Value too large for defined data type   |
|    ENOTUNIQ     |  76  |        Name not unique on network        |
|     EBADFD      |  77  |       File descriptor in bad state       |
|     EREMCHG     |  78  |          Remote address changed          |
|     ELIBACC     |  79  |  Cannot access a needed shared library   |
|     ELIBBAD     |  80  |   Accessing a corrupted shared library   |
|     ELIBSCN     |  81  |  A .lib section in an .out is corrupted  |
|     ELIBMAX     |  82  |   Linking in too many shared libraries   |
|    ELIBEXEC     |  83  |  Cannot exec a shared library directly   |
|     EILSEQ      |  84  |          Illegal byte sequence           |
|    ERESTART     |  85  | Interrupted system call should be restarted |
|    ESTRPIPE     |  86  |            Streams pipe error            |
|     EUSERS      |  87  |              Too many users              |
|    ENOTSOCK     |  88  |      Socket operation on non-socket      |
|  EDESTADDRREQ   |  89  |       Destination address required       |
|    EMSGSIZE     |  90  |             Message too long             |
|   EPROTOTYPE    |  91  |      Protocol wrong type for socket      |
|   ENOPROTOOPT   |  92  |          Protocol not available          |
| EPROTONOSUPPORT |  93  |          Protocol not supported          |
| ESOCKTNOSUPPORT |  94  |        Socket type not supported         |
|   EOPNOTSUPP    |  95  |   Operation not supported on transport   |
|  EPFNOSUPPORT   |  96  |      Protocol family not supported       |
|  EAFNOSUPPORT   |  97  | Address family not supported by protocol |
|   EADDRINUSE    |  98  |          Address already in use          |
|  EADDRNOTAVAIL  |  99  |     Cannot assign requested address      |
|    ENETDOWN     | 100  |             Network is down              |
|   ENETUNREACH   | 101  |          Network is unreachable          |
|    ENETRESET    | 102  |             Network dropped              |
|  ECONNABORTED   | 103  |        Software caused connection        |
|   ECONNRESET    | 104  |           Connection reset by            |
|     ENOBUFS     | 105  |        No buffer space available         |
|     EISCONN     | 106  |            Transport endpoint            |
|    ENOTCONN     | 107  |            Transport endpoint            |
|    ESHUTDOWN    | 108  |       Cannot send after transport        |
|  ETOOMANYREFS   | 109  |           Too many references            |
|    ETIMEDOUT    | 110  |             Connection timed             |
|  ECONNREFUSED   | 111  |            Connection refused            |
|    EHOSTDOWN    | 112  |               Host is down               |
|  EHOSTUNREACH   | 113  |             No route to host             |
|    EALREADY     | 114  |            Operation already             |
|   EINPROGRESS   | 115  |             Operation now in             |
|     ESTALE      | 116  |          Stale NFS file handle           |
|     EUCLEAN     | 117  |         Structure needs cleaning         |
|     ENOTNAM     | 118  |            Not a XENIX-named             |
|     ENAVAIL     | 119  |           No XENIX semaphores            |
|     EISNAM      | 120  |           Is a named type file           |
|    EREMOTEIO    | 121  |             Remote I/O error             |
|     EDQUOT      | 122  |              Quota exceeded              |
|    ENOMEDIUM    | 123  |             No medium found              |
|   EMEDIUMTYPE   | 124  |            Wrong medium type             |