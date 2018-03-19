#
#
# Copyright (c) 2015-2017 by blindtiger ( blindtiger@foxmail.com )
#
# The contents of this file are subject to the Mozilla Public License Version
# 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. SEe the License
# for the specific language governing rights and limitations under the
# License.
#
# The Initial Developer of the Original e is blindtiger.
#
#

LINK = LINK.EXE
AS64 = ML64.EXE
IMPLIB = LIB.EXE

ROOT = .

BIND = $(ROOT)\Build\Bin\$(PLATFORM)\$(CONFIG)
OBJD = $(ROOT)\Build\Obj\$(PLATFORM)\$(CONFIG)\$(PROG)

RFLAGS = /nologo /D"UNICODE" /D"_UNICODE"
AFLAGS = /nologo /W3 /D"UNICODE" /D"_UNICODE" /Zi
CFLAGS = /nologo /W4 /D"UNICODE" /D"_UNICODE" /Od /FAcs /DEBUG /Zi /Fd$(OBJD)\$(PROG)$(PLATFORM).PDB	    
CPPFLAGS = /nologo /W4 /D"UNICODE" /D"_UNICODE" /Od /FAcs /DEBUG /Zi /Fd$(OBJD)\$(PROG)$(PLATFORM).PDB	    
CXXFLAGS = /nologo /W4 /D"UNICODE" /D"_UNICODE" /Od /FAcs /DEBUG /Zi /Fd$(OBJD)\$(PROG)$(PLATFORM).PDB
LKFLAGS = /nologo /SUBSYSTEM:CONSOLE /MACHINE:$(PLATFORM) /DEF:$(PROG).DEF /DEBUG /PDB:$(BIND)\$(PROG)$(PLATFORM).PDB

OBJS = \
	$(OBJD)\$(PROG).OBJ\
	$(OBJD)\$(PROG).RES\
!IF "$(PLATFORM)" == "x64"
	$(OBJD)\AMD64.OBJ\
!ELSEIF "$(PLATFORM)" == "x86"
	$(OBJD)\I386.OBJ\
!ENDIF
	$(OBJD)\GLOBAL.OBJ\
	$(OBJD)\LOG.OBJ\
	$(OBJD)\SCAN.OBJ

LIBS = \
    NTDLLP.LIB\
    KERNEL32.LIB\
    USER32.LIB\
    $(ROOT)\LIB\$(PLATFORM)\MSVCRT.LIB

TARGETS: DIR CLEAN PREBUILD $(BIND)\$(PROG)$(PLATFORM).$(TYPE) POSTBUILD

$(BIND)\$(PROG)$(PLATFORM).$(TYPE):$(OBJS)
	@$(LINK) $(LKFLAGS) /ENTRY:Startup /OUT:$@ $** $(LIBS)

.SUFFIXES:.C .CPP .CXX .ASM .RC

.C{$(OBJD)}.OBJ:
	@$(CC) $(CFLAGS) /Fo$@ /Fa$(OBJD)\$(@B).cod /c $<

.CPP{$(OBJD)}.OBJ:
	@$(CPP) $(CFLAGS) /Fo$@ /Fa$(OBJD)\$(@B).cod /c $<
	
.CXX{$(OBJD)}.OBJ:
	@$(CXX) $(CFLAGS) /Fo$@ /Fa$(OBJD)\$(@B).cod /c $<
	
!IF "$(PLATFORM)" == "x64"
.ASM{$(OBJD)}.OBJ:
	@$(AS64) $(AFLAGS) /Fo$@ /c $<
!ELSE
.ASM{$(OBJD)}.OBJ:
	@$(AS) $(AFLAGS) /Fo$@ /c $<
!ENDIF

.RC{$(OBJD)}.RES:
	@$(RC) $(RFLAGS) /Fo$@ /r $<
	
PREBUILD:

POSTBUILD:

DIR:
	@IF NOT EXIST $(OBJD) MD $(OBJD)
	@IF NOT EXIST $(BIND) MD $(BIND)

CLEAN:
	@IF EXIST $(OBJD)\*.OBJ DEL /F /Q $(OBJD)\*.OBJ
	@IF EXIST $(OBJD)\*.RES DEL /F /Q $(OBJD)\*.RES
	@IF EXIST $(OBJD)\*.COD DEL /F /Q $(OBJD)\*.COD
	@IF EXIST $(BIND)\$(PROG)$(PLATFORM).LIB DEL /F /Q $(BIND)\$(PROG)$(PLATFORM).LIB
	@IF EXIST $(BIND)\$(PROG)$(PLATFORM).EXP DEL /F /Q $(BIND)\$(PROG)$(PLATFORM).EXP
	@IF EXIST $(BIND)\$(PROG)$(PLATFORM).DLL DEL /F /Q $(BIND)\$(PROG)$(PLATFORM).DLL
	@IF EXIST $(BIND)\$(PROG)$(PLATFORM).ILK DEL /F /Q $(BIND)\$(PROG)$(PLATFORM).ILK
	@IF EXIST $(BIND)\$(PROG)$(PLATFORM).PDB DEL /F /Q $(BIND)\$(PROG)$(PLATFORM).PDB
