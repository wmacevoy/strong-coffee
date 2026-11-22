# make        build the machine into build/coffee
# make test   build it and run the tests
CXX ?= c++
CXXFLAGS ?= -std=c++17 -O1 -g -Wall

build/coffee: coffee.cpp
	mkdir -p build
	$(CXX) $(CXXFLAGS) -o $@ coffee.cpp

test: build/coffee
	sh tests/run.sh build/coffee

.PHONY: test
