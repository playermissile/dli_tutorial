.. _dli_tutorial:

.. highlight:: ca65


Advanced Tutorial on Atari 8-bit Display List Interrupts
==========================================================

This is a tutorial on advanced Display List Interrupts (DLIs) for the Atari
8-bit series of computers. In a nutshell, DLIs provide a way to notify your
program when a particular scan line is reached, allowing you to make changes
mid-screen.

DLIs are an advanced programming technique in the sense that they require
knowledge of 6502 assembly language, so this tutorial is going to assume that
you are comfortable with that. All the examples here are assembled using the
MAC/65-compatible assembler `ATasm
<https://atari.miribilist.com/atasm/index.html>`_ (and more specifically to
this tutorial, the version built-in to Omnivore).

Before diving into DLIs, it is helpful to understand that they are very
accurately named: Display List Interrupts literally interrupt the display list
-- they cause an event that is processed by your program while the ANTIC is drawing the screen. So it is necessary to understand what display lists are
before understanding what it means to interrupt one.

.. seealso::

   Here are some resources for learning more about display list interrupts:

   * `De Re Atari, Chapter 5 <https://www.atariarchives.org/dere/chapt05.php>`_
   * `Yaron Nir's tutorial using cc65 <https://atariage.com/forums/topic/291991-cc65-writing-a-dli-tutorial/>`_


A Crash Course on Displays
--------------------------------

A TV screen is drawn by an electron beam tracing a path starting above the
visible area, and drawing successive horizontal lines as the beam moves down
the screen. Each line is drawn from left-to-right (as you look at the TV
screen) and when it reaches the right hand side of the screen, the horizontal
retrace starts where the beam is turned off and moved down to the next scan
line below whereupon the beam is turned back on and the next line draws. When
the full frame has been drawn, the beam is turned off again and the vertical
retrace starts (starting the vertical blank interval). Once the beam is
repositioned to the top leftmost position, the vertical blank interval ends,
the beam is turned back on, and the next frame is started.

On NTSC systems, the Atari draws 262 scan lines per frame, 60 times per second.
On PAL systems it draws 312 scan lines per frame, 50 times per second. In
either system, it draws scan lines from the top down, and left to right within
a scan line.

.. figure:: electron-beam.png
   :align: center

This simplified description is the mental model we will use to describe the
video drawing process.

How TVs really (well, kinda approximately) work
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Real TVs are interlaced with 525 scan lines for NTSC and 625 for PAL. Every
refresh interval, the electron beam draws one **field**, starting at the top
left and drawing every other scan line. When it reaches the bottom, the
vertical retrace starts, but this time it positions the electron beam at the
first missing scan line. Then it draws the next field, again skipping every
other scan line but this time filling in the scan lines it missed.

.. figure:: electron-beam-interlaced.png
   :align: center

Notice that this would mean that e.g. one NTSC frame should draw 262 scan lines
and the other 263, but apparently TVs can compensate for the missing scan line
every alternate frame, so the Atari always outputs 262 scan lines. Practically
speaking, you do not need to care that the screen is interlaced. If the Atari
is displaying an unchanging screen, it produces the same information in the 262
scan lines it generates regardless of which field it is drawing.

How TVs produce the colors that they display is very complicated and so far
outside the scope of this tutorial that it might as well be magic. Suffice it
to say that color happens.

On the Atari, a unit called the color clock is the smallest portion of a scan
line that can be displayed with an arbitrary color. There are 228 color clocks
per scan line, of which about 160 were typically visible on a TV display in the
1970s when the Atari was developed. This corresponds to the 160 pixel
horizontal resolution of Antic Modes B through E in the standard width
playfield. Antic Mode F (Graphics 8 in BASIC) has 320 addressable pixels,
corresponding to half a color clock, and only artifacting color is available.

.. seealso::

   * `All About Video Fields <https://lurkertech.com/lg/fields/>`_
   * `Composite artifact colors <https://en.wikipedia.org/wiki/Composite_artifact_colors>`_ article on Wikipedia


A Crash Course on Display Lists
--------------------------------

ANTIC is the special coprocessor that handles screen drawing for the Atari
computers. It is tightly coupled with the 6502 processor, and in fact can be
thought of as being the driver of the 6502 because the ANTIC can halt the 6502
when needed. Since only one chip can read memory at any time, ANTIC needs to
halt the 6502 when it needs access to memory, so this Direct Memory Access
(DMA) can cause 6502 instructions to appear to take more cycles than documented
in a 6502 reference. In fact, the amount of time ANTIC "steals" will depend on
many factors: the graphics mode, player/missiles being used, playfield size,
and more.

Because of the NTSC signal, and the fact that each frame draws 262 scan lines
with 228 color clocks per scan line, the operating frequency of the 6502 was
chosen such that it takes exactly 114 machine cycles per scan line, producing
29868 machine cycles per frame (and with a 60Hz refresh rate, results in a
processor speed of 1.792MHz).

.. note::

   For PAL systems, the 312 scan lines have the same 228 color clocks and 114
   machine cycles per line. This results in 35568 cycles per frame, but since
   the frequency is 50Hz, the processor runs at 1.778MHz

Since there are 228 color clocks but only 114 machine cycles per scan line,
this means that in one machine cycle, two color clocks are drawn on the screen.
A typical machine instruction might take 5 machine cycles, so 10 color clocks
could pass in the time to process a single instruction! This means we don't
have much time per scan line, so it will mean that DLIs will have to be quick.

It also means the 6502 is too slow to draw the screen itself, and this is where
ANTIC's special "machine language" comes in. You program the ANTIC coprocessor
using a display list, and ANTIC takes care of building the screen scan line by
scan line, without any more intervention from the 6502 code. (Unless you ask for intervention! And that's what a DLI is.)

The display list is the special sequence of bytes that ANTIC interprets as a
list of commands. Each command causes ANTIC to draw a certain number of scan
lines in a particular way. A DLI can be set on any ANTIC command.

An ANTIC display list command consists of 1 byte with an optional 2 byte
address. There are 3 types of commands: blank lines, graphics modes, and jump
commands. Commands are encoded into the byte using a bitmask where low 4 bits
encode the graphics mode or command and the high 4 bits encode the flags that
affect that command:

.. csv-table::

    Bit, 7, 6, 5, 4, 3-0
       , DLI, LMS, VSCROLL, HSCROLL, Mode

The 4 flags are:

 * DLI (``$80``): enable a display list interrupt when processing this instruction
 * LMS (``$40``): trigger a Load Memory Scan, changing where ANTIC looks for screen data, and requires an additional 2 byte address immediately following this command byte.
 * VSCROLL (``$20``): enable vertical scrolling for this mode line
 * HSCROLL (``$10``): enable horizontal scrolling for this mode line

The 14 available graphics modes are encoded into bits 3-0 using values as shown
in this table:

.. csv-table::

    Mode, Decimal, BASIC Mode,  Description, Scan Lines, Type, Colors
    2, 02,    0,     40 x 24,   8, text, 2
    3, 03,    n/a,   40 x 19,  10, text, 2
    4, 04,    n/a,   40 x 24,   8, text, 4
    5, 05,    n/a,   40 x 12,  16, text, 4
    6, 06,    1,     20 x 24,   8, text, 5
    7, 07,    2,     20 x 12,  16, text, 5
    8, 08,    3,     40 x 24,   8, graphic, 4
    9, 09,    4,     80 x 48,   4, graphic, 2
    A, 10,    5,     80 x 48,   4, graphic, 4
    B, 11,    6,    160 x 96,   2, graphic, 2
    C, 12,    n/a,  160 x 192,  1, graphic, 2
    D, 13,    7,    160 x 96,   2, graphic, 4
    E, 14,    n/a,  160 x 192,  1, graphic, 4
    F, 15,    8,    320 x 192,  1, graphic*, 2

*mode F is also used as the basis for the GTIA modes (Graphics 9, 10, & 11),
but this is a topic outside the scope of this tutorial.

Blank lines are encoded as a mode value of zero, the bits 6, 5, and 4 taking
the meaning of the number of blank lines rather than LMS, VSCROLL, and HSCROLL. Note that the DLI bit is still available on blank lines, however, as bit 7 is not co-opted by the blank line instruction.

Jumps are encoded using a mode value of one, and require an additional 2 byte
address for the next display list pointer. If bit 6 is also set, it becomes the
Jump and wait for Vertical Blank instruction. the DLI bit may also be set on a
jump instruction.

The typical method to change the currently active display list is to change the
address stored at ``SDLSTL`` (in low byte/high byte format in addresses
``$230`` and ``$231``). At the next vertical blank, the hardware display list
at ``DLISTL`` (``$d402`` and ``$d403``) will be updated with the values stored
here and the screen drawing will commence using the new display list.

The playfield portion of the display list is 192 lines in standard graphics
modes, out of the 262 possible lines in NTSC. More lines are possible, but the
maximum usable amount would depend on the TV screen being used. The more scan
lines are used, the more clock cycles are needed before hitting the vertical
blank, so making a display list with too many lines can cause timing problems
if the vertical blank also takes a long time.

.. seealso::

   More resources about display lists are available:

   * https://www.atariarchives.org/mapping/memorymap.php#560,561
   * https://www.atariarchives.org/mapping/appendix8.php

A Sample Display List
~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is a simple display list that contains different text and graphics modes
mixed in a single screen.


Cycle Stealing by ANTIC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ANTIC coprocessor needs to access memory to perform its functions, and
since the 6502 and ANTIC can't both access at once, ANTIC will pause execution
of the 6502 when it needs to read memory. It happens at specific points within
the 114 cycles of each scan line, but where it happens (and how many times the
6502 gets paused during the scan line) depends on the graphics mode.

For overhead, ANTIC will typically steal 3 cycles to read the display list, 5
cycles if player/missile graphics are enabled, and 9 cycles for memory
refreshing.

Graphics modes (modes 8 - F) have cycles stolen corresponding to the number of
bytes-per-line used in that mode, in addition to the up-to 17 cycles stolen for
ANTIC overhead. For example, mode E will use an additional 40 cycles, so in the
context of writing a game, the typical number of cycles used could be 57 out of
the 114 cycles per scan line. This means you typically have only half of the
cycles available for your 6502 code!

Text modes are the worst-case scenario, because ANTIC must fetch the font
glyphs in addition to its other work. The first scan line of a font mode is
almost entirely used by ANTIC and only a small number of cycles is available to
the 6502. For normal 40-byte wide playfields, the first line of ANTIC modes 2
through 5 will yield at most about 30 cycles and subsequent lines about 60
cycles per scan line. Adding player/missile graphics and scrolling can reduce
the available cycles to less than 10 on the first line and about 30 on
subsequent lines!

.. seealso::

   Chapter 4 in the
   `Altirra Hardware Reference Manual <http://www.virtualdub.org/downloads/Altirra%20Hardware%20Reference%20Manual.pdf>`_
   contains tables depicting exactly which cycles are stolen by ANTIC for
   each mode.


A Crash Course on Display List Interrupts
---------------------------------------------

DLIs are non-maskable interrupts (NMIs), meaning they cannot be ignored. When
an NMI occurs, the 6502 jumps to the address stored at ``$fffa``, which points
to an OS routine that checks the type of interrupt (either a DLI or a VBI) and
vectors through the appropriate user vector. The NMI handler takes care of
saving the processor status register and sets the interrupt flag, but *does
not* save any processor registers. The user routine is responsible for saving
any registers that it uses, restoring them when it is done using them, and must
exit using the ``RTI`` instruction.

Display list interrupts are not enabled by default. To use a DLI, the address
vector at ``VDLSLT`` (``$200`` and ``$201``) must be set to your routine, and
then they must be enabled through a write to ``NMIEN`` at ``$d40e``.

.. warning::

   You must set the address of your DLI before enabling them, otherwise the DLI
   could be called and use whatever address is stored at ``$200``.

This can look like this, where the constants ``NMIEN_VBI`` and ``NMIEN_DLI``
are defined as ``$40`` and ``$80``, respectively, in `hardware.s` in the sample
repository.

.. code-block::

           ; load display list interrupt address
           lda #<dli
           sta VDSLST
           lda #>dli
           sta VDSLST+1

           ; activate display list interrupt
           lda #NMIEN_VBI | NMIEN_DLI
           sta NMIEN

If your program has multiple DLIs, it may be necessary to set your DLIs in a
vertical blank interrupt to guarantee that ANTIC is not in the middle of the
screen when the DLI becomes active. In Yaron Nir's tutorial a different
technique is used, one not requiring a vertical blank interrupt but instead
using the RTCLOK 3-byte zero page variable. The last of the bytes, location
$14, is incremented every vertical blank, so that technique is to wait until
location $14 changes, then set NMIEN:

.. code-block::

           lda RTCLOK+2
   ?loop   cmp RTCLOK+2  ; will be equal until incremented in VB
           beq ?loop

           ; activate display list interrupt
           lda #NMIEN_VBI | NMIEN_DLI
           sta NMIEN



A Simple Example
~~~~~~~~~~~~~~~~~~~~~

A common use of display lists is to change colors part of the way down the
screen. This first display list interrupt will change the color of the
background:

.. code-block::

   dli     pha
           lda #$7a
           sta COLBK
           pla
           rti

but note that running this example causes a flickering line in the background:

.. figure:: first_dli.gif
   :align: center
   :width: 50%



A Simple Example with WSYNC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Atari provides a way to sync with a scan line, and that's triggered by
saving some value (any value, the bit pattern is not important) to the
``WSYNC`` memory location at ``$d40a``. This causes the 6502 to stop processing
instructions until the electron beam nears the end of the scan line, at which
point the 6502 will resume executing instructions. Because the electron beam is
usually off-screen at this point, it is safe to change color registers for at
least the next several instructions without artifacts appearing on screen.

.. code-block::

   dli     pha
           lda #$7a
           sta WSYNC
           sta COLBK
           pla
           rti

.. figure:: first_dli_with_wsync.png
   :align: center
   :width: 50%

.. note::

   ``WSYNC`` (wait for horizontal blank) usually restarts the 6502 on or
   about cycle 105 out of 114, but there are cases that can delay that. See the
   Altirra Hardware Reference Manual for more information.


DLIs in a Nutshell
-----------------------

DLIs provide you with a way to notify your program at a particular vertical
location on the screen. They pause (or interrupt) the normal flow of program
code, save the state of the machine, call your DLI subroutine, and restore the
state of the computer before returning control to the code that was
interrupted.

.. warning::

   Here are the requirements for successful use of DLIs:

   * your DLI routine must save any registers it clobbers
   * restore any registers you save before exiting
   * exit with an ``RTI``
   * use ``WSYNC`` if necessary
   * be aware of cycles stolen by ANTIC: you could have only 60 cycles per scan line in higher resolution graphics modes, and as few as 10 in text modes
   * store the address of your routine in ``VDSLST`` before enabling DLIs with ``NMIEN``

Note that nowhere in that list was the requirement that the DLI be short. It
doesn't have to be, and in fact DLIs that span multiple scan lines are similar
to kernels used in Atari 2600 programming. The difference is that ANTIC steals
cycles depending on a bunch of factors, so the total cycle counting approach
(or `Racing the Beam <https://mitpress.mit.edu/books/racing-beam>`_) is usually
not possible.

However, most DLIs that you will run across in the wild *are* short, because
they typically don't do a lot of calculations. Most of the setup work will
generally be done outside of the DLI and the DLI itself just handles the result
of that work.


Advanced DLI #1: Moving the DLI Up and Down the Screen
------------------------------------------------------------

The DLI subroutine itself doesn't directly know what scan line caused the
interrupt because all DLIs are routed through the same vector at ``VDLSTL``.
The only trigger is in the display list itself, the DLI bit on the display list
command.

The display list can be modified in place to move the DLI to different lines
without changing the DLI code itself.



Advanced DLI #2: Multiple DLIs
------------------------------------------------------------

One of the problems with having a single DLI vector is: what do you do when you
want to have more than one DLI?

Some solutions that you will see in the wild:

 * use ``VCOUNT`` to check where you are on screen
 * change ``VDLSTL`` to point to the next DLI in the chain
 * increment an index value and use that to determine which DLI has been called

Here's another solution that can save some valuable cycles: put your DLIs in the same page of memory and only change the low byte.



Advanced DLI #3: Multiplexing Players & Collision Detection
------------------------------------------------------------------

Simple multiplexing players of is easy, you just set a new value for one of the
player or missile X position registers. But what if you want to have *a lot* of
reuse of players and be able to use the collision registers to see what has
happened in each region?


