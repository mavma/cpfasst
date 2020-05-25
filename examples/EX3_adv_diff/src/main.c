//
// Created by mari on 25.05.20.
//

# include <fftpack.h>
# include <complex.h>

int main(void) {
    double complex myc[2];
    myc[0] = 1 + 2*I;
    myc[1] = 3 + 4*I;
    double wrk[200];
    cffti(2, wrk);
    cfftf(2, (double*) myc, wrk);
}