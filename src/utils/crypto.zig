const std = @import("std");

pub const key_size: usize = 32;
pub const nonce_size: usize = 12;
pub const tag_size: usize = 16;

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

    // try encrypting
    const cipher = try encrypt(allocator, key, msg[0..]);
    defer allocator.free(cipher);
    try std.testing.expectEqual(msg_len + tag_size + nonce_size, cipher.len);
}

pub fn decrypt(allocator: std.mem.Allocator, key: [key_size]u8, cipher: []const u8) ![]const u8 {
    const msg_len = cipher.len - tag_size - nonce_size;
    const message = try allocator.alloc(u8, msg_len);
    const cipher_only = cipher[0..msg_len];
    var tag: [tag_size]u8 = undefined;
    var nonce: [nonce_size]u8 = undefined;
    @memcpy(tag[0..], cipher[msg_len .. msg_len + tag_size]);
    @memcpy(nonce[0..], cipher[msg_len + tag_size ..]);

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

    // try encrypting
    const cipher = try encrypt(allocator, key, msg[0..]);
    defer allocator.free(cipher);
    try std.testing.expectEqual(msg_len + tag_size + nonce_size, cipher.len);

    // try decrypting
    const msg2 = try decrypt(allocator, key, cipher);
    defer allocator.free(msg2);
    try std.testing.expectEqual(msg_len, msg2.len);

    try std.testing.expectEqualSlices(u8, msg, msg2);
}
