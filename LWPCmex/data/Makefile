# Windows nmake Makefile for Intel ifx

FC = ifx

# Optimization / Debug / Profile flags
FOPT  = /O3 /QxCORE-AVX2 /QxHost /warn:nounused
FDBG  = /Wall /check:all /debug:full
FPROF = $(FDBG) /Od /Qprof-gen

# Final flags (matching style of reference)
FFLAGS = $(FOPT) /warn:nointerfaces /Qsave /Qinit:zero

# Executables and generated data files
EXES = unf_coas.exe unf_cond.exe unf_itsn.exe unf_ntia.exe
DATA = coast_d.dat cond_f.dat itsn_d.dat ntia_d.dat

all: $(EXES) $(DATA)


# -------------------------------------------------
# Compile .for → .obj
# -------------------------------------------------

unf_coas.obj: unf_coas.for
	$(FC) /c $(FFLAGS) unf_coas.for

unf_cond.obj: unf_cond.for
	$(FC) /c $(FFLAGS) unf_cond.for

unf_itsn.obj: unf_itsn.for
	$(FC) /c $(FFLAGS) unf_itsn.for

unf_ntia.obj: unf_ntia.for
	$(FC) /c $(FFLAGS) unf_ntia.for


# -------------------------------------------------
# Link → .exe
# -------------------------------------------------

unf_coas.exe: unf_coas.obj
	$(FC) $(FFLAGS) /Fe:unf_coas.exe unf_coas.obj

unf_cond.exe: unf_cond.obj
	$(FC) $(FFLAGS) /Fe:unf_cond.exe unf_cond.obj

unf_itsn.exe: unf_itsn.obj
	$(FC) $(FFLAGS) /Fe:unf_itsn.exe unf_itsn.obj

unf_ntia.exe: unf_ntia.obj
	$(FC) $(FFLAGS) /Fe:unf_ntia.exe unf_ntia.obj


# -------------------------------------------------
# Data file generation (run executables)
# -------------------------------------------------

coast_d.dat: coast.fmt unf_coas.exe
	unf_coas.exe

cond_f.dat: cond_f.fmt unf_cond.exe
	unf_cond.exe

itsn_d.dat: itsn.fmt unf_itsn.exe
	unf_itsn.exe

ntia_d.dat: ntia.fmt unf_ntia.exe
	unf_ntia.exe


# -------------------------------------------------
# Clean
# -------------------------------------------------

clean:
	del /Q *.obj *.exe *.pdb *.ilk *.gcda *.gcno *~ 2>NUL
