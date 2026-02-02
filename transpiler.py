import sys
import os

# Allow imports both as standalone script and as module
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)
if parent_dir not in sys.path:
    sys.path.insert(0, parent_dir)

try:
    from parser import YulParser
    from generator import VenomIRBuilder
except ImportError:
    from parser.yul_parser import YulParser
    from generator.venom_generator import VenomIRBuilder

sys.setrecursionlimit(5000)

class Transpiler:
    def __init__(self, content):
        self.parser = YulParser(content)

    def run(self):
        # 1. Parse Yul
        # print("DEBUG: Starting parse...", file=sys.stderr)
        try:
            objects = self.parser.parse_toplevel_objects()
            if not objects:
                print("ERROR: No Yul objects found.", file=sys.stderr)
                return
            # Use the first (or main) object
            result = objects[0]
        except Exception as e:
            print(f"ERROR: Parse failed: {e}", file=sys.stderr)
            import traceback
            traceback.print_exc(file=sys.stderr)
            return

        if not result:
            print("ERROR: No Yul object found.", file=sys.stderr)
            return
            
        # print(f"DEBUG: Parsed object: {result.name}", file=sys.stderr)

        # 2. Generate Venom IR (Object Model)
        # print("DEBUG: Starting generation...", file=sys.stderr)
        try:
            gen = VenomIRBuilder()
            ir_context = gen.build(result)
            
            # 3. Output
            print(ir_context)
            
        except RecursionError:
            print("ERROR: Recursion limit hit!", file=sys.stderr)
        except Exception as e:
            print(f"Error generation: {e}", file=sys.stderr)
            import traceback
            traceback.print_exc(file=sys.stderr)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 transpiler.py <file.yul>", file=sys.stderr)
        sys.exit(1)

    yul_path = sys.argv[1]
    try:
        with open(yul_path, 'rb') as f:
            content = f.read().decode('utf-8')
    except FileNotFoundError:
        print(f"File not found: {yul_path}", file=sys.stderr)
        sys.exit(1)

    # DISABLED: Previously sliced to "_deployed" object only.
    # Now we transpile the FULL init code (constructor + embedded runtime)
    # This allows automatic immutable handling via setimmutable/codecopy
    # idx = content.find('_deployed"')
    # if idx != -1:
    #     start = content.rfind('object "', 0, idx)
    #     if start != -1:
    #         content = content[start:]
    
    transpiler = Transpiler(content)
    transpiler.run()
