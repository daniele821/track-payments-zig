const std = @import("std");
const errors = @import("./errors.zig");

const StringSet = std.StringHashMap(void);
const String = []const u8;

const InsertError = errors.InsertError;

const ValueSet = struct {
    allocator: std.mem.Allocator,
    cities: StringSet,
    shops: StringSet,
    methods: StringSet,
    items: StringSet,

    pub fn init(allocator: std.mem.Allocator) ValueSet {
        return .{
            .allocator = allocator,
            .cities = StringSet.init(allocator),
            .shops = StringSet.init(allocator),
            .methods = StringSet.init(allocator),
            .items = StringSet.init(allocator),
        };
    }
    pub fn deinit(self: *ValueSet) void {
        self.cities.deinit();
        self.shops.deinit();
        self.methods.deinit();
        self.items.deinit();
    }
};

test "ValueSet init" {
    const allocator = std.testing.allocator;
    var value_set = ValueSet.init(allocator);
    defer value_set.deinit();
}

const Order = struct {
    quantity: u32,
    unit_price: u32,
    item: String,

    pub fn new(value_set: ValueSet, quantity: u32, unit_price: u32, item: String) InsertError!Order {
        return .{
            .quantity = quantity,
            .unit_price = unit_price,
            .item = value_set.items.getKey(item) orelse return InsertError.NotInValueSet,
        };
    }
};

test "Order init" {
    const allocator = std.testing.allocator;
    var value_set = ValueSet.init(allocator);
    defer value_set.deinit();
    try value_set.items.put("Item", {});
    _ = try Order.new(value_set, 1, 123, "Item");
}

const AllPayments = struct {
    allocator: std.mem.Allocator,
    value_set: ValueSet,

    pub fn init(allocator: std.mem.Allocator) AllPayments {
        return .{
            .allocator = allocator,
            .value_set = ValueSet.init(allocator),
        };
    }
    pub fn deinit(self: *AllPayments) void {
        self.value_set.deinit();
    }
};

test "AllPayments init" {
    const allocator = std.testing.allocator;
    var allPayments = AllPayments.init(allocator);
    defer allPayments.deinit();
}
