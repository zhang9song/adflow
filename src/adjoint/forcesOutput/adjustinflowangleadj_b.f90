!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade 2.2.4 (r2308) - 03/04/2008 10:03
!  
!  Differentiation of adjustinflowangleadj in reverse (adjoint) mode:
!   gradient, with respect to input variables: alphaadj betaadj
!   of linear combination of output variables: liftdirectionadj
!                veldirfreestreamadj
!
!      ******************************************************************
!      *                                                                *
!      * File:          adjustInflowAngleAdj.f90                        *
!      * Author:        C.A.(Sandy) Mader                               *
!      * Starting date: 05-14-2008                                      *
!      * Last modified: 05-14-2008                                      *
!      *                                                                *
!      ******************************************************************
!
SUBROUTINE ADJUSTINFLOWANGLEADJ_B(alphaadj, alphaadjb, betaadj, betaadjb&
&  , veldirfreestreamadj, veldirfreestreamadjb, liftdirectionadj, &
&  liftdirectionadjb, dragdirectionadj)
  USE constants
  IMPLICIT NONE
!Subroutine Vars
  REAL(KIND=REALTYPE), DIMENSION(3) :: veldirfreestreamadj
  REAL(KIND=REALTYPE), DIMENSION(3) :: veldirfreestreamadjb
  REAL(KIND=REALTYPE), DIMENSION(3) :: liftdirectionadj
  REAL(KIND=REALTYPE), DIMENSION(3) :: liftdirectionadjb
  REAL(KIND=REALTYPE), DIMENSION(3) :: dragdirectionadj
  REAL(KIND=REALTYPE) :: alphaadj, betaadj
  REAL(KIND=REALTYPE) :: alphaadjb, betaadjb
!Local Vars
  REAL(KIND=REALTYPE) :: temp1, temp2, temp3
!Begin Execution
! Velocity direction given by the rotation of a unit vector
! initially aligned along the positive x-direction (1,0,0)
! 1) rotate alpha radians cw about z-axis
! 2) rotate beta radians ccw about y-axis
!temp1 = velDirFreestreamAdj(1)
!temp2 = velDirFreestreamAdj(2)
!temp3 = velDirFreestreamAdj(3)
!      call getDirVector(one, zero, zero, alphaAdj, betaAdj, &
!                        velDirFreestreamAdj(1), &
!                        velDirFreestreamAdj(2), &
!                        velDirFreestreamAdj(3))
! Drag direction given by the rotation of a unit vector
! initially aligned along the positive x-direction (1,0,0)
! 1) rotate alpha radians cw about z-axis
! 2) rotate beta radians ccw about y-axis
!      call getDirVector(one, zero, zero, alphaAdj, betaAdj,   &
!                        dragDirectionAdj(1), dragDirectionAdj(2), &
!                        dragDirectionAdj(3))
!temp1 = dragDirectionAdj(1)
!temp2 = dragDirectionAdj(2)
!temp3 = dragDirectionAdj(3)
! Lift direction given by the rotation of a unit vector
! initially aligned along the positive z-direction (0,0,1)
! 1) rotate alpha radians cw about z-axis
! 2) rotate beta radians ccw about y-axis
!      call getDirVector(zero,one, zero, alphaAdj, betaAdj,   &
!                        liftDirectionAdj(1), liftDirectionAdj(2), &
!                        liftDirectionAdj(3))
!temp1 = liftDirectionAdj(1)
!temp2 = liftDirectionAdj(2)
!temp3 = liftDirectionAdj(3)
  REAL(KIND=REALTYPE) :: temp1b, temp2b, temp3b
  temp3b = liftdirectionadjb(3)
  liftdirectionadjb(3) = 0.0
  temp2b = liftdirectionadjb(2)
  liftdirectionadjb(2) = 0.0
  temp1b = liftdirectionadjb(1)
  betaadjb = 0.0
  alphaadjb = 0.0
  CALL GETDIRVECTOR_B(zero, one, zero, alphaadj, alphaadjb, betaadj, &
&                betaadjb, temp1, temp1b, temp2, temp2b, temp3, temp3b)
  temp3b = veldirfreestreamadjb(3)
  veldirfreestreamadjb(3) = 0.0
  temp2b = veldirfreestreamadjb(2)
  veldirfreestreamadjb(2) = 0.0
  temp1b = veldirfreestreamadjb(1)
  CALL GETDIRVECTOR_B(one, zero, zero, alphaadj, alphaadjb, betaadj, &
&                betaadjb, temp1, temp1b, temp2, temp2b, temp3, temp3b)
END SUBROUTINE ADJUSTINFLOWANGLEADJ_B
