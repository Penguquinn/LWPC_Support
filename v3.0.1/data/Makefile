FOPT=-O3 -mavx -march=native -ffast-math
FDBG=-Wall -fcheck=all -g 
FPROF=$(FDBG) -O0 -fprofile-arcs -ftest-coverage -pg
FFLAGS=$(FPROF) -fno-automatic -finit-local-zero
FC=gfortran
FILES=coast_d.dat cond_f.dat itsn_d.dat ntia_d.dat unf_coas.out unf_cond.out unf_itsn.out unf_ntia.out

all : $(FILES)

%.out : %.for
	$(FC) $(FFLAGS) -o $@ $< 

coast_d.dat : coast.fmt unf_coas.out
	./unf_coas.out
	
cond_f.dat : cond_f.fmt unf_cond.out
	./unf_cond.out
	
itsn_d.dat : itsn.fmt unf_itsn.out
	./unf_itsn.out

ntia_d.dat : ntia.fmt unf_ntia.out
	./unf_ntia.out

.PHONY : clean
clean : 
	rm -f $(FILES) *.o *.gcda *.gcno *~
