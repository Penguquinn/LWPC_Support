      SUBROUTINE STR_COUNT_LIST
     &          (string,first_character,last_character,nl)

c***********************************************************************

c  Function:
c     Returns the number of values which are encoded in a character
c     string; the values are separated by commas and spaces

c  Parameters passed:
c     string           [s] character string
c     first_character  [s] character at which to start the search
c     last_character   [s] character at which to end   the search

c  Parameters returned:
c     nl               [i] number of values in the list

c  Common blocks referenced:

c  Functions and subroutines referenced:
c     istr_length

c  References:

c  Change History:
c     08 May 1996   Added test for TAB character.

c*******************!***************************************************

      character*(*) string
      character*  1 TAB
      integer       first_character,last_character
      tab = char(9)


      if (first_character .eq. 0) then
         jf=1
      else
         jf=first_character
      end if
      if (last_character .eq. 0) then
         jl=ISTR_LENGTH(string)
      else
         jl=last_character
      end if

      nl=0
      j=jf
      do while (j .le. jl)
c        Find the starting location of the value
         do while (string(j:j) .eq. ' ' .or.
     &             string(j:j) .eq. TAB)
            if (j .eq. jl) RETURN
            j=j+1
         end do
         nl=nl+1
c        Find the ending location of the value
         do while (string(j:j) .ne. ' ' .and.
     &             string(j:j) .ne. TAB .and.
     &             string(j:j) .ne. ',')
            if (j .eq. jl) RETURN
            j=j+1
         end do
         if (string(j:j) .eq. ',') j=j+1
      end do

      RETURN
      END      ! STR_COUNT_LIST
