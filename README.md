# MIPS-SIMD-Architecture
Design "customized" Instruction Set Architecture (ISA) - SIMD - based upon the MIPS "baseline" ISA.

## Description
Most SIMD execution units in today's processors have vector registers that are 128 bits wide. This provides for vectors that can hold 16-byte elements per register, 8 had-word (16 bits) elements per register, 4 word (32-bits) elements per register, or 2 double-word (64 bits) elements per register.

Since the MIPS process only has 32-bit registers, the "baseline enhancements" will combine two MIPS registers (conceptually concatenated" to form "one 64-bit vector register" for all SIMD instructions.

## Programmers Reference Manual
Please see the document "SIMD Enhanced MIPS Instructions" with all explanations, diagrams, and examples for all the "customized" instructions.
