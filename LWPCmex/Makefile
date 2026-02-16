FOPT=-Ofast -mavx2 -march=native -ffast-math -std=legacy -fallow-argument-mismatch
FDBG=-Wall -fcheck=all -g 
FPROF=$(FDBG) -O0 -fprofile-arcs -ftest-coverage -pg
FFLAGS=$(FOPT) -fno-automatic -finit-local-zero -Iinclude  
FC=gfortran

%.o : %.for
	$(FC) -c $(FFLAGS) -o $@ $<
             
all : lwpm

library/lwpc.a :
	$(MAKE) -C library

lwpm : lwpm.for library/lwpc.a data
	$(FC) $(FFLAGS) -o $@ lwpm.for library/lwpc.a
	
.PHONY : data
data :
	$(MAKE) -C data

.PHONY : libclean
libclean :
	$(MAKE) -C library clean
	
.PHONY : datclean
datclean :
	$(MAKE) -C data clean

.PHONY : clean
clean : libclean datclean
	rm -f lwpm *.o *~ *.mds *.lwf *.gcda *.gcno



