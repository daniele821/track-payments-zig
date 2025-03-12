const std = @import("std");

const key_size: usize = 32;
const nonce_size: usize = 12;
const tag_size: usize = 16;

pub fn encrypt(allocator: std.mem.Allocator, key: [key_size]u8, message: []const u8) ![]const u8 {
    const cipher_tag = try allocator.alloc(u8, message.len + tag_size + nonce_size);
    var tag: [tag_size]u8 = undefined;
    var nonce: [nonce_size]u8 = undefined;
    std.crypto.random.bytes(nonce[0..]);

    std.crypto.aead.aes_gcm.Aes256Gcm.encrypt(
        cipher_tag[0..message.len],
        &tag,
        message,
        "",
        nonce,
        key,
    );

    @memcpy(cipher_tag[message.len .. message.len + tag_size], tag[0..]);
    @memcpy(cipher_tag[message.len + tag_size ..], nonce[0..]);
    return cipher_tag;
}

test "AES256 encryption" {
    const allocator = std.testing.allocator;
    const msg_len = 32;

    const key = [_]u8{'a'} ** key_size;
    const msg = "b" ** msg_len;

    const cipher = try encrypt(allocator, key, msg[0..]);
    defer allocator.free(cipher);

    try std.testing.expectEqual(msg_len + tag_size + nonce_size, cipher.len);
}

pub fn decrypt(allocator: std.mem.Allocator, key: [key_size]u8, cipher: []const u8) ![]const u8 {
    _ = key;

    // std.crypto.aead.aes_gcm.Aes256Gcm.decrypt(m: []u8, c: []const u8, tag: [tag_length]u8, ad: []const u8, npub: [nonce_length]u8, key: [key_length]u8);
    return try allocator.alloc(u8, cipher.len - tag_size - nonce_size);
}

test "AES256 decryption" {
    const allocator = std.testing.allocator;
    const msg_len = 32;

    const key = [_]u8{'a'} ** key_size;
    const cipher = [_]u8{ 0xe3, 0x1d, 0xb2, 0xd9, 0x09, 0x5f, 0x73, 0x64, 0x41, 0x03, 0x8f, 0x0f, 0xdf, 0xa0, 0x4e, 0x98, 0xf7, 0x36, 0x0e, 0x72, 0x15, 0xa0, 0xa5, 0xb2, 0xb5, 0x76, 0x84, 0xab, 0xf3, 0xc4, 0x79, 0x88, 0x06, 0x06, 0x53, 0xd0, 0x6e, 0x77, 0x84, 0x12, 0x7d, 0x29, 0x2f, 0x9c, 0xbd, 0x5e, 0xb5, 0xd3, 0x7e, 0x43, 0x11, 0x3a, 0x80, 0xcc, 0x80, 0xf7, 0x13, 0xfb, 0x92, 0x2b };

    const msg = try decrypt(allocator, key, cipher[0..]);
    defer allocator.free(msg);

    try std.testing.expectEqual(msg_len, msg.len);
}
