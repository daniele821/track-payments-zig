const std = @import("std");
const errors = @import("./errors.zig");

const InsertError = error{
    NotInValueSet,
    NotUniqueValue,
};

pub const ValueSet = struct {
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

pub const Order = struct {
    quantity: u32,
    unit_price: u32,
    item: *const []const u8,

    pub fn init(
        value_set: ValueSet,
        quantity: u32,
        unit_price: u32,
        item: []const u8,
    ) !Order {
        return .{
            .quantity = quantity,
            .unit_price = unit_price,
            .item = value_set.items.getKeyPtr(item) orelse return InsertError.NotInValueSet,
        };
    }

    pub fn lessThen(self: *const Order, other: *const Order) bool {
        return std.mem.lessThan(u8, self.item.*, other.item.*);
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

pub const Payment = struct {
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
            .city = value_set.cities.getKeyPtr(city) orelse return InsertError.NotInValueSet,
            .shop = value_set.shops.getKeyPtr(shop) orelse return InsertError.NotInValueSet,
            .method = value_set.methods.getKeyPtr(method) orelse return InsertError.NotInValueSet,
            .date = date,
            .orders = std.ArrayList(*Order).init(allocator),
        };
    }

    pub fn deinit(self: *Payment) void {
        self.orders.deinit();
    }

    pub fn lessThen(self: *const Payment, other: *const Payment) bool {
        return self.date < other.date;
    }

    pub fn sortOrders(self: *const Payment) void {
        const lessThanFn = struct {
            fn func(context: void, lhs: *Order, rhs: *Order) bool {
                _ = context;
                return lhs.lessThen(rhs);
            }
        }.func;
        std.mem.sort(*Order, self.orders.items, {}, lessThanFn);
    }
};

test "Payment" {
    const allocator = std.testing.allocator;
    var value_set = ValueSet.init(allocator);
    defer value_set.deinit();
    try value_set.shops.put("Shop1", {});
    try value_set.cities.put("City1", {});
    try value_set.methods.put("Method1", {});
    try value_set.items.put("Item1", {});
    try value_set.items.put("Item2", {});
    try value_set.items.put("Item3", {});

    var payment1 = try Payment.init(allocator, value_set, "City1", "Shop1", "Method1", 0);
    defer payment1.deinit();
    var payment2 = try Payment.init(allocator, value_set, "City1", "Shop1", "Method1", 1);
    defer payment2.deinit();

    try std.testing.expect(payment1.lessThen(&payment2));
    try std.testing.expect(!payment2.lessThen(&payment1));

    var order1 = try Order.init(value_set, 1, 200, "Item1");
    var order2 = try Order.init(value_set, 2, 120, "Item2");
    var order3 = try Order.init(value_set, 3, 169, "Item3");

    try payment1.orders.append(&order2);
    try payment1.orders.append(&order1);
    try payment1.orders.append(&order3);

    payment1.sortOrders();

    for (payment1.orders.items, 0..) |item, index| {
        if (index == 0) continue;
        try std.testing.expect(payment1.orders.items[index - 1].lessThen(item));
    }
}

pub const AllPayments = struct {
    allocator: std.mem.Allocator,
    value_set: ValueSet,
    payments: std.ArrayList(*Payment),
    dates: std.AutoHashMap(i64, *Payment),

    pub fn init(allocator: std.mem.Allocator) AllPayments {
        return .{
            .allocator = allocator,
            .value_set = ValueSet.init(allocator),
            .payments = std.ArrayList(*Payment).init(allocator),
            .dates = std.AutoHashMap(i64, *Payment).init(allocator),
        };
    }

    pub fn deinit(self: *AllPayments) void {
        for (self.payments.items) |payment| {
            for (payment.orders.items) |order| {
                self.allocator.destroy(order);
            }
            payment.orders.deinit();
            self.allocator.destroy(payment);
        }
        self.value_set.deinit();
        self.payments.deinit();
        self.dates.deinit();
    }

    pub fn sortPayments(self: *const AllPayments) void {
        const lessThanFn = struct {
            fn func(context: void, lhs: *Payment, rhs: *Payment) bool {
                _ = context;
                return lhs.lessThen(rhs);
            }
        }.func;
        std.mem.sort(*Payment, self.payments.items, {}, lessThanFn);
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
        for (cities) |city| _ = try self.value_set.cities.getOrPut(city);
        for (shops) |shop| _ = try self.value_set.shops.getOrPut(shop);
        for (methods) |method| _ = try self.value_set.methods.getOrPut(method);
        for (items) |item| _ = try self.value_set.items.getOrPut(item);
    }

    pub fn addPayment(self: *AllPayments, payment: Payment) !*Payment {
        if (self.dates.contains(payment.date)) return InsertError.NotUniqueValue;

        var self_tmp = self;
        const allocated_payment = try self_tmp.allocator.create(Payment);
        allocated_payment.* = payment;
        _ = try self.dates.put(payment.date, allocated_payment);
        try self.payments.append(allocated_payment);
        return allocated_payment;
    }

    pub fn addOrder(self: *const AllPayments, payment: *Payment, order: Order) !*Order {
        var self_tmp = self;
        const allocated_order = try self_tmp.allocator.create(Order);
        allocated_order.* = order;
        _ = try payment.orders.append(allocated_order);
        return allocated_order;
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
    const pay2ptr = try allPayments.addPayment(pay2);
    const pay1ptr = try allPayments.addPayment(pay1);
    _ = try allPayments.addOrder(pay1ptr, order1);
    _ = try allPayments.addOrder(pay1ptr, order3);
    _ = try allPayments.addOrder(pay1ptr, order2);
    _ = try allPayments.addOrder(pay2ptr, order1);

    allPayments.sortPayments();
    for (allPayments.payments.items, 0..) |payment, index_payment| {
        if (index_payment == 0) continue;
        try std.testing.expect(allPayments.payments.items[index_payment - 1].lessThen(payment));
        for (payment.orders.items, 0..) |order, index_order| {
            if (index_order == 0) continue;
            try std.testing.expect(payment.orders.items[index_order - 1].lessThen(order));
        }
    }
}

test "tmp" {}
