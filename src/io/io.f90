submodule (swiftest_classes) s_io
   use swiftest
contains
   module subroutine io_config_reader(self, unit, iotype, v_list, iostat, iomsg) 
      !! author: The Purdue Swiftest Team - David A. Minton, Carlisle A. Wishard, Jennifer L.L. Pouplin, and Jacob R. Elliott
      !!
      !! Read in parameters for the integration
      !! Currently this procedure does not work in user-defined derived-type input mode 
      !!    e.g. read(unit,'(DT)') param 
      !! as the newline characters are ignored in the input file when compiled in ifort.
      !!
      !! Adapted from David E. Kaufmann's Swifter routine io_init_config.f90
      !! Adapted from Martin Duncan's Swift routine io_init_config.f
      implicit none
      ! Arguments
      class(swiftest_configuration), intent(inout) :: self       !! Collection of  configuration parameters
      integer, intent(in)                          :: unit       !! File unit number
      character(len=*), intent(in)                 :: iotype     !! Dummy argument passed to the  input/output procedure contains the text from the char-literal-constant, prefixed with DT. 
                                                                 !!    If you do not include a char-literal-constant, the iotype argument contains only DT.
      integer, intent(in)                          :: v_list(:)  !! The first element passes the integrator code to the reader
      integer, intent(out)                         :: iostat     !! IO status code
      character(len=*), intent(inout)              :: iomsg      !! Message to pass if iostat /= 0
      ! Internals
      logical                        :: t0_set = .false.        !! Is the initial time set in the input file?
      logical                        :: tstop_set = .false.     !! Is the final time set in the input file?
      logical                        :: dt_set = .false.        !! Is the step size set in the input file?
      logical                        :: mtiny_set = .false.     !! Is the mtiny value set?
      integer(I4B)                   :: ilength, ifirst, ilast  !! Variables used to parse input file
      character(STRMAX)              :: line                    !! Line of the input file
      character (len=:), allocatable :: line_trim,config_name, config_value !! Strings used to parse the config file
      character(*),parameter         :: linefmt = '(A)'         !! Format code for simple text string
      integer(I4B)                   :: integrator              !! Symbolic name of integrator being used

      integrator = v_list(1)
      ! Parse the file line by line, extracting tokens then matching them up with known parameters if possible
      do
         read(unit = unit, fmt = linefmt, iostat = iostat, end = 1) line
         line_trim = trim(adjustl(line))
         ilength = len(line_trim)
         if ((ilength /= 0)) then 
            ifirst = 1
            ! Read the pair of tokens. The first one is the parameter name, the second is the value.
            config_name = io_get_token(line_trim, ifirst, ilast, iostat)
            if (config_name == '') cycle ! No parameter name (usually because this line is commented out)
            call util_toupper(config_name)
            ifirst = ilast + 1
            config_value = io_get_token(line_trim, ifirst, ilast, iostat)
            select case (config_name)
            case ("NPLMAX")
               read(config_value, *) self%nplmax
            case ("NTPMAX")
               read(config_value, *) self%ntpmax
            case ("T0")
               read(config_value, *) self%t0
               t0_set = .true.
            case ("TSTOP")
               read(config_value, *) self%tstop
               tstop_set = .true.
            case ("DT")
               read(config_value, *) self%dt
               dt_set = .true.
            case ("CB_IN")
               self%incbfile = config_value
            case ("PL_IN")
               self%inplfile = config_value
            case ("TP_IN")
               self%intpfile = config_value
            case ("IN_TYPE")
               call util_toupper(config_value)
               self%in_type = config_value
            case ("ISTEP_OUT")
               read(config_value, *) self%istep_out
            case ("BIN_OUT")
               self%outfile = config_value
            case ("OUT_TYPE")
               call util_toupper(config_value)
               self%out_type = config_value
            case ("OUT_FORM")
               call util_toupper(config_value)
               self%out_form = config_value
            case ("OUT_STAT")
               call util_toupper(config_value)
               self%out_stat = config_value
            case ("ISTEP_DUMP")
               read(config_value, *) self%istep_dump
            case ("CHK_CLOSE")
               call util_toupper(config_value)
               if (config_value == "YES" .or. config_value == 'T') self%lclose = .true.
            case ("CHK_RMIN")
               read(config_value, *) self%rmin
            case ("CHK_RMAX")
               read(config_value, *) self%rmax
            case ("CHK_EJECT")
               read(config_value, *) self%rmaxu
            case ("CHK_QMIN")
               read(config_value, *) self%qmin
            case ("CHK_QMIN_COORD")
               call util_toupper(config_value)
               self%qmin_coord = config_value
            case ("CHK_QMIN_RANGE")
               read(config_value, *) self%qmin_alo
               ifirst = ilast + 1
               config_value = io_get_token(line, ifirst, ilast, iostat)
               read(config_value, *) self%qmin_ahi
            case ("ENC_OUT")
               self%encounter_file = config_value
            case ("EXTRA_FORCE")
               call util_toupper(config_value)
               if (config_value == "YES" .or. config_value == 'T') self%lextra_force = .true.
            case ("BIG_DISCARD")
               call util_toupper(config_value)
               if (config_value == "YES" .or. config_value == 'T' ) self%lbig_discard = .true.
            case ("FRAGMENTATION")
               call util_toupper(config_value)
               if (config_value == "YES" .or. config_value == "T") self%lfragmentation = .true.
            case ("MU2KG")
               read(config_value, *) self%MU2KG
            case ("TU2S")
               read(config_value, *) self%TU2S
            case ("DU2M")
               read(config_value, *) self%DU2M
            case ("MTINY")
               read(config_value, *) self%mtiny
               mtiny_set = .true.
            case ("ENERGY")
               call util_toupper(config_value)
               if (config_value == "YES" .or. config_value == 'T') self%lenergy = .true.
            case ("ROTATION")
               call util_toupper(config_value)
               if (config_value == "YES" .or. config_value == 'T') self%lrotation = .true. 
            case ("TIDES")
               call util_toupper(config_value)
               if (config_value == "YES" .or. config_value == 'T') self%ltides = .true. 
            case ("GR")
               call util_toupper(config_value)
               if (config_value == "YES" .or. config_value == 'T') self%lgr = .true. 
            case ("YARKOVSKY")
               call util_toupper(config_value)
               if (config_value == "YES" .or. config_value == 'T') self%lyarkovsky = .true. 
            case ("YORP")
               call util_toupper(config_value)
               if (config_value == "YES" .or. config_value == 'T') self%lyorp = .true. 
            case default
               write(iomsg,*) "Unknown parameter -> ",config_name
               iostat = -1
               return
            end select
         end if
      end do
      1 continue
      iostat = 0

      !! Do basic sanity checks on the input values
      if ((.not. t0_set) .or. (.not. tstop_set) .or. (.not. dt_set)) then
         write(iomsg,*) 'Valid simulation time not set'
         iostat = -1
         return
      end if
      if (self%dt <= 0.0_DP) then
         write(iomsg,*) 'Invalid timestep: '
         iostat = -1
         return
      end if
      if (self%inplfile == "") then
         write(iomsg,*) 'No valid massive body file in input file'
         iostat = -1
         return
      end if
      if ((self%in_type /= REAL8_TYPE) .and. (self%in_type /= "ASCII")) then
         write(iomsg,*) 'Invalid input file type:',trim(adjustl(self%in_type))
         iostat = -1
         return
      end if
      if ((self%istep_out <= 0) .and. (self%istep_dump <= 0)) then
         write(iomsg,*) 'Invalid istep'
         iostat = -1
         return
      end if
      if ((self%istep_out > 0) .and. (self%outfile == "")) then
         write(iomsg,*) 'Invalid outfile'
         iostat = -1
         return
      end if
      if (self%outfile /= "") then
         if ((self%out_type /= REAL4_TYPE) .and. (self%out_type /= REAL8_TYPE) .and. &
               (self%out_type /= SWIFTER_REAL4_TYPE)  .and. (self%out_type /= SWIFTER_REAL8_TYPE)) then
            write(iomsg,*) 'Invalid out_type: ',trim(adjustl(self%out_type))
            iostat = -1
            return
         end if
         if ((self%out_form /= "EL") .and. (self%out_form /= "XV")) then
            write(iomsg,*) 'Invalid out_form: ',trim(adjustl(self%out_form))
            iostat = -1
            return
         end if
         if ((self%out_stat /= "NEW") .and. (self%out_stat /= "REPLACE") .and. (self%out_stat /= "APPEND")) then
            write(iomsg,*) 'Invalid out_stat: ',trim(adjustl(self%out_stat))
            iostat = -1
            return
         end if
      end if
      if (self%qmin > 0.0_DP) then
         if ((self%qmin_coord /= "HELIO") .and. (self%qmin_coord /= "BARY")) then
            write(iomsg,*) 'Invalid qmin_coord: ',trim(adjustl(self%qmin_coord))
            iostat = -1
            return
         end if
         if ((self%qmin_alo <= 0.0_DP) .or. (self%qmin_ahi <= 0.0_DP)) then
            write(iomsg,*) 'Invalid qmin vals'
            iostat = -1
            return
         end if
      end if

      write(*,*) "NPLMAX         = ",self%nplmax
      write(*,*) "NTPMAX         = ",self%ntpmax
      write(*,*) "T0             = ",self%t0
      write(*,*) "TSTOP          = ",self%tstop
      write(*,*) "DT             = ",self%dt
      write(*,*) "CB_IN          = ",trim(adjustl(self%incbfile))
      write(*,*) "PL_IN          = ",trim(adjustl(self%inplfile))
      write(*,*) "TP_IN          = ",trim(adjustl(self%intpfile))
      write(*,*) "IN_TYPE        = ",trim(adjustl(self%in_type))
      write(*,*) "ISTEP_OUT      = ",self%istep_out
      write(*,*) "BIN_OUT        = ",trim(adjustl(self%outfile))
      write(*,*) "OUT_TYPE       = ",trim(adjustl(self%out_type))
      write(*,*) "OUT_FORM       = ",trim(adjustl(self%out_form))
      write(*,*) "OUT_STAT       = ",trim(adjustl(self%out_stat))
      write(*,*) "ISTEP_DUMP     = ",self%istep_dump
      write(*,*) "CHK_CLOSE      = ",self%lclose
      write(*,*) "CHK_RMIN       = ",self%rmin
      write(*,*) "CHK_RMAX       = ",self%rmax
      write(*,*) "CHK_EJECT      = ",self%rmaxu
      write(*,*) "CHK_QMIN       = ",self%qmin
      write(*,*) "CHK_QMIN_COORD = ",trim(adjustl(self%qmin_coord))
      write(*,*) "CHK_QMIN_RANGE = ",self%qmin_alo, self%qmin_ahi
      write(*,*) "ENC_OUT        = ",trim(adjustl(self%encounter_file))
      write(*,*) "EXTRA_FORCE    = ",self%lextra_force
      write(*,*) "BIG_DISCARD    = ",self%lbig_discard
      if (self%lenergy) write(*,*) "ENERGY         = ",self%lenergy
      write(*,*) "MU2KG          = ",self%MU2KG       
      write(*,*) "TU2S           = ",self%TU2S        
      write(*,*) "DU2M           = ",self%DU2M        

      if ((self%MU2KG < 0.0_DP) .or. (self%TU2S < 0.0_DP) .or. (self%DU2M < 0.0_DP)) then
         write(iomsg,*) 'Invalid unit conversion factor'
         iostat = -1
         return
      end if

      ! Calculate the G for the system units
      self%GU = GC / (self%DU2M**3 / (self%MU2KG * self%TU2S**2))

      ! Calculate the inverse speed of light in the system units
      self%inv_c2 = einstinC * self%TU2S / self%DU2M
      self%inv_c2 = (self%inv_c2)**(-2)

      ! The fragmentation model requires the user to set the unit system explicitly.
      if ((integrator == SYMBA) .or. (integrator == RINGMOONS)) then 
         write(*,*) "FRAGMENTATION  = ",self%lfragmentation
         if (.not.mtiny_set) then
            write(iomsg,*) 'SyMBA requres an MTINY value'
            iostat = -1
         end if
      else
         if (self%lfragmentation) then
            write(iomsg,*) 'This integrator does not support fragmentation.'
            iostat = -1
            return
         end if
         if (mtiny_set) then
            write(iomsg,*) 'This integrator does not support MTINY'
            iostat = -1
            return
         end if
      end if

      if ((integrator == SYMBA) .or. (integrator == RINGMOONS) .or. (integrator == RMVS)) then
         if (.not.self%lclose) then
            write(iomsg,*) 'This integrator requires CHK_CLOSE to be enabled'
            iostat = -1
            return
         end if
      end if

      if (mtiny_set) then
         if (self%mtiny < 0.0_DP) then
            write(iomsg,*) "Invalid MTINY: ", self%mtiny
            iostat = -1
            return
         else
            write(*,*) "MTINY          = ", self%mtiny   
         end if
      end if

      ! Determine if the GR flag is set correctly for this integrator
      select case(integrator)
      case(WHM)
         write(*,*) "GR             = ", self%lgr
      case default   
         write(iomsg, *) 'GR is implemented compatible with this integrator'
         iostat = -1
      end select

      iostat = 0

      return 
   end subroutine io_config_reader

   module subroutine io_config_writer(self, unit, iotype, v_list, iostat, iomsg) 
      !! author: David A. Minton
      !!
      !! Dump integration parameters to file
      !!
      !! Adapted from David E. Kaufmann's Swifter routine io_dump_config.f90
      !! Adapted from Martin Duncan's Swift routine io_dump_config.f
      implicit none
      ! Arguments
      class(swiftest_configuration),intent(in)     :: self         !! Collection of  configuration parameters
      integer, intent(in)                          :: unit       !! File unit number
      character(len=*), intent(in)                 :: iotype     !! Dummy argument passed to the  input/output procedure contains the text from the char-literal-constant, prefixed with DT. 
                                                               !!    If you do not include a char-literal-constant, the iotype argument contains only DT.
      integer, intent(in)                          :: v_list(:)  !! Not used in this procedure
      integer, intent(out)                         :: iostat     !! IO status code
      character(len=*), intent(inout)              :: iomsg      !! Message to pass if iostat /= 0
      ! Internals
                                                               !! In user-defined derived-type output, we need newline characters at the end of each format statement
      !character(*),parameter :: Ifmt  = '(A20,1X,I0/)'         !! Format label for integer values
      !character(*),parameter :: Rfmt  = '(A20,1X,ES25.17/)'    !! Format label for real values 
      !character(*),parameter :: R2fmt = '(A20,2(1X,ES25.17)/)'  !! Format label for 2x real values 
      !character(*),parameter :: Sfmt  = '(A20,1X,A/)'          !! Format label for string values 
      !character(*),parameter :: Lfmt  = '(A20,1X,L1/)'         !! Format label for logical values 
      !character(*),parameter :: Pfmt  = '(A20/)'               !! Format label for single parameter string
      character(*),parameter :: Ifmt  = '(A20,1X,I0)'         !! Format label for integer values
      character(*),parameter :: Rfmt  = '(A20,1X,ES25.17)'    !! Format label for real values 
      character(*),parameter :: R2fmt = '(A20,2(1X,ES25.17))'  !! Format label for 2x real values 
      character(*),parameter :: Sfmt  = '(A20,1X,A)'          !! Format label for string values 
      character(*),parameter :: Lfmt  = '(A20,1X,L1)'         !! Format label for logical values 
      character(*),parameter :: Pfmt  = '(A20)'               !! Format label for single parameter string

      write(unit, Ifmt) "NPLMAX",                   self%nplmax
      write(unit, Ifmt) "NTPMAX",                   self%ntpmax
      write(unit, Rfmt) "T0",                       self%t0
      write(unit, Rfmt) "TSTOP",                    self%tstop
      write(unit, Rfmt) "DT",                       self%dt
      write(unit, Sfmt) "CB_IN",                    trim(adjustl(self%incbfile))
      write(unit, Sfmt) "PL_IN",                    trim(adjustl(self%inplfile))
      write(unit, Sfmt) "TP_IN",                    trim(adjustl(self%intpfile))
      write(unit, Sfmt) "IN_TYPE",                  trim(adjustl(self%out_type))
      if (self%istep_out > 0) then
         write(unit, Ifmt) "ISTEP_OUT",             self%istep_out
         write(unit, Sfmt) "BIN_OUT",               trim(adjustl(self%outfile))
         write(unit, Sfmt) "OUT_TYPE",              trim(adjustl(self%out_type))
         write(unit, Sfmt) "OUT_FORM",              trim(adjustl(self%out_form))
         write(unit, Sfmt) "OUT_STAT",              "APPEND"
      else
         write(unit, Pfmt) "!ISTEP_OUT "
         write(unit, Pfmt) "!BIN_OUT"
         write(unit, Pfmt) "!OUT_TYPE"
         write(unit, Pfmt) "!OUT_FORM"
         write(unit, Pfmt) "!OUT_STAT"
      end if
      write(unit, Sfmt) "ENC_OUT",                  trim(adjustl(self%encounter_file))
      if (self%istep_dump > 0) then
         write(unit, Ifmt) "ISTEP_DUMP",            self%istep_dump
      else
         write(unit, Pfmt) "!ISTEP_DUMP" 
      end if
      write(unit, Rfmt) "CHK_RMIN",                 self%rmin
      write(unit, Rfmt) "CHK_RMAX",                 self%rmax
      write(unit, Rfmt) "CHK_EJECT",                self%rmaxu
      write(unit, Rfmt) "CHK_QMIN",                 self%qmin
      if (self%qmin >= 0.0_DP) then
         write(unit, Sfmt) "CHK_QMIN_COORD",        trim(adjustl(self%qmin_coord))
         write(unit, R2fmt) "CHK_QMIN_RANGE",       self%qmin_alo, self%qmin_ahi
      else
         write(unit, Pfmt) "!CHK_QMIN_COORD"
         write(unit, Pfmt) "!CHK_QMIN_RANGE"
      end if
      if (self%lmtiny) write(unit, Rfmt) "MTINY",   self%mtiny
      write(unit, Rfmt) "MU2KG",                    self%MU2KG
      write(unit, Rfmt) "TU2S",                     self%TU2S 
      write(unit, Rfmt) "DU2M",                     self%DU2M
      
      write(unit, Lfmt) "EXTRA_FORCE",              self%lextra_force
      write(unit, Lfmt) "BIG_DISCARD",              self%lbig_discard
      write(unit, Lfmt) "CHK_CLOSE",                self%lclose
      write(unit, Lfmt) "FRAGMENTATION",            self%lfragmentation
      write(unit, Lfmt) "ROTATION",                 self%lrotation
      write(unit, Lfmt) "TIDES",                    self%ltides
      write(unit, Lfmt) "GR",                       self%lgr
      write(unit, Lfmt) "ENERGY",                   self%lenergy
      !write(unit, Lfmt) "YARKOVSKY", self%lyarkovsky
      !write(unit, Lfmt) "YORP", self%lyorp

      return
   end subroutine io_config_writer

   module subroutine io_dump_config(self, config_file_name, t, dt)
      !! author: David A. Minton
      !!
      !! Dump integration parameters to file
      !!
      !! Adapted from David E. Kaufmann's Swifter routine io_dump_config.f90
      !! Adapted from Martin Duncan's Swift routine io_dump_config.f
      implicit none
      ! Arguments
      class(swiftest_configuration),intent(in) :: self    !! Output collection of  parameters
      character(len=*), intent(in)             :: config_file_name !! Parameter input file name (i.e. param.in)
      real(DP),intent(in)                      :: t       !! Current simulation time
      real(DP),intent(in)                      :: dt      !! Step size
      ! Internals
      integer(I4B), parameter      :: LUN = 7       !! Unit number of output file
      integer(I4B)                 :: ierr          !! Error code
      character(STRMAX)            :: error_message !! Error message in UDIO procedure

      open(unit = LUN, file = config_file_name, status='replace', form = 'FORMATTED', iostat =ierr)
      if (ierr /=0) then
         write(*,*) 'Swiftest error.'
         write(*,*) '   Could not open dump file: ',trim(adjustl(config_file_name))
         call util_exit(FAILURE)
      end if
      
      !! todo: Currently this procedure does not work in user-defined derived-type input mode 
      !!    due to compiler incompatabilities
      !write(LUN,'(DT)') config
      call self%writer(LUN, iotype = "none", v_list = [0], iostat = ierr, iomsg = error_message)
      if (ierr /= 0) then
         write(*,*) trim(adjustl(error_message))
         call util_exit(FAILURE)
      end if
      close(LUN)

      return
   end subroutine io_dump_config

   module subroutine io_dump_swiftest(self, config, t, dt, msg) 
      !! author: David A. Minton
      !!
      !! Dump massive body data to files
      !!
      !! Adapted from David E. Kaufmann's Swifter routine: io_dump_pl.f90 and io_dump_tp.f90
      !! Adapted from Hal Levison's Swift routine io_dump_pl.f and io_dump_tp.f
      implicit none
      ! Arguments
      class(swiftest_base),          intent(inout) :: self   !! Swiftest base object
      class(swiftest_configuration), intent(in)    :: config !! Input collection of  configuration parameters 
      real(DP),                      intent(in)    :: t      !! Current simulation time
      real(DP),                      intent(in)    :: dt     !! Stepsize
      character(*), optional,        intent(in)    :: msg  !! Message to display with dump operation
      ! Internals
      integer(I4B)                   :: ierr    !! Error code
      integer(I4B),parameter         :: LUN = 7 !! Unit number for dump file
      integer(I4B)                   :: iu = LUN
      character(len=:), allocatable  :: dump_file_name

      select type(self)
      class is(swiftest_cb)
         dump_file_name = trim(adjustl(config%incbfile)) 
      class is (swiftest_pl)
         dump_file_name = trim(adjustl(config%inplfile)) 
      class is (swiftest_tp)
         dump_file_name = trim(adjustl(config%intpfile)) 
      end select
      open(unit = iu, file = dump_file_name, form = "UNFORMATTED", status = 'replace', iostat = ierr)
      if (ierr /= 0) then
         write(*, *) "Swiftest error:"
         write(*, *) "   Unable to open binary dump file " // dump_file_name
         call util_exit(FAILURE)
      end if
      call self%write_frame(iu, config, t, dt)
      close(LUN)

      return
   end subroutine io_dump_swiftest

   module subroutine io_dump_system(self, config, t, dt, msg)
      !! author: David A. Minton
      !!
      !! Dumps the state of the system to files in case the simulation is interrupted.
      !! As a safety mechanism, there are two dump files that are written in alternating order
      !! so that if a dump file gets corrupted during writing, the user can restart from the older one.
      implicit none
      ! Arguments
      class(swiftest_nbody_system),  intent(inout) :: self    !! Swiftest system object
      class(swiftest_configuration), intent(in)    :: config  !! Input collection of  configuration parameters 
      real(DP),                      intent(in)    :: t       !! Current simulation time
      real(DP),                      intent(in)    :: dt      !! Stepsize
      character(*), optional,        intent(in)    :: msg  !! Message to display with dump operation
      ! Internals
      class(swiftest_configuration), allocatable :: dump_config   !! Local configuration variable used to configuration change input file names 
                                                    !!    to dump file-specific values without changing the user-defined values
      integer(I4B), save           :: idx = 1       !! Index of current dump file. Output flips between 2 files for extra security
                                                    !!    in case the program halts during writing
      character(len=:), allocatable :: config_file_name
      real(DP) :: tfrac
     

      allocate(dump_config, source=config)
      config_file_name = trim(adjustl(DUMP_CONFIG_FILE(idx)))
      dump_config%incbfile = trim(adjustl(DUMP_CB_FILE(idx))) 
      dump_config%inplfile = trim(adjustl(DUMP_PL_FILE(idx))) 
      dump_config%intpfile = trim(adjustl(DUMP_TP_FILE(idx)))
      dump_config%out_form = XV
      dump_config%out_stat = 'APPEND'
      call dump_config%dump(config_file_name,t,dt)

      call self%cb%dump(dump_config, t, dt)
      if (self%pl%nbody > 0) call self%pl%dump(dump_config, t, dt)
      if (self%tp%nbody > 0) call self%tp%dump(dump_config, t, dt)

      idx = idx + 1
      if (idx > NDUMPFILES) idx = 1

      ! Print the status message (format code passed in from main driver)
      tfrac = (t - config%t0) / (config%tstop - config%t0)
      write(*,msg) t, tfrac, self%pl%nbody, self%tp%nbody

      return
   end subroutine io_dump_system

   module function io_get_args(integrator, config_file_name) result(ierr)
      !! author: David A. Minton
      !!
      !! Reads in the name of the configuration file. 
      implicit none
      ! Arguments
      integer(I4B)                  :: integrator      !! Symbolic code of the requested integrator  
      character(len=:), allocatable :: config_file_name !! Name of the input configuration file
      ! Result
      integer(I4B)                  :: ierr             !! I/O error cod
      ! Internals
      character(len=STRMAX) :: arg1, arg2
      integer :: narg,ierr_arg1, ierr_arg2
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
               call util_version() 
            else if (arg1 == '-h' .or. arg1 == '--help') then
               call util_exit(HELP)
            end if
         end if
      end if
      if (ierr /= 0) call util_exit(USAGE) 
   end function io_get_args

   module function io_get_token(buffer, ifirst, ilast, ierr) result(token)
      !! author: David A. Minton
      !!
      !! Retrieves a character token from an input string. Here a token is defined as any set of contiguous non-blank characters not 
      !! beginning with or containing "!". If "!" is present, any remaining part of the buffer including the "!" is ignored
      !!
      !! Adapted from David E. Kaufmann's Swifter routine io_get_token.f90
      implicit none
      ! Arguments
      character(len=*), intent(in)     :: buffer         !! Input string buffer
      integer(I4B), intent(inout)      :: ifirst         !! Index of the buffer at which to start the search for a token
      integer(I4B), intent(out)        :: ilast          !! Index of the buffer at the end of the returned token
      integer(I4B), intent(out)        :: ierr           !! Error code
      ! Result
      character(len=:),allocatable     :: token          !! Returned token string
      ! Internals
      integer(I4B) :: i,ilength
   
      ilength = len(buffer)
   
      if (ifirst > ilength) then
          ilast = ifirst
          ierr = -1 !! Bad input
          token = ''
          return
      end if
      do i = ifirst, ilength
          if (buffer(i:i) /= ' ') exit
      end do
      if ((i > ilength) .or. (buffer(i:i) == '!')) then
          ifirst = i
          ilast = i
          ierr = -2 !! No valid token
          token = ''
          return
      end if
      ifirst = i
      do i = ifirst, ilength
          if ((buffer(i:i) == ' ') .or. (buffer(i:i) == '!')) exit
      end do
      ilast = i - 1
      ierr = 0
   
      token = buffer(ifirst:ilast)
      return
   end function io_get_token

   module subroutine io_read_body_in(self, config) 
      !! author: The Purdue Swiftest Team - David A. Minton, Carlisle A. Wishard, Jennifer L.L. Pouplin, and Jacob R. Elliott
      !!
      !! Read in either test particle or massive body data 
      !!
      !! Adapted from David E. Kaufmann's Swifter routine swiftest_init_pl.f90 and swiftest_init_tp.f90
      !! Adapted from Martin Duncan's Swift routine swiftest_init_pl.f and swiftest_init_tp.f
      implicit none
      ! Arguments
      class(swiftest_body),          intent(inout) :: self   !! Swiftest particle object
      class(swiftest_configuration), intent(inout) :: config !! Input collection of  configuration parameters
      ! Internals
      integer(I4B), parameter       :: LUN = 7              !! Unit number of input file
      integer(I4B)                  :: iu = LUN
      integer(I4B)                  :: i, ierr, nbody
      logical                       :: is_ascii, is_pl
      character(len=:), allocatable :: infile
      real(DP)                      :: t
      real(QP)                      :: val

      ! Select the appropriate polymorphic class (test particle or massive body)
      select type(self)
      class is (swiftest_pl)
         infile = config%inplfile
         is_pl = .true.
      class is (swiftest_tp)
         infile = config%intpfile
         is_pl = .false.
      end select

      ierr = 0
      is_ascii = (config%in_type == 'ASCII') 
      select case(config%in_type)
      case(ASCII_TYPE)
         open(unit = iu, file = infile, status = 'old', form = 'FORMATTED', iostat = ierr)
         read(iu, *, iostat = ierr) nbody
         call self%setup(nbody)
         if (nbody > 0) then
            do i = 1, nbody
               select type(self)
               class is (swiftest_pl)
                  read(iu, *, iostat = ierr) self%name(i), val 
                  self%mass(i) = real(val / config%GU, kind=DP)
                  self%Gmass(i) = real(val, kind=DP)
                  if (config%lclose) then
                     read(iu, *, iostat = ierr) self%radius(i)
                     if (ierr /= 0 ) exit
                  else
                     self%radius(i) = 0.0_DP
                  end if
                  if (config%lrotation) then
                     read(iu, iostat = ierr) self%Ip(:, i)
                     read(iu, iostat = ierr) self%rot(:, i)
                  end if
                  if (config%ltides) then
                     read(iu, iostat = ierr) self%k2(i)
                     read(iu, iostat = ierr) self%Q(i)
                  end if
               class is (swiftest_tp)
                  read(iu, *, iostat = ierr) self%name(i)
               end select
               if (ierr /= 0 ) exit
               read(iu, *, iostat = ierr) self%xh(1, i), self%xh(2, i), self%xh(3, i)
               read(iu, *, iostat = ierr) self%vh(1, i), self%vh(2, i), self%vh(3, i)
               if (ierr /= 0 ) exit
               self%status(i) = ACTIVE
            end do
         end if
      case (REAL4_TYPE, REAL8_TYPE)  !, SWIFTER_REAL4_TYPE, SWIFTER_REAL8_TYPE)
         open(unit = iu, file = infile, status = 'old', form = 'UNFORMATTED', iostat = ierr)
         read(iu, iostat = ierr) nbody
         call self%setup(nbody)
         if (nbody > 0) then
            call self%read_frame(iu, config, XV, t, ierr)
            self%status(:) = ACTIVE
         end if
      case default
         write(*,*) trim(adjustl(config%in_type)) // ' is an unrecognized file type'
         ierr = -1
      end select
      close(iu)
      if (ierr /= 0 ) then
         write(*,*) 'Error reading in initial conditions from ',trim(adjustl(infile))
         call util_exit(FAILURE)
      end if

      return
   end subroutine io_read_body_in

   module subroutine io_read_cb_in(self, config) 
      !! author: David A. Minton
      !!
      !! Reads in central body data 
      !!
      !! Adapted from David E. Kaufmann's Swifter routine swiftest_init_pl.f90
      !! Adapted from Martin Duncan's Swift routine swiftest_init_pl.f
      implicit none
      ! Arguments
      class(swiftest_cb),            intent(inout) :: self
      class(swiftest_configuration), intent(inout) :: config
      ! Internals
      integer(I4B), parameter :: LUN = 7              !! Unit number of input file
      integer(I4B)            :: iu = LUN
      integer(I4B)            :: ierr
      logical                 :: is_ascii 
      real(DP)                :: t
      real(QP)                :: val

      ierr = 0
      is_ascii = (config%in_type == 'ASCII') 
      if (is_ascii) then
         open(unit = iu, file = config%incbfile, status = 'old', form = 'FORMATTED', iostat = ierr)
         read(iu, *, iostat = ierr) val 
         self%Gmass = real(val, kind=DP)
         self%mass = real(val / config%GU, kind=DP)
         read(iu, *, iostat = ierr) self%radius
         read(iu, *, iostat = ierr) self%j2rp2
         read(iu, *, iostat = ierr) self%j4rp4
         if (config%lrotation) then
            read(iu, *, iostat = ierr) self%Ip(:)
            read(iu, *, iostat = ierr) self%rot(:)
         end if
         if (config%ltides) then
            read(iu, *, iostat = ierr) self%k2
            read(iu, *, iostat = ierr) self%Q
         end if
            
      else
         open(unit = iu, file = config%incbfile, status = 'old', form = 'UNFORMATTED', iostat = ierr)
         call self%read_frame(iu, config, XV, t, ierr)
      end if
      close(iu)
      if (ierr /=  0) then
         write(*,*) 'Error opening massive body initial conditions file ',trim(adjustl(config%incbfile))
         call util_exit(FAILURE)
      end if
      if (self%j2rp2 /= 0.0_DP) config%loblatecb = .true.

      return
   end subroutine io_read_cb_in

   module subroutine io_read_config_in(self, config_file_name) 
      !! author: David A. Minton
      !!
      !! Read in parameters for the integration
      !!
      !! Adapted from David E. Kaufmann's Swifter routine io_init_config.f90
      !! Adapted from Martin Duncan's Swift routine io_init_config.f
      implicit none
      ! Arguments
      class(swiftest_configuration),intent(out) :: self             !! Input collection of  configuration parameters
      character(len=*), intent(in)              :: config_file_name !! Parameter input file name (i.e. param.in)
      ! Internals
      integer(I4B), parameter :: LUN = 7                 !! Unit number of input file
      integer(I4B)            :: ierr = 0                !! Input error code
      character(STRMAX)       :: error_message           !! Error message in UDIO procedure

      ! Read in name of parameter file
      write(*, *) 'Configuration data file is ', trim(adjustl(config_file_name))
      write(*, *) ' '
      100 format(A)
      open(unit = LUN, file = config_file_name, status = 'old', iostat = ierr)
      if (ierr /= 0) then
         write(*,*) 'Swiftest error: ', ierr
         write(*,*) '   Unable to open file ',trim(adjustl(config_file_name))
         call util_exit(FAILURE)
      end if

      !! todo: Currently this procedure does not work in user-defined derived-type input mode 
      !!    as the newline characters are ignored in the input file when compiled in ifort.

      !read(LUN,'(DT)', iostat= ierr, iomsg = error_message) config
      call self%reader(LUN, iotype= "none", v_list = [self%integrator], iostat = ierr, iomsg = error_message)
      if (ierr /= 0) then
         write(*,*) 'Swiftest error reading ', trim(adjustl(config_file_name))
         write(*,*) ierr,trim(adjustl(error_message))
         call util_exit(FAILURE)
      end if

      return 
   end subroutine io_read_config_in

   module function io_read_encounter(t, name1, name2, mass1, mass2, radius1, radius2, &
         xh1, xh2, vh1, vh2, encounter_file, out_type) result(ierr)
      !! author: David A. Minton
      !!
      !! Read close encounter data from input binary files
      !!     Other than time t, there is no direct file input from this function
      !!     Function returns read error status (0 = OK, nonzero = ERROR)
      !! Adapted from David E. Kaufmann's Swifter routine: io_read_encounter.f90
      implicit none
      ! Arguments
      integer(I4B), intent(out)     :: name1, name2
      real(DP), intent(out)      :: t, mass1, mass2, radius1, radius2
      real(DP), dimension(NDIM), intent(out) :: xh1, xh2, vh1, vh2
      character(*), intent(in)      :: encounter_file, out_type
      ! Result
      integer(I4B)         :: ierr
      ! Internals
      logical , save    :: lfirst = .true.
      integer(I4B), parameter :: lun = 30
      integer(I4B), save    :: iu = lun

      if (lfirst) then
         open(unit = iu, file = encounter_file, status = 'OLD', form = 'UNFORMATTED', iostat = ierr)
         if (ierr /= 0) then
            write(*, *) "Swiftest Error:"
            write(*, *) "   unable to open binary encounter file"
            call util_exit(FAILURE)
         end if
         lfirst = .false.
      end if
      read(iu, iostat = ierr) t
      if (ierr /= 0) then
         close(unit = iu, iostat = ierr)
         return
      end if
  
      read(iu, iostat = ierr) name1, xh1(1), xh1(2), xh1(3), vh1(1), vh1(2), vh1(3), mass1, radius1
      if (ierr /= 0) then
         close(unit = iu, iostat = ierr)
         return
      end if
      read(iu, iostat = ierr) name2, xh2(2), xh2(2), xh2(3), vh2(2), vh2(2), vh2(3), mass2, radius2
      if (ierr /= 0) then
         close(unit = iu, iostat = ierr)
         return
      end if

      return
   end function io_read_encounter

   module subroutine io_read_frame_body(self, iu, config, form, t, ierr)
      !! author: David A. Minton
      !!
      !! Reads a frame of output of either test particle or massive body data to the binary output file
      !!    Note: If outputting to orbital elements, but sure that the conversion is done prior to calling this method
      !!
      !! Adapted from David E. Kaufmann's Swifter routine  io_read_frame.f90
      !! Adapted from Hal Levison's Swift routine io_read_frame.F
      implicit none
      ! Arguments
      class(swiftest_body),          intent(inout) :: self    !! Swiftest particle object
      integer(I4B),                  intent(inout) :: iu      !! Unit number for the output file to write frame to
      class(swiftest_configuration), intent(inout) :: config  !! Input collection of  configuration parameters 
      character(*),                  intent(in)    :: form    !! Input format code ("XV" or "EL")
      real(DP),                      intent(out)   :: t       !! Simulation time
      integer(I4B),                  intent(out)   :: ierr    !! Error code

      associate(n => self%nbody)
         read(iu, iostat = ierr) self%name(1:n)
         select case (form)
         case (EL) 
            read(iu, iostat = ierr) self%a(1:n)
            read(iu, iostat = ierr) self%e(1:n)
            read(iu, iostat = ierr) self%inc(1:n)
            read(iu, iostat = ierr) self%capom(:)
            read(iu, iostat = ierr) self%omega(:)
            read(iu, iostat = ierr) self%capm(:)
         case (XV)
            read(iu, iostat = ierr) self%xh(1, 1:n)
            read(iu, iostat = ierr) self%xh(2, 1:n)
            read(iu, iostat = ierr) self%xh(3, 1:n)
            read(iu, iostat = ierr) self%vh(1, 1:n)
            read(iu, iostat = ierr) self%vh(2, 1:n)
            read(iu, iostat = ierr) self%vh(3, 1:n)
         end select
         select type(self)  
         class is (swiftest_pl)  ! Additional output if the passed polymorphic object is a massive body
            read(iu, iostat = ierr) self%Gmass(1:n)
            self%mass(1:n) = self%Gmass / config%GU 
            read(iu, iostat = ierr) self%radius(1:n)
            if (config%lrotation) then
               read(iu, iostat = ierr) self%Ip(1, 1:n)
               read(iu, iostat = ierr) self%Ip(2, 1:n)
               read(iu, iostat = ierr) self%Ip(3, 1:n)
               read(iu, iostat = ierr) self%rot(1, 1:n)
               read(iu, iostat = ierr) self%rot(2, 1:n)
               read(iu, iostat = ierr) self%rot(3, 1:n)
            end if
            if (config%ltides) then
               read(iu, iostat = ierr) self%k2(1:n)
               read(iu, iostat = ierr) self%Q(1:n)
            end if
         end select
      end associate

      if (ierr /=0) then
         write(*,*) 'Error reading Swiftest body data'
         call util_exit(FAILURE)
      end if

      return
   end subroutine io_read_frame_body

   module subroutine io_read_frame_cb(self, iu, config, form, t, ierr)
      !! author: David A. Minton
      !!
      !! Reads a frame of output of central body data to the binary output file
      !!
      !! Adapted from David E. Kaufmann's Swifter routine  io_read_frame.f90
      !! Adapted from Hal Levison's Swift routine io_read_frame.F
      implicit none
      ! Arguments
      class(swiftest_cb),            intent(inout) :: self     !! Swiftest central body object
      integer(I4B),                  intent(inout) :: iu       !! Unit number for the output file to write frame to
      class(swiftest_configuration), intent(inout) :: config   !! Input collection of  configuration parameters 
      character(*),                  intent(in)    :: form     !! Input format code ("XV" or "EL")
      real(DP),                      intent(out)   :: t        !! Simulation time
      integer(I4B),                  intent(out)   :: ierr     !! Error cod

      read(iu, iostat = ierr) self%Gmass
      self%mass = self%Gmass / config%GU
      read(iu, iostat = ierr) self%radius
      read(iu, iostat = ierr) self%j2rp2 
      read(iu, iostat = ierr) self%j4rp4 
      if (config%lrotation) then
         read(iu, iostat = ierr) self%Ip(:)
         read(iu, iostat = ierr) self%rot(:)
      end if
      if (config%ltides) then
         read(iu, iostat = ierr) self%k2
         read(iu, iostat = ierr) self%Q
      end if
      if (ierr /=0) then
         write(*,*) 'Error reading central body data'
         call util_exit(FAILURE)
      end if

      return
   end subroutine io_read_frame_cb
 
   module subroutine io_read_frame_system(self, iu, config, form, t, ierr)
      !! author: The Purdue Swiftest Team - David A. Minton, Carlisle A. Wishard, Jennifer L.L. Pouplin, and Jacob R. Elliott
      !!
      !! Read a frame (header plus records for each massive body and active test particle) from a output binary file
      implicit none
      ! Arguments
      class(swiftest_nbody_system),  intent(inout) :: self   !! Swiftest system object
      integer(I4B),                  intent(inout) :: iu     !! Unit number for the output file to write frame to
      class(swiftest_configuration), intent(inout) :: config !! Input collection of  configuration parameters 
      character(*),                  intent(in)    :: form   !! Input format code ("XV" or "EL")
      real(DP),                      intent(out)   :: t      !! Current simulation time
      integer(I4B),                  intent(out)   :: ierr   !! Error code
      ! Internals
      logical, save             :: lfirst = .true.

      iu = BINUNIT
      if (lfirst) then
         open(unit = iu, file = config%outfile, status = 'OLD', form = 'UNFORMATTED', iostat = ierr)
         lfirst = .false.
         if (ierr /= 0) then
            write(*, *) "Swiftest error:"
            write(*, *) "   Binary output file already exists or cannot be accessed"
            return
         end if
      end if
      ierr =  io_read_hdr(iu, t, self%pl%nbody, self%tp%nbody, config%out_form, config%out_type)
      if (ierr /= 0) then
         write(*, *) "Swiftest error:"
         write(*, *) "   Binary output file already exists or cannot be accessed"
         return
      end if
      call self%cb%read_frame(iu, config, form, t, ierr)
      if (ierr /= 0) return
      call self%pl%read_frame(iu, config, form, t, ierr)
      if (ierr /= 0) return
      call self%tp%read_frame(iu, config, form, t, ierr)
      return
   end subroutine io_read_frame_system

   module function io_read_hdr(iu, t, npl, ntp, out_form, out_type) result(ierr)
      !! author: David A. Minton
      !!
      !! Read frame header from input binary files
      !!     Function returns read error status (0 = OK, nonzero = ERROR)
      !! Adapted from David E. Kaufmann's Swifter routine: io_read_hdr.f90
      !! Adapted from Hal Levison's Swift routine io_read_hdr.f
      implicit none
      ! Arguments
      integer(I4B), intent(in)   :: iu
      integer(I4B), intent(out)  :: npl, ntp
      character(*), intent(out)  ::  out_form
      real(DP), intent(out)   :: t
      character(*), intent(in)   :: out_type
      ! Result
      integer(I4B)      :: ierr
      ! Internals
      real(SP)             :: ttmp

      select case (out_type)
      case (REAL4_TYPE, SWIFTER_REAL4_TYPE)
         read(iu, iostat = ierr) ttmp, npl, ntp, out_form
         if (ierr /= 0) return
         t = ttmp
      case (REAL8_TYPE, SWIFTER_REAL8_TYPE)
         read(iu, iostat = ierr) t
         read(iu, iostat = ierr) npl
         read(iu, iostat = ierr) ntp
         read(iu, iostat = ierr) out_form
      case default
         write(*,*) trim(adjustl(out_type)) // ' is an unrecognized file type'
         ierr = -1
      end select

      return
   end function io_read_hdr

   module subroutine io_read_initialize_system(self, config)
      !! author: David A. Minton
      !!
      !! Wrapper method to initialize a basic Swiftest nbody system from files
      !!
      implicit none
      ! Arguments
      class(swiftest_nbody_system),  intent(inout) :: self    !! Swiftest system object
      class(swiftest_configuration), intent(inout) :: config  !! Input collection of  configuration parameters
  
      call self%cb%initialize(config)
      call self%pl%initialize(config)
      call self%tp%initialize(config)
      call self%set_msys()
      call self%pl%set_mu(self%cb) 
      call self%tp%set_mu(self%cb) 
   
   end subroutine io_read_initialize_system

   module subroutine io_write_discard(self, config, discards)
      !! author: David A. Minton
      !!
      !! Write out information about discarded test particle
      !!
      !! Adapted from David E. Kaufmann's Swifter routine  io_discard_write.f90
      !! Adapted from Hal Levison's Swift routine io_discard_write.f
      implicit none
      ! Arguments
      class(swiftest_nbody_system),  intent(inout) :: self     !! Swiftest system object
      class(swiftest_configuration), intent(in)    :: config   !! Input collection of  configuration parameters 
      class(swiftest_body),          intent(inout) :: discards !! Swiftest discard object 
      ! Internals
      integer(I4B), parameter   :: LUN = 40
      integer(I4B)          :: i, ierr
      logical, save :: lfirst = .true. 
      real(DP), dimension(:,:), allocatable :: vh
      character(*), parameter :: HDRFMT    = '(E23.16, 1X, I8, 1X, L1)'
      character(*), parameter :: NAMEFMT   = '(A, 2(1X, I8))'
      character(*), parameter :: VECFMT    = '(3(E23.16, 1X))'
      character(*), parameter :: NPLFMT    = '(I8)'
      character(*), parameter :: PLNAMEFMT = '(I8, 2(1X, E23.16))'
      class(swiftest_body), allocatable :: pltemp

      associate(t => config%t, config => config, nsp => discards%nbody, dxh => discards%xh, dvh => discards%vh, &
                dname => discards%name, dstatus => discards%status) 
         
         if (config%out_stat == 'APPEND' .or. (.not.lfirst)) then
            open(unit = LUN, file = DISCARD_FILE, status = 'OLD', position = 'APPEND', form = 'FORMATTED', iostat = ierr)
         else if (config%out_stat == 'NEW') then
            open(unit = LUN, file = DISCARD_FILE, status = 'NEW', form = 'FORMATTED', iostat = ierr)
         else if (config%out_stat == 'REPLACE') then
            open(unit = LUN, file = DISCARD_FILE, status = 'REPLACE', form = 'FORMATTED', iostat = ierr)
         else
            write(*,*) 'Invalid status code',trim(adjustl(config%out_stat))
            call util_exit(FAILURE)
         end if
         lfirst = .false.
         if (config%lgr) then
            select type(discards)
            class is (whm_tp)
               call discards%gr_pv2vh(config)
            end select
         end if
         write(LUN, HDRFMT) t, nsp, config%lbig_discard
         do i = 1, nsp
            write(LUN, NAMEFMT) sub, dname(i), dstatus(i)
            write(LUN, VECFMT) dxh(1, i), dxh(2, i), dxh(3, i)
            write(LUN, VECFMT) dvh(1, i), dvh(2, i), dvh(3, i)
         end do
         if (config%lbig_discard) then
            associate(npl => self%pl%nbody, pl => self%pl, GMpl => self%pl%Gmass, &
                     Rpl => self%pl%radius, name => self%pl%name, xh => self%pl%xh)

               if (config%lgr) then
                  allocate(pltemp, source = pl)
                  select type(pltemp)
                  class is (whm_pl)
                     call pltemp%gr_pv2vh(config)
                     allocate(vh, source = pltemp%vh)
                  end select
                  deallocate(pltemp)
               else
                  allocate(vh, source = pl%vh)
               end if

               write(LUN, NPLFMT) npl
               do i = 1, npl
                  write(LUN, PLNAMEFMT) name(i), GMpl(i), Rpl(i)
                  write(LUN, VECFMT) xh(1, i), xh(2, i), xh(3, i)
  
                  write(LUN, VECFMT) vh(1, i), vh(2, i), vh(3, i)
               end do
               deallocate(vh)
            end associate
         end if
         close(LUN)
      end associate
      return
   
   end subroutine io_write_discard

   module subroutine io_write_encounter(t, name1, name2, mass1, mass2, radius1, radius2, &
                                          xh1, xh2, vh1, vh2, encounter_file, out_type)
      !! author: David A. Minton
      !!
      !! Write close encounter data to output binary files
      !!  There is no direct file output from this subroutine
      !!
      !! Adapted from David E. Kaufmann's Swifter routine: io_write_encounter.f90
      !! Adapted from Hal Levison's Swift routine io_write_encounter.f
      implicit none
      ! Arguments
      integer(I4B), intent(in)     :: name1, name2
      real(DP), intent(in)      :: t, mass1, mass2, radius1, radius2
      real(DP), dimension(NDIM), intent(in) :: xh1, xh2, vh1, vh2
      character(*), intent(in)     :: encounter_file, out_type
      ! Internals
      logical , save    :: lfirst = .true.
      integer(I4B), parameter :: lun = 30
      integer(I4B)        :: ierr
      integer(I4B), save    :: iu = lun

      open(unit = iu, file = encounter_file, status = 'OLD', position = 'APPEND', form = 'UNFORMATTED', iostat = ierr)
      if ((ierr /= 0) .and. lfirst) then
         open(unit = iu, file = encounter_file, status = 'NEW', form = 'UNFORMATTED', iostat = ierr)
      end if
      if (ierr /= 0) then
         write(*, *) "Swiftest Error:"
         write(*, *) "   Unable to open binary encounter file"
         call util_exit(FAILURE)
      end if
      lfirst = .false.
      write(iu, iostat = ierr) t
      if (ierr < 0) then
         write(*, *) "Swiftest Error:"
         write(*, *) "   Unable to write binary file record"
         call util_exit(FAILURE)
      end if
      write(iu) name1, xh1(1), xh1(2), xh1(3), vh1(1), vh1(2), mass1, radius1
      write(iu) name2, xh2(1), xh2(2), xh2(3), vh2(1), vh2(2), mass2, radius2
      close(unit = iu, iostat = ierr)
      if (ierr /= 0) then
         write(*, *) "Swiftest Error:"
         write(*, *) "   Unable to close binary encounter file"
         call util_exit(FAILURE)
      end if

      return

   end subroutine io_write_encounter

   module subroutine io_write_frame_body(self, iu, config, t, dt)
      !! author: David A. Minton
      !!
      !! Write a frame of output of either test particle or massive body data to the binary output file
      !!    Note: If outputting to orbital elements, but sure that the conversion is done prior to calling this method
      !!
      !! Adapted from David E. Kaufmann's Swifter routine  io_write_frame.f90
      !! Adapted from Hal Levison's Swift routine io_write_frame.F
      implicit none
      ! Arguments
      class(swiftest_body),          intent(in)    :: self   !! Swiftest particle object
      integer(I4B),                  intent(inout) :: iu     !! Unit number for the output file to write frame to
      class(swiftest_configuration), intent(in)    :: config !! Input collection of  configuration parameters 
      real(DP),                      intent(in)    :: t      !! Current simulation time
      real(DP),                      intent(in)    :: dt     !! Step size

      associate(n => self%nbody)
         if (n == 0) return
         write(iu) self%name(1:n)
         select case (config%out_form)
         case (EL) 
            write(iu) self%a(1:n)
            write(iu) self%e(1:n)
            write(iu) self%inc(1:n)
            write(iu) self%capom(1:n)
            write(iu) self%omega(1:n)
            write(iu) self%capm(1:n)
         case (XV)
            write(iu) self%xh(1, 1:n)
            write(iu) self%xh(2, 1:n)
            write(iu) self%xh(3, 1:n)
            write(iu) self%vh(1, 1:n)
            write(iu) self%vh(2, 1:n)
            write(iu) self%vh(3, 1:n)
         end select
         select type(self)  
         class is (swiftest_pl)  ! Additional output if the passed polymorphic object is a massive body
            write(iu) self%Gmass(1:n)
            write(iu) self%radius(1:n)
            if (config%lrotation) then
               write(iu) self%Ip(1, 1:n)
               write(iu) self%Ip(2, 1:n)
               write(iu) self%Ip(3, 1:n)
               write(iu) self%rot(1, 1:n)
               write(iu) self%rot(2, 1:n)
               write(iu) self%rot(3, 1:n)
            end if
            if (config%ltides) then
               write(iu) self%k2(1:n)
               write(iu) self%Q(1:n)
            end if
         end select
      end associate

      return
   end subroutine io_write_frame_body

   module subroutine io_write_frame_cb(self, iu, config, t, dt)
      !! author: David A. Minton
      !!
      !! Write a frame of output of central body data to the binary output file
      !!
      !! Adapted from David E. Kaufmann's Swifter routine  io_write_frame.f90
      !! Adapted from Hal Levison's Swift routine io_write_frame.F
      implicit none
      ! Arguments
      class(swiftest_cb),            intent(in)    :: self   !! Swiftest central body object 
      integer(I4B),                  intent(inout) :: iu     !! Unit number for the output file to write frame to
      class(swiftest_configuration), intent(in)    :: config !! Input collection of  configuration parameters 
      real(DP),                      intent(in)    :: t      !! Current simulation time
      real(DP),                      intent(in)    :: dt     !! Step size

      write(iu) self%Gmass
      write(iu) self%radius
      write(iu) self%j2rp2 
      write(iu) self%j4rp4 
      if (config%lrotation) then
         write(iu) self%Ip(1)
         write(iu) self%Ip(2)
         write(iu) self%Ip(3)
         write(iu) self%rot(1)
         write(iu) self%rot(2)
         write(iu) self%rot(3)
      end if
      if (config%ltides) then
         write(iu) self%k2
         write(iu) self%Q
      end if

      return
   end subroutine io_write_frame_cb

   module subroutine io_write_frame_system(self, iu, config, t, dt)
      !! author: The Purdue Swiftest Team - David A. Minton, Carlisle A. Wishard, Jennifer L.L. Pouplin, and Jacob R. Elliott
      !!
      !! Write a frame (header plus records for each massive body and active test particle) to output binary file
      !! There is no direct file output from this subroutine
      !!
      !! Adapted from David E. Kaufmann's Swifter routine  io_write_frame.f90
      !! Adapted from Hal Levison's Swift routine io_write_frame.F
      implicit none
      ! Arguments
      class(swiftest_nbody_system),  intent(in)    :: self   !! Swiftest system object
      integer(I4B),                  intent(inout) :: iu     !! Unit number for the output file to write frame to
      class(swiftest_configuration), intent(in)    :: config !! Input collection of  configuration parameters 
      real(DP),                      intent(in)    :: t      !! Current simulation time
      real(DP),                      intent(in)    :: dt     !! Step size
      ! Internals
      logical, save                         :: lfirst = .true. !! Flag to determine if this is the first call of this method
      integer(I4B)                          :: ierr            !! I/O error code

      class(swiftest_cb), allocatable       :: cb         !! Temporary local version of pl structure used for non-destructive conversions
      class(swiftest_pl), allocatable       :: pl              !! Temporary local version of pl structure used for non-destructive conversions
      class(swiftest_tp), allocatable       :: tp              !! Temporary local version of pl structure used for non-destructive conversions

      allocate(cb, source = self%cb)
      allocate(pl, source = self%pl)
      allocate(tp, source = self%tp)
      iu = BINUNIT

      if (lfirst) then
         select case(config%out_stat)
         case('APPEND')
            open(unit = iu, file = config%outfile, status = 'OLD', position = 'APPEND', form = 'UNFORMATTED', iostat = ierr)
         case('NEW')
            open(unit = iu, file = config%outfile, status = 'NEW', form = 'UNFORMATTED', iostat = ierr)
         case ('REPLACE')
            open(unit = iu, file = config%outfile, status = 'REPLACE', form = 'UNFORMATTED', iostat = ierr)
         case default
            write(*,*) 'Invalid status code',trim(adjustl(config%out_stat))
            call util_exit(FAILURE)
         end select
         if (ierr /= 0) then
            write(*, *) "Swiftest error: io_write_frame_system - first", ierr
            write(*, *) "   Binary output file " // trim(adjustl(config%outfile)) // " already exists or cannot be accessed"
            write(*, *) "   out_stat: " // trim(adjustl(config%out_stat))
            call util_exit(FAILURE)
         end if
         lfirst = .false.
      else
         open(unit = iu, file = config%outfile, status = 'OLD', position =  'APPEND', form = 'UNFORMATTED', iostat = ierr)
         if (ierr /= 0) then
            write(*, *) "Swiftest error: io_write_frame_system"
            write(*, *) "   Unable to open binary output file for APPEND"
            call util_exit(FAILURE)
         end if
      end if
      call io_write_hdr(iu, t, pl%nbody, tp%nbody, config%out_form, config%out_type)

      if (config%lgr) then
         associate(vh => pl%vh, vht => tp%vh)
            select type(pl)
            class is (whm_pl)
               call pl%gr_pv2vh(config)
            end select
            select type(tp) 
            class is (whm_tp)
               call tp%gr_pv2vh(config)
            end select
         end associate
      end if

      if (config%out_form == EL) then ! Do an orbital element conversion prior to writing out the frame, as we have access to the central body here
         call pl%xv2el(cb)
         call tp%xv2el(cb)
      end if
      
      ! Write out each data type frame
      call cb%write_frame(iu, config, t, dt)
      call pl%write_frame(iu, config, t, dt)
      call tp%write_frame(iu, config, t, dt)

      deallocate(cb, pl, tp)

      close(iu)

      return
   end subroutine io_write_frame_system

   module subroutine io_write_hdr(iu, t, npl, ntp, out_form, out_type)
      !! author: The Purdue Swiftest Team - David A. Minton, Carlisle A. Wishard, Jennifer L.L. Pouplin, and Jacob R. Elliott
      !!
      !! Write frame header to output binary file
      !!
      !! Adapted from David Adapted from David E. Kaufmann's Swifter routine io_write_hdr.f90
      !! Adapted from Hal Levison's Swift routine io_write_hdr.F
      implicit none
      ! Arguments
      integer(I4B), intent(in) :: iu       !! Output file unit number
      real(DP),     intent(in) :: t        !! Current time of simulation
      integer(I4B), intent(in) :: npl      !! Number of massive bodies
      integer(I4B), intent(in) :: ntp      !! Number of test particles
      character(*), intent(in) :: out_form !! Output format type ("EL" or  "XV")
      character(*), intent(in) :: out_type !! Output file format type (REAL4, REAL8 - see swiftest module for symbolic name definitions)
      ! Internals
      integer(I4B)               :: ierr !! Error code
   
      select case (out_type)
      case (REAL4_TYPE,SWIFTER_REAL4_TYPE)
         write(iu, iostat = ierr) real(t, kind=SP)
         if (ierr /= 0) then
            write(*, *) "Swiftest error:"
            write(*, *) "   Unable to write binary file header"
            call util_exit(FAILURE)
         end if
      case (REAL8_TYPE,SWIFTER_REAL8_TYPE)
         write(iu, iostat = ierr) t
         if (ierr /= 0) then
            write(*, *) "Swiftest error:"
            write(*, *) "   Unable to write binary file header"
            call util_exit(FAILURE)
         end if
      end select
      write(iu, iostat = ierr) npl
      write(iu, iostat = ierr) ntp
      write(iu, iostat = ierr) out_form
   
      return
   
   end subroutine io_write_hdr


end submodule s_io
