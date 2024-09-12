---
title: FromNand2Tetris
date: 2024-08-30 10:48:23 +0200
categories: [software, courses] # TOP_CATEGORY, SUB_CATEGORY, MAX 2.
tags: [software, hardware, courses, certificates] # TAG names should always be lowercase.
description: Notes and thoughts on this great online course.
---

## Overview

In this [famous course](https://www.nand2tetris.org/) (often regarded as one of the best courses ever designed for Computer Science), we build a computer
from scratch, and then, using a higher-level programming language that we design ourselves, develop a program that runs on
that very computer.

This means that we go through all the building blocks a modern computer needs to be able to run software. In Part I we design
the hardware, and in Part II we focus on the software.

Part I consists of five projects:

1. Boolean functions and gate logic: we design our own basic chips, using the course's HDL (Hardware Descriptive Language), e.g.
   And, Not, Or, Xor, Mux, Dmux, etc.
2. Boolean Arithmetic and the ALU (Arithmetic Logic Unit)
3. etc.

Feel free to check out my [repo for the course](https://github.com/aljazkovac/from-nand-to-tetris/tree/main/).

## Highlights and Notes on Project 1

I really enjoyed designing the chips using the HDL (Figure 1). One thing one needs to keep in mind is that the multi-bit buses are indexed from right to left, so the opposite from what one is used to. I especially enjoyed designing the Mux4Way16 and Mux8Way16 and the Dmux4Way and Dmux8Way chips. It helped to actually draw out the sketches for the designs to get a better understanding. Another interesting thing happened around this time. I saw a post by [Andrej Karpathy](https://github.com/karpathy) about [Cursor](https://www.cursor.com/), a fork of VS Code, but with a built-in AI assistant (basically similar to GitHub Copilot, the only difference being that Cursor offers the chance to choose between various models, such as ChatGPT4o, Claude Sonnet 3.5, etc.). It looked pretty good and I really enjoyed using it but it would automatically produce solutions for me for the first couple of chips. After a few minutes I realized I wasn't solving the problems myself, and was therefore not learning anything. I deleted all the solutions and re-implemented everything myself from scratch. This could lead to a further debate on how to properly use LLMs for both work and learning, but my general feeling at the moment is simply: Don't use them to give you solutions. Only use them as a form of quicker and more comprehensive research, or as a complement to Googling and reading the documentation. That is, if you actually want to learn anything, of course.

![Desktop View](../assets/images/fromnand2tetris/fromnand2tetris-p1-chips.jpg){: w="700" h="400" }
_Figure 1: Design for a Dmux4Way and a Dmux8Way chip_

## Highlights and Notes on Project 2

In this project we built an ALU (Arithmetic Logic Unit). We built a family of adders (half-adder, full adder, add16, inc16), and then we used those to build a full ALU. The ALU computes a function on two inputs, and outputs the result.
It can perform a family of 18 functions, including setting an integer to 0, negating it, addition, multiplication and division of two integers, etc. It is a simple and elegant design.

Here is my implementation in less than twenty lines of HDL code:

```verilog
 * ALU (Arithmetic Logic Unit):
 * Computes out = one of the following functions:
 *                0, 1, -1,
 *                x, y, !x, !y, -x, -y,
 *                x + 1, y + 1, x - 1, y - 1,
 *                x + y, x - y, y - x,
 *                x & y, x | y
 * on the 16-bit inputs x, y,
 * according to the input bits zx, nx, zy, ny, f, no.
 * In addition, computes the two output bits:
 * if (out == 0) zr = 1, else zr = 0
 * if (out < 0)  ng = 1, else ng = 0
 */
// Implementation: Manipulates the x and y inputs
// and operates on the resulting values, as follows:
// if (zx == 1) sets x = 0        // 16-bit constant
// if (nx == 1) sets x = !x       // bitwise not
// if (zy == 1) sets y = 0        // 16-bit constant
// if (ny == 1) sets y = !y       // bitwise not
// if (f == 1)  sets out = x + y  // integer 2's complement addition
// if (f == 0)  sets out = x & y  // bitwise and
// if (no == 1) sets out = !out   // bitwise not

CHIP ALU {
    IN
        x[16], y[16],  // 16-bit inputs
        zx, // zero the x input?
        nx, // negate the x input?
        zy, // zero the y input?
        ny, // negate the y input?
        f,  // compute (out = x + y) or (out = x & y)?
        no; // negate the out output?
    OUT
        out[16], // 16-bit output
        zr,      // if (out == 0) equals 1, else 0
        ng;      // if (out < 0)  equals 1, else 0

    PARTS:
    // Pre-setting the x-input
    Mux16(a=x, b[0..15]=false, sel=zx, out=xSetZero);
    Not16(in=xSetZero, out=notX);
    Mux16(a=xSetZero, b=notX, sel=nx, out=xSet);

    // Pre-setting the y-input
    Mux16(a=y, b[0..15]=false, sel=zy, out=ySetZero);
    Not16(in=ySetZero, out=notY);
    Mux16(a=ySetZero, b=notY, sel=ny, out=ySet);

    // Selecting between computing + or &
    Add16(a=xSet, b=ySet, out=xPlusY);
    And16(a=xSet, b=ySet, out=xAndY);
    Mux16(a=xAndY, b=xPlusY, sel=f, out=fSet);

    // Post-setting the output
    Not16(in=fSet, out=notOut);
    Mux16(a=fSet, b=notOut, sel=no, out=out, out[0..7]=outFirst, out[8..15]=outSecond, out[15]=outMSB);

    // Setting the control bits
    // Or8Way outputs 1 if any of the bits is 1, and 0 if all are 0
    Or8Way(in=outFirst, out=firstPartAllZero);
    Or8Way(in=outSecond, out=secondPartAllZero);
    Or(a=firstPartAllZero, b=secondPartAllZero, out=allBitsZero);
    Mux(a=true, b=false, sel=allBitsZero, out=zr);

    // if (MSB == 1) then the number is negative
    Mux(a=false, b=true, sel=outMSB, out=ng);
}
```
