const std = @import("std");

const key_size: usize = 32;
const nonce_size: usize = 12;
const tag_size: usize = 16;

pub fn encrypt(allocator: std.mem.Allocator, key: [key_size]u8, message: []const u8) []const u8 {
    _ = allocator;
    const cipher: [message.len]u8 = undefined;
    const tag: [tag_size]u8 = undefined;
    const nonce: [nonce_size]u8 = undefined;
    std.crypto.random.bytes(&nonce);
    std.crypto.aead.aes_gcm.Aes256Gcm.encrypt(cipher, tag, message, "", nonce, key);
}

pub fn decrypt(allocator: std.mem.Allocator, key: [key_size]u8, message: []const u8) []const u8 {
    _ = allocator;
    _ = key;
    _ = message;
}
