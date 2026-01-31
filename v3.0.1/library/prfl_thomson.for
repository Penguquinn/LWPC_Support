      SUBROUTINE PRFL_THOMSON
     &          (initialize,print_hgts,prfl_id,
     &           freq,month,day,year,UT,dip,zenith,
     &           hpr_mid,beta,hprm,pindex)

c***********************************************************************

c     Processes LWPM-THOMSON profile specification

c     Pflag        Profile specification
c     11           Thomson month/day/year hour:minute SR SS

c*******************!***************************************************

c     LWPC parameters
      include      'lwpc_lun.cmn'

c     NRDD          number of segments in the dawn to dusk variation
      parameter    (nrdd=7)

      character*(*) prfl_id
      logical       initialize
      integer       print_hgts,pindex,
     &              day,year,UT

      common/prfl/  zzz(181),ddd(181),bbb(181),hhh(181),nrz,nrd

      logical       flag
      integer       prev_index
      dimension     polar_cap(2),freq_n(2),beta_n(2),hprm_n(2),
     &              sr(2),dd_chi(nrdd),dd_beta(nrdd),dd_hprm(nrdd),ss(2)

c                   Nighttime BETA,HPRIME dependence on frequency
      data          freq_n/10.,60./,beta_n/0.3,0.8/,hprm_n/87.,87./,
c                   Sunrise transition in solar zenith angle
     &              sr/-99.,-90./,
c                   Dawn to dusk variation in solar zenith angle
     &              dd_chi /-90.0,-64.7,-50.1,-31.3, 40.0, 60.8, 71.9/,
c                   Dawn to dusk variation in beta
     &              dd_beta/ 0.30, 0.35, 0.40, 0.45, 0.40, 0.35, 0.30/,
c                   Dawn to dusk variation in hprime
     &              dd_hprm/ 75.4, 74.4, 72.4, 70.4, 71.2, 73.8, 75.5/,
c                   Sunset transition in solar zenith angle
     &              ss/ 90., 99./,
c                   Polar cap transition in geomagnetic dip angle
     &              polar_cap/70.,74./


      if (initialize) then

c        NRTERM is the number of segments in the day/night transition
         nrterm=5

c        NRPRFL is total number of segments to be generated
         nrprfl=2*(nrterm+1)+nrdd

c        MID is the number of the segment defining the beginning of the
c        polar cap boundary for nighttime conditions
         mid=nrterm/2+2

c        Check for a file named SRSS.PRF in the current directory.
         INQUIRE (file='srss.prf',exist=flag)
         if (flag) then

c           Cycle through logical unit numbers
            lu=0
            do while (flag)
               lu=lu+1
               INQUIRE (lu,opened=flag)
            end do

c           Get modified sunrise and sunset solar zenith angles
            OPEN (lu,file='srss.prf',status='old')
            read (lu,*) sr,ss
            CLOSE(lu)
         end if

c        Polar cap transition
         deltad=(polar_cap(2)-polar_cap(1))/(mid-2)
         dd=polar_cap(1)

c        Get nighttime BETA,HPRIME for specific frequency
         slope=(freq-freq_n(1))/(freq_n(2)-freq_n(1))
         beta_f=beta_n(1)+slope*(beta_n(2)-beta_n(1))
         hprm_f=hprm_n(1)+slope*(hprm_n(2)-hprm_n(1))

c        Night to day transition
         sr_deltaz=(sr(1)-sr(2))/nrterm
         sr_deltab=(beta_f-dd_beta(1))/(nrterm+1)
         sr_deltah=(hprm_f-dd_hprm(1))/(nrterm+1)

c        Ensure morning begins at end of night to day transition
         dd_chi(1)=sr(2)

c        Day to night transition
         ss_deltaz=(ss(1)-ss(2))/nrterm
         ss_deltab=(dd_beta(7)-beta_f)/(nrterm+1)
         ss_deltah=(dd_hprm(7)-hprm_f)/(nrterm+1)

c        Build table of BETA,HPRIME vs. solar zenith angle
c        starting with midnight
         za=-180.
         bt=beta_f
         hp=hprm_f
         nrz=0
         nx=0
         do while (za .le. ss(2)-.5*ss_deltaz)

            nrz=nrz+1
            if (za .lt. 0.) then
               zzz(nrz)=AINT(10.*za-.5)/10.
            else
               zzz(nrz)=AINT(10.*za+.5)/10.
            end if

            bbb(nrz)=AINT(1000.*bt+.5)/1000.
            hhh(nrz)=AINT(  10.*hp+.5)/10.

            if (nrz .gt. 2 .and. nrz .le. mid) then
               dd=dd+deltad
            else
     &      if (nrz .gt. nrprfl-mid+1 .and. nrz .le. nrprfl-1) then
               dd=dd-deltad
            end if
            ddd(nrz)=AINT(10.*dd+.5)/10.

            if (nrz .eq. 1) then

c              Begin sunrise transition
               za=sr(1)
               bt=bt-sr_deltab
               hp=hp-sr_deltah
            else

               if (za .lt. 0.) then

                  if (za .lt. sr(2)+1.5*sr_deltaz) then

c                    Continue sunrise transition
                     za=za-sr_deltaz
                     bt=bt-sr_deltab
                     hp=hp-sr_deltah
                  else

c                    Transition from sunrise to noon
                     nx=nx+1
                     za=dd_ chi(nx)
                     bt=dd_beta(nx)
                     hp=dd_hprm(nx)
                  end if
               else

                  if (nx .lt. 7) then

c                    Transition from noon to sunset
                     nx=nx+1
                     za=dd_ chi(nx)
                     bt=dd_beta(nx)
                     hp=dd_hprm(nx)
                  else
     &            if (nx .eq. 7) then

c                    Start sunset transition
                     nx=nx+1
                     za=ss(1)
                     bt=dd_beta(7)-ss_deltab
                     hp=dd_hprm(7)-ss_deltah
                  else

c                    Continue sunset transition
                     za=za-ss_deltaz
                     bt=bt-ss_deltab
                     hp=hp-ss_deltah
                  end if
               end if
            end if
         end do
         nrd=nrz

         write(prfl_id,
     &       '(''ZZ '',2(i2.2,''/''),i2.2,'':'',i4.4,
     &         f7.1,''/'',f5.1,''/'',f4.1,''/'',f5.1)')
     &         month,day,MOD(year,100),UT,sr,ss

c        Set previous index
         prev_index=0
      else

c        Set reference height for LW_STEP
         hpr_mid=hhh(mid)

c        Find the profile index based on solar zenith angle
         pindex=1
         flag=.true.
         do while (flag)
            if (zzz(pindex) .le. zenith .and.
     &                           zenith .lt. zzz(pindex+1)) then
               flag=.false.
            else
               pindex=pindex+1
               if (pindex .eq. nrprfl) flag=.false.
            end if
         end do


c        Check polar cap
         if (ABS(dip) .ge. polar_cap(2)) then

c           Inside the polar cap
            ndx2=mid
         else
     &   if (ABS(dip) .ge. polar_cap(1)) then

c           In the polar cap transition
            ndx2=INT((ABS(dip)-polar_cap(1))/deltad+2.)
         else

c           Below the polar cap transition
            ndx2=1
         end if
         if (zenith .gt. 0.) ndx2=nrprfl+1-ndx2

c        Choose profile with the lower height
         if (hhh(pindex) .ge. hhh(ndx2)) pindex=ndx2

c        Retrieve profile parameters
         beta=bbb(pindex)
         hprm=hhh(pindex)
         if (pindex .ne. prev_index) then

c           Set profile
            call PRFL_EXP (beta,hprm)

c           Get reference heights for current profile.
            call PRFL_HGTS (print_hgts)

c           Set previous index
            prev_index=pindex
         end if
      end if

      RETURN
      END      ! PRFL_THOMSON
