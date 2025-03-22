const std = @import("std");
const pay = @import("./payments.zig");

pub const AllPaymentsBasic = struct {
    allocator: std.mem.Allocator,
    items: std.StringHashMap(void),
    cities: std.StringHashMap(void),
    shops: std.StringHashMap(void),
    methods: std.StringHashMap(void),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
            .items = std.StringHashMap(void).init(allocator),
            .cities = std.StringHashMap(void).init(allocator),
            .shops = std.StringHashMap(void).init(allocator),
            .methods = std.StringHashMap(void).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.items.deinit();
        self.cities.deinit();
        self.shops.deinit();
        self.methods.deinit();
    }

    pub fn allPayments(self: *Self) pay.AllPayments {
        return .{
            .ptr = self,
            .vtable = &.{
                .hasElement = hasElement,
                .addElement = addElement,
            },
        };
    }

    fn addElement(self: *anyopaque, new_element: []const u8, elem_type: pay.Elements) !void {
        const selfTyped: *Self = @ptrCast(@alignCast(self));
        switch (elem_type) {
            .item => try selfTyped.items.put(new_element, {}),
            .city => try selfTyped.cities.put(new_element, {}),
            .shop => try selfTyped.shops.put(new_element, {}),
            .method => try selfTyped.methods.put(new_element, {}),
        }
    }

    fn hasElement(self: *anyopaque, element: []const u8, elem_type: pay.Elements) bool {
        const selfTyped: *Self = @ptrCast(@alignCast(self));
        return switch (elem_type) {
            .item => selfTyped.items.contains(element),
            .city => selfTyped.cities.contains(element),
            .shop => selfTyped.shops.contains(element),
            .method => selfTyped.methods.contains(element),
        };
    }
};

test "AllPaymentBasic" {
    const allocator = std.testing.allocator;
    var allPaymentsBasic = AllPaymentsBasic.init(allocator);
    defer allPaymentsBasic.deinit();

    try pay.testImplementation(allPaymentsBasic.allPayments());
}
