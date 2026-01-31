      SUBROUTINE MF_XFER (a,b,n)

c***********************************************************************

c     Routine for transferring the values of one complex array into
c     another.

c*******************!***************************************************

      complex       a(n),b(n)


      do i=1,n
         b(i)=a(i)
      end do
      return

      END      ! MF_XFER
