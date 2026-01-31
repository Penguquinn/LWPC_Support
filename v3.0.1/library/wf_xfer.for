      SUBROUTINE WF_XFER
     &          (a,b,n)

c***********************************************************************

c     Transfer array A into array B.

c*******************!***************************************************

      real     *  8 a(n),b(n)


      do j=1,n
         b(j)=a(j)
      end do
      RETURN
      END      ! WF_XFER
