/*
    This code was written to support the book, "ARM Assembly for Embedded Applications",
    by Daniel W. Lewis. Permission is granted to freely share this software provided
    that this notice is not removed. This software is intended to be used with a run-time
    library adapted by the author from the STM Cube Library for the 32F429IDISCOVERY 
    board and available for download from http://www.engr.scu.edu/~dlewis/book3.
*/

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "library.h"
#include "graphics.h"

#pragma GCC push_options
#pragma GCC optimize ("O0")

int32_t Square(int32_t x) ;
int32_t SquareRoot(int32_t n) ;

int32_t __attribute__((weak)) Less1(int32_t x)
    {
    return x - 1 ;
    }

int32_t __attribute__((weak)) Add(int32_t x, int32_t y)
    {
    return x + y ;
    }

int32_t __attribute__((weak)) Square2x(int32_t x)
    {
    return Square(x + x) ;
    }

int32_t __attribute__((weak)) Last(int32_t x)
    {
    return x + SquareRoot(x) ;
    }

#pragma GCC pop_options

// Public fonts defined in run-time library
typedef struct
    {
    const uint8_t * table ;
    const uint16_t  Width ;
    const uint16_t  Height ;
    } sFONT ;

typedef struct
    {
    int x, y ;
    } TEST ;

typedef struct
    {
    int             xlft ;
    int             ytop ;
    char *          name ;
    char *          desc ;
    } BOX ;

typedef enum        {LEFT, CENTER, RIGHT, ABOVE, BELOW} ALIGN ;
typedef enum        {FALSE=0, TRUE=1} BOOL ;

#define BOX_HEIGHT  58
#define BOX_WIDTH   58
#define BOX_HSPACE  ((XPIXELS - 3*BOX_WIDTH - 4)/2)
#define BOX_VSPACE  30

#define PROGRESS_Y  75

#define ROW1_YTOP   105
#define ROW2_YTOP   (ROW1_YTOP + BOX_HEIGHT + BOX_VSPACE)

#define COL1_XLFT   5
#define COL2_XLFT   (COL1_XLFT + BOX_WIDTH + BOX_HSPACE) - 5
#define COL3_XLFT   (COL2_XLFT + BOX_WIDTH + BOX_HSPACE) - 3

#define INPUT1_X    (COL1_XLFT + BOX_WIDTH/2)
#define INPUT1_Y    (ROW1_YTOP - BOX_VSPACE)

#define INPUT2_X    INPUT1_X
#define INPUT2_Y    (ROW2_YTOP + BOX_HEIGHT + BOX_VSPACE)

#define OUTPUT3_X   (COL3_XLFT + BOX_WIDTH/2)
#define OUTPUT3_Y   (ROW1_YTOP - BOX_VSPACE)

#define TEMP1_X     (COL1_XLFT + BOX_WIDTH/2)
#define TEMP1_Y     (ROW2_YTOP - BOX_VSPACE/2)

#define TEMP2_X     (COL1_XLFT + BOX_WIDTH + BOX_HSPACE/2) - 2
#define TEMP2_Y     (ROW1_YTOP + BOX_HEIGHT/2)

#define TEMP3_X     (COL2_XLFT + BOX_WIDTH + BOX_HSPACE/2)
#define TEMP3_Y     (ROW1_YTOP + BOX_HEIGHT/2)

#define INPUT3_X    (COL2_XLFT + BOX_WIDTH/3)
#define INPUT3_Y    (ROW2_YTOP - BOX_VSPACE/2)

#define OUTPUT1_X   (COL2_XLFT + 2*BOX_WIDTH/3)
#define OUTPUT1_Y   (ROW2_YTOP - BOX_VSPACE/2)

#define INPUT4_X    (COL3_XLFT + BOX_WIDTH/3)
#define INPUT4_Y    (ROW2_YTOP - BOX_VSPACE/2)

#define OUTPUT2_X   (COL3_XLFT + 2*BOX_WIDTH/3)
#define OUTPUT2_Y   (ROW2_YTOP - BOX_VSPACE/2)

#define ENTRIES(a)  (sizeof(a)/sizeof(a[0]))

#define ARG_REGS    4
#define TTL_REGS    12

extern sFONT        Font8, Font12, Font16, Font20, Font24 ;
static sFONT *      font = &Font12 ;
static uint32_t     stack ;
static BOOL         preserved = TRUE ;
static BOX boxes[] =
    {
    {COL1_XLFT, ROW2_YTOP, "Less1",     "x-1"},
    {COL1_XLFT, ROW1_YTOP, "Add",       "x+y"},
    {COL2_XLFT, ROW1_YTOP, "Square2x",  "2x*2x"},
    {COL3_XLFT, ROW1_YTOP, "Last",      "x+SR(x)"},
    {COL3_XLFT, ROW2_YTOP, "Square",    "Root"},
    {COL2_XLFT, ROW2_YTOP, "Square",    "x*x"}
    } ;

static void         CallFunction(void *function, uint32_t before[], uint32_t after[]) ;
static void         DisplayProgress(int which, int count) ;
static void         DrawVArrow(int x, int y_fm, int y_to) ;
static void         DrawHArrow(int y, int x_fm, int x_to) ;
static void         FillBox(BOX *box, BOOL ok) ;
static void         InitializeRegisters(uint32_t before[]) ;
static void         InvokeFunction(void *function, uint32_t before[], uint32_t after[]) ;
static void         LEDs(BOOL grn_on, BOOL red_on) ;
static void         PaintBox(BOX *box, int fg_color, int bg_color) ;
static void         PutStringAt(int x, int y, char *fmt, ...) ;
static void         PutValueAt(int x, int y, char *text, ALIGN align) ;
static void         SetFontSize(sFONT *pFont) ;
static char *       String(int n) ;
static int32_t      _SquareRoot(int32_t n) ;

int main(void)
    {
    static TEST tests[] =
        {
        {+1, +1}, {-1, -1}, {+2, -3}, {-3, +2}, {+4, +5},
        {-4, -5}, {+6, -7}, {+7, -6}, {+8, +9}, {-9, -8}
        } ;
    int x, y, z, t1, t2, t3 ;
    BOOL ok ;

    InitializeHardware(HEADER, "Lab 3A: Functions & Parameters") ;

    for (int k = 0; k < 4; k++) PaintBox(&boxes[k], COLOR_BLACK, COLOR_LIGHTGRAY) ;

    DrawHArrow(ROW1_YTOP + BOX_HEIGHT/2,    COL1_XLFT + BOX_WIDTH,                  COL2_XLFT) ;
    DrawHArrow(ROW1_YTOP + BOX_HEIGHT/2,    COL2_XLFT + BOX_WIDTH,                  COL3_XLFT) ;
    DrawVArrow(COL1_XLFT + BOX_WIDTH/2,     ROW2_YTOP,                              ROW1_YTOP + BOX_HEIGHT) ;
    DrawVArrow(COL2_XLFT + 1*BOX_WIDTH/3,   ROW1_YTOP + BOX_HEIGHT,                 ROW2_YTOP) ;
    DrawVArrow(COL2_XLFT + 2*BOX_WIDTH/3,   ROW2_YTOP,                              ROW1_YTOP + BOX_HEIGHT) ;
    DrawVArrow(COL3_XLFT + 1*BOX_WIDTH/3,   ROW1_YTOP + BOX_HEIGHT,                 ROW2_YTOP) ;
    DrawVArrow(COL3_XLFT + 2*BOX_WIDTH/3,   ROW2_YTOP,                              ROW1_YTOP + BOX_HEIGHT) ;
    DrawVArrow(COL1_XLFT + BOX_WIDTH/2,     ROW1_YTOP - BOX_VSPACE,                 ROW1_YTOP) ;
    DrawVArrow(COL3_XLFT + BOX_WIDTH/2,     ROW1_YTOP,                              ROW1_YTOP - BOX_VSPACE) ;
    DrawVArrow(COL1_XLFT + BOX_WIDTH/2,     ROW2_YTOP + BOX_HEIGHT + BOX_VSPACE,    ROW2_YTOP + BOX_HEIGHT) ;

    PutValueAt(TEMP1_X,     TEMP1_Y,    "?", LEFT) ;
    PutValueAt(TEMP2_X,     TEMP2_Y,    "?", ABOVE) ;
    PutValueAt(TEMP3_X,     TEMP3_Y,    "?", ABOVE) ;
    PutValueAt(OUTPUT3_X,   OUTPUT3_Y,  "?", ABOVE) ;
    PutValueAt(INPUT3_X,    INPUT3_Y,   "?", RIGHT) ;
    PutValueAt(OUTPUT1_X,   OUTPUT1_Y,  "?", LEFT) ;
    PutValueAt(INPUT4_X,    INPUT4_Y,   "?", RIGHT) ;
    PutValueAt(OUTPUT2_X,   OUTPUT2_Y,  "?", LEFT) ;

    for (int which = 0;; which = (which + 1) % ENTRIES(tests))
        {
        static uint32_t before[TTL_REGS] __attribute__((aligned(8))) ;
        static uint32_t after[TTL_REGS]  __attribute__((aligned(8))) ;

        DisplayProgress(which, ENTRIES(tests)) ;

        x = tests[which].x ;
        PutValueAt(INPUT1_X, INPUT1_Y, String(x), ABOVE) ;
        y = tests[which].y ;
        PutValueAt(INPUT2_X, INPUT2_Y, String(y), BELOW) ;

        stack = 0 ;
        PaintBox(&boxes[0], COLOR_BLACK, COLOR_ORANGE) ;
        InitializeRegisters(before) ;
        before[0] = (uint32_t) y ;
        InvokeFunction((void *) Less1, before, after) ;
        t1 = (int) after[0] ;
        ok = (t1 == y - 1) ;
        PutValueAt(TEMP1_X, TEMP1_Y, String(t1), LEFT) ;
        FillBox(&boxes[0], ok) ;

        stack = 0 ;
        PaintBox(&boxes[1], COLOR_BLACK, COLOR_ORANGE) ;
        InitializeRegisters(before) ;
        before[0] = (uint32_t) x ;
        before[1] = (uint32_t) t1 ;
        InvokeFunction((void *) Add, before, after) ;
        t2 = (int) after[0] ;
        ok = (t2 == x + t1) ;
        PutValueAt(TEMP2_X, TEMP2_Y, String(t2), ABOVE) ;
        FillBox(&boxes[1], ok) ;

        PaintBox(&boxes[2], COLOR_BLACK, COLOR_ORANGE) ;
        InitializeRegisters(before) ;
        before[0] = (int) t2 ;
        InvokeFunction((void *) Square2x, before, after) ;
        t3 = (int) after[0] ;
        ok = (t3 == 4*t2*t2) ;
        PutValueAt(TEMP3_X, TEMP3_Y, String(t3), ABOVE) ;
        FillBox(&boxes[2], ok) ;

        PaintBox(&boxes[3], COLOR_BLACK, COLOR_ORANGE) ;
        InitializeRegisters(before) ;
        before[0] = (uint32_t) t3 ;
        InvokeFunction((void *) Last, before, after) ;
        z = (int) after[0] ;
        ok = (z == t3 + _SquareRoot(t3)) ;
        PutValueAt(OUTPUT3_X, OUTPUT3_Y, String(z), ABOVE) ;
        FillBox(&boxes[3], ok) ;

        WaitForPushButton() ;
        }

    return 0 ;
    }

int32_t Square(int32_t x)
    {
    int32_t square = x * x ;

    stack = (uint32_t) &square ;

    PaintBox(&boxes[5], COLOR_BLACK, COLOR_YELLOW) ;
    PutValueAt(INPUT3_X, INPUT3_Y, String(x), RIGHT) ;
    PutValueAt(OUTPUT1_X, OUTPUT1_Y, String(square), LEFT) ;
    return square ;
    }

int32_t SquareRoot(int32_t n)
    {
    int32_t root ;

    stack = (uint32_t) &root ;

    PaintBox(&boxes[4], COLOR_BLACK, COLOR_YELLOW) ;
    PutValueAt(INPUT4_X, INPUT4_Y, String(n), RIGHT) ;
    root = _SquareRoot(n) ;
    PutValueAt(OUTPUT2_X, OUTPUT2_Y, String(root), LEFT) ;
    return root ;
    }

static int32_t _SquareRoot(int32_t n)
    {
    int32_t smallCandidate, largeCandidate ;

    if (n < 2) return n ;

    // Recursive call:
    smallCandidate = 2 * _SquareRoot(n / 4) ;
    largeCandidate = smallCandidate + 1 ;

    if (largeCandidate * largeCandidate > n) return smallCandidate ;
    return largeCandidate ;
    }

static void DisplayProgress(int which, int count)
    {
    char text[100] ;

    sprintf(text, " Test %d of %d ", which + 1, count) ;
    SetFontSize(&Font16) ;
    SetForeground(COLOR_BLACK) ;
    SetBackground(COLOR_WHITE) ;
    PutStringAt((XPIXELS - font->Width * strlen(text)) / 2, PROGRESS_Y, text) ;
    }

static char *String(int n)
    {
    static char text[20] ;
    sprintf(text, "%d", n) ;
    return text ;
    }

static void PutValueAt(int x, int y, char *text, ALIGN align)
    {
    char erase[] = "    " ;
    int width, save ;

    SetFontSize(&Font12) ;

    save = x ;
    width = strlen(erase) * font->Width ;
    switch (align)
        {
        case RIGHT:     x -= width + 2; y -= font->Height/2;    break ;
        case CENTER:    x -= width/2;   y -= font->Height/2;    break ;
        case LEFT:      x += 2;         y -= font->Height/2;    break ;
        case ABOVE:     x -= width/2;   y -= font->Height + 2;  break ;
        case BELOW:     x -= width/2;   y += 2;                 break ;
        }
    SetForeground(COLOR_BLACK) ;
    SetBackground(COLOR_WHITE) ;
    PutStringAt(x, y, erase) ;

    x = save ;
    width = strlen(text) * font->Width ;
    switch (align)
        {
        case RIGHT:     x -= width + 2; break ;
        case CENTER:    x -= width/2;   break ;
        case LEFT:      x += 2;         break ;
        case ABOVE:     x -= width/2;   break ;
        case BELOW:     x -= width/2;   break ;
        }
    PutStringAt(x, y, text) ;
    }

static void FillBox(BOX *box, BOOL ok)
    {
    int fg_color, bg_color ;

    if (!ok)
         {
         fg_color = COLOR_WHITE ;
         bg_color = COLOR_RED ;
         }
    else if (!preserved)
         {
         fg_color = COLOR_WHITE ;
         bg_color = COLOR_BLUE ;
         }
    else if ((stack & 0x7) != 0)
         {
         fg_color = COLOR_WHITE ;
         bg_color = COLOR_MAGENTA ;
         }
    else
         {
         fg_color = COLOR_BLACK ;
         bg_color = COLOR_LIGHTGREEN ;
         LEDs(TRUE,FALSE) ;
         }

    PaintBox(box, fg_color, bg_color) ;
    }

static void PaintBox(BOX *box, int fg_color, int bg_color)
    {
    int x, y ;

    SetForeground(bg_color) ;
    FillRect(box->xlft, box->ytop, BOX_WIDTH, BOX_HEIGHT) ;
    SetForeground(COLOR_BLACK) ;
    DrawRect(box->xlft, box->ytop, BOX_WIDTH, BOX_HEIGHT) ;

    SetForeground(fg_color) ;
    SetBackground(bg_color) ;

    SetFontSize(&Font12) ;
    x = box->xlft + (BOX_WIDTH - font->Width*strlen(box->name))/2 ;
    y = box->ytop + BOX_HEIGHT/2 - font->Height ;
    PutStringAt(x, y, box->name) ;

    SetFontSize(&Font12) ;
    x = box->xlft + (BOX_WIDTH - font->Width*strlen(box->desc))/2 ;
    y = box->ytop + BOX_HEIGHT/2 ;
    PutStringAt(x, y, box->desc) ;
    }

static void DrawVArrow(int x, int y_fm, int y_to)
    {
    SetColor(COLOR_BLACK) ;
    if (y_fm < y_to)
        {
        DrawVLine(x, y_fm, y_to - y_fm) ;
        FillTriangle(x, x-3, x+3, y_to, y_to-5, y_to-5) ;
        }
    else
        {
        DrawVLine(x, y_to, y_fm - y_to) ;
        FillTriangle(x, x-3, x+3, y_to, y_to+5, y_to+5) ;
        }
    }

static void DrawHArrow(int y, int x_fm, int x_to)
    {
    SetColor(COLOR_BLACK) ;
    if (x_fm < x_to)
        {
        DrawHLine(x_fm, y, x_to - x_fm) ;
        FillTriangle(x_to, x_to-5, x_to-5, y, y-3, y+3) ;
        }
    else
        {
        DrawHLine(x_to, y, x_fm - x_to) ;
        FillTriangle(x_to, x_to+5, x_to+5, y, y-3, y+3) ;
        }
    }

static void PutStringAt(int x, int y, char *fmt, ...)
    {
    va_list args ;
    char text[100] ;

    va_start(args, fmt) ;
    vsprintf(text, fmt, args) ;
    va_end(args) ;

    DisplayStringAt(x, y, text) ;
    }

static void SetFontSize(sFONT *Font)
    {
    extern void BSP_LCD_SetFont(sFONT *) ;
    BSP_LCD_SetFont(Font) ;
    font = Font ;
    }

static void LEDs(BOOL grn_on, BOOL red_on)
    {
    static uint32_t * const pGPIOG_MODER    = (uint32_t *) 0x40021800 ;
    static uint32_t * const pGPIOG_ODR      = (uint32_t *) 0x40021814 ;
    
    *pGPIOG_MODER |= (1 << 28) | (1 << 26) ;    // output mode
    *pGPIOG_ODR &= ~(3 << 13) ;                 // both off
    *pGPIOG_ODR |= (grn_on ? 1 : 0) << 13 ;
    *pGPIOG_ODR |= (red_on ? 1 : 0) << 14 ;
    }

static void InitializeRegisters(uint32_t before[])
    {
    uint32_t *reg = &before[0] ;
    for (int r = 0; r < TTL_REGS; r++, reg++)
        {
        *reg = GetRandomNumber() ;
        }
    }

static void InvokeFunction(void *function, uint32_t before[], uint32_t after[])
    {
    uint32_t *inp = &before[ARG_REGS] ; 
    uint32_t *out = &after[ARG_REGS] ;
    int reg ;

    stack = 0 ;
    LEDs(FALSE, TRUE) ;
    CallFunction(function, before, after) ;
    for (reg = ARG_REGS; reg < TTL_REGS; reg++, inp++, out++)
        {
        if (*out != *inp) break ;
        }
    preserved = (reg == TTL_REGS) ;
    }

#pragma GCC push_options
#pragma GCC optimize ("O1")
static void CallFunction(void *function, uint32_t before[], uint32_t after[]) 
    {
    __asm(
        "push    {r4-r12,lr}    \n\t"
        "mov     r12,r0         \n\t"             // r12 <-- function
        "push    {r2}           \n\t"             // save after
        "ldmia   r1,{r0-r11}    \n\t"             // regs <-- before
        "blx     r12            \n\t"             // call function
        "pop     {r12}          \n\t"             // r12 <-- after
        "stmia   r12,{r0-r11}   \n\t"             // regs --> after
        "pop     {r4-r12,pc}    \n\t"
        ) ;
    }
#pragma GCC pop_options

