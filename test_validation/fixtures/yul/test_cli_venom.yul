
        object "Test" {
            code {
                let x := 42
                mstore(0, x)
                return(0, 32)
            }
        }
        