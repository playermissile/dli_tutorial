DEST = xex/
SRC = src/
BINS = xex/sample_display_list.xex \
	xex/first_dli.xex \
	xex/first_dli_with_wsync.xex \
	xex/rainbow_wsync.xex \
	xex/marching_rainbow.xex \
	xex/dli_interrupting_dli.xex \
	xex/dli_interrupting_vbi.xex \
	xex/vbi_interrupting_dli.xex \
	xex/multiple_dli_same_page.xex \
	xex/simple_multiplex_player.xex \
	xex/simple_multiplex_player_no_wsync.xex \
	xex/moving_dli.xex \
	xex/simple_chbase.xex \
	xex/multiplex_player_movement.xex \
	xex/reusing_player_horz.xex \
	xex/background_color_kernel.xex \
	xex/parallax_scrolling.xex \
	xex/multiple_scrolling_regions.xex

# undefine this to get extra debugging files during assembly
# DEBUG_FILES = -L$<.var -g$<.lst

.PHONY: png

# %.xex: %.s
# 	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<
.s.xex:
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

all: $(BINS)

xex/sample_display_list.xex: src/sample_display_list.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/first_dli.xex: src/first_dli.s src/util.s src/util_dli.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/first_dli_with_wsync.xex: src/first_dli_with_wsync.s src/util.s src/util_dli.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/rainbow_wsync.xex: src/rainbow_wsync.s src/util.s src/util_dli.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/marching_rainbow.xex: src/marching_rainbow.s src/util.s src/util_dli.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/dli_interrupting_dli.xex: src/dli_interrupting_dli.s src/util.s src/util_dli.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/vbi_interrupting_dli.xex: src/vbi_interrupting_dli.s src/util.s src/util_dli.s src/util_vbi.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/dli_interrupting_vbi.xex: src/dli_interrupting_vbi.s src/util.s src/util_dli.s src/util_vbi.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/multiple_dli_same_page.xex: src/multiple_dli_same_page.s src/util.s src/util_dli.s src/util_vbi.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/moving_dli.xex: src/moving_dli.s src/util.s src/util_dli.s src/util_vbi.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/simple_chbase.xex: src/simple_chbase.s src/util.s src/util_dli.s src/util_font.s src/font_data_antic4.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/simple_multiplex_player.xex: src/simple_multiplex_player.s src/util.s src/util_dli.s src/util_vbi.s src/util_pmg.s src/util_font.s src/font_data_antic4.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<
ex/simple_multiplex_player_no_wsync.xex: src/simple_multiplex_player_no_wsync.s src/util.s src/util_dli.s src/util_vbi.s src/util_pmg.s src/util_font.s src/font_data_antic4.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/multiplex_player_movement.xex: src/multiplex_player_movement.s src/util.s src/util_dli.s src/util_vbi.s src/util_pmg.s src/util_multiplex_pmg.s src/util_font.s src/font_data_antic4.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/reusing_player_horz.xex: src/reusing_player_horz.s src/util.s src/util_dli.s src/util_vbi.s src/util_pmg.s src/util_multiplex_pmg.s src/util_font.s src/font_data_antic4.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/background_color_kernel.xex: src/background_color_kernel.s src/util.s src/util_dli.s src/util_bitmap.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/parallax_scrolling.xex: src/parallax_scrolling.s src/util.s src/util_dli.s src/util_vbi.s src/util_scroll.s src/util_font.s src/font_data_antic4.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

xex/multiple_scrolling_regions.xex: src/multiple_scrolling_regions.s src/util.s src/util_dli.s src/util_vbi.s src/util_scroll.s src/util_font.s src/font_data_antic4.s
	atasm -mae -Isrc -o$@ $(DEBUG_FILES) $<

png:
	optipng *.png

clean:
	rm -f $(BINS)
