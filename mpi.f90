module mpi_utils

    use mpi_f08
    implicit none


    integer :: myid, ranks, ierror


    contains 

    subroutine init_mpi()
        call MPI_INIT(ierror)
        call mpi_comm_size(mpi_comm_world, ranks, ierror)
        call mpi_comm_rank(mpi_comm_world, myid, ierror)

        if (myid.eq.0) print *, 'mpi: ', ranks, ' ranks'
    end subroutine init_mpi


    subroutine destroy_mpi()
        call mpi_finalize(ierror)
    end subroutine


end module mpi_utils