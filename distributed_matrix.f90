module distributed_matrix 

    use mpi_utils, only: myid, ranks 
    use blacs_utilities, only: ictxt, nprow, npcol, myrow, mycol

    implicit none 


    type dist_matrix 
        real(kind=8), dimension(:, :), allocatable :: mat
        integer :: glob_rows
        integer :: glob_cols
        integer :: loc_rows
        integer :: loc_cols
        integer :: nb_row
        integer :: nb_col
        integer, dimension(9) :: desc 

        contains 

            procedure :: init_mat
            procedure :: destroy_mat
            procedure :: fill_mat_with

    end type dist_matrix

    integer, external :: numroc

    contains 

    subroutine init_mat(this, glob_rows, glob_cols, nb_row, nb_col) 
        class(dist_matrix), intent(inout) :: this
        integer, intent(in) :: glob_rows
        integer, intent(in) :: glob_cols
        integer, intent(in) :: nb_row
        integer, intent(in) :: nb_col

        ! internal variables 
        integer :: info

        ! store indizes 
        this%glob_rows = glob_rows
        this%glob_cols = glob_cols

        this%nb_row = nb_row
        this%nb_col = nb_col

        this%loc_rows = numroc(glob_rows, nb_row, myrow, 0, nprow)
        this%loc_cols = numroc(glob_cols, nb_col, mycol, 0, npcol)
        
        ! allocate matrix
        if (.not. allocated(this%mat)) then 
            allocate(this%mat(this%loc_rows, this%loc_cols))
        else
            print *, "WARNING: matrix already initiated"
            return
        end if 

        ! initialize descriptor
        call descinit(this%desc, glob_rows, glob_cols, nb_row, nb_col, &
                      0, 0, ictxt, this%loc_rows, info)

    end subroutine

    subroutine destroy_mat(this)
        class(dist_matrix), intent(inout) :: this 

        if (allocated(this%mat)) then 
            deallocate(this%mat)
        end if 
    end subroutine destroy_mat

    subroutine fill_mat_with(this, val)
        class(dist_matrix), intent(inout) :: this 
        real(kind=8), intent(in) :: val

        this%mat(:, :) = val
    end subroutine


    subroutine mat_mul_distributed(mat_A, mat_B, mat_C, backend)
        type(dist_matrix), intent(in) :: mat_A
        type(dist_matrix), intent(in) :: mat_B
        type(dist_matrix), intent(inout) :: mat_C
        character(*), intent(in), optional :: backend

        ! internal variables 
        character :: transA, transB 
        real(kind=8) :: alpha, beta 
        integer, parameter :: scalapack = 1 
        integer, parameter :: cosma = 2
        integer :: local_backend 

        if (present(backend)) then 
            select case (backend)
                case ("scalapack")
                    local_backend = scalapack
                case ("cosma")
                    local_backend = cosma
                case default
                    print *, "pxgemm backend ", backend, " not known"
                    stop 
            end select 
        else 
            local_backend = scalapack
        end if 

        transA = 'n'
        transB = 'n'

        alpha = 1.0d0
        beta = 0.0d0

        if (local_backend.eq.scalapack) then 
            call pdgemm(transA, transB, mat_A%glob_rows, mat_B%glob_cols, mat_A%glob_cols, alpha, &
                        mat_A%mat, 1, 1, mat_A%desc, &
                        mat_B%mat, 1, 1, mat_B%desc, &
                        beta, mat_C%mat, 1, 1, mat_C%desc)
        else if (local_backend.eq.cosma) then 
            call cosma_pdgemm(transA, transB, mat_A%glob_rows, mat_B%glob_cols, mat_A%glob_cols, alpha, &
                        mat_A%mat, 1, 1, mat_A%desc, &
                        mat_B%mat, 1, 1, mat_B%desc, &
                        beta, mat_C%mat, 1, 1, mat_C%desc)
        end if 

    end subroutine



end module 