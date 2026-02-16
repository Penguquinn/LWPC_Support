      SUBROUTINE SW_NEXT
     &          (pflag,nsgmnt0,nsgmnt)

c***********************************************************************

c     Locates the next segment which matches the one just done

c pflag          profile index flag
c      =0 ---    non-exponential profile on whole path
c      =1 ---        exponential profile on whole path
c      =2 ---        exponential profiles for all day
c      =3 ---        exponential profiles for all night
c      =4,11-        exponential profiles for a specific date and time
c      =5,7,9    non-exponential profiles at each point
c      =6,8,10       exponential profiles at each point

c nsgmnt0        index of starting segment
c nsgmnt         index of current segment

c*******************!***************************************************

      parameter    (mxsgmnt=2001)

      common/mf_sw_1/
     &              dst(mxsgmnt),xla(mxsgmnt),xlo(mxsgmnt),
     &              azm(mxsgmnt),xdp(mxsgmnt),fld(mxsgmnt),
     &              sgm(mxsgmnt),eps(mxsgmnt),ncd(mxsgmnt),
     &              bta(mxsgmnt),hpr(mxsgmnt),npr(mxsgmnt),
     &              num(mxsgmnt),nrsgmnt

      logical       endLoop
      integer       pflag


      endLoop=.false.
      do while (.not.endLoop)
         nsgmnt=nsgmnt+1
         if (nsgmnt .gt. nrsgmnt) then

            endLoop=.true.
         else

            if (sgm(nsgmnt) .eq. sgm(nsgmnt0) .and.
     &          num(nsgmnt) .eq. 0) then

               if (pflag .gt. 1) then

                  if (pflag .eq. 5 .or. pflag .eq. 7 .or.
     &                pflag .eq. 9) then

                     if (npr(nsgmnt) .eq. npr(nsgmnt0)) endLoop=.true.
                  else

                     if (hpr(nsgmnt) .eq. hpr(nsgmnt0)) endLoop=.true.
                  end if
               else

                  endLoop=.true.
               end if
            end if
         end if
      end do

      RETURN
      END      ! SW_NEXT
