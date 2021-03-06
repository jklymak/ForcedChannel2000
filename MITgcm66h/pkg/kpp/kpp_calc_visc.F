C $Header$
C $Name$

#include "KPP_OPTIONS.h"

      SUBROUTINE KPP_CALC_VISC(
     I        bi,bj,iMin,iMax,jMin,jMax,K,
     U        KappaRU,KappaRV,
     I        myThid)

C     *==========================================================*
C     | SUBROUTINE KPP_CALC_VISC                                 |
C     | o Add contrubution to net viscosity from KPP mixing      |
C     *==========================================================*
      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DYNVARS.h"
#include "GRID.h"
#include "KPP.h"

C     == Routine arguments ==
C     bi, bj, iMin, iMax, jMin, jMax - Range of points for which calculation
C     myThid - Instance number for this innvocation of CALC_COMMON_FACTORS
C
      INTEGER bi,bj,iMin,iMax,jMin,jMax,K
      _RL KappaRU(1-Olx:sNx+Olx,1-Oly:sNy+Oly,Nr)
      _RL KappaRV(1-Olx:sNx+Olx,1-Oly:sNy+Oly,Nr)
      INTEGER myThid

C     == Local variables ==
C     I, J, K - Loop counters
      INTEGER i,j

      DO j=jMin,jMax
       DO i=iMin,iMax
        KappaRU(i,j,k) = max ( KappaRU(i,j,k),
     &         KappaRU(i,j,k) - viscArNr(1) + _maskW(i,j,k,bi,bj) *
     &         0.5*(KPPviscAz(i,j,k,bi,bj)+KPPviscAz(i-1,j,k,bi,bj)) )
       ENDDO
      ENDDO

      DO j=jMin,jMax
       DO i=iMin,iMax
        KappaRV(i,j,k) = max ( KappaRV(i,j,k),
     &         KappaRV(i,j,k) - viscArNr(1) + _maskS(i,j,k,bi,bj) *
     &         0.5*(KPPviscAz(i,j,k,bi,bj)+KPPviscAz(i,j-1,k,bi,bj)) )
       ENDDO
      ENDDO

      RETURN
      END
