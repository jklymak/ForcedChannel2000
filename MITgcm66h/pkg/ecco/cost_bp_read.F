C $Header$
C $Name$

#include "ECCO_OPTIONS.h"


      subroutine cost_bp_read(
     I localobsfile, localstartdate, 
     O localobs, localmask,
     I irec,myThid)

c     ==================================================================
c     SUBROUTINE cost_bp_read
c     ==================================================================
c
c     o Read a given record of the GRACE data.
c
c     started: Gael Forget Oct-2009
c
c     ==================================================================
c     SUBROUTINE cost_bp_read
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "GRID.h"

#ifdef ALLOW_CAL
# include "cal.h"
#endif
#ifdef ALLOW_ECCO
# include "ecco_cost.h"
#endif

c     == routine arguments ==

      character*(MAX_LEN_FNAM) localobsfile
      integer localstartdate(4)
      _RL localobs   (1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      _RL localmask  (1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      integer irec
      integer mythid

#ifdef ALLOW_ECCO

c     == local variables ==

      integer bi,bj
      integer i,j,k
      integer itlo,ithi
      integer jtlo,jthi
      integer jmin,jmax
      integer imin,imax
      integer nobs
      integer bprec
      integer beginbp
      integer beginrun

      INTEGER beginlocal, beginmodel, obsrec

      _RL spval
      _RL vartile

cnew(
      integer  il
      integer mody, modm
      integer iyear, imonth
      character*(80) fnametmp
      logical exst
cnew)

c     == external functions ==

      integer  ilnblnk
      external ilnblnk

c     == end of interface ==

      parameter (spval = -998. )
ce    --> there is certainly a better place for this.

      jtlo = mybylo(mythid)
      jthi = mybyhi(mythid)
      itlo = mybxlo(mythid)
      ithi = mybxhi(mythid)
      jmin = 1
      jmax = sny
      imin = 1
      imax = snx


       beginlocal = localstartdate(1)/10000
       beginmodel = modelstartdate(1)/10000
       obsrec =  ( beginmodel - beginlocal )*nmonthyear
     &         + ( mod(modelstartdate(1)/100,100)
     &            -mod(localstartdate(1)/100,100) )
     &         + irec

      mody = modelstartdate(1)/10000
      modm = modelstartdate(1)/100 - mody*100
      iyear = mody + INT((modm-1+irec-1)/12)
      imonth = 1 + MOD(modm-1+irec-1,12)

      il=ilnblnk(localobsfile)
      write(fnametmp(1:80),'(2a,i4)')
     &     localobsfile(1:il), '_', iyear
      inquire( file=fnametmp, exist=exst )
      if (.NOT. exst) then
         write(fnametmp(1:80),'(a)') localobsfile(1:il)
         imonth = obsrec
      endif

      if ( (obsrec.GT.0).AND.(imonth.GT.0) ) then
        call mdsreadfield( fnametmp, cost_iprec, cost_yftype, 1,
     &                   localobs, imonth, mythid )
      else
        do bj = jtlo,jthi
         do bi = itlo,ithi
          do j = jmin,jmax
           do i = imin,imax
            localobs(i,j,bi,bj) = spval
           enddo
          enddo
         enddo
        enddo
      endif

      nobs = 0

      do bj = jtlo,jthi
        do bi = itlo,ithi
          k = 1
          do j = jmin,jmax
            do i = imin,imax
c              if (maskC(i,j,k,bi,bj) .eq. 0.) then
c                localmask(i,j,bi,bj) = 0. _d 0
c              else
c                localmask(i,j,bi,bj) = 1. _d 0
c              endif
              if (localobs(i,j,bi,bj) .le. spval) then
                localmask(i,j,bi,bj) = 0. _d 0
              else
                localmask(i,j,bi,bj) = 1. _d 0
              endif
              localobs(i,j,bi,bj) = localobs(i,j,bi,bj)*
     &                              localmask(i,j,bi,bj)
              nobs = nobs + int(localmask(i,j,bi,bj))
            enddo
          enddo
        enddo
      enddo

#endif

      return
      end

