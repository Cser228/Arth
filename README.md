**Arth** This stack based language, get based from Forth, this language writed in ASM x86_64

**How to compile**
just write in the console "make main"

**How to run**
Rigth now you need write code in the file name.sb, and in the end of main.asm write name.sb in src file ""

**Functions**
(number) - push this number in stack.
\+ - pop 2 numbers and push the sum of them.
\- - pop 2 numbers and push the difference of them, in the order they was written (2 1 -) = (1).
dump - pop 1 number and print him.
dup - pop 1 number and push this number twice.
if/else/end - condition words.
// - after this nothing will be work in this line (comments).
while/do - while loop.
= / != / > / < / >= / <= - operators, pop 2 numbers and cmp them, push 1 if true, push 0 if false.
mem - push the address of the beginning of the memory where you can read and write onto the stack.
