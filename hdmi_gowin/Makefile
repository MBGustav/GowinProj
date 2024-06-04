GOWIN_PACK ?= $(HOME)/.local/bin/gowin_pack
BOARD=tangnano9k
FAMILY=GW1N-9C
MKDIR=mkdir -p
DEVICE=GW1NR-LV9QN88PC6/I5

PROJECT=top

VERILOG_FILES := $(wildcard *.v)
# VERILOG_FILES=	top.v				\
# 				display_signal.v  	\
# 				hdmi.v				\
# 				test_RAM.v			\
# 				Gowin_rPLL.v		\
# 				clock_div.v
# TMDS_Encoder_test.v 

all: ${PROJECT}.fs

# Synthesis
${PROJECT}.json: ../config_devices/${FAMILY}-dyn.vh ${VERILOG_FILES} 
	yosys -p "read_verilog $^ ; synth_gowin -top ${PROJECT} -json ${PROJECT}.json"


# Place and Route
${PROJECT}_pnr.json: ${PROJECT}.json
	nextpnr-gowin --json   ${PROJECT}.json --freq 27  \
				  --write  ${PROJECT}_pnr.json        \
				  --device ${DEVICE}                  \
				  --family ${FAMILY}                  \
				  --cst ../config_devices/${BOARD}.cst


# Generate Bitstream
${PROJECT}.fs: ${PROJECT}_pnr.json
		${GOWIN_PACK} --sspi_as_gpio --mspi_as_gpio -d ${FAMILY} -o $@ $^


# Unpack IP Program
${PROJECT}-unpack.v: ${PROJECT}.fs
	gowin_unpack -d GW1N-9C -o $@ $^


# Program Board
load: ${PROJECT}.fs
	openFPGALoader -b ${BOARD} ${PROJECT}.fs -f

debug:  dbg/${PROJECT}_tb.v
	iverilog -o design.vpp dbg/top_tb.v sdpll.v top.v 
	vvp design.vpp
	gtkwave design.vpp


.PHONY: load
.INTERMEDIATE: ${PROJECT}_pnr.json ${PROJECT}.json