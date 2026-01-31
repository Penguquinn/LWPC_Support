c     Routine determines the location of the LWPC Data files
c     As of 24 Feb, this location now points to Compaq/MS binary files

      SUBROUTINE LWPC_DAT_LOC

c     LWPC parameters
      include      'lwpc_cfg.cmn'
      include      'lwpc_lun.cmn'

      character*  1 delimiter(3)
      integer       ISTR_LENGTH

c     Get the location of the LWPC data
c      open (lwpcDAT_lun,file='C:\lwpcDATv3.loc',status='old',err=900)
c      read (lwpcDAT_lun,'(a)') lwpcDAT_loc
c      close(lwpcDAT_lun)
      call GET_ENVIRONMENT_VARIABLE 
     &      ('LWPC_DAT_LOC', lwpcDAT_loc, lenstr, istat)
      if(lenstr .eq. 0 .or. istat .ne. 0) goto 900
c     Get delimiters used in the file names
      call GET_DELIMITER (delimiter)
c     Ensure lwpcDAT_loc is properly terminated
      n=ISTR_LENGTH(lwpcDAT_loc)
      if (lwpcDAT_loc(n:n) .ne. delimiter(3)) then
         n=n+1
         lwpcDAT_loc(n:n)=delimiter(3)
      end if
      RETURN

900   call LWPC_ERROR ('Error', 
     &   'Set LWPC_DAT_LOC to directory containing data files')
      END      ! LWPC_DAT_LOC
