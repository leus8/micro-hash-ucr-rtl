SPEED = sistema_speed
SPEED_TB = $(SPEED)_tb
SPEED_SYNTH = $(SPEED)_synth
SPEED_SYNTH_TB = $(SPEED_SYNTH)_tb

AREA = sistema_area
AREA_TB = $(AREA)_tb
AREA_SYNTH = $(AREA)_synth
AREA_SYNTH_TB = $(AREA_SYNTH)_tb

HCELL = heatmaps/cell


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

# Run qflow for area system up until synthesis
synth-area: prep
	qflow synthesize -T osu018 $(AREA)
	rm -rf .magicrc sistema.par

# Run qflow for speed system up until placement
place-speed: synth-speed
	qflow place -T osu018 $(SPEED)

# Run qflow for area system up until placement
place-area: synth-area
	qflow place -T osu018 $(AREA)

# Run qflow for speed system up until STA
sta-speed: place-speed
	qflow sta -T osu018 $(SPEED)

# Run qflow for area system up until STA
sta-area: place-area
	qflow sta -T osu018 $(AREA)

# Run all qflow steps for speed system and display 
# routed result
all-speed: prep
	qflow all -T osu018 $(SPEED)

# Run all qflow steps for area system and display 
# routed result
all-area: prep
	qflow all -T osu018 $(AREA)

# Generate behavioral sim for both systems
sim: sim-speed sim-area

# Generate behavioral sim for speed system
sim-speed:
	mkdir -p sim waves
	iverilog -o sim/$(SPEED_TB) test/$(SPEED_TB).v
	vvp sim/$(SPEED_TB)
	mv $(SPEED).vcd waves/$(SPEED).vcd

# Generate behavioral sim for speed system
sim-area:
	mkdir -p sim waves
	iverilog -o sim/$(AREA_TB) test/$(AREA_TB).v
	vvp sim/$(AREA_TB)
	mv $(AREA).vcd waves/$(AREA).vcd

# Display behavioral waves for both systems
waves: waves-speed waves-area

# Display behavioral waves for speed system
waves-speed: sim-speed
	gtkwave waves/$(SPEED).vcd

# Display behavioral waves for area system
waves-area: sim-area
	gtkwave waves/$(AREA).vcd

# Generate behavioral and synth sim for both systems
sim-synth: sim-synth-speed sim-synth-area

# Generate behavioral and synth sim for speed system
sim-synth-speed:
	mkdir -p sim waves
	mv synthesis/$(SPEED).rtlnopwr.v synthesis/$(SPEED_SYNTH).rtlnopwr.v
	sed -i 's/\bsistema_speed\b/sistema_speed_synth/g' synthesis/$(SPEED_SYNTH).rtlnopwr.v
	iverilog -I /usr/share/qflow/tech/osu018 -T typ -o sim/$(SPEED_SYNTH_TB) test/$(SPEED_SYNTH_TB).v
	vvp sim/$(SPEED_SYNTH_TB)
	mv $(SPEED_SYNTH).vcd waves/$(SPEED_SYNTH).vcd
	sed -i 's/\bsistema_speed_synth\b/sistema_speed/g' synthesis/$(SPEED_SYNTH).rtlnopwr.v
	mv synthesis/$(SPEED_SYNTH).rtlnopwr.v synthesis/$(SPEED).rtlnopwr.v

# Generate behavioral and synth sim for area system
sim-synth-area:
	mkdir -p sim waves
	sed -i 's/\bsistema_area\b/sistema_area_synth/g' synthesis/$(AREA_SYNTH).rtlnopwr.v
	iverilog -I /usr/share/qflow/tech/osu018 -T typ -o sim/$(AREA_SYNTH_TB) test/$(AREA_SYNTH_TB).v
	vvp sim/$(AREA_SYNTH_TB)
	mv $(AREA_SYNTH).vcd waves/$(AREA_SYNTH).vcd
	sed -i 's/\bsistema_area_synth\b/sistema_area/g' synthesis/$(AREA_SYNTH).rtlnopwr.v

# Display behavioral and synth waves for both systems
waves-synth: waves-synth-speed sim-synth-area

# Display behavioral and synth waves for speed system
waves-synth-speed: sim-synth-speed
	gtkwave waves/$(SPEED_SYNTH).vcd

# Display behavioral and synth waves for area system
waves-synth-area: sim-synth-area
	gtkwave waves/$(AREA_SYNTH).vcd

# Generate cell density heatmap for area system
heatmap-cell-area:
	touch -c $(AREA)_coordinates.csv
	sed -n -e '/COMPONENTS.*;/,/END COMPONENTS/ p' layout/$(AREA).def > $(HCELL)/$(AREA)_coordinates.csv
	sed -i '/- FILL/ d' $(HCELL)/$(AREA)_coordinates.csv
	sed -i '1d;$d' $(HCELL)/$(AREA)_coordinates.csv
	sed -i 's/.*( \(.*\) ).*/\1/' $(HCELL)/$(AREA)_coordinates.csv
	sed -i 's/ /,/' $(HCELL)/$(AREA)_coordinates.csv
	sed -i '1 i\x,y' $(HCELL)/$(AREA)_coordinates.csv

# Clean workspace
clean: 
	qflow cleanup $(SPEED)
	qflow cleanup $(AREA)
	rm -rf sim waves layout synthesis log source/*.ys source/*.blif *.sh *.magicrc test/sistema_formal