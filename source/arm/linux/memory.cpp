#include <syfala/arm/memory.hpp>
#include <syfala/utilities.hpp>
#include <sys/mman.h>

#define FRAME_BUFFER_BASE_ADDR  0x35000000
#define FRAME_BUFFER_LEN        0x08000000

using namespace Syfala;

static size_t memlen(unsigned int izone,
                     unsigned int fzone) {
    size_t mlen =
            izone * sizeof(int)
          + fzone * sizeof(float);
    assert(mlen < (size_t) FRAME_BUFFER_LEN);
    return mlen;
}

static int* get_reserved_addr(unsigned int izone,
                              unsigned int fzone) {
    off_t off  = FRAME_BUFFER_BASE_ADDR;
    int fd   = open("/dev/mem", O_RDWR | O_SYNC);
    auto map = mmap(NULL, FRAME_BUFFER_LEN,
                    PROT_READ | PROT_WRITE,
                     MAP_FILE | MAP_SHARED,
                     fd, off);
    if (map == MAP_FAILED) {
        perror("[mem] Can't map reserved memory space");
        exit(1);
    } else {
        size_t len = memlen(izone, fzone);
        memset(map, 0, len);
        printf("[mem] Reserved: %ld bytes from DDR memory\n", len);
        return (int*) map;
    }
}

void Memory::initialize(XSyfala& x, data& d, int ilen, int flen) {
    d.i_zone = get_reserved_addr(ilen, flen);
    d.f_zone = reinterpret_cast<float*>(d.i_zone + ilen);
    IP::set_mem_zone_i(&x, FRAME_BUFFER_BASE_ADDR);
    IP::set_mem_zone_f(&x, FRAME_BUFFER_BASE_ADDR + (ilen * sizeof(int)));
    sy_printf("[mem] Memory successfully initialized.");
}
