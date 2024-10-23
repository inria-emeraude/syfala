#pragma once

#include <string>
#include <vector>
#include <fstream>
#include <cassert>

#define SYFALA_NUM_INPUTS 2
#define SYFALA_NUM_OUTPUTS 2
#define SYFALA_NCONTROLS_F 0
#define SYFALA_NCONTROLS_I 0
#define SYFALA_NCONTROLS_P 0
#define SYFALA_NMEM_F 0
#define SYFALA_NMEM_I 0

namespace Syfala {
namespace CSIM {

static std::string
get_file_path(const char* argv, const char* filename, int n) {
    char file[32];
    std::string path = argv;
    sprintf(file, "/%s%d.txt", filename, n);
    path += file;
    return path;
}

template<typename T>
static std::vector<T> get_fstreams (
        const char* argv,
        const char* pattern,
                int N
){
    char file[32];
    std::vector<T> res;
    for (int n = 0; n < N; ++n) {
        std::string path = get_file_path(argv, pattern, n);
        res.emplace_back(path);
        assert(res.back().is_open());
    }
    return res;
}

} // CSIM
} // Syfala
