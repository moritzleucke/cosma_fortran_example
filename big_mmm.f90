program big_mmm

    use mpi_utils, only: init_mpi, destroy_mpi, mpi_barrier, mpi_comm_world, ierror
    use blacs_utilities
    use distributed_matrix, only: dist_matrix, mat_mul_distributed
    use timer, only: clock

    implicit none

    integer :: m, n, k, nb
    type(clock) :: scalapack, cosma 


    call init_mpi()
    call init_blacs()

    !m = 10000
    !n = 20000
    !k = 1000000
!
    !nb = 64

    call get_cli_arguments(m, n, k, nb)

    !m = 1000
    !n = 2000
    !k = 100000

    !-------------------------------------------------- 
    ! BLAS
    !-------------------------------------------------- 
    !call run_BLAS("blas", m, n, k, blas)

    !-------------------------------------------------- 
    ! ScalaPack
    !-------------------------------------------------- 
    call run_distributed("ScalaPACK", m, n, k, nb, nb, nb, scalapack, "scalapack")
    call run_distributed("COSMA", m, n, k, nb, nb, nb, cosma, "cosma")
    if (myid.eq.0) print *, "speedup cosma:", scalapack%time/cosma%time




    call destroy_blacs()


    contains 

    subroutine run_locally(name, m, n, k, time)
        character(*), intent(in) :: name 
        integer, intent(in) :: m
        integer, intent(in) :: n
        integer, intent(in) :: k
        type(clock), intent(inout) :: time
        
        ! internal variables
        real(kind=8), dimension(:, :), allocatable :: A, B, C 

        allocate(A(m, k), B(k, n), C(m, n))
        A(:, :) = 1.3
        B(:, :) = 2.5
        call time%start_clock()
        call dgemm('n', 'n', m, n, k, 1.0d0, A, m, B, k, 0.0d0, C, m)
        call time%end_clock()
        if (myid.eq.0) print *, name, m, n, k, time%time
        deallocate(A, B, C)

    end subroutine



    subroutine run_distributed(name, m, n, k, nb_m, nb_n, nb_k, time, backend)
        character(*), intent(in) :: name 
        integer, intent(in) :: m
        integer, intent(in) :: n
        integer, intent(in) :: k
        integer, intent(in) :: nb_m
        integer, intent(in) :: nb_n
        integer, intent(in) :: nb_k
        type(clock), intent(inout) :: time
        character(*), intent(in), optional :: backend

        ! internal variables
        type(dist_matrix) :: mat_A, mat_B, mat_C
        character(10) :: local_backend

        if (present(backend)) then 
            local_backend = backend
        else 
            local_backend = "scalapack"
        end if 

        !initialize matrices
        call mat_A%init_mat(m, k, nb_m, nb_k)
        call mat_A%fill_mat_with(1.3d0)
        call mat_B%init_mat(k, n, nb_k, nb_n)
        call mat_B%fill_mat_with(2.5d0)
        call mat_C%init_mat(m, n, nb_m, nb_n)

        ! run matmul
        call mpi_barrier(mpi_comm_world, ierror)
        call time%start_clock()
        call mat_mul_distributed(mat_A, mat_B, mat_C, local_backend)
        call mpi_barrier(mpi_comm_world, ierror)
        call time%end_clock()
        if (myid.eq.0) print *, name, ' ', m, n, k, nb_m, nb_n, nb_k, time%time

        ! deallocate
        call mat_A%destroy_mat()
        call mat_B%destroy_mat()
        call mat_C%destroy_mat()

    end subroutine

    subroutine get_cli_arguments(m, n, k, nb)
        integer, intent(out) :: m
        integer, intent(out) :: n
        integer, intent(out) :: k
        integer, intent(out) :: nb 

        ! internal variables
        character(10) :: tmp 

        call get_command_argument(1, tmp)
        read(tmp, *) m
        call get_command_argument(2, tmp)
        read(tmp, *) n
        call get_command_argument(3, tmp)
        read(tmp, *) k
        call get_command_argument(4, tmp)
        read(tmp, *) nb

    end subroutine


end program big_mmm

