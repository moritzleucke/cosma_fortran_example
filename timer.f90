module timer

    implicit none 

    type clock

        real :: start, end, time 

        contains

            procedure :: start_clock
            procedure :: end_clock
            procedure :: report
            
    end type clock

    contains 

        subroutine start_clock(this)
            class(clock), intent(inout) :: this 
            call cpu_time(this%start)
        end subroutine

        subroutine end_clock(this)
            class(clock), intent(inout) :: this
            call cpu_time(this%end)
            this%time = this%end - this%start
        end subroutine

        subroutine report(this, name)
            class(clock), intent(in) :: this 
            character(*), intent(in) :: name 
            print *, name, ': ', this%time, 's'
        end subroutine
        
end module timer 