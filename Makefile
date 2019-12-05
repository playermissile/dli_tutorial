DEST = xex/
SRC = src/
BINS = xex/sample_display_list.xex xex/first_dli.xex xex/first_dli_with_wsync.xex xex/rainbow_wsync.xex xex/dli_interrupting_dli.xex xex/vbi_interrupting_dli.xex xex/multiple_dli_same_page.xex xex/simple_multiplex_player.xex xex/simple_multiplex_player_no_wsync.xex xex/moving_dli.xex xex/multiplex_player_movement.xex xex/horizontal_multiplex_player.xex xex/horizontal_multiplex_player_kernel.xex

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

xex/dli_interrupting_dli.xex: src/dli_interrupting_dli.s src/util.s src/util_dli.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

xex/vbi_interrupting_dli.xex: src/vbi_interrupting_dli.s src/util.s src/util_dli.s src/util_vbi.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

xex/multiple_dli_same_page.xex: src/multiple_dli_same_page.s src/util.s src/util_dli.s src/util_vbi.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

xex/moving_dli.xex: src/moving_dli.s src/util.s src/util_dli.s src/util_vbi.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

xex/simple_multiplex_player.xex: src/simple_multiplex_player.s src/util.s src/util_dli.s src/util_vbi.s src/util_pmg.s src/util_font.s src/font_data_antic4.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

xex/simple_multiplex_player_no_wsync.xex: src/simple_multiplex_player_no_wsync.s src/util.s src/util_dli.s src/util_vbi.s src/util_pmg.s src/util_font.s src/font_data_antic4.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

xex/multiplex_player_movement.xex: src/multiplex_player_movement.s src/util.s src/util_dli.s src/util_vbi.s src/util_pmg.s src/util_multiplex_pmg.s src/util_font.s src/font_data_antic4.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

xex/horizontal_multiplex_player.xex: src/horizontal_multiplex_player.s src/util.s src/util_dli.s src/util_vbi.s src/util_pmg.s src/util_multiplex_pmg.s src/util_font.s src/font_data_antic4.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

xex/horizontal_multiplex_player_kernel.xex: src/horizontal_multiplex_player_kernel.s src/util.s src/util_dli.s src/util_vbi.s src/util_pmg.s src/util_multiplex_pmg.s src/util_font.s src/font_data_antic4.s
	atasm -mae -Isrc -o$@ -L$<.var -g$<.lst $<

clean:
	rm -f $(BINS)
