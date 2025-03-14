const std = @import("std");

const StringSet = std.StringHashMap(void);
const String = []const u8;

const InsertError = error{NotInValueSet};

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

const Order = struct {
    quantity: u32,
    unit_price: u32,
    item: String,

    pub fn init(value_set: ValueSet, quantity: u32, unit_price: u32, item: String) InsertError!Order {
        return .{
            .quantity = quantity,
            .unit_price = unit_price,
            .item = value_set.items.getKey(item) orelse return InsertError.NotInValueSet,
        };
    }
};

test "AllPayments" {
    const allocator = std.testing.allocator;
    var allPayments = AllPayments.init(allocator);
    defer allPayments.deinit();
}

test "ValueSet" {
    const allocator = std.testing.allocator;
    const value_set = ValueSet.init(allocator);
    _ = value_set;
}

test "Order" {
    const allocator = std.testing.allocator;
    _ = try Order.init(ValueSet.init(allocator), 1, 123, "12");
}
