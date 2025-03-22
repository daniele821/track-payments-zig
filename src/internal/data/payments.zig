const std = @import("std");

pub const Payments = struct {
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        _ = self;
    }
};

test "payments" {
    const allocator = std.testing.allocator;
    const payments = Payments.init(allocator);
    defer payments.deinit();
}
