const std = @import("std");

pub const Elements = enum { city, shop, method, item };

pub const Payments = struct {
    allocator: std.mem.Allocator,
    strings_pool: StringPool,
    elements: ElementSets,

    const Self = @This();
    const StringPool = std.StringHashMapUnmanaged([]const u8);
    const ElementSet = std.AutoHashMapUnmanaged(*const []const u8, void);
    const ElementSets = std.AutoHashMapUnmanaged(Elements, ElementSet);

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
            .strings_pool = StringPool{},
            .elements = ElementSets{},
        };
    }

    pub fn deinit(self: *Self) void {
        self.strings_pool.deinit(self.allocator);
        var iterator = self.elements.valueIterator();
        while (iterator.next()) |elems| {
            elems.deinit(self.allocator);
        }
        self.elements.deinit(self.allocator);
    }
};

test "payments" {
    const allocator = std.testing.allocator;
    var payments = Payments.init(allocator);
    defer payments.deinit();
}
