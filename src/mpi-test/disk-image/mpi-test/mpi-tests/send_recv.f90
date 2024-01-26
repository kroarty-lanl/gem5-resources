program mpi_pass
!! passes data between two threads
!! This would be much simpler using Fortran 2008 coarray syntax
!!
!!  Original author:  John Burkardt
use, intrinsic :: iso_fortran_env, only: real32
use mpi_f08, only : mpi_status, mpi_comm_world, mpi_init, mpi_get_count, &
  mpi_real, mpi_any_source, mpi_any_tag, mpi_source, mpi_tag, mpi_comm_size, &
  mpi_comm_rank, mpi_recv, mpi_send, mpi_finalize

implicit none

real(real32) :: dat, val
integer :: num_procs, id

type(MPI_STATUS) :: status

call MPI_Init()

!  Determine this process's ID.
call MPI_Comm_rank(MPI_COMM_WORLD, id)

!  Find out the number of processes available.
call MPI_Comm_size(MPI_COMM_WORLD, num_procs)

if (num_procs < 2) error stop 'two threads are required, use: mpiexec -np 2 ./mpi_pass'

!  Process 0 expects to receive as much as 200 real values, from any source.
if (id == 0) then
  call MPI_Recv( &
          val, &
          1, &
          MPI_REAL, &
          1, &
          55, &
          MPI_COMM_WORLD, &
          status)

  print *, 'Process 0 received number ', val, ' from process 1'

!  Process 1 sends 1 value to process 0.
else if (id == 1) then
  dat = real(32)
  call MPI_Send( &
          dat, &
          1, &
          MPI_REAL, &
          0, &
          55, &
          MPI_COMM_WORLD)
end if

call MPI_Finalize()
end program
