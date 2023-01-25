#include <stdint.h>
#include <math.h>
#include <stdbool.h>

uint32_t Bits2Unsigned(int8_t bits[8]){
    int num = 0;

    for(int i = 0; i < 8; i++) {//traverses each bit and converts
        num += (pow(2, i)) * bits[i];
    }

    return num;
}

void Increment(int8_t bits[8]) {
    int cin = 1;
    int cout;

    for (int i = 0; i < 8; i++) {//carries in 1
        cout = cin & bits[i];
        bits[i] = cin ^ bits[i];
        cin = cout;
    }
}

int32_t Bits2Signed(int8_t bits[8]){
    bool positive = true;
    int num;


    if(bits[7] == 1) {//checks the sign of the number
        int8_t new_bits[8];
        positive = false;

        for (int i = 0; i < 8; i++)//inverts each bit
            if(bits[i])
                new_bits[i] = 0;
            else
                new_bits[i] = 1;
        Increment(new_bits);
        num = Bits2Unsigned(new_bits);
    } else {
        num = Bits2Unsigned(bits);
    }

    return positive? num : (-1 * num);
}

void Unsigned2Bits(uint32_t n, int8_t bits[8]) {
    for(int i = 0; i < 8; i++){//divides n by 2 and puts the remainder in array bits
        bits[i] = n % 2;
        n /= 2;
    }
}

