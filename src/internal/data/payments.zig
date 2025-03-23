const std = @import("std");

pub const ElementType = enum { city, shop, method, item };

pub const Payments = struct {
    allocator: std.mem.Allocator,
    elements: ElementSets,

    const Self = @This();
    const ElementSet = std.AutoHashMapUnmanaged([]const u8, void);
    const ElementSets = std.AutoHashMapUnmanaged(ElementType, ElementSet);

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
            .elements = ElementSets{},
        };
    }

    pub fn deinit(self: *Self) void {
        var iterator = self.elements.valueIterator();
        while (iterator.next()) |elems| {
            elems.deinit(self.allocator);
        }
        self.elements.deinit(self.allocator);
    }

    pub fn addElement(self: *Self, new_element: []const u8, element_type: ElementType) !void {
        _ = self;
        _ = new_element;
        _ = element_type;
    }

    pub fn hasElement(self: *Self, element: []const u8, element_type: ElementType) bool {
        _ = self;
        _ = element;
        _ = element_type;
        return true;
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
