package main

import (
	"errors"
	"unsafe"
)

type ArenaAllocator struct {
	size   uintptr
	buffer []byte
	offset uintptr
}

func NewArenaAllocator(maxNumBytes uintptr) *ArenaAllocator {
	buffer := make([]byte, maxNumBytes)
	return &ArenaAllocator{
		size:   maxNumBytes,
		buffer: buffer,
		offset: 0,
	}
}

func (a *ArenaAllocator) Alloc(size uintptr, align uintptr) (unsafe.Pointer, error) {
	if a.buffer == nil {
		return nil, errors.New("arena allocator has been moved")
	}

	remainingBytes := a.size - a.offset

	// Calculate aligned address
	currentAddr := uintptr(unsafe.Pointer(&a.buffer[0])) + a.offset
	alignedAddr := (currentAddr + align - 1) &^ (align - 1)
	alignedOffset := alignedAddr - uintptr(unsafe.Pointer(&a.buffer[0]))

	if alignedOffset+size > a.size {
		return nil, errors.New("not enough memory in arena")
	}

	a.offset = alignedOffset + size
	return unsafe.Pointer(&a.buffer[alignedOffset]), nil
}

func Emplace[T any](a *ArenaAllocator, value T) (*T, error) {
	size := unsafe.Sizeof(value)
	align := unsafe.Alignof(value)

	ptr, err := a.Alloc(size, align)
	if err != nil {
		return nil, err
	}

	result := (*T)(ptr)
	*result = value
	return result, nil
}