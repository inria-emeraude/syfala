#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <assert.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <proc/readproc.h>
#include <proc/procps.h>

static void kill_running_processes(void) {
    proc_t proc_info;
    PROCTAB* proc = openproc(
        PROC_FILLMEM        |
        PROC_FILLSTAT       |
        PROC_FILLSTATUS
    );
    memset(&proc_info, 0, sizeof(proc_info));
    while (readproc(proc, &proc_info) != NULL) {
        if (strcmp(proc_info.cmd, "application.elf") == 0) {
            char cmd[16];
            sprintf(cmd, "kill %d", proc_info.tid);
            printf("%s\n", cmd);
            system(cmd);
        }
    }
}

static void print_usage() {
    printf("usage: syfala-load [<target>|<cmd>] \n"
           "--no-reset: don't reset audio codec\n"
           "-l | --list: lists all available targets\n"
           "-h | --help: displays this :P\n"
    );
}

static inline int is_directory(const char* path) {
    if (strcmp(path, ".") == 0 || strcmp(path, "..") == 0) {
        return 0;
    } else {
        struct stat spath;
        stat(path, &spath);
        return S_ISDIR(spath.st_mode);
    }
}

static void list_available_targets(void) {
    struct dirent* sd;
    DIR* d;
    d = opendir("/home/syfala");
    if (d) {
        while ((sd = readdir(d)) != NULL) {
            if (is_directory(sd->d_name)) {
                printf("- %s\n", sd->d_name);
            }
        }
        closedir(d);
    }
}

static inline int file_exists(const char* f) {
    return access(f, F_OK) == 0;
}

static void parse_load_target(const char* target, const char* arguments) {
    char bin[128], app[128], cmd[256]; int err;
    sprintf(bin, "/home/syfala/%s/bitstream.bin", target);
    sprintf(app, "/home/syfala/%s/application.elf", target);
    // Load .bin format bitstream
    if (file_exists(bin)) {
        // kill running processes first, otherwise it will
        // result in a freeze
        kill_running_processes();
        sleep(1);
        printf("Loading bitstream: %s\n", bin);
        sprintf(cmd, "fpgautil -b %s", bin);
        if ((err = system(cmd))) {
            exit(err);
        } else {
            printf("bitstream successfully loaded.\n");
        }
    } else {
        printf("File: %s does not exist, aborting...\n", bin);
        exit(1);
    }
    // Execute .elf format application
    if (file_exists(app)) {
        printf("Executing application: %s\n", app);
        if (arguments) {
            sprintf(app, "/home/syfala/%s/application.elf %s", target, arguments);
            printf("%s\n", app);
        }
        if ((err = system(app))) {
            exit(err);
        }
    } else {
        printf("File: %s does not exist, aborting...\n", app);
        exit(1);
    }
}

static inline int isopt(int argc, const char* argv[], const char* t, const char* tfull) {
    for (int n = 0; n < argc; ++n) {
         if (strcmp(argv[n], t) == 0 || strcmp(argv[n], tfull) == 0) {
             return 1;
         }
    }
    return 0;
}

int main(int argc, char* argv[])
{
    const char* target = argv[1];
    if (isopt(argc, argv, "-l", "--list")) {
        list_available_targets();
    } else if (isopt(argc, argv, "-h", "--help")) {
        print_usage();
    } else if (isopt(argc, argv, "-r", "--no-reset")) {
        printf("NO RESET\n");
        parse_load_target(target, "--no-reset");
    } else {
        parse_load_target(target, NULL);
    }
    return 0;
}
