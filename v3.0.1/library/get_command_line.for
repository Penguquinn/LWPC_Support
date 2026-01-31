      SUBROUTINE GET_COMMAND_LINE
     &          (LenCMD,CMDLine)

c      USE DFLIB

c***********************************************************************
c                         subroutine get_command_line
c***********************************************************************

c  Program Source:  Naval Ocean Systems Center - Code 542

c  Date:
c     04 Dec 1996

c  Function:
c     Returns current command line used to run the program

c  Parameters passed:
c     none

c  Parameters returned:
c     LenCMD           [i] length of the command line
c     cmdline          [s] the command line

c  Common blocks referenced:

c  Functions and subroutines referenced:
c     fgetcmd
c     getarg
c     iargc

c  References:

c  Change History:

c        April 7, 2003 : Modified to handle Compaq Fortran Compiler

c*******************!***************************************************

c     WATCOM specific code
c      integer       FGETCMD
c      integer       i,n
c      integer       ISTR_LENGTH
c      integer       LenCMD
c      character*120 CMDLine
c      character*80  buf

c     SUN SOLARIS specific code
c     character *60 argv(2)


c     WATCOM specific code
c      LenCMD=FGETCMD (CMDLine)
c     WATCOM specific code

c     COMPAQ specific code
c      n=IARGC ()
c      do i=1,n
c        call GETARG (i,buf)
c        if (i .EQ. 1)  then
c           CMDLine = buf (1:ISTR_LENGTH(buf))
c        else
c           CMDLine = CMDLine(1:ISTR_LENGTH(CMDLine))//' '
c           CMDLine = CMDLine(1:ISTR_LENGTH(CMDLine)+1)//
c     &               buf(1:ISTR_LENGTH(buf))
c        end if
c      end do
c      LenCMD=n

c     COMPAQ specific code

c     SUN SOLARIS specific code
c     n=IARGC ()
c     do i=1,n
c        call GETARG (i,argv)
c     end do
c     CMDLine=argv(1)
c     LenCMD=n
c     SUN SOLARIS specific code

c     gfortran
      integer       LenCMD
      character*(*) CMDLine
      CALL GETARG(1,CMDLine)
      LenCMD = ISTR_LENGTH(CMDLine)

      RETURN
      END      ! GET_COMMAND_LINE
