!
!     ******************************************************************
!     *                                                                *
!     * File:          computeForcesAdj.f90                            *
!     * Author:        C.A.(Sandy) Mader, Andre C. Marta               *
!     *                Seongim Choi
!     * Starting date: 12-14-2007                                      *
!     * Last modified: 12-27-2007                                      *
!     *                                                                *
!     ******************************************************************
!
      subroutine computeForcesAdj(xAdj,wAdj,pAdj, &
                       iiBeg,iiEnd,jjBeg,jjEnd,i2Beg,i2End,j2Beg,j2End, &
                       mm,cFxAdj,cFyAdj,cFzAdj,cMxAdj,cMyAdj,cMzAdj,&
                       yplusMax,refPoint,CLAdj,CDAdj,  &
                       nn,level,sps,cFpAdj,cMpAdj,righthanded,&
                       alphaAdj,betaAdj,machAdj,machcoefAdj,prefAdj,&
                       rhorefAdj, pinfdimAdj, rhoinfdimAdj,&
                       rhoinfAdj, pinfAdj,murefAdj, timerefAdj,pInfCorrAdj)
        !(xAdj, &
        !         iiBeg,iiEnd,jjBeg,jjEnd,i2Beg,i2End,j2Beg,j2End, &
        !         mm,cFxAdj,cFyAdj,cFzAdj, &
        !         cMxAdj,cMyAdj,cMzAdj,yplusMax,refPoint,CLAdj,CDAdj,  &
         !        nn,level,sps,cFpAdj,cMpAdj)
!
!     ******************************************************************
!     *                                                                *
!     * Computes the Force coefficients for the current configuration  *
!     * for the finest grid level and specified time instance using the*
!     * auxiliar routines modified for tapenade. This code calculates  *
!     * the result for a single boundary subface and requires an       *
!     * outside driver to loop over mm subfaces and nn domains to      *
!     * calculate the total forces and moments.                        *
!     *                                                                *
!     ******************************************************************
!
      use blockPointers        ! ie,je,ke
      use communication        ! procHalo(currentLevel)%nProcSend, myID
      use inputPhysics         ! equations
      use inputTimeSpectral    ! nTimeIntervalsSpectral!nTimeInstancesMax
      use bcTypes              ! EulerWall, ...
      use flowvarrefstate      !nw

      implicit none

!
!     Subroutine arguments.
!
      integer(kind=intType), intent(in) :: mm,nn,level, sps
      integer(kind=intType), intent(in) :: iiBeg,iiEnd,jjBeg,jjEnd
      integer(kind=intType), intent(in) :: i2Beg,i2End,j2Beg,j2End

      real(kind=realType), dimension(3) :: refPoint
      real(kind=realType) :: yplusMax
      real(kind=realType),dimension(3) :: cFpAdj, cMpAdj , cFvAdj, cMvAdj 
      real(kind=realType), dimension(0:ie,0:je,0:ke,3), intent(in) :: xAdj
      real(kind=realType), dimension(0:ib,0:jb,0:kb,nw), intent(in) :: wAdj
      real(kind=realType), dimension(0:ib,0:jb,0:kb), intent(in) :: pAdj
      ! notice the range of x dim is set 1:2 which corresponds to 1/il
      real(kind=realType), dimension(nTimeIntervalsSpectral)::       &
                             ClAdj,CdAdj,CfxAdj,CfyAdj,CfzAdj,   &
                             CmxAdj,CmyAdj,CmzAdj
      real(kind=realType), dimension(3) :: velDirFreestreamAdj
      real(kind=realType), dimension(3) :: liftDirectionAdj
      real(kind=realType), dimension(3) :: dragDirectionAdj
      real(kind=realType) :: MachAdj,MachCoefAdj,uInfAdj,pInfCorrAdj
      real(kind=realType), dimension(nw)::wInfAdj 
      REAL(KIND=REALTYPE) :: prefAdj, rhorefAdj
      REAL(KIND=REALTYPE) :: pinfdimAdj, rhoinfdimAdj
      REAL(KIND=REALTYPE) :: rhoinfAdj, pinfAdj
      REAL(KIND=REALTYPE) :: murefAdj, timerefAdj
      
      real(kind=realType) :: alphaAdj, betaAdj


!
!     Local variables.
!
      real(kind=realType), dimension(1:2,iiBeg:iiEnd,jjBeg:jjEnd,3) :: siAdj 
      ! notice the range of y dim is set 1:2 which corresponds to 1/jl
      real(kind=realType), dimension(iiBeg:iiEnd,1:2,jjBeg:jjEnd,3) :: sjAdj
      ! notice the range of z dim is set 1:2 which corresponds to 1/kl
      real(kind=realType), dimension(iiBeg:iiEnd,jjBeg:jjEnd,1:2,3) :: skAdj
      real(kind=realType), dimension(iiBeg:iiEnd,jjBeg:jjEnd,3) :: normAdj

      !add to allow for scaling!
      real(kind=realType), dimension(3):: cFpAdjOut, cFvAdjOut
      real(kind=realType), dimension(3):: cMpAdjOut, cMvAdjOut

      logical, intent(in)::righthanded

      integer(kind=intType):: i,j,k,l,kk
!
!     ******************************************************************
!     *                                                                *
!     * Begin execution.                                               *
!     *                                                                *
!     ******************************************************************
!
      
      !===============================================================
      ! Compute the forces.

!      call the initialization routines to calculate the effect of Mach and alpha
      call adjustInflowAngleAdj(alphaAdj,betaAdj,velDirFreestreamAdj,&
           liftDirectionAdj,dragDirectionAdj)
      
      call checkInputParamAdj(velDirFreestreamAdj,liftDirectionAdj,&
           dragDirectionAdj, Machadj, MachCoefAdj)
      
      call referenceStateAdj(velDirFreestreamAdj,liftDirectionAdj,&
           dragDirectionAdj, Machadj, MachCoefAdj,uInfAdj,prefAdj,&
           rhorefAdj, pinfdimAdj, rhoinfdimAdj, rhoinfAdj, pinfAdj,&
           murefAdj, timerefAdj)
      !(velDirFreestreamAdj,liftDirectionAdj,&
      !     dragDirectionAdj, Machadj, MachCoefAdj,uInfAdj)
      
      call setFlowInfinityStateAdj(velDirFreestreamAdj,liftDirectionAdj,&
           dragDirectionAdj, Machadj, MachCoefAdj,uInfAdj,wInfAdj,prefAdj,&
           rhorefAdj, pinfdimAdj, rhoinfdimAdj, rhoinfAdj, pinfAdj,&
           murefAdj, timerefAdj,pInfCorrAdj)

      
      ! Compute the surface normals (normAdj which is used only in 
      ! visous force computation) for the stencil
      ! Get siAdj,sjAdj,skAdj,normAdj

          
      call getSurfaceNormalsAdj(xAdj,siAdj,sjAdj,skAdj,normAdj, &
           iiBeg,iiEnd,jjBeg,jjEnd,mm,level,nn,sps,righthanded)

      call computeForcesPressureAdj(wAdj, pAdj)

      
      ! Integrate force components along the given subface
      call forcesAndMomentsAdj(cFpAdj,cMpAdj,cFvAdj,cMvAdj, &
           cFpAdjOut,cMpAdjOut, cFvAdjOut,cMvAdjOut, &
           yplusMax,refPoint,siAdj,sjAdj,skAdj,normAdj,xAdj,pAdj,wAdj,&
           iiBeg,iiEnd,jjBeg,jjEnd,i2Beg,i2End,j2Beg,j2End, &
           level,mm,nn,machCoefAdj)
      !(cFpAdj,cMpAdj, &
      !     cFpAdjOut,cMpAdjOut, &
      !     yplusMax,refPoint,siAdj,sjAdj,skAdj,normAdj,xAdj,pAdj,wAdj,&
      !     iiBeg,iiEnd,jjBeg,jjEnd,i2Beg,i2End,j2Beg,j2End, &
      !     level,mm,nn,machCoefAdj)
      

      !end if invForce
         
      ! Compute the force components for the current block subface
    
      CLAdj(sps) = (cfpAdjOut(1) + cfvAdjOut(1))*liftDirectionAdj(1) &
                 + (cfpAdjOut(2) + cfvAdjOut(2))*liftDirectionAdj(2) &
                 + (cfpAdjOut(3) + cfvAdjOut(3))*liftDirectionAdj(3)
      
      CDAdj(sps) = (cfpAdjOut(1) + cfvAdjOut(1))*dragDirectionAdj(1) &
                 + (cfpAdjOut(2) + cfvAdjOut(2))*dragDirectionAdj(2) &
                 + (cfpAdjOut(3) + cfvAdjOut(3))*dragDirectionAdj(3)

      
      CfxAdj(sps) = cfpAdjOut(1) + cfvAdjOut(1)
      
      CfyAdj(sps) = cfpAdjOut(2) + cfvAdjOut(2)
      
      CfzAdj(sps) = cfpAdjOut(3) + cfvAdjOut(3)
      
      CmxAdj(sps) = cmpAdjOut(1) + cmvAdjOut(1)
      
      CmyAdj(sps) = cmpAdjOut(2) + cmvAdjOut(2)
      
      CmzAdj(sps) = cmpAdjOut(3) + cmvAdjOut(3)
!!$      
    end subroutine computeForcesAdj
