object "StorageTest" {
    code {
        // Call the constructor function
        constructor_StorageTest()
        
        // Deploy the runtime code
        let runtime_size := datasize("runtime")
        let runtime_offset := dataoffset("runtime")
        
        // Copy runtime code to memory at position 0
        codecopy(0, runtime_offset, runtime_size)
        
        // Return the runtime code
        return(0, runtime_size)
        
        // Constructor function definition
        function constructor_StorageTest() {
            // Store the value 42 in storage slot 0
            sstore(0, 42)
        }
    }
    
    object "runtime" {
        code {
            // Runtime code - handles function calls
            
            // Simple dispatcher - if calldata is empty, return stored value
            if iszero(calldatasize()) {
                // Get stored value from slot 0
                let value := sload(0)
                
                // Store it in memory
                mstore(0, value)
                
                // Return 32 bytes from memory position 0
                return(0, 32)
            }
            
            // Otherwise revert
            revert(0, 0)
        }
    }
}