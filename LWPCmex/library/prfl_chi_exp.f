      SUBROUTINE PRFL_CHI_EXP
     &          (initialize,print_hgts,
     &           prfl_file,prfl_id,chi,beta,hprime,pindex)

c***********************************************************************

c     Set up exponential profiles vs. solar zenith angle

c     The sign convention is such that -180<CHI<0 is the midnight to
c     noon portion of the day and 0<CHI<180 is noon to midnight.

c  Change History:
c     27 Jun 2003   Modified to store the variation of the profile in
c                   common PRFL$; reduced the maximum number of profiles
c                   to 41 to be consistent with the common block.

c*******************!***************************************************

c     LWPC parameters
      include      'lwpc_cfg.cmn'

      character*(*) prfl_file,prfl_id
      logical       initialize
      integer       print_hgts,pindex
      real          hten,algen,htnu,algnu,charge,ratiom,
     &              select_hgts,hgts

      common/lwpc_pr/
     &              hten(51),algen(51,3),nrhten,ihten,
     &              htnu(51),algnu(51,3),nrhtnu,ihtnu,
     &              charge(3),ratiom(3),nrspec,lu_prf,
     &              select_hgts(2),hgts(3)

      parameter    (mxchi=181)
      common/prfl/  zzz(mxchi),ddd(mxchi),bbb(mxchi),hhh(mxchi),nrz,nrd

      character*120 string,file_name,directory,root_file,extension
      character*200 error_msg
      logical       set_id,flag,loop
      integer       prev_ndx
      real          item(3)


      if (initialize) then

c        Get file name
         file_name=prfl_file
         call DECODE_FILE_NAME
     &       (file_name,directory,root_file,extension)

c        Check for a file named "PRFL_FILE".NDX
         if (ISTR_LENGTH(directory) .eq. 0) then
            if (ISTR_LENGTH(lwpcNDX_loc) .eq. 0) then
               file_name=root_file(:ISTR_LENGTH(root_file))//'.ndx'
            else
               file_name=lwpcNDX_loc(:ISTR_LENGTH(lwpcNDX_loc))//
     &                   root_file(:ISTR_LENGTH(root_file))//'.ndx'
            end if
         else
            file_name=directory(:ISTR_LENGTH(directory))//
     &                root_file(:ISTR_LENGTH(root_file))//'.ndx'
         end if
         set_id=.true.

         INQUIRE (file=file_name,exist=flag)
         if (flag) then

            OPEN (lu_prf,file=file_name,status='old')

            nrchi=0
            loop=.true.
            do while (loop)

               read (lu_prf,'(a)',end=9) string

c              Check for comment line
               if (string(1:1) .eq. ';') then
                  if (ISTR_LENGTH(string) .gt. 1) then
                     if (set_id) then
c                       First comment line is the profile id
                        set_id=.false.
                        prfl_id=string(2:ISTR_LENGTH(string))
                     end if
                  end if
               else
     &         if (ISTR_LENGTH(string) .gt. 0) then

c                 Segment data should contain: chi beta hprime
                  call DECODE_LIST_FLT (string,3,nritem,item)
                  if (nritem .ne. 3) then
                     write(error_msg,
     &                   '(''[PRFL_CHI_EXP]: '',
     &                     ''Chi, beta and hprime not all input'')')
                     call LWPC_ERROR('ERROR', error_msg)
                  end if

                  nrchi=nrchi+1
                  if (nrchi .gt. mxchi) then
                     write(error_msg,
     &                   '(''[PRFL_CHI_EXP]: '',
     &                     ''Number of entries in the NDX file exceeds''
     &                     i2)') mxchi
                     call LWPC_ERROR('ERROR', error_msg)
                  else
                     zzz(nrchi)=item(1)
                     bbb(nrchi)=item(2)
                     hhh(nrchi)=item(3)
                  end if
               end if
            end do
9           loop=.false.
            CLOSE(lu_prf)
            nrz=nrchi
            nrd=0
         else

            write(error_msg,
     &          '(''[PRFL_CHI_EXP]: '',
     &            ''Index file not found: '',a)')
     &              prfl_file(:MAX(1,ISTR_LENGTH(prfl_file)))
            call LWPC_ERROR('ERROR', error_msg)
         end if

c        Set previous index
         prev_ndx=0
         prev_bta=0.
         prev_hpr=0.
      else

c        Find the profile index
         nchi=1
         flag=.true.
         do while (flag)
            if (zzz(nchi) .le. chi
     &                   .and. chi .lt. zzz(nchi+1)) then
               flag=.false.
            else
               nchi=nchi+1
               if (nchi .eq. nrz) flag=.false.
            end if
         end do
         pindex=nchi
         beta  =bbb(pindex)
         hprime=hhh(pindex)

         if (beta .ne. prev_bta .or. hprime .ne. prev_hpr) then

c           Set up profile.
            call PRFL_EXP (beta,hprime)

c           Get reference heights for this profile.
            call PRFL_HGTS (print_hgts)

c           Set previous index
            prev_ndx=pindex
            prev_bta=beta
            prev_hpr=hprime
         end if
      end if

      RETURN
      END      ! PRFL_CHI_EXP
