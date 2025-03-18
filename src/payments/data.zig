const std = @import("std");
const errors = @import("./errors.zig");

const InsertError = errors.InsertError;

const ValueSet = struct {
    cities: std.StringHashMap(void),
    shops: std.StringHashMap(void),
    methods: std.StringHashMap(void),
    items: std.StringHashMap(void),

    pub fn init(allocator: std.mem.Allocator) ValueSet {
        return .{
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

test "ValueSet" {
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

    pub fn init(
        value_set: ValueSet,
        quantity: u32,
        unit_price: u32,
        item: []const u8,
    ) !Order {
        return .{
            .quantity = quantity,
            .unit_price = unit_price,
            .item = value_set.items.getKey(item) orelse return InsertError.NotInValueSet,
        };
    }

    pub fn lessThen(self: *Order, other: *Order) bool {
        return std.mem.lessThan(u8, self.item, other.item);
    }
};

test "Order" {
    const allocator = std.testing.allocator;
    var value_set = ValueSet.init(allocator);
    defer value_set.deinit();

    try value_set.items.put("Item1", {});
    try value_set.items.put("Item2", {});
    var order1 = try Order.init(value_set, 1, 123, "Item1");
    var order2 = try Order.init(value_set, 1, 123, "Item2");
    try std.testing.expect(order1.lessThen(&order2));
    try std.testing.expect(!order2.lessThen(&order1));

    const failure = Order.init(value_set, 2, 100, "InvalidItem");
    try std.testing.expectError(InsertError.NotInValueSet, failure);
}

const Payment = struct {
    city: *const []const u8,
    shop: *const []const u8,
    method: *const []const u8,
    date: i64,
    orders: std.ArrayList(*Order),

    pub fn init(
        allocator: std.mem.Allocator,
        value_set: ValueSet,
        city: []const u8,
        shop: []const u8,
        method: []const u8,
        date: i64,
    ) !Payment {
        return .{
            .city = &(value_set.cities.getKey(city) orelse return InsertError.NotInValueSet),
            .shop = &(value_set.shops.getKey(shop) orelse return InsertError.NotInValueSet),
            .method = &(value_set.methods.getKey(method) orelse return InsertError.NotInValueSet),
            .date = date,
            .orders = std.ArrayList(*Order).init(allocator),
        };
    }

    pub fn deinit(self: *Payment) void {
        self.orders.deinit();
    }

    pub fn lessThen(self: *Payment, other: *Payment) bool {
        return self.date < other.date;
    }

    pub fn sortOrders(self: *Payment) void {
        const lessThanFn = struct {
            fn func(context: void, lhs: *Order, rhs: *Order) bool {
                _ = context;
                return lhs.lessThen(rhs);
            }
        }.func;
        std.mem.sort(*Order, self.orders, {}, lessThanFn);
    }
};

test "Payment" {
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
    payments: std.ArrayList(*Payment),
    dates: std.AutoHashMap(i64, void),

    pub fn init(allocator: std.mem.Allocator) AllPayments {
        return .{
            .allocator = allocator,
            .value_set = ValueSet.init(allocator),
            .payments = std.ArrayList(*Payment).init(allocator),
            .dates = std.AutoHashMap(i64, void).init(allocator),
        };
    }

    pub fn deinit(self: *AllPayments) void {
        for (self.payments.items) |payment| {
            for (payment.orders.items) |orders| {
                self.allocator.destroy(orders);
            }
            self.allocator.destroy(payment);
        }
        self.value_set.deinit();
        self.payments.deinit();
        self.dates.deinit();
    }

    pub fn sortPayments(self: *AllPayments) void {
        const lessThanFn = struct {
            fn func(context: void, lhs: *Payment, rhs: *Payment) bool {
                _ = context;
                return lhs.lessThen(rhs);
            }
        }.func;
        std.mem.sort(*Payment, self.payments, {}, lessThanFn);
        for (self.payments.items) |payment| {
            payment.sortOrders();
        }
    }

    pub fn addValues(
        self: *AllPayments,
        cities: []const []const u8,
        shops: []const []const u8,
        methods: []const []const u8,
        items: []const []const u8,
    ) !void {
        for (cities) |c| _ = try self.value_set.cities.getOrPut(c);
        for (shops) |s| _ = try self.value_set.shops.getOrPut(s);
        for (methods) |m| _ = try self.value_set.methods.getOrPut(m);
        for (items) |i| _ = try self.value_set.items.getOrPut(i);
    }

    pub fn addPayment(self: *AllPayments, payment: Payment) !*Payment {
        if (self.dates.contains(payment.date)) {
            return InsertError.NotUniqueValue;
        }
        var self_tmp = self;
        const allocated_payment = try self_tmp.allocator.create(Payment);
        allocated_payment.* = payment;
        _ = try self.dates.getOrPut(payment.date);
        try self.payments.append(allocated_payment);
        return allocated_payment;
    }
};

test "AllPayments" {
    const allocator = std.testing.allocator;
    var allPayments = AllPayments.init(allocator);
    defer allPayments.deinit();

    try allPayments.addValues(&.{"City"}, &.{"Shop"}, &.{"Method"}, &.{ "Item1", "Item2", "Item3" });
    const pay1 = try Payment.init(allocator, allPayments.value_set, "City", "Shop", "Method", 1);
    const pay2 = try Payment.init(allocator, allPayments.value_set, "City", "Shop", "Method", 2);
    const order1 = try Order.init(allPayments.value_set, 3, 129, "Item1");
    const order2 = try Order.init(allPayments.value_set, 4, 100, "Item2");
    const order3 = try Order.init(allPayments.value_set, 1, 342, "Item3");
    _ = try allPayments.addPayment(pay1);
    _ = try allPayments.addPayment(pay2);
    _ = order1;
    _ = order2;
    _ = order3;

    // temporary : think how to handle allocations inside allpayment deinit
    std.debug.print("TODOwd\n", .{});
}
