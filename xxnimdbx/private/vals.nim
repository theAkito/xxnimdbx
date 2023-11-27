# vals.nim

import libmdbx
import strformat


## Helper functions that make `MDBX_val` act more like a Nim sequence.
## Not intended to be public, since `MDBX_val` is not public; `Data` is the public abstraction.


proc c_memcmp(a, b: pointer, size: csize_t): cint {.
  importc: "memcmp", header: "<string.h>", noSideEffect.}


#%%%%%%%% FACTORIES


proc mkVal*[A](a: openarray[A]): MDBX_val {.inline.} =
    if a.len > 0:
        result.iov_base = unsafeAddr a[0]
        result.iov_len = csize_t(a.len * sizeof a[0])

proc mkVal*[T](p: ptr T): MDBX_val {.inline.} =
    result.iov_base = p
    result.iov_len = csize_t(sizeof T)


#%%%%%%% ACCESSORS


func exists*(val: MDBX_val): bool {.inline.} =
    val.iov_base != nil

func len*(val: MDBX_val): int {.inline.} =
    int(val.iov_len)

func unsafeArray*[T](val: MDBX_val): ptr UncheckedArray[T] {.inline.} =
    cast[ptr UncheckedArray[T]](val.iov_base)

func unsafeBytes*(val: MDBX_val): ptr UncheckedArray[byte] {.inline.} =
    cast[ptr UncheckedArray[byte]](val.iov_base)

func asValue*[T](val: MDBX_val): T =
    if val.len != sizeof(T):
        raise newException(RangeDefect, &"Data is wrong size ({val.iov_len}; expected {sizeof(T)})")
    return cast[ptr T](val.iov_base)[]

func asValue*[T](val: var MDBX_val): var T =
    if val.len != sizeof(T):
        raise newException(RangeDefect, &"Data is wrong size ({val.len}; expected {sizeof(T)})")
    return cast[ptr T](val.iov_base)[]

func `[]`*(val: MDBX_val, i: int): var byte =
    rangeCheck i >= 0 and i < val.len
    return val.unsafeBytes[i]

func `[]`*(val: MDBX_val, range: Slice[int]): seq[byte] =
    rangeCheck range.a >= 0 and range.b < val.len
    if range.len == 0:
        return @[]
    return @( toOpenArray(unsafeBytes(val), range.a, range.b) )

func asSeq*[T](val: MDBX_val): seq[T] =
    if val.len < sizeof(T):
        return @[]
    return @( toOpenArray(unsafeArray[T](val), 0, (val.len div sizeof(T)) - 1) )

func asString*(val: MDBX_val): string =
    result = newString(val.len)
    if val.len > 0:
        copyMem(addr result[0], val.iov_base, val.len)

template asOpenArray*(val: MDBX_val): openarray[byte] =
    toOpenArray(unsafeBytes(val), 0, val.len - 1)


func dataCmp*(ptr1: pointer, len1: int, ptr2: pointer, len2: int): int =
    ## Compares the `len1` bytes at `ptr` with the `len2` bytes at `ptr2`.
    let len = min(len1, len2)
    if len > 0:
        result = c_memcmp(ptr1, ptr2, csize_t(len))
        if result != 0:
            return
    result = len1 - len2


func cmp*(a, b: MDBX_val): int =
    ## Compares data of two MDBX_vals. This enables `\<`, `==`, `\>`, etc.
    return dataCmp(a.iov_base, int(a.iov_len), b.iov_base, int(b.iov_len))
