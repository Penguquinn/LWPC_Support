module lwpm_c_wrapper
  use iso_c_binding, only: c_char, c_int, c_ptr, c_f_pointer, c_null_char
  implicit none

contains

  subroutine LWPM_C(lwpcDAT_loc, lwpcDAT_len, file_name, file_name_len) bind(C,name="LWPM_C")

  use iso_c_binding
  implicit none

  integer(c_int), value :: lwpcDAT_len
  integer(c_int), value :: file_name_len

  character(kind=c_char), intent(in) :: lwpcDAT_loc(lwpcDAT_len)
  character(kind=c_char), intent(in) :: file_name(file_name_len)

  character(len=:), allocatable :: lwpcDAT_f, fname_f
  integer :: i

  allocate(character(len=lwpcDAT_len) :: lwpcDAT_f)
  allocate(character(len=file_name_len) :: fname_f)

  do i = 1, lwpcDAT_len
      lwpcDAT_f(i:i) = lwpcDAT_loc(i)
  end do
  lwpcDAT_f(lwpcDAT_len+1:lwpcDAT_len+1) = c_null_char
  do i = 1, file_name_len
      fname_f(i:i) = file_name(i)
  end do
  fname_f(file_name_len+1:file_name_len+1) = c_null_char
  write(*,*) "It worked"
  print *, lwpcDAT_f
  print *, fname_f

  call LWPM(lwpcDAT_f, lwpcDAT_len, fname_f,file_name_len)

end subroutine


end module lwpm_c_wrapper
