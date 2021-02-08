.PHONY: all clean web

BOARDS = mPCIe-GNSS mPCIe-GNSS-panel
BOARDSFILES = $(addprefix build/, $(BOARDS:=.kicad_pcb))
SCHFILES = $(addprefix build/, $(BOARDS:=.sch))
GERBERS = $(addprefix build/, $(BOARDS:=-gerber.zip))
JLCGERBERS = $(addprefix build/, $(BOARDS:=-jlcpcb.zip))
JLCIGNORE = U1,PC1,J1,J2,BAT1
GITREPO = https://github.com/neg2led/mpcie-lea-m8t.git

RADIUS=0.75

all: $(GERBERS) $(JLCGERBERS) build/web/index.html

build/mPCIe-GNSS.kicad_pcb: mPCIe-GNSS/mPCIe-GNSS.kicad_pcb build
	kikit panelize extractboard -s 125 75 30 50.95 $< $@

build/mPCIe-GNSS.sch: mPCIe-GNSS/mPCIe-GNSS.sch build
	cp $< $@

build/mPCIe-GNSS-panel.kicad_pcb: build/mPCIe-GNSS.kicad_pcb
	kikit panelize grid --space 3 --gridsize 1 2 \
		--tabwidth 5 --tabheight 5 --htabs 2 --vtabs 2 \
		--panelsize 90 90 --framecutV --fiducials 10 2.5 1 2 --tooling 5 2.5 1.5 \
		--mousebites 0.5 0.75 0.25 --radius $(RADIUS) $< $@

build/mPCIe-GNSS-panel.sch: mPCIe-GNSS/mPCIe-GNSS.sch
		cp $< $@

%-gerber: %.kicad_pcb
	kikit export gerber $< $@

%-gerber.zip: %-gerber
	zip -j $@ `find $<`

%-jlcpcb: %.sch %.kicad_pcb
	kikit fab jlcpcb --assembly --ignore $(JLCIGNORE) --schematic $^ $@

%-jlcpcb.zip: %-jlcpcb
	zip -j $@ `find $<`

web: build/web/index.html

build:
	mkdir -p build

build/web: build
	mkdir -p build/web

build/web/index.html: build/web $(BOARDSFILES)
	kikit present boardpage \
		-d README.md \
		--name "miniPCIe LEA-M8T GNSS Card" \
		-b "mini-PCIe LEA-M8T GNSS Board" " " build/mPCIe-GNSS.kicad_pcb  \
		-b "mini-PCIe LEA-M8T GNSS Board Panelized" " " build/mPCIe-GNSS-panel.kicad_pcb  \
		-r "mPCIe-GNSS/mPCIe-GNSS.png" \
		--repository "$(GITREPO)"\
		build/web

clean:
	rm -r build