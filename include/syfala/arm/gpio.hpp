#pragma once

namespace Syfala::GPIO {
    extern void initialize();
    extern int read_sw3();
}

namespace Syfala::Status {
    extern void waiting(const char* message);
    extern void warning(const char* message);
    extern void error(const char* message);
    extern void fatal(const char* message, int err = 1);
    extern void ok(const char* message);
}
