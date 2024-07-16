# export LD_LIBRARY_PATH="/p/project1/eat2d/mleucke/cosma/install/lib64:$LD_LIBRARY_PATH"

# Define the Fortran compiler
FC = mpifort

# Define compiler flags
#LIBS = -lopenblas -lscalapack
#LIBS = -lopenblas -L/p/project1/eat2d/mleucke/cosma/install/lib64 -lcosma_pxgemm -lcosma -lcosta_scalapack -lscalapack
#LIBS = -lopenblas -L/p/project1/eat2d/mleucke/cosma/install/lib64 -lcosma_pxgemm -lcosma  -lTiled-MM -lcublas -lcudart -lrt  -lscalapack
LIBS = -lopenblas -L/p/project1/eat2d/mleucke/cosma/install/lib64 -lcosma_prefixed_pxgemm -lcosma  -lTiled-MM -lcublas -lcudart -lrt  -lscalapack
INC = -I/p/project1/eat2d/mleucke/cosma/install/include
FCFLAGS = -Wall -O2 -g $(LIBS) $(INC)

# Define the target executable name
TARGET = test

# Define the source files
SRCS = big_mmm.f90 timer.f90 mpi.f90 blacs.f90 distributed_matrix.f90

# Define the object files (replace .f90 with .o)
OBJS = $(SRCS:.f90=.o)

# Default rule to build the executable
all: $(TARGET)

# Rule to link object files and create the executable
$(TARGET): $(OBJS)
	$(FC) $(FCFLAGS) -o $(TARGET) $(OBJS)

# Rule to compile module.f90 into module.o
timer.o: timer.f90
	$(FC) $(FCFLAGS) -c timer.f90

mpi.o: mpi.f90
	$(FC) $(FCFLAGS) -c mpi.f90

blacs.o: blacs.f90
	$(FC) $(FCFLAGS) -c blacs.f90

distributed_matrix.o: distributed_matrix.f90
	$(FC) $(FCFLAGS) -c distributed_matrix.f90

# Rule to compile main.f90 into main.o
big_mmm.o: big_mmm.f90 timer.o mpi.o blacs.o distributed_matrix.o
	$(FC) $(FCFLAGS) -c big_mmm.f90

# Clean rule to remove object files and the executable
clean:
	rm -f $(OBJS) $(TARGET) *.mod slurm*

# Phony targets to avoid conflicts with files named 'all' or 'clean'
.PHONY: all clean
