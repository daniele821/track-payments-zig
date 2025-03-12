const std = @import("std");

const blockSize: usize = 32;

pub fn encrypt(allocator: std.mem.Allocator, key: [blockSize]u8, message: []const u8) []const u8 {
    _ = allocator;
    _ = key;
    _ = message;
}

pub fn decrypt(allocator: std.mem.Allocator, key: [blockSize]u8, message: []const u8) []const u8 {
    _ = allocator;
    _ = key;
    _ = message;
}
