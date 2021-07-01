SPEED = sistema_speed
SPEED_TB = $(SPEED)_tb
SPEED_SYNTH = $(SPEED)_synth
SPEED_SYNTH_TB = $(SPEED_SYNTH)_tb


all: sim

# Install missing osu018 files
install:
	mkdir -p temp
	cd temp ;\
	git clone https://github.com/RTimothyEdwards/qflow.git ;\
	sudo cp qflow/tech/osu018/osu018_stdcells.gds2 /usr/share/qflow/tech/osu018/
	sudo chmod -x /usr/share/qflow/tech/osu018/osu018_stdcells.gds2
	rm -rf temp

# Prep qflow directories
prep:
	mkdir -p layout synthesis log

# Run qflow for speed system up until synthesis
synth-speed: prep
	qflow synthesize -T osu018 $(SPEED)
	rm -rf .magicrc sistema.par

# Run qflow for speed system up until placement
place-speed: synth-speed
	qflow place -T osu018 $(SPEED)

# Run qflow for speed system up until STA
sta-speed: place-speed
	qflow sta -T osu018 $(SPEED)

# Run all qflow steps for speed system and display 
# routed result
all-speed: prep
	qflow all -T osu018 $(SPEED)

# Generate behavioral sim for both systems
sim: sim-speed

# Generate behavioral sim for speed system
sim-speed:
	mkdir -p sim waves
	iverilog -o sim/$(SPEED_TB) test/$(SPEED_TB).v
	vvp sim/$(SPEED_TB)
	mv $(SPEED).vcd waves/$(SPEED).vcd

# Display behavioral waves for both systems
waves: waves-speed

# Display behavioral waves for speed system
waves-speed: sim-speed
	gtkwave waves/$(SPEED).vcd

# Generate behavioral and synth sim for both systems
sim-synth: sim-synth-speed

# Generate behavioral and synth sim for speed system
sim-synth-speed:
	mkdir -p sim waves
	sed -i 's/\bsistema_speed\b/sistema_speed_synth/g' synthesis/$(SPEED_SYNTH).rtlbb.v
	iverilog -I /usr/share/qflow/tech/osu018 -T typ -o sim/$(SPEED_SYNTH_TB) test/$(SPEED_SYNTH_TB).v
	vvp sim/$(SPEED_SYNTH_TB)
	mv $(SPEED_SYNTH).vcd waves/$(SPEED_SYNTH).vcd
	sed -i 's/\bsistema_speed_synth\b/sistema_speed/g' synthesis/$(SPEED_SYNTH).rtlbb.v

# Display behavioral and synth waves for both systems
waves-synth: waves-synth-speed

# Display behavioral and synth waves for speed system
waves-synth-speed: sim-synth-speed
	gtkwave waves/$(SPEED_SYNTH).vcd

# Clean workspace
clean: 
	qflow cleanup $(SPEED)
	rm -rf sim waves layout synthesis log source/*.ys source/*.blif *.sh *.magicrc