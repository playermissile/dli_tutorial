DEST = xex/
SRC = src/
BINS = xex/sample_display_list.xex xex/first_dli.xex xex/first_dli_with_wsync.xex xex/rainbow_wsync.xex xex/multiplex_player_movement.xex

# %.xex: %.s
# 	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<
.s.xex:
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

all: $(BINS)

xex/sample_display_list.xex: src/sample_display_list.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

xex/first_dli.xex: src/first_dli.s src/util.s src/util_dli.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

xex/first_dli_with_wsync.xex: src/first_dli_with_wsync.s src/util.s src/util_dli.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

xex/rainbow_wsync.xex: src/rainbow_wsync.s src/util.s src/util_dli.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

xex/multiplex_player_movement.xex: src/multiplex_player_movement.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

clean:
	rm -f $(BINS)
