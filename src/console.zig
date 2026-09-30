const std = @import("std");
const io = @import("io.zig");

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;

const VGA_BUFFER_ADDR: usize = 0xB8000;
const VGA_BUFFER: *volatile [VGA_WIDTH * VGA_HEIGHT]u16 = @ptrFromInt(VGA_BUFFER_ADDR);

var row: usize = 0;
var col: usize = 0;

const Color = enum(u4) {
    black = 0,
    blue = 1,
    green = 2,
    cyan = 3,
    red = 4,
    magenta = 5,
    brown = 6,
    light_grey = 7,
    dark_grey = 8,
    light_blue = 9,
    light_green = 10,
    light_cyan = 11,
    light_red = 12,
    light_magenta = 13,
    yellow = 14,
    white = 15,
};

fn makeEntryColor(fg: Color, bg: Color) u8 {
    return @as(u8, @intFromEnum(fg)) | (@as(u8, @intFromEnum(bg)) << 4);
}

pub fn vgaEntry(ch: u8, fg: Color, bg: Color) u16 {
    return @as(u16, ch) | @as(u16, makeEntryColor(fg, bg)) << 8;
}

fn newline() void {
    col = 0;
    row += 1;
}

pub fn putChar(ch: u8, fg: Color, bg: Color) void {
    if (ch == '\n') {
        newline();
        return;
    }

    putCharAt(ch, fg, bg, col, row);
    col += 1;
    if (col == VGA_WIDTH) newline();
}

pub fn putCharAt(ch: u8, fg: Color, bg: Color, x: usize, y: usize) void {
    VGA_BUFFER[y * VGA_WIDTH + x] = vgaEntry(ch, fg, bg);
}

pub fn clearScreen() void {
    for (0..VGA_HEIGHT) |y| {
        for (0..VGA_WIDTH) |x| {
            putCharAt(' ', .white, .black, x, y);
        }
    }
}

pub fn print(msg: []const u8, fg: Color, bg: Color) void {
    for (0..msg.len) |i| {
        putChar(msg[i], fg, bg);
    }
}

pub fn hideCursor() void {
    io.outb(0x3D4, 0x0A);
    io.outb(0x3D5, 0x20);
}
