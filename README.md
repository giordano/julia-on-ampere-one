## Julia on AmpereOne A192-32X

This repository contains some information about using Julia on [AmpereOne A192-32X](https://amperecomputing.com/briefs/ampereone-family-product-brief).

```console
$ lscpu
Architecture:             aarch64
  CPU op-mode(s):         64-bit
  Byte Order:             Little Endian
CPU(s):                   192
  On-line CPU(s) list:    0-191
Vendor ID:                Ampere
  Model name:             Ampere-1a
    Model:                0
    Thread(s) per core:   1
    Core(s) per socket:   192
    Socket(s):            1
    Stepping:             0x0
    Frequency boost:      disabled
    CPU(s) scaling MHz:   32%
    CPU max MHz:          3200.0000
    CPU min MHz:          1000.0000
    BogoMIPS:             2000.00
    Flags:                fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm jscvt fcma lrcpc dcpop sha3 sm3 sm4 asimddp sha512 asimdfhm dit uscat ilrcpc flagm ssbs sb paca pacg dcpodp flagm2 frint i8mm bf16
                          rng bti ecv
Caches (sum of all):
  L1d:                    12 MiB (192 instances)
  L1i:                    3 MiB (192 instances)
  L2:                     384 MiB (192 instances)
NUMA:
  NUMA node(s):           1
  NUMA node0 CPU(s):      0-191
Vulnerabilities:
  Gather data sampling:   Not affected
  Itlb multihit:          Not affected
  L1tf:                   Not affected
  Mds:                    Not affected
  Meltdown:               Not affected
  Mmio stale data:        Not affected
  Reg file data sampling: Not affected
  Retbleed:               Not affected
  Spec rstack overflow:   Not affected
  Spec store bypass:      Mitigation; Speculative Store Bypass disabled via prctl
  Spectre v1:             Mitigation; __user pointer sanitization
  Spectre v2:             Not affected
  Srbds:                  Not affected
  Tsx async abort:        Not affected
```

I got access to this system thanks to BIOS-IT and SuperMicro.
