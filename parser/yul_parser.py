import re
import sys
from collections import deque
from dataclasses import dataclass, field
from typing import List, Union, Optional

# --- Reference AST Nodes matching Vyper/Venom style ---

@dataclass
class AstNode:
    pass

@dataclass
class YulLiteral(AstNode):
    value: str

@dataclass
class YulCall(AstNode):
    function: str
    args: List['YulExpression']

@dataclass
class YulExpression(AstNode):
    # wrapper for Union[YulLiteral, YulCall]
    node: Union[YulLiteral, YulCall]

@dataclass
class YulStatement(AstNode):
    pass

@dataclass
class YulBlock(YulStatement):
    statements: List[YulStatement] = field(default_factory=list)

@dataclass
class YulAssignment(YulStatement):
    vars: List[str]
    value: YulExpression

@dataclass
class YulVariableDeclaration(YulStatement):
    vars: List[str]
    value: YulExpression

@dataclass
class YulIf(YulStatement):
    condition: YulExpression
    body: YulBlock

@dataclass
class YulSwitch(YulStatement):
    condition: YulExpression
    cases: List['YulCase']

@dataclass
class YulCase(AstNode):
    value: Union[str, int, None] # None for default
    body: YulBlock

@dataclass
class YulForLoop(YulStatement):
    init: YulBlock
    condition: YulExpression
    post: YulBlock
    body: YulBlock

@dataclass
class YulFunctionDef(YulStatement):
    name: str
    args: List[str]
    returns: List[str]
    body: YulBlock

@dataclass
class YulLeave(YulStatement):
    pass

@dataclass
class YulBreak(YulStatement):
    pass

@dataclass
class YulContinue(YulStatement):
    pass

@dataclass
class YulExpressionStmt(YulStatement):
    expr: YulExpression

@dataclass
class YulData(AstNode):
    name: str
    encoding: str
    value: str

@dataclass
class YulObject(AstNode):
    name: str
    code: YulBlock
    functions: List[YulFunctionDef] = field(default_factory=list)
    sub_objects: List['YulObject'] = field(default_factory=list)
    data_items: List[YulData] = field(default_factory=list)


class YulParser:
    def __init__(self, content):
        self.content = content
        self.pos = 0
        self.length = len(content)
        self.token_re = re.compile(r'[a-zA-Z0-9_$.]+')
        self.ws_re = re.compile(r'(\s+)|(//[^\n]*\n?)|(/\*.*?\*/)', re.DOTALL)

    def skip_whitespace(self):
        while self.pos < self.length:
            match = self.ws_re.match(self.content, self.pos)
            if match:
                self.pos = match.end()
            else:
                break

    def peek(self):
        self.skip_whitespace()
        if self.pos >= self.length:
            return None
        return self.content[self.pos]

    def consume(self, expected=None):
        self.skip_whitespace()
        if self.pos >= self.length:
            return None
        
        if expected:
            if self.content.startswith(expected, self.pos):
                self.pos += len(expected)
                return expected
            else:
                got = self.content[self.pos:self.pos+10]
                raise ValueError(f"Expected '{expected}' at {self.pos}. Got: '{got!r}'")
        
        match = self.token_re.match(self.content, self.pos)
        if match:
            token = match.group(0)
            self.pos += len(token)
            return token
        
        if self.content[self.pos] == '"':
            end = self.content.find('"', self.pos + 1)
            while end != -1 and self.content[end-1] == '\\':
                 end = self.content.find('"', end + 1)
            if end != -1:
                token = self.content[self.pos:end+1]
                self.pos = end + 1
                return token
        
        char = self.content[self.pos]
        self.pos += 1
        return char

    def parse_toplevel_objects(self) -> List[YulObject]:
        # Return all top-level objects found (e.g. "Base", "MegaTest", "Middle")
        objects = []
        while self.peek() is not None:
            saved_pos = self.pos
            word = self.consume()
            if word == 'object':
                self.pos = saved_pos
                obj = self.parse_object()
                if obj:
                    objects.append(obj)
            # If prompt text or comments appear between objects, consume/skip could handle it
            # parse_object consumes the object block.
            # After an object, we loop again.
        return objects

    def parse_object(self) -> Optional[YulObject]:
        word = self.consume()
        if not word or word != 'object': return None
        
        name = self.consume()
        self.consume('{')
        
        code_block = None
        functions = []
        sub_objects = []
        data_items = []
        
        while True:
            p = self.peek()
            if p is None or p == '}': break
            
            saved_pos = self.pos
            token = self.consume()
            
            if token == 'code':
                code_block = self.parse_block()
            elif token == 'object':
                self.pos = saved_pos
                nested = self.parse_object()
                if nested:
                    sub_objects.append(nested)
            elif token == 'function':
                self.pos = saved_pos 
                func_def = self.parse_function_def()
                functions.append(func_def)
            elif token == 'data':
                data_name = self.consume()
                data_encoding = self.consume()
                data_value = self.consume()
                if data_name and data_encoding and data_value:
                    data_items.append(
                        YulData(name=data_name, encoding=data_encoding, value=data_value)
                    )
            else:
                pass
        
        self.consume('}')
        
        if code_block:
             return YulObject(
                 name=name,
                 code=code_block,
                 functions=functions,
                 sub_objects=sub_objects,
                 data_items=data_items,
             )
        return None

    def skip_block(self):
        self.consume('{')
        balance = 1
        while balance > 0:
            if self.pos >= self.length: break
            token = self.consume()
            if token == '{': balance += 1
            elif token == '}': balance -= 1

    def parse_block(self) -> YulBlock:
        self.consume('{')
        statements = []
        while True:
            p = self.peek()
            if p is None or p == '}': break
            
            try:
                stmt = self.parse_statement()
                if stmt:
                    statements.append(stmt)
                else:
                    break
            except ValueError as e:
                # Debugging parser recovery
                break
        self.consume('}')
        return YulBlock(statements=statements)

    def parse_function_def(self) -> YulFunctionDef:
        self.consume('function')
        name = self.consume()
        self.consume('(')
        args = []
        while self.peek() is not None and self.peek() != ')':
            args.append(self.consume())
            if self.peek() == ',': self.consume(',')
        self.consume(')')
        
        returns = []
        self.skip_whitespace()
        if self.content.startswith('->', self.pos):
            self.consume('->')
            while self.peek() is not None and self.peek() != '{':
                returns.append(self.consume())
                if self.peek() == ',': self.consume(',')

        body = self.parse_block()
        return YulFunctionDef(name=name, args=args, returns=returns, body=body)

    def _parse_let_declaration(self) -> YulVariableDeclaration:
        vars_ = []
        has_initializer = False

        while self.peek() is not None:
            self.skip_whitespace()
            if self.content.startswith(':=', self.pos):
                self.consume(':=')
                has_initializer = True
                break

            saved_pos = self.pos
            next_token = self.consume()
            if next_token in ('let', 'if', 'switch', 'for', 'function', 'leave', 'break', 'continue', '}'):
                self.pos = saved_pos
                break

            vars_.append(next_token)
            if self.peek() == ',':
                self.consume(',')

        expr = self.parse_expression() if has_initializer else None
        return YulVariableDeclaration(vars=vars_, value=expr)

    def _parse_switch_statement(self) -> YulSwitch:
        cond = self.parse_expression()
        cases = []

        while True:
            token = self.peek()
            if token is None or token == '}':
                break

            saved_pos = self.pos
            keyword = self.consume()

            if keyword == 'case':
                value = self.consume()
                body = self.parse_block()
                cases.append(YulCase(value=value, body=body))
                continue

            if keyword == 'default':
                body = self.parse_block()
                cases.append(YulCase(value=None, body=body))
                continue

            self.pos = saved_pos
            break

        return YulSwitch(condition=cond, cases=cases)

    def _parse_assignment_or_expression(self, first_word: str) -> YulStatement:
        if self.peek() == '(':
            self.pos -= len(first_word)
            return YulExpressionStmt(expr=self.parse_expression())

        vars_ = [first_word]
        while self.peek() == ',':
            self.consume(',')
            vars_.append(self.consume())

        self.skip_whitespace()
        if self.content.startswith(':=', self.pos):
            self.consume(':=')
            value = self.parse_expression()
            return YulAssignment(vars=vars_, value=value)

        if len(vars_) == 1:
            return YulExpressionStmt(expr=YulLiteral(value=first_word))

        raise ValueError(f"Unexpected tokens at {self.pos}")

    def parse_statement(self) -> Optional[YulStatement]:
        token = self.peek()
        if token is None or token == '}': return None
        if token == '{': return self.parse_block()
        
        word = self.consume()
        if not word: return None

        if word == 'let':
            return self._parse_let_declaration()
        
        elif word == 'if':
            cond = self.parse_expression()
            body = self.parse_block()
            return YulIf(condition=cond, body=body)
        
        elif word == 'switch':
            return self._parse_switch_statement()
        
        elif word == 'for':
            init_block = self.parse_block()
            cond_expr = self.parse_expression()
            post_block = self.parse_block()
            body_block = self.parse_block()
            return YulForLoop(init=init_block, condition=cond_expr, post=post_block, body=body_block)
        
        elif word == 'function':
            self.pos -= len(word) 
            return self.parse_function_def()
        
        elif word == 'leave': return YulLeave()
        elif word == 'break': return YulBreak()
        elif word == 'continue': return YulContinue()

        else:
            return self._parse_assignment_or_expression(word)

    def parse_expression(self) -> Union[YulLiteral, YulCall]:
        # Iterative Expression Parser
        start_token = self.consume()
        if start_token is None: return YulLiteral(value='0')
        
        if self.peek() != '(':
             return YulLiteral(value=start_token)

        # It IS a call. 
        # Stack elements: [func_name, args_list]
        stack = deque()
        stack.append([start_token, []])
        self.consume('(')

        final_call = None
        
        while stack:
            if self.peek() == ')':
                self.consume(')')
                current = stack.pop()
                func_name = current[0]
                args = current[1]
                
                node = YulCall(function=func_name, args=args)
                
                if not stack:
                    final_call = node
                    break
                else:
                    stack[-1][1].append(node)
                    if self.peek() == ',': self.consume(',')
                    continue
            
            # Next arg
            token = self.consume()
            
            if self.peek() == '(':
                stack.append([token, []])
                self.consume('(')
            else:
                stack[-1][1].append(YulLiteral(value=token))
                if self.peek() == ',': self.consume(',')
        
        return final_call
