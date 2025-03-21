const std = @import("std");
const pay = @import("./payments.zig");

pub const AllPaymentsOptimized = struct {
    allocator: std.mem.Allocator,
};

test "AllPaymentBasic" {}
