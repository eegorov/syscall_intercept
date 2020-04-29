/*
 * Copyright 2016-2017, Intel Corporation
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in
 *       the documentation and/or other materials provided with the
 *       distribution.
 *
 *     * Neither the name of the copyright holder nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * intercept_wrapper.s -- see asm_wrapper.md
 */

/* the function in this file */
.global intercept_wrapper
.hidden intercept_wrapper
.type intercept_wrapper, @function

/* the C function in intercept.c */
.global intercept_routine
.hidden intercept_routine
.type intercept_routine, @function

/* the other C function in intercept.c, called right after cloning a thread */
.global intercept_routine_post_clone
.hidden intercept_routine_post_clone
.type intercept_routine_post_clone, @function

.text

/*
 * Local stack layout:
 *
 * 0x448(%rsp)  -- return address, to the generated asm wrapper
 * Arguments recieved on stack:
 * 0x450(%rsp)  -- original value of rsp
 * 0x458(%rsp)  -- pointer to a struct patch_desc instance
 * Locals on stack:
 * 0xe8(%rsp) - 0x168(%rsp) -- saved GPRs
 * 0x200(%rsp) - 0x400(%rsp) -- saved SIMD registers
 *
 * A pointer to these saved register is passed to intercept_routine, so the
 * layout of `struct context` must match this part of the stack layout.
 *
 * Other arguments:
 * %rcx  -- which C function to call
 */
intercept_wrapper:
    # Recover x6
    ldr x6, [sp, #0x18]
    # Down stack pointer
    sub sp, sp, #0x140
    # Save all GPRs on the stack
    stp x0, x1, [sp, #0x00]
    stp x2, x3, [sp, #0x10]
    stp x4, x5, [sp, #0x20]
    stp x6, x7, [sp, #0x30]
    stp x8, x9, [sp, #0x40]
    stp x10, x11, [sp, #0x50]
    stp x12, x13, [sp, #0x60]
    stp x14, x15, [sp, #0x70]
    stp x16, x17, [sp, #0x80]
    stp x18, x19, [sp, #0x90]
    stp x20, x21, [sp, #0xa0]
    stp x22, x23, [sp, #0xb0]
    stp x24, x25, [sp, #0xc0]
    stp x26, x27, [sp, #0xd0]
    stp x28, x29, [sp, #0xe0]
    # Save floating-point registers
    stp d8, d9, [sp, #0x100]
    stp d10, d11, [sp, #0x110]
    stp d12, d13, [sp, #0x120]
    stp d14, d15, [sp, #0x130]
    # Save lr, sp
    ldr x0, [sp, #0x150]
    add x1, sp, #0x160
    stp x0, x1, [sp, #0xf0]

    mov x0, sp
    mov x29, lr
    bl intercept_routine
    mov lr, x29

    # Restore all GPRs except x0, x1
    ldp x2, x3, [sp, #0x10]
    ldp x4, x5, [sp, #0x20]
    ldp x6, x7, [sp, #0x30]
    ldp x8, x9, [sp, #0x40]
    ldp x10, x11, [sp, #0x50]
    ldp x12, x13, [sp, #0x60]
    ldp x14, x15, [sp, #0x70]
    ldp x16, x17, [sp, #0x80]
    ldp x18, x19, [sp, #0x90]
    ldp x20, x21, [sp, #0xa0]
    ldp x22, x23, [sp, #0xb0]
    ldp x24, x25, [sp, #0xc0]
    ldp x26, x27, [sp, #0xd0]
    ldp x28, x29, [sp, #0xe0]
    # Restore floating-point registers
    ldp d8, d9, [sp, #0x100]
    ldp d10, d11, [sp, #0x110]
    ldp d12, d13, [sp, #0x120]
    ldp d14, d15, [sp, #0x130]
    # Up stack pointer
    add sp, sp, #0x140
    # Return
    ret
