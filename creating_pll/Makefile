GOWIN_PACK ?= /home/gustav/.local/bin/gowin_pack
BOARD=tangnano9k
FAMILY=GW1N-9C
MKDIR=mkdir -p
DEVICE=GW1NR-LV9QN88PC6/I5

PROJECT=top

# VERILOG_FILES := $(wildcard *.v)
VERILOG_FILES=	top.v 

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

debug:  dbg/${PROJECT}_tb.v
	 iverilog -o design.vpp dbg/top_tb.v sdpll.v top.v 
	 vvp design.vpp
	 gtkwave design.vpp


.PHONY: load
.INTERMEDIATE: ${PROJECT}_pnr.json ${PROJECT}.json