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

Create a file with any name and `.sb` extension:

```forth
// hello.sb
35 34 + dump        // prints 69
10 20 + dup dump    // prints 30
5 - dump            // prints 25
```

### Link and run

At the end of `main.asm`, specify your source file:

```asm
src "hello.sb"
```

Then compile and run:

```bash
make main
./main
```

---

## 📚 Language Reference

### Stack Operations

| Syntax | Description | Example |
|--------|-------------|---------|
| `<number>` | Push a number onto the stack | `42` → stack: `[42]` |
| `dup` | Duplicate the top of the stack | `5 dup` → stack: `[5, 5]` |

### Arithmetic

| Syntax | Description | Example |
|--------|-------------|---------|
| `+` | Pop two numbers, push their sum | `3 5 +` → stack: `[8]` |
| `-` | Pop two numbers, push the difference (in written order) | `10 3 -` → stack: `[7]` |

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
| `dump` | Pop and print the top value | `42 dump` → prints `42` |

### Control Flow

| Syntax | Description |
|--------|-------------|
| `if` / `else` / `end` | Conditional execution. Pops top value; runs if-block when non-zero |
| `while` / `do` | Loop. Repeats while top of stack is non-zero |

### Memory

| Syntax | Description |
|--------|-------------|
| `mem` | Push the address of the memory buffer for reading/writing |

### Comments

| Syntax | Description |
|--------|-------------|
| `//` | Line comment — everything after `//` is ignored |

---

## 💡 Examples

### Arithmetic & Output

```forth
10 20 + dump    // 30
50 8 - dump     // 42
100 dup dump    // 100
100 - dump      // 0
```

### Conditionals

```forth
10 5 > if
  1 dump        // prints 1 (true)
else
  0 dump        // won't run
end
```

### Countdown Loop

```forth
10
while dup 0 > do
  dup dump
  1 -
end
// prints: 10 9 8 7 6 5 4 3 2 1
```

### Comparisons

```forth
5 5 = dump      // 1 (equal)
5 3 != dump     // 1 (not equal)
10 5 >= dump    // 1 (greater or equal)
3 7 < dump      // 1 (less than)
```

---

## 🏗️ How It Works

```
┌─────────────┐      ┌────────────────┐      ┌──────────────┐
│  .sb Source  │ ───▶ │  ASM Compiler  │ ───▶ │  Executable  │
│  (your code) │      │   (x86_64)     │      │ (native bin) │
└─────────────┘      └────────────────┘      └──────────────┘
```

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
