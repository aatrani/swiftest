submodule(swiftest_classes) s_user_getacch
   use swiftest
contains
   module subroutine user_getacch_body(self, cb, param, t)
      !! author: David A. Minton
      !!
      !! Add user-supplied heliocentric accelerations to planets
      !!
      !! Adapted from David E. Kaufmann's Swifter routine whm_user_getacch.f90
      implicit none
      ! Arguments
      class(swiftest_body),          intent(inout) :: self   !! Swiftest massive body particle data structure
      class(swiftest_cb),            intent(inout) :: cb     !! Swiftest central body particle data structuree
      class(swiftest_parameters), intent(in)    :: param !! Input collection of user parameters parameters
      real(DP),                      intent(in)    :: t      !! Current time

      return
   end subroutine user_getacch_body

end submodule s_user_getacch
