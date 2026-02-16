      SUBROUTINE DECODE_LIST_STR
     &          (data_string,
     &           mxlist,nrlist,list)

c***********************************************************************

c  Function:
c     Reads a list of charcter items from a data string

c  Parameters passed:
c     parameter-name [t,n] description {t is type, n is dimension}

c     data_string    [c,*] string containing the data to be decoded.
c     mxlist         [i  ] maximum number of strings which can be output

c  Parameters returned:
c     parameter-name [t,n] description {t is type, n is dimension}

c     nrlist         [i  ] number of strings which are output
c     list           [r  ] array of character strings to be output

c  Common blocks referenced:

c  Functions and subroutines referenced:
c     str_count_list
c     str_get_item

c  References:

c  Change History:

c*******************!***************************************************

      character*(*) data_string
      character*120 item
      character*200 error_msg
      character*(*) list(mxlist)


      if (ISTR_LENGTH(data_string) .eq. 0) THEN
         write(error_msg,
     &       '(''[DECODE_LIST_STR]: Data string missing'')')
         call LWPC_ERROR('ERROR', error_msg)
      end if

      call STR_COUNT_LIST (data_string,0,0,nrlist)

      if (nrlist .gt. mxlist) then
         nrlist=mxlist
      end if

      do n=1,nrlist
         item=''
         call STR_GET_ITEM (n,data_string,item,n1,n2)
         if (ISTR_LENGTH(item) .gt. 0) list(n)=item
      end do

      RETURN
      END      ! DECODE_LIST_STR
