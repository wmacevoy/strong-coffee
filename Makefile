# make        build the machine into build/coffee
# make test   build it and run the tests
# make safe   build it with the sanitizers watching memory and arithmetic, and shake it: random
#             commands from ten seeds. Prints "safe: PASS" when nothing was caught.
CXX ?= c++
CXXFLAGS ?= -std=c++17 -O1 -g -Wall
SANITIZE = -fsanitize=address,undefined -fno-sanitize-recover=all

build/coffee: src/machine.cpp src/strong/*.h
	mkdir -p build
	$(CXX) $(CXXFLAGS) -Isrc -o $@ src/machine.cpp

build/coffee-safe: src/machine.cpp src/strong/*.h
	mkdir -p build
	$(CXX) $(CXXFLAGS) $(SANITIZE) -Isrc -o $@ src/machine.cpp

test: build/coffee
	sh tests/run.sh build/coffee

safe: build/coffee-safe
	sh tests/safe.sh build/coffee-safe

.PHONY: test safe
