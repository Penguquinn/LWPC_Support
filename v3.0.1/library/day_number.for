      SUBROUTINE DAY_NUMBER
     &          (to_day_number,month,day,year,date)

c***********************************************************************

c  Function:
c     Converts date (day number) to/from month and day. YEAR is used
c     to determine if leap year.

c  Parameters passed:
c     to_day_number [l  ] =T:  MONTH, DAY and YEAR to DATE
c                         =F:  DATE and YEAR to MONTH and DAY
c        year       [i  ] year

c     If TO_DAY_NUMBER is true:
c        month      [s  ] month name
c        day        [i  ] day of the month

c     If TO_DAY_NUMBER is false:
c        date       [i  ] day number

c  Parameters returned:
c     If TO_DAY_NUMBER is true:
c        date       [i  ] day number

c     If TO_DAY_NUMBER is false:
c        month      [s  ] month name
c        day        [i  ] day of the month

c  Common blocks referenced:

c  Functions and subroutines referenced:
c     mod

c     leap_year
c     month_number

c  References:

c  Change History:
c     22 Mar 1997   Added call to leap year function.

c*******************!***************************************************

      character*(*) month
      logical       to_day_number,leap,
     &              leap_year
      integer       day,year,date,days

      dimension     days(13)
      data          days/0,31,59,90,120,151,181,212,243,273,304,334,365/


c     Determine if this is a leap year
      leap=LEAP_YEAR (year)

      if (to_day_number) then

c        Convert MONTH and DAY to DATE (day number).
         call MONTH_NUMBER (month,mnth)
         date=days(mnth)+day
         if (leap .and. mnth .gt. 2) date=date+1
      else

c        Convert DATE (day number) to MONTH and DAY.
         jday=date
         if (leap) then
c           Leap year
            if (jday .eq. 60) then
c              Leap year, Feb 29
               month='February'
               day=29
               RETURN
            else
     &      if (jday .gt. 60) then
c              Leap year but date is past Feb 29
               jday=jday-1
            end if
         end if
         j=2
         do while (jday .gt. days(j))
            j=j+1
         end do
         mnth=j-1
         day=jday-days(mnth)
         call MONTH_NAME (mnth,month)
      end if
      RETURN
      END      ! DAY_NUMBER
