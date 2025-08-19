#!/usr/bin/env python3
import sys
import argparse

opcodes = {
    0x00: "STOP", 0x01: "ADD", 0x02: "MUL", 0x03: "SUB", 0x04: "DIV",
    0x05: "SDIV", 0x06: "MOD", 0x07: "SMOD", 0x08: "ADDMOD", 0x09: "MULMOD",
    0x0a: "EXP", 0x0b: "SIGNEXTEND", 0x10: "LT", 0x11: "GT", 0x12: "SLT",
    0x13: "SGT", 0x14: "EQ", 0x15: "ISZERO", 0x16: "AND", 0x17: "OR",
    0x18: "XOR", 0x19: "NOT", 0x1a: "BYTE", 0x1b: "SHL", 0x1c: "SHR",
    0x1d: "SAR", 0x20: "SHA3", 0x30: "ADDRESS", 0x31: "BALANCE", 0x32: "ORIGIN",
    0x33: "CALLER", 0x34: "CALLVALUE", 0x35: "CALLDATALOAD", 0x36: "CALLDATASIZE",
    0x37: "CALLDATACOPY", 0x38: "CODESIZE", 0x39: "CODECOPY", 0x3a: "GASPRICE",
    0x3b: "EXTCODESIZE", 0x3c: "EXTCODECOPY", 0x3d: "RETURNDATASIZE", 0x3e: "RETURNDATACOPY",
    0x3f: "EXTCODEHASH", 0x40: "BLOCKHASH", 0x41: "COINBASE", 0x42: "TIMESTAMP",
    0x43: "NUMBER", 0x44: "PREVRANDAO", 0x45: "GASLIMIT", 0x46: "CHAINID",
    0x47: "SELFBALANCE", 0x48: "BASEFEE", 0x49: "BLOBHASH", 0x4a: "BLOBBASEFEE",
    0x50: "POP", 0x51: "MLOAD", 0x52: "MSTORE", 0x53: "MSTORE8", 0x54: "SLOAD",
    0x55: "SSTORE", 0x56: "JUMP", 0x57: "JUMPI", 0x58: "PC", 0x59: "MSIZE",
    0x5a: "GAS", 0x5b: "JUMPDEST", 0x5f: "PUSH0",
    0xa0: "LOG0", 0xa1: "LOG1", 0xa2: "LOG2", 0xa3: "LOG3", 0xa4: "LOG4",
    0xf0: "CREATE", 0xf1: "CALL", 0xf2: "CALLCODE", 0xf3: "RETURN", 0xf4: "DELEGATECALL",
    0xf5: "CREATE2", 0xfa: "STATICCALL", 0xfd: "REVERT", 0xff: "SELFDESTRUCT"
}

def get_mnemonic(opcode):
    """Convert opcode to mnemonic, emitting unknown opcodes as hex."""
    if 0x60 <= opcode <= 0x7f:  # PUSH1 to PUSH32
        n = opcode - 0x60 + 1
        return f"PUSH{n}"
    elif 0x80 <= opcode <= 0x8f:  # DUP1 to DUP16
        n = opcode - 0x80 + 1
        return f"DUP{n}"
    elif 0x90 <= opcode <= 0x9f:  # SWAP1 to SWAP16
        n = opcode - 0x90 + 1
        return f"SWAP{n}"
    elif opcode in opcodes:
        return opcodes[opcode]
    else:
        return f"0x{opcode:02x}"

def disassemble(code, runtime=None):
    """Disassemble bytecode into a list of instructions.
    
    Args:
        code: The EVM bytecode to disassemble
        runtime: If True, only return runtime code. If False, only return deployment code.
                If None, return all code.
    """
    instructions = []
    pc = 0
    while pc < len(code):
        opcode = code[pc]
        mnemonic = get_mnemonic(opcode)
        if 0x60 <= opcode <= 0x7f:  # PUSH instructions
            n = opcode - 0x60 + 1
            if pc + n >= len(code):
                instructions.append({'pc': pc, 'opcode': opcode, 'mnemonic': f"0x{opcode:02x}", 'operand': None})
                break
            operand = code[pc + 1:pc + 1 + n]
            instructions.append({'pc': pc, 'opcode': opcode, 'mnemonic': mnemonic, 'operand': operand})
            pc += 1 + n
        else:
            instructions.append({'pc': pc, 'opcode': opcode, 'mnemonic': mnemonic, 'operand': None})
            pc += 1
    
    if runtime is not None:
        runtime_offset = find_runtime_offset(instructions)
        if runtime_offset is None:
            print("Warning: Could not find runtime code offset")
            return []
        
        if runtime:
            # Filter for runtime code
            instructions = [inst for inst in instructions if inst['pc'] >= runtime_offset]
        else:
            # Filter for deployment code
            instructions = [inst for inst in instructions if inst['pc'] < runtime_offset]
    
    return instructions

def find_runtime_offset(instructions):
    """Find the offset where runtime code begins."""
    for i in range(len(instructions) - 6):
        insts = instructions[i:i + 7]
        if (insts[0]['mnemonic'].startswith('PUSH') and
            insts[1]['mnemonic'] == 'DUP1' and
            insts[2]['mnemonic'].startswith('PUSH') and
            insts[3]['mnemonic'].startswith('PUSH') and
            insts[4]['mnemonic'] == 'CODECOPY' and
            insts[5]['mnemonic'].startswith('PUSH') and
            insts[6]['mnemonic'] == 'RETURN'):
            offset_inst = insts[2]  # Third PUSH contains the offset
            if offset_inst['operand'] is not None:
                return int.from_bytes(offset_inst['operand'], 'big')
    return None

def output_disassembly(instructions, runtime_offset):
    """Print the disassembly with runtime code annotation."""
    for inst in instructions:
        pc_str = f"{inst['pc']:04x}"
        if runtime_offset is not None and inst['pc'] == runtime_offset:
            print("; Runtime code starts here")
        if inst['mnemonic'] == 'JUMPDEST':
            print(f"{pc_str}: JUMPDEST ; loc_{pc_str}")
        elif inst['operand'] is not None:
            operand_str = "0x" + inst['operand'].hex()
            print(f"{pc_str}: {inst['mnemonic']} {operand_str}")
        else:
            print(f"{pc_str}: {inst['mnemonic']}")

def disassemble_evm(code, runtime=None):
    """Main function to disassemble EVM bytecode."""
    instructions = disassemble(code, runtime)
    runtime_offset = find_runtime_offset(instructions) if runtime is None else None
    output_disassembly(instructions, runtime_offset)


def translate_evm_to_venomir(code):
    """Translate EVM bytecode directly into VenomIR code."""
    venomir_code = []
    stack = []
    variables = {}
    variable_counter = 0
    labels = {}  # Track all labels and their usage
    dynamic_jumps = []  # Track locations of dynamic jumps
    current_pc = 0  # Track current PC during translation

    def getv():
        nonlocal variable_counter
        variable_counter += 1
        return f"%{variable_counter}"

    def get_label(pc):
        """Get or create a label for a given PC."""
        if pc not in labels:
            labels[pc] = f"label_{pc:04x}"
        return labels[pc]

    # Disassemble the bytecode into instructions
    instructions = disassemble(code, runtime=True)
    
    # First pass: identify all JUMPDESTs and create labels
    for inst in instructions:
        if inst['mnemonic'] == "JUMPDEST":
            get_label(inst['pc'])

    # Second pass: translate instructions
    for i, inst in enumerate(instructions):
        current_pc = inst['pc']
        mnemonic = inst['mnemonic']

        # JUMPDEST: Define a label
        if mnemonic == "JUMPDEST":
            venomir_code.append(f"{get_label(current_pc)}:")
        
        # PUSH instructions
        elif mnemonic.startswith("PUSH"):
            if mnemonic == "PUSH0":  # Special case for 0x5f
                value = 0
            else:
                value = int.from_bytes(inst['operand'], 'big')
            v = getv()
            venomir_code.append(f"\t{v} = {value}")
            stack.append(v)
            variables[v] = value  # Record constant for jumps

        # Arithmetic operations
        elif mnemonic == "ADD":
            b, a = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = add {a}, {b}")
            stack.append(v)
        elif mnemonic == "SUB":
            b, a = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = sub {a}, {b}")
            stack.append(v)
        elif mnemonic == "MUL":
            b, a = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = mul {a}, {b}")
            stack.append(v)
        elif mnemonic == "GT":
            b, a = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = gt {a}, {b}")
            stack.append(v)
        elif mnemonic == "LT":
            b, a = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = lt {a}, {b}")
            stack.append(v)
        elif mnemonic == "SLT":
            b, a = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = slt {a}, {b}")
            stack.append(v)
        elif mnemonic == "EQ":
            b, a = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = eq {a}, {b}")
            stack.append(v)
        elif mnemonic == "ISZERO":
            value = stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = iszero {value}")
            stack.append(v)
        elif mnemonic == "XOR":
            b, a = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = xor {a}, {b}")
            stack.append(v)
        elif mnemonic == "AND":
            b, a = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = and {a}, {b}")
            stack.append(v)
        elif mnemonic == "OR":
            b, a = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = or {a}, {b}")
            stack.append(v)
        elif mnemonic == "SHR":
            shift, value = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = shr {value}, {shift}")
            stack.append(v)
        elif mnemonic == "SHL":
            shift, value = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = shl {value}, {shift}")
            stack.append(v)
        elif mnemonic == "SHA3":
            size, offset = stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = keccak256 {offset}, {size}")
            stack.append(v)

        # Memory and storage
        elif mnemonic == "MLOAD":
            address = stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = mload {address}")
            stack.append(v)
        elif mnemonic == "MSTORE":
            value, address = stack.pop(), stack.pop()
            venomir_code.append(f"\tmstore {address}, {value}")
        elif mnemonic == "MSTORE8":
            value, address = stack.pop(), stack.pop()
            venomir_code.append(f"\tmstore8 {address}, {value}")
        elif mnemonic == "SLOAD":
            address = stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = sload {address}")
            stack.append(v)
        elif mnemonic == "SSTORE":
            value, address = stack.pop(), stack.pop()
            venomir_code.append(f"\tsstore {address}, {value}")

        # Stack operations
        elif mnemonic == "POP":
            stack.pop()
        elif mnemonic.startswith("DUP"):
            dup_num = int(mnemonic[3:])
            if 1 <= dup_num <= 16 and len(stack) >= dup_num:
                v = getv()
                venomir_code.append(f"\t{v} = {stack[-dup_num]}")
                stack.append(v)
        elif mnemonic.startswith("SWAP"):
            swap_num = int(mnemonic[4:])
            if 1 <= swap_num <= 16 and len(stack) >= swap_num + 1:
                stack[-1], stack[-swap_num - 1] = stack[-swap_num - 1], stack[-1]

        # Control flow
        elif mnemonic == "JUMP":
            target_var = stack.pop()
            if target_var in variables:
                # Static jump to known label
                venomir_code.append(f"\tjmp @{get_label(variables[target_var])}")
            else:
                # Dynamic jump - we'll handle this with a switch statement
                dynamic_jumps.append((current_pc, target_var))
                venomir_code.append(f"\t; Dynamic jump at PC {current_pc:04x}")
                venomir_code.append(f"\t; Target computed as {target_var}")
        elif mnemonic == "JUMPI":
            target_var = stack.pop()
            condition = stack.pop()
            if target_var in variables:
                # Static conditional jump
                true_label = f"@{get_label(variables[target_var])}"
                false_label = f"@{get_label(instructions[i + 1]['pc'])}" if i + 1 < len(instructions) else "@end"
                venomir_code.append(f"\tjnz {condition}, {true_label}, {false_label}")
            else:
                # Dynamic conditional jump
                dynamic_jumps.append((current_pc, target_var))
                venomir_code.append(f"\t; Dynamic conditional jump at PC {current_pc:04x}")
                venomir_code.append(f"\t; Target computed as {target_var}")
        elif mnemonic == "STOP":
            venomir_code.append("\tstop")
        elif mnemonic == "RETURN":
            size, offset = stack.pop(), stack.pop()
            venomir_code.append(f"\treturn {offset}, {size}")
        elif mnemonic == "REVERT":
            if len(stack) >= 2:
                size, offset = stack.pop(), stack.pop()
                venomir_code.append(f"\trevert {offset}, {size}")

        # Log operations
        elif mnemonic.startswith("LOG"):
            n = int(mnemonic[3])  # Get number of topics from opcode (LOG0 to LOG4)
            if len(stack) >= n + 2:  # Need n topics + size + offset
                # Pop topics in reverse order (top of stack is last topic)
                topics = [stack.pop() for _ in range(n)][::-1]
                size, offset = stack.pop(), stack.pop()
                
                # Create log statement with topics
                log_stmt = f"\tlog {offset}, {size}"
                if topics:
                    log_stmt += f", {', '.join(topics)}"
                venomir_code.append(log_stmt)

        # Environmental opcodes
        elif mnemonic == "CALLER":
            v = getv()
            venomir_code.append(f"\t{v} = caller")
            stack.append(v)
        elif mnemonic == "CALLVALUE":
            v = getv()
            venomir_code.append(f"\t{v} = callvalue")
            stack.append(v)
        elif mnemonic == "CALLDATASIZE":
            v = getv()
            venomir_code.append(f"\t{v} = calldatasize")
            stack.append(v)
        elif mnemonic == "CALLDATALOAD":
            value = stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = calldataload {value}")
            stack.append(v)
        elif mnemonic == "CODECOPY":
            size, offset, code_offset = stack.pop(), stack.pop(), stack.pop()
            v = getv()
            venomir_code.append(f"\t{v} = codecopy {code_offset}, {offset}, {size}")
            stack.append(v)

        # Handle unknown opcodes
        elif mnemonic.startswith("0x"):
            print(f"Warning: Unknown opcode {mnemonic} at pc=0x{current_pc:x}")
            venomir_code.append(f"\t; Unknown opcode {mnemonic} at PC {current_pc:04x}")
        else:
            print(f"Warning: Unhandled opcode {mnemonic} at pc={current_pc:x}")
            venomir_code.append(f"\t; Unhandled opcode {mnemonic} at PC {current_pc:04x}")

    # Add dynamic jump handling at the end
    if dynamic_jumps:
        venomir_code.append("\n; Dynamic jump handling")
        for pc, target_var in dynamic_jumps:
            venomir_code.append(f"\n; Dynamic jump from PC {pc:04x}")
            venomir_code.append(f"\t; Target variable: {target_var}")

    return "function main {\nmain:\n" + "\n".join(venomir_code) + "\n}"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Disassemble EVM bytecode')
    parser.add_argument('--runtime', action='store_true', help='Show only runtime code')
    parser.add_argument('--deploy', action='store_true', help='Show only deployment code')
    args = parser.parse_args()
    
    if args.runtime and args.deploy:
        print("Error: Cannot specify both --runtime and --deploy")
        sys.exit(1)
    
    runtime_param = None
    if args.runtime:
        runtime_param = True
    elif args.deploy:
        runtime_param = False
    
    try:
        hex_input = sys.stdin.read().strip()
        code = bytes.fromhex(hex_input)
        disassemble_evm(code, runtime_param)
        print(translate_evm_to_venomir(code))
        
    except ValueError as e:
        print(f"Error: Invalid hexadecimal input. {e}", file=sys.stderr)
        sys.exit(1)