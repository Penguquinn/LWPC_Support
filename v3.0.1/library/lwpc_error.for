      SUBROUTINE LWPC_ERROR
     &          (error_type,error_msg)

c***********************************************************************
c                         subroutine lwpc_error
c***********************************************************************
c
c  Program Source:  Naval Ocean Systems Center - Code D882
c
c  Date:
c     29 October 1992
c
c  Function:
c     Displays an error message to either an graphics screen, or to the
c     standard output device.
c
c  Parameters passed:
c     error_level      [s] type error level:
c                         'WARNING' for a warning message
c                         'ERROR'   for a fatal error message
c     error_msg    [s] the error message to display/print
c
c  Parameters returned:
c
c  Common blocks referenced:
c
c  Functions and subroutines referenced:
c     close
c     log
c     write
c
c     sys_error_msg
c
c     ISTR_LENGTH
c
c  Common blocks:
c     sysstrct.cmn
c
c  References:
c
c  Change History:
c     21 Oct 95     Changed to get the LOG unit from LWPC_LUN.CMN.
c
c*******************!***************************************************

c     LWPC parameters
      include      'lwpc_lun.cmn'

      character*(*) error_type
      character*(*) error_msg
      integer       ISTR_LENGTH

c     This is a text based program;
c     write messages to standard outout
      WRITE(lwpcLOG_lun,'(a)')
     &      error_type(1:ISTR_LENGTH(error_type))
      WRITE(lwpcLOG_lun,'(a)')
     &      error_msg (1:ISTR_LENGTH(error_msg ))

      if (error_type(1:1) .eq. 'E' .or.
     &    error_type(1:1) .eq. 'e') then

c     This is a fatal ERROR, force termination with a trace back
         temp=1.
         result=LOG(-1.*temp)
         CLOSE(lwpcLOG_lun)
         STOP
      end if

      RETURN
      END      ! LWPC_ERROR
