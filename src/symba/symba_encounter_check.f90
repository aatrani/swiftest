submodule (symba_classes) s_symba_encounter_check
   use swiftest
contains

   module function symba_encounter_check_pl(self, param, system, dt, irec) result(lany_encounter)
      !! author: David A. Minton
      !!
      !! Check for an encounter between massive bodies.
      !!
      implicit none
      ! Arguments
      class(symba_pl),            intent(inout)  :: self   !! SyMBA test particle object  
      class(swiftest_parameters), intent(inout)  :: param  !! Current swiftest run configuration parameters
      class(symba_nbody_system),  intent(inout)  :: system !! SyMBA nbody system object
      real(DP),                   intent(in)     :: dt     !! step size
      integer(I4B),               intent(in)     :: irec   !! Current recursion level
      ! Result
      logical                                   :: lany_encounter !! Returns true if there is at least one close encounter      
      ! Internals
      integer(I8B) :: k, nplplm, kenc
      integer(I4B) :: i, j, nenc, npl, nplm
      logical, dimension(:), allocatable :: lencounter, loc_lvdotr, lvdotr
      integer(I4B), dimension(:), allocatable :: index1, index2
      integer(I4B), dimension(:,:), allocatable :: k_plpl_enc 
      type(interaction_timer), save :: itimer
      logical, save :: lfirst = .true.
  
      if (self%nbody == 0) return

      associate(pl => self, plplenc_list => system%plplenc_list)

         if (param%ladaptive_interactions) then
            if (self%nplplm > 0) then
               if (lfirst) then
                  write(itimer%loopname, *)  "symba_encounter_check_pl"
                  write(itimer%looptype, *)  "ENCOUNTERS"
                  call itimer%time_this_loop(param, pl, pl%nplplm)
                  lfirst = .false.
               else
                  if (itimer%check(param, pl%nplplm)) call itimer%time_this_loop(param, pl, pl%nplplm)
               end if
            else
               param%lflatten_encounters = .false.
            end if
         end if

         npl = pl%nbody
         if (param%lflatten_encounters) then
            nplplm = pl%nplplm

            allocate(lencounter(nplplm))
            allocate(loc_lvdotr(nplplm))
  
            call encounter_check_all_flat_plpl(nplplm, pl%k_plpl, pl%xh, pl%vh, pl%renc, dt, lencounter, loc_lvdotr)

            nenc = count(lencounter(:))

            lany_encounter = nenc > 0
            if (lany_encounter) then 
               call plplenc_list%resize(nenc)
               allocate(lvdotr(nenc))					
               allocate(index1(nenc))					
               allocate(index2(nenc))					
               lvdotr(:) = pack(loc_lvdotr(:), lencounter(:))					
               index1(:) = pack(pl%k_plpl(1,1:nplplm), lencounter(:)) 					
               index2(:) = pack(pl%k_plpl(2,1:nplplm), lencounter(:)) 					
               deallocate(lencounter, loc_lvdotr)					
               call move_alloc(lvdotr, plplenc_list%lvdotr)					
               call move_alloc(index1, plplenc_list%index1) 					
               call move_alloc(index2, plplenc_list%index2) 
            end if					
         else
            nplm = pl%nplm
            call encounter_check_all_triangular_plpl(npl, nplm, pl%xh, pl%vh, pl%renc, dt, lvdotr, index1, index2, nenc)
            lany_encounter = nenc > 0
            if (lany_encounter) then
               call plplenc_list%resize(nenc)
               call move_alloc(lvdotr, plplenc_list%lvdotr)
               call move_alloc(index1, plplenc_list%index1)
               call move_alloc(index2, plplenc_list%index2)
            end if
         end if

         if (lany_encounter) then 
            do k = 1, nenc
               i = plplenc_list%index1(k)
               j = plplenc_list%index2(k)
               plplenc_list%id1(k) = pl%id(i)
               plplenc_list%id2(k) = pl%id(j)
               plplenc_list%status(k) = ACTIVE
               plplenc_list%level(k) = irec
               pl%lencounter(i) = .true.
               pl%lencounter(j) = .true.
               pl%levelg(i) = irec
               pl%levelm(i) = irec
               pl%levelg(j) = irec
               pl%levelm(j) = irec
               pl%nplenc(i) = pl%nplenc(i) + 1
               pl%nplenc(j) = pl%nplenc(j) + 1
            end do
         end if

         if (param%ladaptive_interactions .and. self%nplplm > 0) then 
            if (itimer%is_on) call itimer%adapt(param, pl, pl%nplplm)
         end if

      end associate

      return
   end function symba_encounter_check_pl


   module function symba_encounter_check(self, param, system, dt, irec) result(lany_encounter)
      !! author: David A. Minton
      !!
      !! Check for an encounter between test particles and massive bodies in the pltpenc list.
      !! Note: This method works for the polymorphic symba_pltpenc and symba_plplenc types.
      !!
      !! Adapted from portions of David E. Kaufmann's Swifter routine: symba_step_recur.f90
      implicit none
      ! Arguments
      class(symba_encounter),     intent(inout) :: self           !! SyMBA pl-pl encounter list object
      class(swiftest_parameters), intent(in)    :: param          !! Current swiftest run configuration parameters
      class(symba_nbody_system),  intent(inout) :: system         !! SyMBA nbody system object
      real(DP),                   intent(in)    :: dt             !! step size
      integer(I4B),               intent(in)    :: irec           !! Current recursion level 
      logical                                   :: lany_encounter !! Returns true if there is at least one close encounter  
      ! Internals
      integer(I4B)              :: i, j, k, lidx, nenc_enc
      real(DP), dimension(NDIM) :: xr, vr
      logical                   :: isplpl
      real(DP)                  :: rlim2, rji2, rcrit12
      logical, dimension(:), allocatable :: lencmask, lencounter
      integer(I4B), dimension(:), allocatable :: encidx

      lany_encounter = .false.
      if (self%nenc == 0) return

      select type(self)
      class is (symba_plplenc)
         isplpl = .true.
      class is (symba_pltpenc)
         isplpl = .false.
      end select

      select type(pl => system%pl)
      class is (symba_pl)
         select type(tp => system%tp)
         class is (symba_tp)
            allocate(lencmask(self%nenc))
            lencmask(:) = (self%status(1:self%nenc) == ACTIVE) .and. (self%level(1:self%nenc) == irec - 1)
            nenc_enc = count(lencmask(:))
            if (nenc_enc == 0) return

            allocate(encidx(nenc_enc))
            allocate(lencounter(nenc_enc))
            encidx(:) = pack([(k, k = 1, self%nenc)], lencmask(:))
            lencounter(:) = .false.
            if (isplpl) then
               do concurrent(lidx = 1:nenc_enc)
                  k = encidx(lidx)
                  i = self%index1(k)
                  j = self%index2(k)
                  xr(:) = pl%xh(:,j) - pl%xh(:,i)
                  vr(:) = pl%vb(:,j) - pl%vb(:,i)
                  rcrit12 = pl%renc(i) + pl%renc(j)
                  call encounter_check_one(xr(1), xr(2), xr(3), vr(1), vr(2), vr(3), rcrit12, dt, lencounter(lidx), self%lvdotr(k))
                  if (lencounter(lidx)) then
                     rlim2 = (pl%radius(i) + pl%radius(j))**2
                     rji2 = dot_product(xr(:), xr(:))! Check to see if these are physically overlapping bodies first, which we should ignore
                     lencounter(lidx) = rji2 > rlim2
                  end if
               end do
            else
               do concurrent(lidx = 1:nenc_enc)
                  k = encidx(lidx)
                  i = self%index1(k)
                  j = self%index2(k)
                  xr(:) = tp%xh(:,j) - pl%xh(:,i)
                  vr(:) = tp%vb(:,j) - pl%vb(:,i)
                  call encounter_check_one(xr(1), xr(2), xr(3), vr(1), vr(2), vr(3), pl%renc(i), dt, lencounter(lidx), self%lvdotr(k))
                  if (lencounter(lidx)) then
                     rlim2 = (pl%radius(i))**2
                     rji2 = dot_product(xr(:), xr(:))! Check to see if these are physically overlapping bodies first, which we should ignore
                     lencounter(lidx) = rji2 > rlim2
                  end if
               end do
            end if
            lany_encounter = any(lencounter(:))
            if (lany_encounter) then
               nenc_enc = count(lencounter(:))
               encidx(1:nenc_enc) = pack(encidx(:), lencounter(:))
               do lidx = 1, nenc_enc
                  k = encidx(lidx)
                  i = self%index1(k)
                  j = self%index2(k)
                  pl%levelg(i) = irec
                  pl%levelm(i) = MAX(irec, pl%levelm(i))
                  if (isplpl) then
                     pl%levelg(j) = irec
                     pl%levelm(j) = MAX(irec, pl%levelm(j))
                  else
                     tp%levelg(j) = irec
                     tp%levelm(j) = MAX(irec, tp%levelm(j))
                  end if
                  self%level(k) = irec
               end do
            end if   
         end select
      end select

      return
   end function symba_encounter_check


   module function symba_encounter_check_tp(self, param, system, dt, irec) result(lany_encounter)
      !! author: David A. Minton
      !!
      !! Check for an encounter between test particles and massive bodies.
      !!
      implicit none
      ! Arguments
      class(symba_tp),            intent(inout) :: self   !! SyMBA test particle object  
      class(swiftest_parameters), intent(in)    :: param  !! Current swiftest run configuration parameters
      class(symba_nbody_system),  intent(inout) :: system !! SyMBA nbody system object
      real(DP),                   intent(in)    :: dt     !! step size
      integer(I4B),               intent(in)    :: irec   !! Current recursion level
      ! Result
      logical                                   :: lany_encounter !! Returns true if there is at least one close encounter      
      ! Internals
      real(DP)                                  :: r2crit, vdotr, r2, v2, tmin, r2min, term2
      integer(I4B)                              :: i, j, k,nenc, plind, tpind
      real(DP),     dimension(NDIM)             :: xr, vr
      real(DP)                                  :: rshell_irec
      logical,      dimension(:),   allocatable :: lvdotr
      integer(I4B), dimension(:),   allocatable :: index1, index2
  
      if (self%nbody == 0) return

      associate(tp => self, ntp => self%nbody, pl => system%pl, npl => system%pl%nbody)
         call encounter_check_all_triangular_pltp(npl, ntp, pl%xh, pl%vh, tp%xh, tp%vh, pl%renc, dt, lvdotr, index1, index2, nenc) 
   
         lany_encounter = nenc > 0
         if (lany_encounter) then 
            associate(pltpenc_list => system%pltpenc_list)
               call pltpenc_list%resize(nenc)
               pltpenc_list%status(1:nenc) = ACTIVE
               pltpenc_list%level(1:nenc) = irec
               call move_alloc(index1, pltpenc_list%index1)
               call move_alloc(index2, pltpenc_list%index2)
               call move_alloc(lvdotr, pltpenc_list%lvdotr)
               pltpenc_list%id1(1:nenc) = pl%id(pltpenc_list%index1(1:nenc))
               pltpenc_list%id2(1:nenc) = tp%id(pltpenc_list%index2(1:nenc))
               select type(pl)
               class is (symba_pl)
                  pl%lencounter(1:npl) = .false.
                  do k = 1, nenc
                     plind = pltpenc_list%index1(k)
                     tpind = pltpenc_list%index2(k)
                     pl%lencounter(plind) = .true.
                     pl%levelg(plind) = irec
                     pl%levelm(plind) = irec
                     tp%levelg(tpind) = irec
                     tp%levelm(tpind) = irec
                     pl%ntpenc(plind) = pl%ntpenc(plind) + 1
                     tp%nplenc(tpind) = tp%nplenc(tpind) + 1
                  end do
               end select
            end associate
         end if
      end associate

      return
   end function symba_encounter_check_tp

end submodule s_symba_encounter_check
