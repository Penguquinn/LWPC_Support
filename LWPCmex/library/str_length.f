      FUNCTION   iSTR_LENGTH
     &          (string)

c***********************************************************************

c  Function:
c     Returns the location of the last right-most non-blank character of
c     a string.  Leading blanks are included in the length.

c  Parameters passed:
c     string           [s] character string

c  Parameters returned:

c  Common blocks referenced:

c  Functions and subroutines referenced:
c     len

c  References:

c  Change History:
c     08 May 1996   Added test for TAB character.

c*******************!***************************************************

      character     string*(*)
      character*  1 TAB
      tab = char(9)


c     Check if string is defined
      if (iCHAR(string(1:1)) .eq. 0) then
         istr_length=0
      else
c        Determine the dimension of the string
         istr_length=LEN(string)
c        Count the number of characters in the string
10       if (iCHAR(string(istr_length:istr_length)) .gt. 0) then
            if (string(istr_length:istr_length) .ne. ' ' .and.
     &          string(istr_length:istr_length) .ne. TAB) RETURN
         end if
         istr_length=istr_length-1
         if (istr_length .gt. 0) go to 10
      end if
      RETURN
      END      ! iSTR_LENGTH
