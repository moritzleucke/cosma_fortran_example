module blacs_utilities

    use mpi_utils, only: ranks, myid
    
    implicit none

    integer :: ictxt, order, nprow, npcol, myrow, mycol

    contains 

    subroutine init_blacs()

        ! Find the factors of 'ranks' to create a nearly square grid
        nprow = int(sqrt(real(ranks)))
        do while (mod(ranks, nprow) /= 0)
            nprow = nprow - 1
        end do
        npcol = ranks / nprow

        ! init grid 
        call blacs_get(0,0,ictxt)
        call blacs_gridinit(ictxt, order, nprow, npcol)
        call blacs_gridinfo(ictxt, nprow, npcol, myrow, mycol)

        if (myid.eq.0) print *, 'blacs grid:', nprow, 'x', npcol


    end subroutine init_blacs

    subroutine destroy_blacs()
        call blacs_gridexit(ictxt)
        call blacs_exit(0)
    end subroutine destroy_blacs
end module blacs_utilities