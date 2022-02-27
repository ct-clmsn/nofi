#  Copyright (c) 2022 Christopher Taylor
#
#  SPDX-License-Identifier: BSL-1.0
#  Distributed under the Boost Software License, Version 1.0. *(See accompanying
#  file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
import system/assertions
import ./bindings

#{.emit: "#include<stdio.h>".}
#{.emit: "NIM_EXTERNC void printaddr(void * adr) { printf(\"\\n%p\\n\"); }" .}
#proc printaddr(adr : pointer) {.importc: "printaddr" .}

proc nofi_init*(provider:string) : int =
    ## Invocation of this function is required to initialize nofi. Not calling
    ## this function first will result in hazards. Returns 0 on success, -1
    ## on error.
    ##
    result = bindings.rofi_init(cstring(provider))

proc nofi_finit*() : int =
    ## Invocation of this function is required to finalize nofi. Not calling 
    ## this function first will result in hazards. Returns 0 on success, -1
    ## on error.
    ##
    result = bindings.rofi_finit()

proc nofi_get_size*() : uint32 =
    ## Returns the number of processes (locales) running as part of this SPMD
    ## application.
    ##
    result = bindings.rofi_get_size()

proc nofi_get_id*() : uint32 =
    ## Returns the ID (rank) of the process within this SPMD application.
    ##
    result = bindings.rofi_get_id()

proc nofi_barrier*() =
    ## global barrier; blocks until all processes in an SPMD application have
    ## call this function. When the last process enters the barrier, all processes
    ## will be released
    ##
    bindings.rofi_barrier()

proc nofi_wait*() : int =
    ## blocks until outstanding remote memory operations have completed; intended for use
    ## with nofi_get and nofi_put.
    ##
    result = bindings.rofi_wait()

proc nofi_put*[T : SomeNumber](dst : ptr UncheckedArray[T], dst_len : uint32, src : ptr UncheckedArray[T], src_len : uint32, id : uint32, flags : uint64) : int =
    ## Asynchronous put; transfers byte in `src` in the current process virtual address space to
    ## process `id` at address `dst` in the destination. Users must check for completion or invoke
    ## nofi_wait. Do not modify the seq before the transfer terminates
    ##
    assert(dst_len == src_len)
    result = bindings.rofi_put(dst, src, T.sizeof * src_len, id, flags)

proc nofi_get*[T : SomeNumber](dst : ptr UncheckedArray[T], dst_len : uint32, src : ptr UncheckedArray[T], src_len : uint32, id : uint32, flags : uint64) : int =
    ## Asynchronous get; transfers bytes in `src` in a remote process `id`'s virtual address space
    ## into the current process at address `dst`. Users must check for completion or invoke nofi_wait.
    ## Do not modify the seq before the transfer terminates
    ## 
    assert(dst_len == src_len)
    result = bindings.rofi_get(dst, src, T.sizeof * src_len, id, flags)

proc nofi_iput*[T : SomeNumber](dst : ptr UncheckedArray[T], dst_len : uint32, src : ptr UncheckedArray[T], src_len : uint32, id : uint32, flags : uint64) : int =
    ## Synchronous put; transfers byte in `src` in the current process virtual address space to
    ## process `id` at address `dst` in the destination process.
    ##
    assert(dst_len == src_len)
    result = bindings.rofi_put(dst, src, T.sizeof * src.len, id, flags)

proc nofi_iget*[T : SomeNumber](dst : ptr UncheckedArray[T], dst_len : uint32, src : ptr UncheckedArray[T], src_len : uint32, id : uint32, flags : uint64) : int =
    ## Synchronous get; transfers bytes in `src` in a remote process `id`'s virtual address space
    ## into the current process at address `dst`.
    ## 
    assert(dst_len == src_len)
    result = bindings.rofi_get(dst, src, T.sizeof * src.len, id, flags)

proc nofi_isend*[T : SomeNumber](id : uint32, src : ptr UncheckedArray[T], src_len : uint32, flags : uint64) : int =
    ## Synchronous transfer bytes from the current process at address `src` to process `id` 
    ##
    result = bindings.rofi_isend(id, src, T.sizeof*src_len, flags)

proc nofi_irecv*[T : SomeNumber](id : uint32, src : ptr UncheckedArray[T], src_len : uint32, flags : uint64) : int =
    ## Synchronous transfer bytes from remote process `id` into current process at 'src' 
    ##
    result = bindings.rofi_irecv(id, src, T.sizeof*src_len, flags)

proc nofi_alloc*[T : SomeNumber](n : uint64, flags : uint64) : ptr UncheckedArray[T] =
    ## allocates memory region of size n*T.sizeof bytes, registers the memory
    ## to be accessible remotely to other processes (computes) via RDMA. If all
    ## processe in a job call this function, the application has created a
    ## symmetric heap that can be accessed remotely. Currently, only 1 memory
    ## region can be allocated at any given time.
    ##
    var ret : ptr UncheckedArray[T]
    let rc = bindings.rofi_alloc(cast[uint64](T.sizeof)*n, flags, addr( ret ) )
    assert(rc == 0)
    return ret

proc nofi_release*[T : SomeNumber](src : var ptr UncheckedArray[T]) =
    ## deallocate memory region that was allocated by 'nofi_alloc'
    ##
    let rc = bindings.rofi_release( src )
    assert(rc == 0)

proc nofi_get_remote_address*[T : SomeNumber](src : ptr UncheckedArray[T], id : uint64) : pointer =
    ## nofi does not require virtual addresses be aligned; virutal addresses are not
    ## symmetric in the SPMD application, only the offsets are; this function maps
    ## an address at 'src' in a current process with it's remote counterpart.
    ##
    result = bindings.rofi_get_remote_address(src, id)

proc nofi_get_local_address_from_remote_address*[T : SomeNumber](src : ptr UncheckedArray[T], id : uint64) : pointer =
    ## this function map the an address at 'src' on a remote process with the corresponding
    ## address in the local process.
    ##
    result = bindings.rofi_get_local_address_from_remote_address(src, id)

type nofiseq*[T : SomeNumber] = object
    ## a sequence type for SomeNumber values;
    ## the memory for every value in the sequence
    ## is registered with libfabric for RDMA
    ## communications.
    ##
    open : bool
    len : uint64
    data : ptr UncheckedArray[T]

proc createSeq*[T](sz : uint64) : nofiseq[T] =
    ## creates a nofiseq[T] with 'sz' number of
    ## elements of type 'T'
    ##
    return nofiseq[T]( open : true, len : sz, data : nofi_alloc[T](sz, 0x0) )

proc createSeq*[T](elems: varargs[T]) : nofiseq[T] =
    ## creates a nofiseq[T] that has the same length
    ## as 'elems' and each value in the returned
    ## nofiseq[T] is equal to the values in 'elems'
    ##
    var sz = cast[uint64](elems.len)
    var res = nofiseq[T]( open : true, len : sz, data : nofi_alloc[T](sz, 0x0) )
    for i in 0..<res.len: res.data[i] = elems[i]
    return res

proc freeSeq*[T](x : var nofiseq[T]) =
    ## manually frees a nofiseq[T]
    ##
    if x.open:
        x.len = 0
        nofi_release[T](x.data)
        x.data = nil
        x.open = false

proc `=destroy`*[T](x : var nofiseq[T]) =
    ## frees a nofiseq[T] when it falls out
    ## of scope
    ##
    if x.open:
        nofi_release[T](x.data)
        x.open = false

proc `=sink`*[T](a: var nofiseq[T]; b: nofiseq[T]) =
    ## provides move assignment
    ##
    `=destroy`(a)
    # move assignment, optional.
    # Compiler is using `=destroy` and `copyMem` when not provided
    # 
    wasMoved(a)
    a.len = b.len
    a.data = b.data

proc `[]`*[T](x:nofiseq[T]; i: Natural): lent T =
    ## return a value at position 'i'
    ##
    assert cast[uint64](i) < x.len
    x.data[i]

proc `[]=`*[T](x: var nofiseq[T]; i: Natural; y: sink T) =
    ## assign a value at position 'i' equal to
    ## the value 'y'
    ##
    assert i < x.len
    x.data[i] = y

#proc print*[T](x : var nofiseq[T]) =
#    printaddr(x.data)

proc len*[T](x: nofiseq[T]): uint64 {.inline.} = x.len

proc get_remote_address(src : nofiseq[T]) : int =
    result = bindings.rofi_get_remote_address(src.data, id)

proc get_local_address_from_remote_address(src : nofiseq[T]) : int =
    result = bindings.rofi_get_local_address_from_remote_address(src.data, id)

proc put*[T : SomeNumber](dst : nofiseq[T], src : nofiseq[T], id : uint32, flags : uint64) : int =
    ## Asynchronous put; transfers byte in `src` in the current process virtual address space to
    ## process `id` at address `dst` in the destination. Users must check for completion or invoke
    ## nofi_wait. Do not modify the seq before the transfer terminates
    ##
    assert(dst.len == src.len)
    result = bindings.rofi_put(dst.data, src.data, T.sizeof * src.len, id, flags)

proc get*[T : SomeNumber](dst : nofiseq[T], src : nofiseq[T], id : uint32, flags : uint64) : int =
    ## Asynchronous get; transfers bytes in `src` in a remote process `id`'s virtual address space
    ## into the current process at address `dst`. Users must check for completion or invoke nofi_wait.
    ## Do not modify the seq before the transfer terminates
    ## 
    assert(dst.len == src.len)
    result = bindings.rofi_get(dst.data, src.data, T.sizeof * src.len, id, flags)

proc iput*[T : SomeNumber](dst : nofiseq[T], src : nofiseq[T], id : uint32, flags : uint64) : int =
    ## Synchronous put; transfers byte in `src` in the current process virtual address space to
    ## process `id` at address `dst` in the destination process.
    ##
    assert(dst.len == src.len)
    result = bindings.rofi_put(dst.data, src.data, T.sizeof * src.len, id, flags)

proc iget*[T : SomeNumber](dst : nofiseq[T], src : nofiseq[T], id : uint32, flags : uint64) : int =
    ## Synchronous get; transfers bytes in `src` in a remote process `id`'s virtual address space
    ## into the current process at address `dst`.
    ## 
    assert(dst.len == src.len)
    result = bindings.rofi_get(dst.data, src.data, T.sizeof * src.len, id, flags)

proc isend*[T : SomeNumber](src : nofiseq[T], id : uint32, flags : uint64) : int =
    ## Synchronous transfer bytes from the current process at address `src` to process `id` 
    ##
    result = bindings.rofi_isend(id, src.data, T.sizeof*src.len, flags)

proc irecv*[T : SomeNumber](src : nofiseq[T], id : uint32, flags : uint64) : int =
    ## Synchronous transfer bytes from remote process `id` into current process at 'src' 
    ##
    result = bindings.rofi_irecv(id, src.data, T.sizeof*src.len, flags)


