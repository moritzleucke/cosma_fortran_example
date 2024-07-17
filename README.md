# COSMA fortran example 


compile cosma:
```
cmake -DCOSMA_BLAS=CUDA -DCOSMA_SCALAPACK=CUSTOM -DCOSMA_WITH_NCCL=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=/p/project1/eat2d/mleucke/cosma/install ..
```

link:
```
-lopenblas -lcosma_prefixed_pxgemm -lcosma  -lTiled-MM -lcublas -lcudart -lrt  -lscalapack
```