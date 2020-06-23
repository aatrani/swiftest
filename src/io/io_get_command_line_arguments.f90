submodule (swiftest_classes) s_io_get_command_line_arguments


contains

   subroutine io_usage_message()
      !use swiftest
      implicit none
      write(*,*) 'Usage: swiftest [bs|helio|ra15|rmvs|symba|tu4|whm] configfile'
   end subroutine io_usage_message

   subroutine io_help_message()
      !use swiftest
      implicit none
      ! TODO: Put in a more detailed help message
      call io_useage_message()
   end subroutine io_help_message

   module procedure io_get_command_line_arguments
      !! author: David A. Minton
      !!
      !! Reads in the name of the configuration file. 
      use swiftest_globals
      implicit none

      character(len=STRMAX) :: arg1, arg2
      integer :: i,narg,ierr_arg1, ierr_arg2
      character(len=*),parameter    :: linefmt = '(A)'

      ierr = -1 ! Default is to fail
      narg = command_argument_count() !
      if (narg == 2) then
         call get_command_argument(1, arg1, status = ierr_arg1)
         call get_command_argument(2, arg2, status = ierr_arg2)
         if ((ierr_arg1 == 0) .and. (ierr_arg2 == 0)) then
            ierr = 0
            call util_toupper(arg1)
            select case(arg1)
            case('BS')
               integrator = BS
            case('HELIO')
               integrator = HELIO
            case('RA15')
               integrator = RA15
            case('TU4')
               integrator = TU4
            case('WHM')
               integrator = WHM
            case('RMVS')
               integrator = RMVS
            case('SYMBA')
               integrator = SYMBA
            case('RINGMOONS')
               integrator = RINGMOONS
            case default
               integrator = UNKNOWN_INTEGRATOR
               write(*,*) trim(adjustl(arg1)) // ' is not a valid integrator.'
               ierr = -1
            end select
            config_file_name = trim(adjustl(arg2))
         end if
      else 
         call get_command_argument(1, arg1, status = ierr_arg1)
         if (ierr_arg1 == 0) then
            if (arg1 == '-v' .or. arg1 == '--version') then
               call util_version 
            else if (arg1 == '-h' .or. arg1 == '--help') then
               call io_help_message()
            end if
         end if
      end if
      if (ierr /= 0) call io_usage_message()
   end procedure io_get_command_line_arguments



end submodule s_io_get_command_line_arguments
