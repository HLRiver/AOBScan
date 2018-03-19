/*
*
* Copyright (c) 2015-2017 by blindtiger ( blindtiger@foxmail.com )
*
* The contents of this file are subject to the Mozilla Public License Version
* 2.0 (the "License"); you may not use this file except in compliance with
* the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. SEe the License
* for the specific language governing rights and limitations under the
* License.
*
* The Initial Developer of the Original e is blindtiger.
*
*/

#include "Global.h"
#include "Log.h"

BOOLEAN
NTAPI
TrimBytes(
    __in PCTSTR Sig,
    __out PBYTE * Coll,
    __out PSIZE_T CollSize
)
{
    BOOLEAN Result = FALSE;
    PTSTR Buffer = NULL;
    SIZE_T BufferSize = 0;
    TCHAR Single[3] = { 0 };
    ULONG Digit = 0;

    for (SIZE_T i = 0;
        i < _tcslen(Sig);
        i++) {
        if (_istxdigit(*(Sig + i)) ||
            *(Sig + i) == TEXT('?')) {
            BufferSize += sizeof(TCHAR);
        }
    }

    if (0 != BufferSize) {
        Buffer = malloc(BufferSize);

        if (NULL != Buffer) {
            RtlZeroMemory(
                Buffer,
                BufferSize);

            for (SIZE_T i = 0;
                i < _tcslen(Sig);
                i++) {
                if (_istxdigit(*(Sig + i))
                    || *(Sig + i) == TEXT('?')) {
                    RtlCopyMemory(
                        Buffer + _tcslen(Buffer),
                        Sig + i,
                        sizeof(TCHAR) * 2);
                    i++;
                }
            }

            if (0 != BufferSize &&
                0 == BufferSize % 2) {
                *CollSize = BufferSize / (2 * sizeof(TCHAR));
                *Coll = malloc(*CollSize);

                if (NULL != *Coll) {
                    for (SIZE_T i = 0;
                        i < BufferSize / sizeof(TCHAR);
                        i += 2) {
                        if (*(Buffer + i) != TEXT('?') &&
                            *(Buffer + i + 1) != TEXT('?')) {
                            RtlCopyMemory(
                                Single,
                                Buffer + i,
                                sizeof(TCHAR) * 2);

                            Digit = _tcstoul(Single, NULL, 16);
                            *(*Coll + i / 2) = LOBYTE(Digit);
                        }
                        else if (*(Buffer + i) == TEXT('?') &&
                            *(Buffer + i + 1) == TEXT('?')) {
                            *(*Coll + i / 2) = '?';

                            Result = TRUE + 1;
                        }
                        else {
                            // invalid sig

                            free(*Coll);

                            *Coll = NULL;
                            *CollSize = 0;

                            return FALSE;
                        }
                    }

                    if (FALSE == Result ) {
                        Result = TRUE;
                    }
                }
            }

            free(Buffer);
        }
    }

    return Result;
}

SIZE_T
NTAPI
CompareBytes(
    __in PBYTE Destination,
    __in PBYTE Source,
    __in SIZE_T Length,
    __in BOOLEAN Selector
)
{
    register SIZE_T Count = 0;

    if (TRUE == Selector) {
        for (Count = 0;
            Count < Length;
            Count++) {
            if (*(Destination + Count) != *(Source + Count)) {
                break;
            }
        }
    }
    else {
        for (Count = 0;
            Count < Length;
            Count++) {
            if (*(Destination + Count) != *(Source + Count) &&
                *(Source + Count) != '?') {
                break;
            }
        }
    }

    return Count;
}

PVOID
NTAPI
ScanBytes(
    __in PBYTE Begin,
    __in PBYTE End,
    __in PCTSTR Sig
)
{
    BOOLEAN Selector = FALSE;
    PBYTE Coll = NULL;
    SIZE_T CollSize = 0;
    PVOID Result = NULL;

    Selector = TrimBytes(
        Sig,
        &Coll,
        &CollSize);

    if (FALSE != Selector) {
        for (SIZE_T i = 0;
            i < End - Begin - CollSize;
            i++) {
            if (CompareBytes(
                Begin + i,
                Coll,
                CollSize,
                Selector) == CollSize) {
                Result = Begin + i;
                break;
            }
        }

        free(Coll);
    }
    else {
        _PRINT(TEXT("invalid sig\n"));;
    }

    return Result;
}
