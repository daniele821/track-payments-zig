const std = @import("std");

const key_size: usize = 32;
const nonce_size: usize = 12;
const tag_size: usize = 16;

pub fn encrypt(allocator: std.mem.Allocator, key: [key_size]u8, message: []const u8) ![]const u8 {
    const result: []u8 = try allocator.alloc(u8, message.len + tag_size);
    var tag: [tag_size]u8 = undefined;
    var nonce: [nonce_size]u8 = undefined;
    std.crypto.random.bytes(nonce[0..]);

    std.crypto.aead.aes_gcm.Aes256Gcm.encrypt(result[0..message.len], &tag, message, "", nonce, key);

    @memcpy(result[message.len..], tag[0..]);
    return result;
}

test "AES256 encryption" {
    const allocator = std.testing.allocator;
    const key = [_]u8{'a'} ** key_size;
    const msg = "b" ** 100;
    const cipher = try encrypt(allocator, key, msg[0..]);
    defer allocator.free(cipher);
}

pub fn decrypt(allocator: std.mem.Allocator, key: [key_size]u8, message: []const u8) []const u8 {
    _ = allocator;
    _ = key;
    _ = message;
}
