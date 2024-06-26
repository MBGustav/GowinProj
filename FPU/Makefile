GOWIN_PACK ?= $(HOME)/.local/bin/gowin_pack
BOARD=tangnano9k
FAMILY=GW1N-9C
MKDIR=mkdir -p
DEVICE=GW1NR-LV9QN88PC6/I5

PROJECT=top

# VERILOG_FILES := $(wildcard *.v)
TEST_PROJECT= FPU


all: ${PROJECT}.fs

# Synthesis
${PROJECT}.json: config_devices/GW1N-9C-dyn.vh ${VERILOG_FILES} 
	yosys -p "read_verilog $^ ; synth_gowin -top ${PROJECT} -json ${PROJECT}.json"

# Place and Route
${PROJECT}_pnr.json: ${PROJECT}.json
	nextpnr-gowin --json ${PROJECT}.json --freq 27 --write ${PROJECT}_pnr.json --device ${DEVICE} --family ${FAMILY} --cst ${BOARD}.cst

# Generate Bitstream
# ${GOWIN_PACK} -d ${FAMILY} -o ${PROJECT}.fs ${PROJECT}_pnr.json
${PROJECT}.fs: ${PROJECT}_pnr.json
	${GOWIN_PACK} --sspi_as_gpio --mspi_as_gpio -d ${FAMILY} -o $@ $^

# Program Board
load: ${PROJECT}.fs
	openFPGALoader -b ${BOARD} ${PROJECT}.fs -f


bin/${TEST_PROJECT}_tb.vvp: tb/${TEST_PROJECT}_tb.v
	iverilog -o bin/${TEST_PROJECT}_tb.vvp tb/${TEST_PROJECT}_tb.v -I rtl/ 

testbench :bin/${TEST_PROJECT}_tb.vvp
	vvp -n bin/${TEST_PROJECT}_tb.vvp -l-

clean_tb : 
	rm bin/${TEST_PROJECT}_tb.vvp

.PHONY: load testbench
.INTERMEDIATE: ${PROJECT}_pnr.json ${PROJECT}.json bin/${TEST_PROJECT}_tb.vvp