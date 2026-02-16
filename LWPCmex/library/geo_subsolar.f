      SUBROUTINE GEO_SUBSOLAR
     &          (year,month,day,UT,ssp_lat,ssp_lon)

c***********************************************************************

c  Function:
c     Returns the sub-solar point (SSP) for a specific date and UT

c  Parameters passed:
c     year          [i] four-digit year
c     month         [i] month number, Jan is 1
c     day           [i] day of the month
c     UT            [i] Universal time; hours

c  Parameters returned:
c     ssp_lat       [r] geocentric latitude of the sub-solar point,
c                       in degrees, positive towards the north.
c     ssp_lon       [r] geographic longitude of the sub-solar point,
c                       in degrees, positive towards the west.

c  Common blocks referenced:

c  Functions and subroutines referenced:

c     day_number
c     month_name

c     cos
c     mod
c     sin

c  References:

c  Change History:

c*******************!***************************************************

      character*  3 monthName
      integer       year,month,day,daynum


      call MONTH_NAME(month,monthName)

      call DAY_NUMBER(.true.,monthName,day,year,daynum)

      kyr=MOD(year,4)
      SELECT CASE (kyr)

      case (0)
      days=daynum

      case (1)
      days=366+daynum

      case (2)
      days=731+daynum

      case (3)
      days=1096+daynum

      END SELECT

c     Offset to the first equinox
      days=days-79
      if (days .lt. 1) days=days+1461

c     x=(days-1)*twopi/1461 (number of days in 4 years)
      x=(days-1)*.00430060596

      c4 =COS( 4.*x)
      s4 =SIN( 4.*x)
      c8 =COS( 8.*x)
      s8 =SIN( 8.*x)
      c12=COS(12.*x)
      s12=SIN(12.*x)

      glat=0.0161363687-0.0288268261* c4+0.9920590100* s4
     &                 +0.0155524287* c8+0.0047017896* s8
     &                 +0.0007771334*c12-0.0072653652*s12

      glon=0.0008334735-0.4209912787* c4-0.1189339143* s4
     &                 -0.0358274427* c8+0.5896789055* s8
     &                 +0.0184572978*c12+0.0061863454*s12

c     Convert to colat and longitude
      ssp_lat=23.44*glat
      ssp_lon= 4.20*glon+UT*15.-180.

      RETURN
      END      ! GEO_SUBSOLAR
