#!/usr/bin/env python3
"""
Memory Layout Calculator for Yul2Venom debugging.

Helps trace memory allocation patterns to identify overlap issues.
"""

def calculate_struct_array_layout(num_elements: int, fmp_init: int = 0x1000):
    """
    Calculate memory layout for Solidity-style struct array allocation.
    
    Solidity/Yul pattern:
    1. Array base at FMP
    2. Bump FMP to reserve space for pointer array
    3. Slots: [length, ptr0, ptr1, ...]
    4. Struct data allocated from bumped FMP
    """
    print(f"=== Memory Layout for {num_elements} Element structs ===")
    print(f"Initial FMP (memoryguard): 0x{fmp_init:04x}")
    
    array_base = fmp_init
    print(f"\nArray base (%31): 0x{array_base:04x}")
    
    # Calculate pointer array size and bump FMP
    # From Yul: add(shl(5, length), 32) aligned to 32
    ptr_array_size = 32 + num_elements * 32  # length + N pointers
    ptr_array_size_aligned = (ptr_array_size + 31) & ~31
    
    fmp = fmp_init + ptr_array_size_aligned
    print(f"FMP bumped to reserve {ptr_array_size_aligned} bytes for pointer array")
    print(f"New FMP after bump: 0x{fmp:04x}")
    print(f"\nPointer array layout:")
    print(f"  [0x{array_base:04x}] = length ({num_elements})")
    for i in range(num_elements):
        ptr_slot = array_base + 32 + i * 32
        print(f"  [0x{ptr_slot:04x}] = pointer to struct[{i}]")
    
    print(f"\n--- Loop 26: Struct Allocation Loop ---")
    struct_addrs = []
    for i in range(num_elements):
        counter = i * 32  # counter increments by 32
        
        # Read current FMP
        current_fmp = fmp
        
        # Allocate 64 bytes for struct (id + value)
        fmp = fmp + 64
        struct_addr = current_fmp
        struct_addrs.append(struct_addr)
        
        # Calculate pointer storage location
        pointer_slot = array_base + 32 + counter
        
        print(f"  Iteration {i} (counter={counter}):")
        print(f"    Read FMP: 0x{current_fmp:04x}")
        print(f"    Allocate struct at 0x{struct_addr:04x}-0x{struct_addr+63:04x}")
        print(f"    Store pointer at 0x{pointer_slot:04x} -> 0x{struct_addr:04x}")
        print(f"    FMP now: 0x{fmp:04x}")
        
        # Check for overlap
        if struct_addr <= pointer_slot < struct_addr + 64:
            print(f"    ❌ OVERLAP: Pointer slot inside struct[{i}] data region!")
        else:
            print(f"    ✓ No overlap")
    
    print(f"\n--- After Allocation Loop ---")
    print(f"Final FMP: 0x{fmp:04x}")
    print(f"Struct addresses: {[f'0x{a:04x}' for a in struct_addrs]}")
    
    # Output buffer allocation
    output_base = fmp
    print(f"\n--- Output Buffer (after loop 33) ---")
    print(f"Output base (%102): 0x{output_base:04x}")
    print(f"  [0x{output_base:04x}] = ABI offset (32)")
    print(f"  [0x{output_base+32:04x}] = length ({num_elements})")
    
    # Check if output overlaps with pointer array
    pointer_array_end = array_base + 32 + num_elements * 32
    print(f"\nPointer array: 0x{array_base+32:04x} to 0x{pointer_array_end:04x}")
    print(f"Output buffer: 0x{output_base:04x} to 0x{output_base+64+num_elements*64:04x}")
    
    if output_base < pointer_array_end:
        print(f"\n❌ OVERLAP DETECTED: Output buffer starts before pointer array ends!")
    else:
        print(f"\n✓ No overlap between pointer array and output buffer")
    
    return {
        "array_base": array_base,
        "struct_addrs": struct_addrs,
        "output_base": output_base,
        "final_fmp": fmp
    }


def trace_serialization_loop(layout: dict, num_elements: int):
    """Trace what the serialization loop would read."""
    print(f"\n--- Serialization Loop (54_blk_loop) ---")
    
    srcPtr = layout["array_base"] + 32  # Start at first pointer slot
    
    for i in range(num_elements):
        print(f"\n  Iteration {i}:")
        print(f"    srcPtr = 0x{srcPtr:04x}")
        
        # In reality, mload(srcPtr) would load the pointer
        # Then mload(pointer) loads id, mload(pointer+32) loads value
        
        # But if srcPtr points to wrong memory due to overlap...
        if srcPtr == layout["output_base"]:
            print(f"    ⚠️  srcPtr points to OUTPUT BUFFER!")
            print(f"    Would read: id=32 (ABI offset), value=2 (length)")
        elif srcPtr in [layout["array_base"] + 32 + j*32 for j in range(num_elements)]:
            idx = (srcPtr - layout["array_base"] - 32) // 32
            struct_addr = layout["struct_addrs"][idx]
            print(f"    Would load pointer: 0x{struct_addr:04x}")
            print(f"    Then read struct[{idx}] data")
        else:
            print(f"    ⚠️  srcPtr points to unexpected location!")
        
        srcPtr += 32


if __name__ == "__main__":
    import sys
    
    num_elements = int(sys.argv[1]) if len(sys.argv) > 1 else 2
    
    layout = calculate_struct_array_layout(num_elements)
    trace_serialization_loop(layout, num_elements)
