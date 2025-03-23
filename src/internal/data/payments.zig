const std = @import("std");

pub const ElementType = enum { city, shop, method, item };

pub const Payments = struct {
    allocator: std.mem.Allocator,
    elements: ElementSets,
    payments: PaymentList,

    const Self = @This();
    const ElementSet = std.StringHashMapUnmanaged(void);
    const ElementSets = std.AutoHashMapUnmanaged(ElementType, ElementSet);
    const PaymentList = std.ArrayListUnmanaged(Payment);
    const OrderList = std.ArrayListUnmanaged(Order);

    const Order = struct {
        unit_price: u32,
        quantity: u32,
        item: *const []const u8,
    };

    const Payment = struct {
        city: *const []const u8,
        shop: *const []const u8,
        method: *const []const u8,
        date: i64,
        orders: OrderList,
    };

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .elements = ElementSets{},
            .payments = PaymentList{},
        };
    }

    pub fn deinit(self: *Self) void {
        var iterator = self.elements.valueIterator();
        while (iterator.next()) |elems| elems.deinit(self.allocator);
        self.elements.deinit(self.allocator);
        for (self.payments.items) |*payment| payment.orders.deinit(self.allocator);
        self.payments.deinit(self.allocator);
    }

    pub fn addElement(self: *Self, new_element: []const u8, element_type: ElementType) !void {
        _ = try self.elements.getOrPutValue(self.allocator, element_type, ElementSet{});
        const elementSetPtr = self.elements.getPtr(element_type).?;
        _ = try elementSetPtr.getOrPut(self.allocator, new_element);
    }

    pub fn hasElement(self: *Self, element: []const u8, element_type: ElementType) bool {
        const element_set = self.elements.get(element_type) orelse return false;
        return element_set.contains(element);
    }
};

test "payments" {
    const allocator = std.testing.allocator;
    var payments = Payments.init(allocator);
    defer payments.deinit();

    try payments.addElement("Item", .item);
    try payments.addElement("City", .city);
    try payments.addElement("Method", .method);
    try payments.addElement("Shop", .shop);

    try std.testing.expect(payments.hasElement("Item", .item));
    try std.testing.expect(payments.hasElement("City", .city));
    try std.testing.expect(payments.hasElement("Method", .method));
    try std.testing.expect(payments.hasElement("Shop", .shop));
}
