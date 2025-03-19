const std = @import("std");

pub const key_size: usize = 32;
pub const nonce_size: usize = 12;
pub const tag_size: usize = 16;
pub const extra_size: usize = tag_size + nonce_size;

pub fn encrypt(allocator: std.mem.Allocator, key: [key_size]u8, message: []const u8) ![]const u8 {
    const cipher = try allocator.alloc(u8, message.len + extra_size);
    var tag: [tag_size]u8 = undefined;
    var nonce: [nonce_size]u8 = undefined;
    std.crypto.random.bytes(nonce[0..]);

    std.crypto.aead.aes_gcm.Aes256Gcm.encrypt(
        cipher[0..message.len],
        &tag,
        message,
        "",
        nonce,
        key,
    );

    @memcpy(cipher[message.len .. message.len + tag_size], tag[0..]);
    @memcpy(cipher[message.len + tag_size ..], nonce[0..]);

    return cipher;
}

test "AES256 encryption" {
    const allocator = std.testing.allocator;
    const msg_len = 32;
    const key = [_]u8{'a'} ** key_size;
    const msg = "b" ** msg_len;

    const cipher = try encrypt(allocator, key, msg[0..]);
    defer allocator.free(cipher);
}

pub fn decrypt(allocator: std.mem.Allocator, key: [key_size]u8, cipher: []const u8) ![]const u8 {
    const message = try allocator.alloc(u8, cipher.len - extra_size);
    const cipher_only = cipher[0..message.len];
    var tag: [tag_size]u8 = undefined;
    var nonce: [nonce_size]u8 = undefined;
    @memcpy(tag[0..], cipher[message.len .. message.len + tag_size]);
    @memcpy(nonce[0..], cipher[message.len + tag_size ..]);

    try std.crypto.aead.aes_gcm.Aes256Gcm.decrypt(
        message,
        cipher_only,
        tag,
        "",
        nonce,
        key,
    );

    return message;
}

test "AES256 decryption" {
    const allocator = std.testing.allocator;
    const msg_len = 32;
    const key = [_]u8{'a'} ** key_size;
    const msg = "b" ** msg_len;

    const cipher = try encrypt(allocator, key, msg[0..]);
    defer allocator.free(cipher);
    const msg2 = try decrypt(allocator, key, cipher[0..]);
    defer allocator.free(msg2);

    try std.testing.expectEqualSlices(u8, msg, msg2[0..]);
}
