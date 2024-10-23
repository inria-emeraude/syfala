
BUILD_DIR = build
OUTPUT_DIR = ..
EXECUTABLE = $(OUTPUT_DIR)/application.elf
INCLUDES = -Iinclude -I.
CC = g++
CXXFLAGS += -O3
CXXFLAGS += -DALPINE

LDFLAGS += -lHTTPDFaust 
LDFLAGS += -lOSCFaust 
LDFLAGS += -llo 
LDFLAGS += -lmicrohttpd 
LDFLAGS += -lasound 
LDFLAGS += -lavahi-client 
LDFLAGS += -lavahi-common 
LDFLAGS += -lgpiod 
LDFLAGS += -liio

CXX_SOURCES := $(wildcard *.cpp)
CXX_OBJECTS := $(CXX_SOURCES:%.cpp=%.o)
C_SOURCES := $(wildcard *.c)
C_OBJECTS := $(C_SOURCES:%.c=%.o)

OBJECTS := $(C_OBJECTS) $(CXX_OBJECTS)
BUILT_OBJECTS := $(addprefix $(BUILD_DIR)/,$(OBJECTS))

$(EXECUTABLE): $(BUILT_OBJECTS)
	$(CC) $(BUILT_OBJECTS) $(LDFLAGS) -o $@

$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CC) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

clean:
	@rm -rf $(BUILD_DIR)
	@rm -rf $(EXECUTABLE)
