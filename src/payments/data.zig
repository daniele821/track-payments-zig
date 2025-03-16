const std = @import("std");
const errors = @import("./errors.zig");

const InsertError = errors.InsertError;

const ValueSet = struct {
    allocator: std.mem.Allocator,
    cities: std.StringHashMap(void),
    shops: std.StringHashMap(void),
    methods: std.StringHashMap(void),
    items: std.StringHashMap(void),

    pub fn init(allocator: std.mem.Allocator) ValueSet {
        return .{
            .allocator = allocator,
            .cities = std.StringHashMap(void).init(allocator),
            .shops = std.StringHashMap(void).init(allocator),
            .methods = std.StringHashMap(void).init(allocator),
            .items = std.StringHashMap(void).init(allocator),
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

    try value_set.items.put("Item1", {});
    try value_set.cities.put("City1", {});
    try value_set.shops.put("Shop1", {});
    try value_set.methods.put("Method1", {});
}

const Order = struct {
    quantity: u32,
    unit_price: u32,
    item: []const u8,

    pub fn new(value_set: ValueSet, quantity: u32, unit_price: u32, item: []const u8) InsertError!Order {
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

    const failure = Order.new(value_set, 2, 100, "InvalidItem");
    try std.testing.expectError(InsertError.NotInValueSet, failure);
}

const Payment = struct {
    allocator: std.mem.Allocator,
    city: []const u8,
    shop: []const u8,
    method: []const u8,
    date: i64,
    orders: std.ArrayList(Order),

    pub fn init(
        allocator: std.mem.Allocator,
        value_set: ValueSet,
        city: []const u8,
        shop: []const u8,
        method: []const u8,
        date: i64,
    ) InsertError!Payment {
        return .{
            .allocator = allocator,
            .city = value_set.cities.getKey(city) orelse return InsertError.NotInValueSet,
            .shop = value_set.shops.getKey(shop) orelse return InsertError.NotInValueSet,
            .method = value_set.methods.getKey(method) orelse return InsertError.NotInValueSet,
            .date = date,
            .orders = std.ArrayList(Order).init(allocator),
        };
    }
    pub fn deinit(self: *Payment) void {
        self.orders.deinit();
    }
};

test "Payment init" {
    const allocator = std.testing.allocator;
    var value_set = ValueSet.init(allocator);
    defer value_set.deinit();
    try value_set.shops.put("Shop1", {});
    try value_set.cities.put("City1", {});
    try value_set.methods.put("Method1", {});

    var payment = try Payment.init(allocator, value_set, "City1", "Shop1", "Method1", 0);
    defer payment.deinit();
}

pub const AllPayments = struct {
    allocator: std.mem.Allocator,
    value_set: ValueSet,
    payments: std.ArrayList(Payment),

    pub fn init(allocator: std.mem.Allocator) AllPayments {
        return .{
            .allocator = allocator,
            .value_set = ValueSet.init(allocator),
            .payments = std.ArrayList(Payment).init(allocator),
        };
    }
    pub fn deinit(self: *AllPayments) void {
        self.value_set.deinit();
        self.payments.deinit();
    }
};

test "AllPayments init" {
    const allocator = std.testing.allocator;
    var allPayments = AllPayments.init(allocator);
    defer allPayments.deinit();
}
