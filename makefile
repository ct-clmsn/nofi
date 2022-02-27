#  Copyright (c) 2022 Christopher Taylor
#
#  SPDX-License-Identifier: BSL-1.0
#  Distributed under the Boost Software License, Version 1.0. *(See accompanying
#  file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
LIBDIR=
INCDIR=
ROFILIB=-lrofi
LIBS=-lpthread -lfabric $(ROFILIB)
CFLAGS=-static $(LIBS)

ifeq ($(LIBDIR),)
    $(error LIBDIR is not set)
endif

ifeq ($(INCDIR),)
    $(error INCDIR is not set)
endif


all:
	nim c --clibdir:$(LIBDIR) -d:danger -d:globalSymbols --cincludes:$(INCDIR) --passC:"$(CFLAGS)" --passL:"$(ROFILIB)" tests/test_initfin.nim
	nim c --clibdir:$(LIBDIR) -d:danger -d:globalSymbols --cincludes:$(INCDIR) --passC:"$(CFLAGS)" --passL:"$(ROFILIB)" tests/test_sharray.nim
	mv tests/test_initfin .
	mv tests/test_sharray .

clean:
	rm test_initfin
	rm test_sharray
