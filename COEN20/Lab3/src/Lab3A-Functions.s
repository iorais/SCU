        .syntax         unified
        .cpu            cortex-m4
        .text
// int32_t Add(int32_t a, int32_t b) ;
        .global         Add
        .thumb_func
        .align
Add:
        ADD r0, r1
        BX              LR

// int32_t Less1(int32_t a) ;
        .global         Less1
        .thumb_func
        .align
Less1:        
        SUB r0, 1
        BX              LR

// int32_t Square2x(int32_t x) ;
        .global         Square2x
        .thumb_func
        .align
Square2x:
        ADD r0, r0
        BX              Square


// int32_t Last(int32_t x) ;
        .global         Last
        .thumb_func
        .align
Last:
        MOV r1, r0 
        
        PUSH {LR}
        BL              SquareRoot
        POP {LR}

        ADD r0, r1
        BX              LR
        .end