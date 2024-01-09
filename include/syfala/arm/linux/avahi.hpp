#pragma once

#include <avahi-client/client.h>
#include <avahi-client/publish.h>
#include <avahi-client/lookup.h>
#include <avahi-common/error.h>
#include <avahi-common/malloc.h>
#include <avahi-common/thread-watch.h>
#include <avahi-common/timeval.h>
#include <avahi-common/simple-watch.h>
#include <stdio.h>
#include <thread>

namespace avahi {

using client = AvahiClient;
using client_state = AvahiClientState;
using simple_poll = AvahiSimplePoll;
using entry_group = AvahiEntryGroup;
using entry_group_state = AvahiEntryGroupState;
using service_browser = AvahiServiceBrowser;

#define AVAHI_SERVICE_TYPE "_faust._tcp";

struct service {
    simple_poll* poll  = nullptr;
    entry_group* group = nullptr;
    avahi::client* client = nullptr;
    const char* name = "syfala";
    const char* type = "_syfala._tcp";
    std::thread thread;
    unsigned short port = 5510;    
    bool running = false;
};

static void group_callback(entry_group* g, entry_group_state state, void* u) {
    switch(state) {
    case AVAHI_ENTRY_GROUP_REGISTERING:
    case AVAHI_ENTRY_GROUP_ESTABLISHED:
    case AVAHI_ENTRY_GROUP_UNCOMMITED:
        break;
    case AVAHI_ENTRY_GROUP_COLLISION: {
        printf("[avahi] entry group collision!\n");
    }
    case AVAHI_ENTRY_GROUP_FAILURE: {
        printf("[avahi] entry group failure\n");
    }
    }

}

static void client_callback(client* c, client_state state, void* u) {
   service* s = (service*)(u);
   switch (state) {
   case AVAHI_CLIENT_CONNECTING:
   case AVAHI_CLIENT_S_REGISTERING:
       break;
   case AVAHI_CLIENT_S_RUNNING: {
       if (!s->group) {
            s->group = avahi_entry_group_new(c, group_callback, s);
       }
       if (avahi_entry_group_is_empty(s->group)) {
           int err = avahi_entry_group_add_service(
                       s->group,
                       AVAHI_IF_UNSPEC,
                       AVAHI_PROTO_INET,
                       (AvahiPublishFlags)(0),
                       s->name, s->type,
                       nullptr, nullptr, s->port, nullptr
           );
           if (err) {
               printf("[avahi] failed to add service: %s\n",
                      avahi_strerror(err));
           }
           if ((err = avahi_entry_group_commit(s->group))) {
               printf("[avahi] failed to commit group: %s\n",
                      avahi_strerror(err));
           } else {
               printf("[avahi] entry_group committed\n");
           }
       }
       break;
   }
   case AVAHI_CLIENT_FAILURE: {
       printf("[avahi] client failure\n");
   }
   case AVAHI_CLIENT_S_COLLISION: {
       printf("[avahi] client collision\n");
   }
   }
}

static void poll(service* s) {
    printf("[avahi] polling service\n");
    while (s->running) {
        avahi_simple_poll_iterate(s->poll, 200);
    }
}

inline void initialize_run(avahi::service& s) {
    int err = 0;
    s.poll = avahi_simple_poll_new();
    s.client = avahi_client_new(
        avahi_simple_poll_get(s.poll),
        static_cast<AvahiClientFlags>(0),
        client_callback,
        &s, &err
    );
    if (err) {
        // memo -26 = daemon not running
        // with systemd, just do 'systemctl enable avahi-daemon.service'
        printf("[avahi] error creating new client: %d (%s)",
               err, avahi_strerror(err));
    } else {
        printf("[avahi] starting thread...\n");
        s.running = true;
        s.thread = std::thread(avahi::poll, &s);
    }
}
}

