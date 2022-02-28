<!-- Copyright (c) 2022 Christopher Taylor                                          -->
<!--                                                                                -->
<!--   Distributed under the Boost Software License, Version 1.0. (See accompanying -->
<!--   file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)        -->
# [nofi - Nim OpenFabrics Interface](https://github.com/ct-clmsn/nofi)

Nofi wraps the existing [rofi](https://github.com/pnnl/rofi) interface implemented by Pacific Northwest National
Laboratory (PNNL). Nofi provides the Nim programming language support
for RDMDA distributed communication (put and get). Messages are treated
as a sequence of bytes.

This library extends rofi by providing a [sequence type](https://nim-lang.org/docs/system.html#seq) that wraps memory
registered with the underlying rofi RDMA communicaton library. The sequence
type only supports values that are of [SomeNumber](https://nim-lang.org/docs/system.html#SomeNumber) types. The sequence
type provides element-access, slice, and partitioning support. **Nim applications
using nofi require static compilation and linking!**

### Install

Download and install [rofi](https://github.com/pnnl/rofi)
```
./configure --prefix=<PATH_TO_INSTALL_DIR>
make && make install
export LD_LIBRARY_PATH=<PATH_TO_INSTALL_DIR>/lib:$LD_LIBRARY_PATH
```

Modify `makefile` to point `LIBDIR` and `INCDIR` to the
path set in `<PATH_TO_INSTALL_DIR>`. Use the makefile to
see if your setup compiles.
```
make
```

Use the nimble tool to install nofi
```
nimble install nofi
```

Generate documentation from source
```
nimble doc nofi
```

### Important Developer Notes

Nofi demonstrates the versitility of the [rofi library](https://github.com/pnnl/rofi) and
it's value as a lightweight technology for extending RDMA
support via libfabric to languages that have a FFI (foreign
function interface) compatible with C.

Users need to review the [rofi documentation](https://github.com/pnnl/rofi/blob/master/README.md) prior
to using this library in order to understand rofi's feature
set and potential limitations.

This library requires static compilation of an end user's
Nim program. Please review the makefile to learn how to
enable static compilation and linking with the Nim compiler.

Users must initialize and terminate all programs using
`nofi_init` and `nofi_finit`. Not taking this step will
result in undefined behavior.

Users are strongly encouraged to utilize Nim blocks and
scoping rules to managing memory that has been registered
with nofi. Users can review 'tests/test_sharray.nim' for
an example of memory management using Nim blocks and scopes.

### Examples

The directory 'tests/' provides several examples regarding
how to interact with this library.

### Licenses

* nofi is Boost Version 1.0 (2022-)
* rofi is BSD License (2020)

### Date

24 February 2022

### Author

Christopher Taylor

### Special Thanks to the ROFI authors

* Roberto Gioiosa - roberto.gioiosa@pnnl.gov
* Ryan Friese - ryan.friese@pnnl.gov
* Mark Raugas - mark.raugas@pnnl.gov
* Pacific Northwest National Labs/US Department of Energy

### Many Thanks

* The Nim community and user/developer forum

### Dependencies

* [nim 1.6.4](https://nim-lang.org)
* [libfabric](https://github.com/ofiwg/libfabric)
* [Rust OpenFabrics Interface Transport Layer - rofi](https://github.com/pnnl/rofi)

### rofi Dependencies

* [GNU Autotools](https://www.gnu.org/software/automake/manual/html_node/Autotools-Introduction.html)
* [libfabric](https://github.com/ofiwg/libfabric)
* [libibverbs](https://github.com/linux-rdma/rdma-core/tree/master/libibverbs)
* [uthash](https://github.com/troydhanson/uthash)
* [libatomic](https://github.com/gcc-mirror/gcc/tree/master/libatomic)
* librt: Extended realtime library, generally installed on Linux development clusters
* pthreads: POSIX thread library, generally installed on Linux development clusters
