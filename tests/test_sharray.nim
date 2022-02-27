#  Copyright (c) 2022 Christopher Taylor
#
#  SPDX-License-Identifier: BSL-1.0
#  Distributed under the Boost Software License, Version 1.0. *(See accompanying
#  file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
import ../nofi

# initialize nofi and
# enable shared memory
# libfabric backend
#
var rc = nofi_init("shm")

# manual memory management
# example
#
block testa:
    const acount : uint64 = 10
    var a : nofiseq[int] = createSeq[int]( acount )

    for i in 0..acount:
        echo a[i]

    freeSeq(a)

# manual memory management
# example
#
block testb:
    const bcount : uint64 = 10
    var b : ptr UncheckedArray[int] = nofi_alloc[int](bcount, 0x0)

    for i in 0..bcount:
        echo b[i]

    nofi_release( b )

# nofiseq is cleaned up
# automatically by the
# scoping rules applied
# to block 'testc'
#
block testc:
    const ccount : uint64 = 10;
    var c : nofiseq[int] = createSeq[int]( ccount )

    for i in 0..ccount:
        echo c[i]

    #print(c)
    
# nofiseq is cleaned up
# automatically by the
# scoping rules applied
# to block 'testd'
#
block testd:
    var d : nofiseq[int] = createSeq[int]([1,2,3,4])

    for i in 0..d.len:
        echo d[i]

    #print(d)

nofi_barrier()

# terminate nofi
#
rc = nofi_finit()
