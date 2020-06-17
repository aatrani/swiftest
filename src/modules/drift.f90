submodule(swiftest_data_structures) drift
implicit none

interface

   pure module subroutine drift_dan(mu, x0, v0, dt0, iflag)
      implicit none
      integer(I4B), intent(out)                :: iflag
      real(DP), intent(in)                     :: mu, dt0
      real(DP), dimension(:), intent(inout)    :: x0, v0
   end subroutine drift_dan

   pure module subroutine drift_kepmd(dm, es, ec, x, s, c)
      implicit none
      real(DP), intent(in)  :: dm, es, ec
      real(DP), intent(out) :: x, s, c
   end subroutine drift_kepmd

   pure module subroutine drift_kepu(dt,r0,mu,alpha,u,fp,c1,c2,c3,iflag)
      implicit none
      integer(I4B), intent(out) :: iflag
      real(DP), intent(in)      :: dt, r0, mu, alpha, u
      real(DP), intent(out)     :: fp, c1, c2, c3
   end subroutine drift_kepu

   pure module subroutine drift_kepu_fchk(dt, r0, mu, alpha, u, s, f)
      implicit none
      real(DP), intent(in)  :: dt, r0, mu, alpha, u, s
      real(DP), intent(out) :: f
   end subroutine drift_kepu_fchk

   pure module subroutine drift_kepu_guess(dt, r0, mu, alpha, u, s)
      implicit none
      real(DP), intent(in)  :: dt, r0, mu, alpha, u
      real(DP), intent(out) :: s
   end subroutine drift_kepu_guess

   pure module subroutine drift_kepu_lag(s, dt, r0, mu, alpha, u, fp, c1, c2, c3, iflag)
      implicit none
      integer(I4B), intent(out) :: iflag
      real(DP), intent(in)      :: dt, r0, mu, alpha, u
      real(DP), intent(inout)   :: s
      real(DP), intent(out)     :: fp, c1, c2, c3
   end subroutine drift_kepu_lag

   pure module subroutine drift_kepu_new(s, dt, r0, mu, alpha, u, fp, c1, c2, c3, iflag)
      implicit none
      integer(I4B), intent(out) :: iflag
      real(DP), intent(in)      :: dt, r0, mu, alpha, u
      real(DP), intent(inout)   :: s
       real(DP), intent(out)     :: fp, c1, c2, c3
   end subroutine drift_kepu_new

   pure module subroutine drift_kepu_p3solve(dt, r0, mu, alpha, u, s, iflag)
      implicit none
      integer(I4B), intent(out) :: iflag
      real(DP), intent(in)      :: dt, r0, mu, alpha, u
      real(DP), intent(out)     :: s
   end subroutine drift_kepu_p3solve

   pure module subroutine drift_kepu_stumpff(x, c0, c1, c2, c3)
      implicit none
      real(DP), intent(inout) :: x
      real(DP), intent(out)   :: c0, c1, c2, c3
   end subroutine drift_kepu_stumpff

   module elemental subroutine drift_one(mu, posx, posy, posz, vx, vy, vz, dt, iflag)
      implicit none
      real(DP), intent(in)      :: mu                !! G * (m1 + m2), G = gravitational constant, m1 = mass of central body, m2 = mass of body to drift
      real(DP), intent(inout)   :: posx, posy, posz  !! Position of body to drift
      real(DP), intent(inout)   :: vx, vy, vz        !! Velocity of body to drift
      real(DP), intent(in)      :: dt                !! Step size
      integer(I4B), intent(out) :: iflag             !! iflag : error status flag for Danby drift (0 = OK, nonzero = ERROR)
   end subroutine drift_one

end interface

end submodule drift
