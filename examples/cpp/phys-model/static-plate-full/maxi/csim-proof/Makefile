
SOURCES += main.cpp
SOURCES += Filter.cpp
OUTPUT := static-plate-modes

all: $(SOURCES)
	clang++-14 -O3 -ffast-math $(SOURCES) -o $(OUTPUT)
	./$(OUTPUT)
