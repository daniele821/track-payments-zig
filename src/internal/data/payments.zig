const std = @import("std");

pub const Payments = struct {
    allocator: std.mem.Allocator,
    strings_pool: std.ArrayList([]const u8),
    payments_pool: std.ArrayList(Payment),
    orders_pool: std.ArrayList(std.ArrayList(Order)),

    const Self = @This();

    const Order = struct {
        unit_price: u32,
        quantity: u32,
        item: u32,
    };

    const Payment = struct {
        city: u32,
        shop: u32,
        method: u32,
        date: i64,
        orders: u32,
    };

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
