const std = @import("std");

const StringSet = std.StringHashMap(void);

const ValueSet = struct {
    cities: *StringSet,
    shops: *StringSet,
    methods: *StringSet,
    items: *StringSet,

    allPayments: *AllPayments,

    pub fn init(allPayments: *AllPayments) ValueSet {
        return .{
            .allPayments = allPayments,
            .cities = &StringSet.init(allPayments.allocator),
        };
    }

    pub fn deinit() void {}
};

const Order = struct {
    quantity: u32,
    unit_price: u32,
    item: []u8,
};

const AllPayments = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) AllPayments {
        return .{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *AllPayments) void {
        _ = self;
    }
};

test "init" {
    const allocator = std.testing.allocator;
    var allPayments = AllPayments.init(allocator);
    defer _ = allPayments.deinit();
}
