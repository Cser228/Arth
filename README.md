<div align="center">

# 🔷 Arth

### Stack-based programming language inspired by Forth

*Written entirely in x86_64 Assembly*

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux--x86__64-lightgrey.svg)](#)
[![Language](https://img.shields.io/badge/written%20in-ASM%20x86__64-orange.svg)](#)

---

</div>

## 📖 About

**Arth** is a minimalist stack-based programming language inspired by [Forth](https://en.wikipedia.org/wiki/Forth_(programming_language)). The compiler is written entirely in **x86_64 Assembly**, making it as close to the hardware as possible.

All operations in Arth work through the stack — you push values, perform operations that pop and push results, and use control flow constructs to build programs.

---

## 🚀 Quick Start

### Compile the compiler

```bash
make main
```

### Write your program

Create a file with any name and `.arth` extension:

```pascal
// hello.arth
include "io.arth"

"Hello World!\n" write
```

### Run code

Run the code!

```bash
./main hello.arth
```

---

## 📚 Language Reference

### Stack Operations

| Syntax | Description | Example |
|--------|-------------|---------|
| `<number>` | Push a number onto the stack | `42` → stack: `[42]` |
| `<string>` | Push a address to memory, where allocated new string and a len of string onto the stack | `"hello"` → stack: `[4207151, 5]` |
| `dup` | Duplicate the top of the stack | `5 dup` → stack: `[5, 5]` |
| `2dup` | Duplicate two numbers of the top of stack | `10 0 2dup` → stack: `[10, 0, 10, 0]` |
| `drop` | Pop last number in the stack | `10 10 drop` → stack: `[10]` |
| `swap` | Swap two near numbers in the stack | `10 5 swap` → stack: `[5, 10]` |
| `over` | Copy second number of top in the stack | `10 5 over` → stack: `[10, 5, 10]` |

### Bits Operations

| Syntax | Description | Example |
|--------|-------------|---------|
| `shr` | Shifts all bytes in first arg by second arg right | `4 1 shr` → stack: `[2]` |
| `shl` | Shifts all bytes in first arg by second arg left | `1 1 shr` → stack: `[2]` |
| `bor` | Compare each bytes in first arg by or by each bytes in second arg | `1 2 bor` → stack: `[3]` |
| `band` | Compare each bytes in first arg by and by each bytes in second arg | `1 3 band` → stack: `[1]` |

### Arithmetic

| Syntax | Description | Example |
|--------|-------------|---------|
| `+` | Pop two numbers, push their sum | `3 5 +` → stack: `[8]` |
| `-` | Pop two numbers, push the difference (in written order) | `10 3 -` → stack: `[7]` |
| `*` | Pop two numbers, push their multiply | `3 2 *` → stack: `[6]` |

### Comparison Operators

| Syntax | Description | Example |
|--------|-------------|---------|
| `=` | Equal | `5 5 =` → stack: `[1]` |
| `!=` | Not equal | `5 3 !=` → stack: `[1]` |
| `>` | Greater than | `5 3 >` → stack: `[1]` |
| `<` | Less than | `3 5 <` → stack: `[1]` |
| `>=` | Greater or equal | `5 5 >=` → stack: `[1]` |
| `<=` | Less or equal | `3 5 <=` → stack: `[1]` |

> All comparison operators pop two values and push `1` (true) or `0` (false).

### I/O

| Syntax | Description | Example |
|--------|-------------|---------|
| `dump` | Pop and print the top value of the stack and print \n | `42 dump` → prints `42\n` |
| `print` | Pop and print the top value of the stack | `42 print` → prints `42` |

### Control Flow

| Syntax | Description |
|--------|-------------|
| `if` / `else` / `end` | Conditional execution. Pops top value; runs if-block when non-zero |
| `while` / `do` | Loop. Repeats while top of stack is non-zero |

### Memory

| Syntax | Description |
|--------|-------------|
| `mem` | Push the address of the memory buffer for reading/writing |
| `.` | Store the given byte at the given address |
| `,` | Load a byte from the given address |

### Comments

| Syntax | Description |
|--------|-------------|
| `//` | Line comment — everything after `//` is ignored |

### System

| Syntax | Description |
|--------|-------------|
| `syscall` | Perform the syscall |

### Macros
| Syntax | Description |
|--------|-------------|
| `macro` | You can write whatever and name it somehow, and when you write name of macro, interpritator auto replace name with implementation |

### Dependencies
| Syntax | Description |
|--------|-------------|
| `include` | Add code in the file to this file |

---

## 💡 Examples

### Arithmetic & Output

```pascal
10 20 + dump    // 30
50 8 - dump     // 42
100 dup dump    // 100
100 - dump      // 0
3 2 * dump      // 6
3 2 mod dump    // 1
```

### Conditionals

```pascal
10 5 > if
  1 dump        // prints 1 (true)
else
  0 dump        // won't run
end
```

### Countdown Loop

```pascal
10 0 while 2dup > do
  dup dump
  1 +
end
drop drop
// prints: 0 1 2 3 4 5 6 7 8 9
```

### Comparisons

```pascal
5 5 = dump      // 1 (equal)
5 3 != dump     // 1 (not equal)
10 5 >= dump    // 1 (greater or equal)
3 7 < dump      // 1 (less than)
```

### Memory

```pascal
mem 1 .         //store 1 into the memory
mem , dump      //read from memory one byte
```

### System

```pascal
1 //1 arg
2 //2 arg
3 //n arg
3 //amount of arguments (n)
1 //syscall number
syscall
```

### Bits Operations

```pascal
4 1 shl //4 << 1
//4 = 0b00000100
//4 << 1 = 0b00001000
//1 = 0b00000001
1 bor
9 = if
	1 dump
else
	0 dump
end
```

### Stack Operations

```pascal
4 1 swap dump dump //print: 1 4
5 10 over dump dump dump //print: 5 10 5
1 "Hello World!" 3 1 syscall //print: Hello World!
```

### Macros

```pascal
macro write
	mem ,
	over mem swap .
	swap drop swap
	1 swap
	mem , 3 1 syscall
	mem swap .
end

"Hello World!\n" write      //print Hello World!(new_line)
```

### Dependencies

```pascal
include "io.arth"

"Hello World!\n" write
//in io.arth can be macro write
```

---

## 🏗️ How It Works

```
┌──────────────┐      ┌────────────────┐      ┌──────────────┐
│ .arth Source │ ───▶ │  ASM Compiler  │ ───▶ │  Executable  │
│  (your code) │      │   (x86_64)     │      │ (native bin) │
└──────────────┘      └────────────────┘      └──────────────┘
```

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
