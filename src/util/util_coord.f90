submodule(swiftest_classes) s_util_coord
   use swiftest
contains

   module subroutine util_coord_h2b_pl(self, cb)
      !! author: David A. Minton
      !!
      !! Convert massive bodies from heliocentric to barycentric coordinates (position and velocity)
      !!
      !! Adapted from David E. Kaufmann's Swifter routine coord_h2b.f90 
      !! Adapted from Hal Levison's Swift routine coord_h2b.f 
      implicit none
      ! Arguments
      class(swiftest_pl), intent(inout) :: self !! Swiftest massive body object
      class(swiftest_cb), intent(inout) :: cb   !! Swiftest central body object
      ! Internals
      integer(I4B)  :: i
      real(DP)      :: Gmtot
      real(DP), dimension(NDIM) :: xtmp, vtmp

      if (self%nbody == 0) return
      associate(pl => self, npl => self%nbody)
         Gmtot = cb%Gmass
         xtmp(:) = 0.0_DP
         vtmp(:) = 0.0_DP
         do i = 1, npl
            if (pl%status(i) == INACTIVE) cycle
            Gmtot = Gmtot + pl%Gmass(i)
            xtmp(:) = xtmp(:) + pl%Gmass(i) * pl%xh(:,i)
            vtmp(:) = vtmp(:) + pl%Gmass(i) * pl%vh(:,i)
         end do
         cb%xb(:) = -xtmp(:) / Gmtot
         cb%vb(:) = -vtmp(:) / Gmtot
         do i = 1, npl
            if (pl%status(i) == INACTIVE) cycle
            pl%xb(:,i) = pl%xh(:,i) + cb%xb(:)
            pl%vb(:,i) = pl%vh(:,i) + cb%vb(:)
         end do
      end associate

      return
   end subroutine util_coord_h2b_pl


   module subroutine util_coord_xh2xb_pl(self, cb)
      !! author: David A. Minton
      !!
      !! Convert position vectors of massive bodies from heliocentric to barycentric coordinates (position and velocity)
      !!
      !! Adapted from David E. Kaufmann's Swifter routine coord_h2b.f90 
      !! Adapted from Hal Levison's Swift routine coord_h2b.f 
      implicit none
      ! Arguments
      class(swiftest_pl), intent(inout) :: self !! Swiftest massive body object
      class(swiftest_cb), intent(inout) :: cb   !! Swiftest central body object
      ! Internals
      integer(I4B)  :: i
      real(DP)      :: Gmtot
      real(DP), dimension(NDIM) :: xtmp

      if (self%nbody == 0) return
      associate(pl => self, npl => self%nbody)
         Gmtot = cb%Gmass
         xtmp(:) = 0.0_DP
         do i = 1, npl
            if (pl%status(i) == INACTIVE) cycle
            Gmtot = Gmtot + pl%Gmass(i)
            xtmp(:) = xtmp(:) + pl%Gmass(i) * pl%xh(:,i)
         end do
         cb%xb(:) = -xtmp(:) / Gmtot
         do i = 1, npl
            if (pl%status(i) == INACTIVE) cycle
            pl%xb(:,i) = pl%xh(:,i) + cb%xb(:)
         end do
      end associate

      return
   end subroutine util_coord_xh2xb_pl


   module subroutine util_coord_h2b_tp(self, cb)
      !! author: David A. Minton
      !!
      !! Convert massive bodies from heliocentric to barycentric coordinates (position and velocity)
      !!
      !! Adapted from David E. Kaufmann's Swifter routine coord_h2b_tp.f90 
      !! Adapted from Hal Levison's Swift routine coord_h2b_tp.f 
      implicit none
      ! Arguments
      class(swiftest_tp), intent(inout) :: self !! Swiftest test particle object
      class(swiftest_cb), intent(in) :: cb   !! Swiftest central body object
      ! Internals
      integer(I4B) :: i

      if (self%nbody == 0) return
      associate(tp => self, ntp => self%nbody)
         do concurrent (i = 1:ntp, tp%status(i) /= INACTIVE)
            tp%xb(:, i) = tp%xh(:, i) + cb%xb(:)
            tp%vb(:, i) = tp%vh(:, i) + cb%vb(:)
         end do
      end associate

      return
   end subroutine util_coord_h2b_tp


   module subroutine util_coord_b2h_pl(self, cb)
      !! author: David A. Minton
      !!
      !! Convert massive bodies from barycentric to heliocentric coordinates (position and velocity)
      !!
      !! Adapted from David E. Kaufmann's Swifter routine coord_b2h.f90 
      !! Adapted from Hal Levison's Swift routine coord_b2h.f 
      implicit none
      ! Arguments
      class(swiftest_pl),     intent(inout) :: self !! Swiftest massive body object
      class(swiftest_cb),  intent(inout) :: cb   !! Swiftest central body object
      ! Internals
      integer(I4B)          :: i

      if (self%nbody == 0) return

      associate(pl => self, npl => self%nbody)
         do concurrent (i = 1:npl, pl%status(i) /= INACTIVE)
            pl%xh(:, i) = pl%xb(:, i) - cb%xb(:)
            pl%vh(:, i) = pl%vb(:, i) - cb%vb(:)
         end do
      end associate

      return
   end subroutine util_coord_b2h_pl


   module subroutine util_coord_b2h_tp(self, cb)
      !! author: David A. Minton
      !!
      !! Convert test particles from barycentric to heliocentric coordinates (position and velocity)
      !!
      !! Adapted from David E. Kaufmann's Swifter routine coord_b2h_tp.f90 
      !! Adapted from Hal Levison's Swift routine coord_b2h_tp.f 
      implicit none
      ! Arguments
      class(swiftest_tp),     intent(inout) :: self !! Swiftest massive body object
      class(swiftest_cb),  intent(in)    :: cb   !! Swiftest central body object
      ! Internals
      integer(I4B) :: i

      if (self%nbody == 0) return

      associate(tp => self, ntp => self%nbody)
         do concurrent(i = 1:ntp, tp%status(i) /= INACTIVE)
            tp%xh(:, i) = tp%xb(:, i) - cb%xb(:)
            tp%vh(:, i) = tp%vb(:, i) - cb%vb(:)
         end do
      end associate

      return
   end subroutine util_coord_b2h_tp
   
end submodule s_util_coord