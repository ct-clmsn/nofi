#  Copyright (c) 2022 Christopher Taylor
#
#  SPDX-License-Identifier: BSL-1.0
#  Distributed under the Boost Software License, Version 1.0. *(See accompanying
#  file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
{.deadCodeElim: on.}
proc rofi_init*(provider:cstring) : int {.cdecl, importc: "rofi_init".}
proc rofi_finit*() : int {.cdecl, importc: "rofi_finit".} 
proc rofi_get_size*() : uint32 {.cdecl, importc: "rofi_get_size".} 
proc rofi_get_id*() : uint32 {.cdecl, importc: "rofi_get_id".} 
proc rofi_put*[T : SomeNumber](dst : ptr UncheckedArray[T], src : ptr UncheckedArray[T], size : uint64, id : uint32, flags : uint64) : int {.cdecl, importc: "rofi_put" .} 
proc rofi_iput*[T : SomeNumber](dst : ptr UncheckedArray[T], src : ptr UncheckedArray[T], size : uint64, id : uint32, flags : uint64) : int {.cdecl, importc: "rofi_iput".} 
proc rofi_get*[T : SomeNumber](dst : ptr UncheckedArray[T], src : ptr UncheckedArray[T], size : uint64, id : uint32, flags : uint64) : int {.cdecl, importc: "rofi_get".} 
proc rofi_iget*[T : SomeNumber](dst : ptr UncheckedArray[T], src : ptr UncheckedArray[T], size : uint64, id : uint32, flags : uint64) : int {.cdecl, importc: "rofi_iget".} 
proc rofi_isend*[T : SomeNumber](id: uint32, address : ptr UncheckedArray[T], size : uint64, flags : uint64) : int {.cdecl, importc: "rofi_isend".} 
proc rofi_irecv*[T : SomeNumber](id : uint32, address : ptr UncheckedArray[T], size : uint64, flags : uint64) : int {.cdecl, importc: "rofi_irecv".} 
proc rofi_alloc*[T : SomeNumber](size : uint64, flags : uint64, buf : ptr ptr UncheckedArray[T]) : int {.cdecl, importc: "rofi_alloc".} 
proc rofi_release*[T : SomeNumber](address : ptr UncheckedArray[T]) : int {.cdecl, importc: "rofi_release".} 
proc rofi_barrier*() {.cdecl, importc: "rofi_barrier".} 
proc rofi_wait*() : int {.cdecl, importc: "rofi_wait".} 
proc rofi_get_remote_address*(address : pointer, id : uint64) : pointer {.cdecl, importc: "rofi_get_remote_addr".} 
proc rofi_get_local_address_from_remote_address*(address : pointer, id : uint64) : pointer {.cdecl, importc: "rofi_get_local_address_from_remote_addr".} 
