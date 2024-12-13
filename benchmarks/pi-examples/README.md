# Computing pi with Julia

Kernel taken from <https://github.com/UCL-RITS/pi_examples/blob/6e194e18325605095bac826b6450a9b4e6978d2d/julia_pi_dir/pi.jl>.

I could reproduce the funky weak scaling observed in Julia also with the [C OpenMP version of the code](https://github.com/UCL-RITS/pi_examples/blob/6e194e18325605095bac826b6450a9b4e6978d2d/c_omp_pi_dir/pi.c), when compiling the code with Clang (but not with GCC), which is LLVM-based like Julia.

To reproduce the behaviour also with the C code (this is weak scaling, so you should expect to see constant time across the different number of threads used):

```console
$ clang --version
clang version 19.1.5 (Fedora 19.1.5-1.fc41)
Target: aarch64-redhat-linux-gnu
Thread model: posix
InstalledDir: /usr/bin
Configuration file: /etc/clang/aarch64-redhat-linux-gnu-clang.cfg
$ make -B CC=clang COPTS='-O2 -fopenmp -mcpu=ampere1a'
clang -O2 -fopenmp -mcpu=ampere1a  -c pi.c -o pi.o
clang -O2 -fopenmp -mcpu=ampere1a  -o pi pi.o
$ for threads in 1 2 3 4 6 8 12 16 24 32 48 64 96 128 192; do OMP_NUM_THREADS=${threads} OMP_PLACES="0:${threads}" ./pi ${threads}000000000; done
Calculating PI using:
  1000000000 slices
  1 thread(s)
Obtained value for PI: 3.141592653589971
Time taken:            2.585074901580811 seconds
Calculating PI using:
  2000000000 slices
  2 thread(s)
Obtained value for PI: 3.141592653589855
Time taken:            2.589401960372925 seconds
Calculating PI using:
  3000000000 slices
  3 thread(s)
Obtained value for PI: 3.141592653589775
Time taken:            3.072261095046997 seconds
Calculating PI using:
  4000000000 slices
  4 thread(s)
Obtained value for PI: 3.141592653589738
Time taken:            3.651237010955811 seconds
Calculating PI using:
  6000000000 slices
  6 thread(s)
Obtained value for PI: 3.141592653589797
Time taken:            3.652868032455444 seconds
Calculating PI using:
  8000000000 slices
  8 thread(s)
Obtained value for PI: 3.141592653589853
Time taken:            3.657607793807983 seconds
Calculating PI using:
  12000000000 slices
  12 thread(s)
Obtained value for PI: 3.141592653589771
Time taken:            3.657762050628662 seconds
Calculating PI using:
  16000000000 slices
  16 thread(s)
Obtained value for PI: 3.141592653589849
Time taken:            3.661301136016846 seconds
Calculating PI using:
  24000000000 slices
  24 thread(s)
Obtained value for PI: 3.141592653589832
Time taken:            3.656550884246826 seconds
Calculating PI using:
  32000000000 slices
  32 thread(s)
Obtained value for PI: 3.14159265358979
Time taken:            3.658497095108032 seconds
Calculating PI using:
  48000000000 slices
  48 thread(s)
Obtained value for PI: 3.141592653589754
Time taken:            3.657592058181763 seconds
Calculating PI using:
  64000000000 slices
  64 thread(s)
Obtained value for PI: 3.141592653590034
Time taken:            3.660107851028442 seconds
Calculating PI using:
  96000000000 slices
  96 thread(s)
Obtained value for PI: 3.141592653589659
Time taken:            3.663879156112671 seconds
Calculating PI using:
  128000000000 slices
  128 thread(s)
Obtained value for PI: 3.141592653589856
Time taken:            3.663228034973145 seconds
Calculating PI using:
  192000000000 slices
  192 thread(s)
Obtained value for PI: 3.141592653589789
Time taken:            3.678163051605225 seconds
```

Like the Julia version, scaling is recovered when pinning the threads to alternate cores:

```console
$ for threads in 1 2 3 4 6 8 12 16 24 32 48 64 96; do OMP_NUM_THREADS=${threads} OMP_PLACES="0:${threads}:2" ./pi ${threads}000000000; done
Calculating PI using:
  1000000000 slices
  1 thread(s)
Obtained value for PI: 3.141592653589971
Time taken:            2.588176965713501 seconds
Calculating PI using:
  2000000000 slices
  2 thread(s)
Obtained value for PI: 3.141592653589855
Time taken:            2.586175918579102 seconds
Calculating PI using:
  3000000000 slices
  3 thread(s)
Obtained value for PI: 3.141592653589775
Time taken:            2.589823961257935 seconds
Calculating PI using:
  4000000000 slices
  4 thread(s)
Obtained value for PI: 3.141592653589738
Time taken:            2.587221145629883 seconds
Calculating PI using:
  6000000000 slices
  6 thread(s)
Obtained value for PI: 3.141592653589797
Time taken:            2.587759017944336 seconds
Calculating PI using:
  8000000000 slices
  8 thread(s)
Obtained value for PI: 3.141592653589853
Time taken:            2.588521957397461 seconds
Calculating PI using:
  12000000000 slices
  12 thread(s)
Obtained value for PI: 3.141592653589771
Time taken:            2.590617895126343 seconds
Calculating PI using:
  16000000000 slices
  16 thread(s)
Obtained value for PI: 3.141592653589849
Time taken:            2.589076995849609 seconds
Calculating PI using:
  24000000000 slices
  24 thread(s)
Obtained value for PI: 3.141592653589832
Time taken:            2.590331077575684 seconds
Calculating PI using:
  32000000000 slices
  32 thread(s)
Obtained value for PI: 3.14159265358979
Time taken:            2.591081142425537 seconds
Calculating PI using:
  48000000000 slices
  48 thread(s)
Obtained value for PI: 3.141592653589754
Time taken:            2.594055891036987 seconds
Calculating PI using:
  64000000000 slices
  64 thread(s)
Obtained value for PI: 3.141592653590034
Time taken:            2.592551946640015 seconds
Calculating PI using:
  96000000000 slices
  96 thread(s)
Obtained value for PI: 3.141592653589659
Time taken:            2.596182107925415 seconds
```

See also the [native code of this C program](https://godbolt.org/z/7chz8xo7x) in the Compiler Explorer.
