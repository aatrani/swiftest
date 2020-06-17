submodule (symba) s_symba_helio_drift_tp
contains
   module procedure symba_helio_drift_tp
   !! author: David A. Minton
   !!
   !! Loop through test particles and call Danby drift routine
   !!
   !! Adapted from David E. Kaufmann's Swifter modules: symba_helio_drift_tp.f90
   !! Adapted from Hal Levison's Swift routine symba5_helio_drift.f
   use swiftest
   implicit none
   integer(I4B)          :: i, iflag

   do i = 1, ntp
      if ((symba_tpA%levelg(i) == irec) .and. (symba_tpA%status(i) == active)) then
         call drift_one(mu, symba_tpA%xh(:,i), symba_tpA%vb(:,i), dt, iflag)
         if (iflag /= 0) then
            symba_tpA%status(i) = discarded_drifterr
            write(*, *) "particle ", symba_tpA%name(i), " lost due to error in danby drift"
         end if
      end if
   end do

   return

   end procedure symba_helio_drift_tp
end submodule s_symba_helio_drift_tp
