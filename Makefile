build: build-speed

build-speed:
	mkdir -p build
	mkdir -p waves
	iverilog -o build/testbench src/hash_speed/testbench.v
	vvp build/testbench
	mv hash_speed.vcd waves/hash_speed.vcd

all: 
	build

waves: waves-speed

waves-speed: build-speed
	gtkwave waves/hash_speed.vcd

clean: 
	rm -rf build
	rm -rf waves