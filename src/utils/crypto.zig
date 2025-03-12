const std = @import("std");

const keySize: usize = 32;
const blockSize: usize = 16;

pub fn encrypt(allocator: std.mem.Allocator, key: [keySize]u8, message: []const u8) []const u8 {
    _ = allocator;
    _ = key;
    _ = message;
}

pub fn decrypt(allocator: std.mem.Allocator, key: [keySize]u8, message: []const u8) []const u8 {
    std.debug.assert(message.len % blockSize == 0);
    std.crypto.core.aes.Aes256.initDec(key).decryptWide(message.len / blockSize, "", "");
    _ = allocator;
}
