pub inline fn outb(port: u16, value: u8) void {
    asm volatile ("outb %al, %dx"
        :
        : [value] "{al}" (value),
          [port] "{dx}" (port),
    );
}

pub inline fn inb(port: u16) u8 {
    return asm volatile ("inb %dx, %al"
        : [value] "={al}" (-> u8),
        : [port] "dx" (port),
    );
}

pub inline fn ioWait() void {
    outb(0x80, 0);
}
