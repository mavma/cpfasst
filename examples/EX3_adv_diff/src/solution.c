#include <quadmath.h>
#include <math.h>

#include "shared.h"

double ad_cos_ex(double t, double x, double nu, double v, double kfreq, double Lx) {
    double u, omega;
    double twopi = (double) (M_PIq * 2.0Q);
    omega = kfreq * twopi / Lx;
    u = cos(omega * (x-t*v)) * exp(-omega*omega*nu*t);
    return u;
}

void exact_ad_cos_1ds(double t, double out[], int nx, double nu, double v, double kfreq, double Lx) {
    for(int i=0; i<nx; i++) {
        double x = Lx*((double) i)/nx;
        out[i] = ad_cos_ex(t, x, nu, v, kfreq, Lx);
    }
}

//TODO: exponential ic type
//
//double ad_exp_ex(double t, double x, double nu, double v, double Lx)
//
//function ad_exp_ex(t, x,nu,v,Lx) result(u)
//real(pfdp), intent(in)  :: t
//        real(pfdp), intent(in)  :: x
//        real(pfdp), intent(in)  :: v
//        real(pfdp), intent(in)  :: nu
//        real(pfdp), intent(in)  :: Lx
//real(pfdp)  :: u
//
//        integer    :: nx, i, ii, k,nbox
//
//real(pfdp) ::  xx,c,t0
//
//        u=0.0_pfdp
//if (nu .gt. 0.0) then
//        t0=0.0025_pfdp/nu
//nbox = ceiling(sqrt(4.0_pfdp*nu*(t0+t)*37.0_pfdp))  !  Decide how many periodic images
//do k = -nbox,nbox
//xx = x- 0.5_pfdp*Lx - t*v + REAL(k,pfdp)*Lx
//u = u + sqrt(t0)/sqrt(t0+t)*exp(-xx*xx/(4.0_pfdp*nu*(t0+t)))
//end do
//else
//nbox = ceiling(sqrt(37.0d0))  !  Decide how many periodic images
//do k = -nbox,nbox
//xx = x - 0.5_pfdp*Lx- t*v  + REAL(k,pfdp)*Lx
//u = u + exp(-xx*xx/(4.0_pfdp*0.0025_pfdp))
//end do
//
//end if
//
//end function ad_exp_ex
//
//        subroutine exact_ad_exp_1d(t, uex,nu,v,Lx)
//real(pfdp), intent(in)  :: t
//        real(pfdp), intent(inout) :: uex(:)
//real(pfdp), intent(in) :: nu,v,Lx
//
//        integer    :: nx, i
//real(pfdp) :: x
//
//        nx = SIZE(uex)
//do i = 1, nx
//x = Lx*REAL(i-1,pfdp)/REAL(nx,pfdp)
//uex(i) = ad_exp_ex(t, x,nu,v,Lx)
//end do
//
//end subroutine exact_ad_exp_1d


// get exact solution at time t
void exact(double* out, int nx, double t) {
    if(local_prm.ic_type == 1) // cosine wave
        exact_ad_cos_1ds(t, out, nx, local_prm.nu, local_prm.v, local_prm.kfreq, local_prm.Lx);
    //else // exponential
        //exact_ad_exp(t, out, local_prm.nu, local_prm.v, local_prm.Lx);
}