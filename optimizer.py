import re
import sys
import os
import time

class YulOptimizer:
    def __init__(self, config=None):
        self.rules = []
        self.structural_targets = []
        self.stats = {
            'blocks_removed': 0,
            'regex_matches': 0,
            'original_size': 0,
            'final_size': 0
        }
        self.config = config or {}
        self._setup_rules()

    def add_structural_target(self, target):
        self.structural_targets.append(target)

    def add_regex_rule(self, name, pattern, replacement, flags=0):
        self.rules.append({
            'name': name,
            'pattern': pattern,
            'replacement': replacement,
            'flags': flags
        })

    def _setup_rules(self):
        # 1. Structural Targets (Panic/Revert in IF)
        self.add_structural_target(r"panic_error_0x41\(\)") # Memory overflow
        self.add_structural_target(r"panic_error_0x32\(\)") # Array bounds
        self.add_structural_target(r"panic_error_0x11\(\)") # Arithmetic overflow
        self.add_structural_target(r"panic_error_0x12\(\)") # Division by zero
        self.add_structural_target(r"panic_error_0x21\(\)") # Enum/Push errors
        # self.add_structural_target(r"revert\(\s*0,\s*0\)")  # DISABLE: Too aggressive, deleting valid logic containment
        self.add_structural_target(r"revert_forward_1\(\)") # Contract creation failure
        self.add_structural_target(r"revert_error_")         # Custom errors
        # self.add_structural_target("0x4e487b71")             # Panic selector (hex) - KEEP overflow checks
        # self.add_structural_target("35408467139433450592217433187231851964531694900788300625387963629091585785856") # Panic selector (dec)

        # Optimization: Unwrap calldatasize check (Safe for modern calls)
        # if iszero(lt(calldatasize(), 4)) { ... } -> { ... }
        self.add_regex_rule(
            "Unwrap Calldata Check", 
            r'if\s+iszero\(lt\(calldatasize\(\),\s*4\)\)', 
            '' # Replaces 'if ...' with empty string. Result: '{ ... }' (valid block)
        )

        # 2. Immutables from Config
        # Config format: "immutables": { "ID": "0xValue", ... }
        immutables = self.config.get('immutables', {})
        for key, val in immutables.items():
            # If val is dict (enhanced format), extract value
            if isinstance(val, dict):
                val = val.get('value')
            
            if val:
                # Rule: replace loadimmutable("KEY") with val
                # Val is likely a hex string "0x..." or decimal. Yul handles hex as 0x...
                # Note: If val is 0x123, ensure it is treated as a literal.
                self.add_regex_rule(
                    f"Hardcode Immutable {key}",
                    rf'loadimmutable\("{re.escape(key)}"\)',
                    str(val)
                )
                # Remove setimmutable instructions for this key (usually in constructor, but harmless to add)
                # setimmutable(offset, "KEY", val)
                self.add_regex_rule(
                    f"Remove SetImmutable {key}",
                    rf'setimmutable\([^,]+, "{re.escape(key)}", [^)]+\)',
                    ''
                )

        # 3. Optimization Levels / Optional Rules
        opt_config = self.config.get('optimizations', {})
        level = opt_config.get('level', 'safe') # safe, aggressive

        # Always applied validators
        self.add_regex_rule("Strip Validator Calls", r'validator_[\w]+\s*\([^)]+\)', '')
        self.add_regex_rule("Strip Identity Validators", r'if\s+iszero\(eq\([^,]+,\s*[\w_$]+\([^)]+\)\)\)\s*\{\s*revert\(0,\s*0\)\s*\}', '')

        # Level: Aggressive
        if level == 'aggressive':
             # Dangerous optimizations (example)
             pass
        
        # Standard Runtime Checks (Always applied if not disabled)
        if not opt_config.get('keep_runtime_checks', False):
            # Strip ExtCodeSize
            self.add_regex_rule("Strip ExtCodeSize", r'if iszero\(extcodesize\([^)]+\)\)\s*\{\s*revert\([^)]+\)\s*\}', '')
            # Strip CallValue
            self.add_regex_rule("Strip CallValue", r'if callvalue\(\)\s*\{[^}]+\}', '')
        
        # Explicit flags in config can override level
        if opt_config.get('strip_creation_check', False):
             self.add_regex_rule(
                "Strip Creation Success Check",
                r'(let\s+([\w_]+)\s*:=\s*create\([\s\S]+?)\s*if\s+iszero\(\2\)\s*\{[^}]+\}',
                r'\1'
             )

        # Generic Cleanup
        self.add_regex_rule("Remove Empty Ifs", r'if [^{]+\{\s*\}', '', flags=re.MULTILINE)
        self.add_regex_rule("Remove Panic Defs", r'function panic_error_0x[\w]+\(\)\s*\{[^}]+\}', '')
        self.add_regex_rule("Remove Revert Defs", r'function revert_error_[\w]+\([^)]*\)\s*\{[^}]+\}', '')

    def _find_enclosing_if(self, text, start_pos):
        # Scan back to find '{'
        i = start_pos
        while i >= 0:
            if text[i] == '{':
                break
            if text[i] == '}': 
                pass 
            i -= 1
        
        if i < 0: return None
        block_start = i
        
        # Scan back for "if"
        k = block_start - 1
        balance = 0
        limit = 4000
        scanned = 0
        
        while k >= 0 and scanned < limit:
            char = text[k]
            if char == ')': balance += 1
            elif char == '(': balance -= 1
            
            if balance == 0:
                if char in '{};': return None
                
                if char == 'f' and k > 0 and text[k-1] == 'i':
                     start_ok = (k == 1) or (not text[k-2].isalnum() and text[k-2] != '_')
                     end_ok = (k+1 >= len(text)) or (not text[k+1].isalnum() and text[k+1] != '_')
                     if start_ok and end_ok:
                         return k-1
            k -= 1
            scanned += 1
            
        return None

    def _phase_structural(self, content):
        matches = 0
        for target_pattern in self.structural_targets:
            search_start = 0
            regex = re.compile(target_pattern)
            
            while True:
                m = regex.search(content, search_start)
                if not m: break
                
                idx = m.start()
                match_len = m.end() - m.start()
                
                match_start = self._find_enclosing_if(content, idx)
                if match_start is not None:
                    open_brace = content.find('{', match_start)
                    if open_brace != -1:
                        balance = 1
                        p = open_brace + 1
                        while p < len(content):
                            if content[p] == '{': balance += 1
                            elif content[p] == '}': balance -= 1
                            
                            if balance == 0:
                                block_content = content[match_start:p+1]
                                if "switch" in block_content or "for " in block_content or "function " in block_content:
                                    search_start = idx + match_len
                                    break
                                
                                # print(f"[Structural] Removing block: {block_content[:50]}...")
                                content = content[:match_start] + content[p+1:]
                                matches += 1
                                search_start = match_start 
                                break
                            p += 1
                        else:
                            search_start = idx + match_len
                            continue
                    else:
                         search_start = idx + match_len
                else:
                    search_start = idx + match_len
                    
        self.stats['blocks_removed'] = matches
        return content

    def _phase_preprocess(self, content):
        content = re.sub(r'/\*[\s\S]*?\*/|//.*', '', content)
        return content

    def _phase_regex(self, content):
        for rule in self.rules:
            try:
                content = re.sub(rule['pattern'], rule['replacement'], content, flags=rule['flags'])
            except Exception as e:
                print(f"[Warn] Rule {rule['name']} failed: {e}")
        return content

    def _phase_cleanup(self, content):
        content = re.sub(r'function\s+\{\s*[^}]+\}', '', content, flags=re.MULTILINE)
        return content

    def optimize(self, content):
        self.stats['original_size'] = len(content)
        start = time.time()
        
        # print("Running Phase 0: Preprocessing...")
        content = self._phase_preprocess(content)
        
        # print("Running Phase 1: Structural Analysis...")
        content = self._phase_structural(content)
        
        # print("Running Phase 2: Regex Transformations...")
        content = self._phase_regex(content)
        
        # print("Running Phase 3: Final Cleanup...")
        content = self._phase_cleanup(content)
        
        end = time.time()
        self.stats['final_size'] = len(content)
        self.stats['time'] = end - start
        
        return content

    def print_report(self):
        reduction = self.stats['original_size'] - self.stats['final_size']
        perc = 0
        if self.stats['original_size'] > 0:
            perc = (reduction / self.stats['original_size']) * 100
            
        print("\n" + "="*40)
        print("Yul2Venom Optimization Report")
        print(f"Original Size    : {self.stats['original_size']:,} bytes")
        print(f"Final Size       : {self.stats['final_size']:,} bytes")
        print(f"Reduction        : {reduction:,} bytes ({perc:.2f}%)")
        print("="*40)

def main():
    import json
    if len(sys.argv) < 3:
        print("Usage: python3 optimizer.py <input> <output> [config.json]")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]
    config = {}
    if len(sys.argv) > 3:
         with open(sys.argv[3], 'r') as f:
             config = json.load(f)
    
    try:
        with open(input_path, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"[Error] File not found: {input_path}")
        sys.exit(1)

    opt = YulOptimizer(config)

    print("Running optimization loop...")
    prev_size = len(content)
    # Reduced passes for speed
    for i in range(5): 
        content = opt.optimize(content)
        current_size = len(content)
        if current_size == prev_size:
            break
        prev_size = current_size

    opt.print_report()
    
    with open(output_path, 'w') as f:
        f.write(content)
 
if __name__ == "__main__":
    main()
