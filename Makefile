SPEED = sistema_speed
SPEED_TB = $(SPEED)_tb

all: sim

synth-speed:
	mkdir -p layout synthesis log
	qflow synthesize -T osu018 $(SPEED)
	qflow cleanup $(SPEED)
	rm -rf .magicrc sistema.par

sim: sim-speed

sim-speed:
	mkdir -p sim waves
	iverilog -o sim/$(SPEED_TB) test/$(SPEED_TB).v
	vvp sim/$(SPEED_TB)
	mv $(SPEED).vcd waves/$(SPEED).vcd

waves: waves-speed

waves-speed: sim-speed
	gtkwave waves/$(SPEED).vcd

clean: 
	rm -rf sim waves layout synthesis log source/*.ys *.sh *.magicrc