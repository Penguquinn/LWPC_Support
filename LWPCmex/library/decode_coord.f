      SUBROUTINE DECODE_COORD
     &          (coord,degrees,minutes,hemisphere)

c***********************************************************************

c  Function:
c     Decodes coordinate from a string of the form:
c        DEGREES:MINUTES HEMISPHERE

c  Parameters passed:
c     coord            [s] coordinate string

c  Parameters returned:
c     degrees          [i] degrees
c     minutes          [i] minutes
c     hemisphere       [s] hemisphere [N/S or E/W]

c  Common blocks referenced:

c  Functions and subroutines referenced:
c     ichar
c     index

c     istr_length

c  References:

c  Change History:

c*******************!***************************************************

      character*(*) coord,hemisphere
      character*  4 frmt(3)
      character*256 dummy
      integer       degrees,minutes

      data          frmt/'(i1)','(i2)','(i3)'/


c     Transfer COORD to DUMMY and delete embedded blanks;
c     I3 is the number of characters in the resulting string.
      i3=0
      do i1=1,ISTR_LENGTH(coord)
         if (coord(i1:i1) .ne. ' ') then
            i3=i3+1
            dummy(i3:i3)=coord(i1:i1)
         end if
      end do

c     I1 is location of punctuation between degrees and minutes
      i1=INDEX(dummy,':')
      if (i1 .eq. 0) then

c        The format is DEGREES HEMISPHERE
         if (ICHAR(dummy(i3:i3)) .ge. 48 .and.
     &       ICHAR(dummy(i3:i3)) .le. 57) then

c           Last character is a digit so only DEGREES;
c           I3 is the number of digits
            read (dummy,frmt(i3)) degrees
         else
     &   if (ICHAR(dummy(1:1)) .lt. 48 .or.
     &            ICHAR(dummy(1:1)) .gt. 57) then

c           First character is not a digit so only HEMISPHERE
            hemisphere=dummy
         else

c           The format is DEGREES HEMISPHERE;
c           I2 is the location of the first non-digit character
            i2=1
            do while (ICHAR(dummy(i2:i2)) .ge. 48 .and.
     &                ICHAR(dummy(i2:i2)) .le. 57)
               i2=i2+1
            end do
            read (dummy,frmt(i2-1)) degrees
            if (i2 .le. i3) hemisphere=dummy(i2:i3)
         end if
      else

c        The format is DEGREES:MINUTES HEMISPHERE
         if (ICHAR(dummy(i3:i3)) .ge. 48 .and.
     &       ICHAR(dummy(i3:i3)) .le. 57) then

c           The last character is a digit so only DEGREES:MINUTES
            if (i1 .gt. 1) read (dummy,frmt(i1-1)) degrees
            if (i3 .gt. i1+1) read (dummy(:i1+1),frmt(i3-i1)) minutes

         else

c           The format is DEGREES:MINUTES HEMISPHERE;
c           I2 is the location of the first non-digit character
            i2=i1+1
            do while (ICHAR(dummy(i2:i2)) .ge. 48 .and.
     &                ICHAR(dummy(i2:i2)) .le. 57)
               i2=i2+1
            end do
            if (i1 .gt. 1) read (dummy,frmt(i1-1)) degrees
            if (i2 .gt. i1+1) read (dummy(i1+1:),frmt(i2-i1-1)) minutes
            if (i2 .le. i3) hemisphere=dummy(i2:i3)
         end if
      end if

      RETURN
      END      ! DECODE_COORD
