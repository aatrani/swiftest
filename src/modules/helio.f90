module helio
   !! author: The Purdue Swiftest Team -  David A. Minton, Carlisle A. Wishard, Jennifer L.L. Pouplin, and Jacob R. Elliott
   !!
   !! Definition of classes and methods specific to the Democratic Heliocentric Method
   !! Adapted from David E. Kaufmann's Swifter modules: helio.f90
   use swiftest_globals
   use swiftest_data_structures
   implicit none

   !! Helio test particle class
   type, public, extends(swiftest_tp) :: helio_tp
      real(DP), dimension(:,:), allocatable :: ah  !! Total heliocentric acceleration
      real(DP), dimension(:,:), allocatable :: ahi !! Teliocentric acceleration due to interactions
   contains
      procedure :: alloc => helio_tp_allocate
      final :: helio_tp_deallocate
      procedure, public :: get_acch => helio_getacch_tp !! Compute heliocentric accelerations of test particles
   end type helio_tp

   !! Helio massive body particle class
   type, public, extends(swiftest_pl) :: helio_pl
      real(DP), dimension(:,:), allocatable :: ah  !! Total heliocentric acceleration
      real(DP), dimension(:,:), allocatable :: ahi !! Heliocentric acceleration due to interactions
   contains
      procedure :: alloc => helio_pl_allocate   !! Constructor method - Allocates space for number of particles
      final :: helio_pl_deallocate              !! Finalizer method - Deallocates all allocatables 
      procedure, public :: get_acch => helio_getacch !! Compute heliocentric accelerations of plAnetss
   end type helio_pl

!> Interfaces for all helio particle methods that are implemented in separate submodules 
interface

   subroutine helio_drift_pl(helio_plA, dt, dummy_mu)
      implicit none
      class(helio_pl), intent(inout) :: helio_plA !! Helio massive body particle data structure
      real(DP), intent(in)           :: dt        !! Stepsize
      real(DP), optional, intent(in) :: dummy_mu  !! Dummy argument used to make this method to be polymorphic pl and tp classes
   end subroutine helio_drift_pl

   subroutine helio_drift_tp(helio_tpA, dt, mu)
      implicit none
      class(helio_tp), intent(inout) :: helio_tpA  !! Helio test particle data structure
      real(DP), intent(in)           :: dt         !! Stepsize
      real(DP), optional, intent(in) :: mu         !! Central mass term. Argument is optional so that this can be a polymorphic method for both pl and tp classes
   end subroutine helio_drift_tp

   subroutine helio_getacch_pl(helio_plA, dummy_helio_plA, param, t, lflag)
      use user
      implicit none
      class(helio_pl), intent(inout)         :: helio_plA       !! Helio massive body particle data structure. 
      class(helio_pl), optional, intent(in)  :: dummy_helio_plA !! Dummy argument used to make this a polymorphic method for both pl and tp classes
      type(user_input_parameters),intent(in) :: param           !! Input collection of user-defined parameter
      real(DP), intent(in)                   :: t               !! Current time. This is passed to the user-defined acceleration function.
      logical, intent(in)                    :: lflag           !! Logical flag indicating whether to recompute direct cross term accelrations
   end subroutine helio_getacch_pl

   subroutine helio_getacch_tp(helio_tpA, helio_plA, param, t, lflag)
      use user
      implicit none
      class(helio_tp), intent(inout)         :: helio_tpA !! Helio test particle data structure
      class(helio_pl), optional, intent(in)  :: helio_plA !! Helio massive body particle data structure. Optional to allow this method to be polymorphic for pl and tp classes
      type(user_input_parameters),intent(in) :: param     !! Input collection of user-defined parameter
      real(DP), intent(in)                   :: t         !! Current time. This is passed to the user-defined acceleration function.
   end subroutine helio_getacch_tp

   subroutine helio_getacch_int_pl(helio_plA, dummy_helio_plA)
      implicit none
      class(helio_pl), intent(inout)        :: helio_plA       !! Helio massive body particle data structure.
      class(helio_pl), optional, intent(in) :: dummy_helio_plA !! Dummy argument used to make this a polymorphic method for both pl and tp classes
   end subroutine helio_getacch_int_pl

   subroutine helio_getacch_int_tp(helio_tpA, helio_plA)
      implicit none
      class(helio_tp), intent(inout)        :: helio_tpA !! Helio test particle data structure
      class(helio_pl), optional, intent(in) :: helio_plA !! Helio massive body particle data structure. Optional to allow this method to be polymorphic for pl and tp classes
   end subroutine helio_getacch_int_tp

   subroutine helio_kickvb_pl(helio_plA, dt)
      implicit none
      class(helio_pl), intent(inout) :: helio_plA !! Helio massive body particle data structure.
      real(DP), intent(in)           :: dt        !! Stepsize
   end subroutine helio_kickvb_pl

   subroutine helio_kickvb_tp(helio_tpA, dt)
      implicit none
      class(helio_tp), intent(inout) :: helio_tpA  !! Helio test particle data structure
      real(DP), intent(in)           :: dt         !! Stepsize
   end subroutine helio_kickvb_tp

   subroutine helio_lindrift_pl(helio_plA, dt, pt)
      implicit none
      class(helio_pl), intent(inout)           :: helio_plA !! Helio massive body particle data structur
      real(DP), intent(in)                     :: dt        !! Stepsize
      real(DP), dimension(NDIM), intent(inout) :: pt        !! Negative barycentric velocity of the Sun
   end subroutine helio_lindrift_pl

   subroutine helio_lindrift_tp(helio_tpA, dt, pt)
      implicit none
      class(helio_tp), intent(inout)           :: helio_tpA !! Helio test particle data structure
      real(DP), intent(in)                     :: dt        !! Stepsize
      real(DP), dimension(NDIM), intent(inout) :: pt        !! Negative barycentric velocity of the Sun
   end subroutine helio_lindrift_tp

   subroutine helio_step(helio_plA, helio_tpA, param, t, dt, lfirst)
      implicit none
      use user
      type(helio_pl), intent(inout)          :: helio_plA !! Helio massive body particle data structure. 
      type(helio_tp), intent(inout)          :: helio_tpA !! Helio test particle data structure
      type(user_input_parameters),intent(in) :: param     !! Input collection of user-defined parameter
      real(DP), intent(in)                   :: t         !! Current time
      real(DP), intent(in)                   :: dt        !! Stepsiz
      logical, intent(inout)                 :: lfirst    !! Logical flag indicating whether current invocation is the first 
                                                          !!     TODO: Replace lfirst with internal flag with save attribute
   end subroutine helio_step

   subroutine helio_step_pl(helio_plA, dummy_helio_plA, param, t, dt, lfirst, xbeg, xend, ptb, pte)
      implicit none
      class(helio_pl), intent(inout)         :: helio_plA       !! Helio massive body particle data structure.
      class(helio_pl), optional, intent(in)  :: dummy_helio_plA !! Dummy argument used to make this a polymorphic method for both pl and tp classes
      type(user_input_parameters),intent(in) :: param           !! Input collection of user-defined parameter
      real(DP), intent(in)                   :: t               !! Current time
      real(DP), intent(in)                   :: dt              !! Stepsize
      logical, intent(inout)                 :: lfirst          !! Logical flag indicating whether current invocation is the first 
                                                                !!     TODO: Replace lfirst with internal flag with save attribute
      real(DP), dimension(:), intent(in)     :: ptb             !! Negative barycentric velocity of the Sun at beginning of time step
      real(DP), dimension(:), intent(in)     :: pte             !! Negative barycentric velocity of the Sun at end of time step
      real(DP), dimension(:, :), intent(in)  :: xbeg            !! Heliocentric planet positions at beginning of time step
      real(DP), dimension(:, :), intent(in)  :: xend            !! Heliocentric planet positions at end of time step
   end subroutine helio_step_pl

   subroutine helio_step_tp(helio_tpA, helio_plA, param, t, dt, lfirst, xbeg, xend, ptb, pte)
      implicit none
      class(helio_tp), intent(inout)         :: helio_tpA !! Helio test particle data structure.
      class(helio_pl), optional, intent(in)  :: helio_plA !! Helio massive body particle data structure.
      type(user_input_parameters),intent(in) :: param     !! Input collection of user-defined parameter
      real(DP), intent(in)                   :: t         !! Current time
      real(DP), intent(in)                   :: dt        !! Stepsize
      logical, intent(inout)                 :: lfirst    !! Logical flag indicating whether current invocation is the first 
                                                          !!     TODO: Replace lfirst with internal flag with save attribute
      real(DP), dimension(:), intent(in)     :: ptb       !! Negative barycentric velocity of the Sun at beginning of time step
      real(DP), dimension(:), intent(in)     :: pte       !! Negative barycentric velocity of the Sun at end of time step
      real(DP), dimension(:, :), intent(in)  :: xbeg      !! Heliocentric planet positions at beginning of time step
      real(DP), dimension(:, :), intent(in)  :: xend      !! Heliocentric planet positions at end of time step
   end subroutine helio_step_tp

   subroutine helio_user_getacch_pl(helio_plA, t)
      implicit none
      class(helio_pl), intent(inout) :: helio_plA  !! Helio massive body particle data structure
      real(DP), intent(in)           :: t          !! Current tim
   end subroutine helio_user_getacch_pl

   subroutine helio_user_getacch_tp(helio_tpA, t)
      implicit none
      class(helio_tp), intent(inout) :: helio_tpA  !! Helio massive body particle data structure
      real(DP), intent(in)           :: t          !! Current tim
   end subroutine helio_user_getacch_tp
end interface

!> Only the constructor and destructor method implementations are listed here. All other methods are implemented in the helio submodules.
   contains
      !! Helio constructor and desctructor methods
      subroutine helio_tp_allocate(self,n)
         !! Helio test particle constructor method
         implicit none

         class(helio_tp), intent(inout) :: self !! Swiftest test particle object
         integer, intent(in)            :: n    !! Number of test particles to allocate

         if (self%is_allocated) then
            write(*,*) 'Helio test particle structure already alllocated'
            return
         end if
         write(*,*) 'Allocating the Swiftest test particle structure'
         
         call self%swiftest_tp%alloc(n)
         if (n <= 0) return
         allocate(self%ah(NDIM,n))
         allocate(self%ahi(NDIM,n))

         self%ah(:,:) = 0.0_DP
         self%ahi(:,:) = 0.0_DP
         return
      end subroutine helio_tp_allocate

      subroutine helio_tp_deallocate(self)
         !! Helio test particle destructor/finalizer
         implicit none

         type(helio_tp), intent(inout)    :: self

         if (self%is_allocated) then
            deallocate(self%ah)
            deallocate(self%ahi)
         end if
         return
      end subroutine helio_tp_deallocate

      subroutine helio_pl_allocate(self,n)
         !! Helio massive body constructor method
         implicit none

         class(helio_pl), intent(inout)    :: self !! Swiftest test particle object
         integer, intent(in)                  :: n    !! Number of test particles to allocate

         if (self%is_allocated) then
            write(*,*) 'Helio plAnet structure already alllocated'
            return
         end if
         call self%swiftest_pl%alloc(n)

         if (n <= 0) return
         allocate(self%ah(NDIM,n))
         allocate(self%ahi(NDIM,n))

         self%ah(:,:) = 0.0_DP
         self%ahi(:,:) = 0.0_DP
         return
      end subroutine helio_pl_allocate

      subroutine helio_pl_deallocate(self)
         !! Helio massive body destructor/finalizer
         implicit none

         type(helio_pl), intent(inout)    :: self
         if (self%is_allocated) then
            deallocate(self%ah)
            deallocate(self%ahi)
         end if
         return
      end subroutine helio_pl_deallocate

      

end module helio