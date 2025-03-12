const std = @import("std");

const key_size: usize = 32;
const nonce_size: usize = 12;
const tag_size: usize = 16;

pub fn encrypt(allocator: std.mem.Allocator, key: [key_size]u8, message: []const u8) ![]const u8 {
    const cipher_tag = try allocator.alloc(u8, message.len + tag_size + nonce_size);
    var tag: [tag_size]u8 = undefined;
    var nonce: [nonce_size]u8 = undefined;
    std.crypto.random.bytes(nonce[0..]);

    const aes256encrypt = std.crypto.aead.aes_gcm.Aes256Gcm.encrypt;
    aes256encrypt(cipher_tag[0..message.len], &tag, message, "", nonce, key);

    @memcpy(cipher_tag[message.len .. message.len + tag_size], tag[0..]);
    @memcpy(cipher_tag[message.len + tag_size ..], nonce[0..]);
    return cipher_tag;
}

test "AES256 encryption" {
    const allocator = std.testing.allocator;
    const msg_len = 100;

    const key = [_]u8{'a'} ** key_size;
    const msg = "b" ** msg_len;

    const cipher = try encrypt(allocator, key, msg[0..]);
    defer allocator.free(cipher);

    try std.testing.expectEqual(msg_len + tag_size + nonce_size, cipher.len);
}

// pub fn decrypt(allocator: std.mem.Allocator, key: [key_size]u8, cipher: []const u8) []const u8 {
//     _ = allocator;
//     _ = key;
//     _ = cipher;
//
//     // std.crypto.aead.aes_gcm.Aes256Gcm.decrypt(m: []u8, c: []const u8, tag: [tag_length]u8, ad: []const u8, npub: [nonce_length]u8, key: [key_length]u8);
//
//     return message;
// }
