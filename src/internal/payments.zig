const std = @import("std");
const builtin = @import("builtin");

pub const Elements = enum { item, city, shop, method };

pub const AllPayments = struct {
    ptr: *anyopaque,
    vtable: *const Vtable,

    const Vtable = struct {
        addElement: *const fn (ptr: *anyopaque, new_element: []const u8, elem_type: Elements) anyerror!void,
        hasElement: *const fn (ptr: *anyopaque, element: []const u8, elem_type: Elements) bool,
    };

    pub fn addElement(self: *anyopaque, new_element: []const u8, elem_type: Elements) !void {
        return self.vtable.addElement(self, new_element, elem_type);
    }

    pub fn hasElement(self: *anyopaque, element: []const u8, elem_type: Elements) bool {
        return self.vtable.hasElement(self, element, elem_type);
    }
};

pub fn testImplementation(allPayments: AllPayments) void {
    std.debug.assert(builtin.is_test);

    // try inserting some elements
    allPayments.addElement("Item", Elements.item);
    allPayments.addElement("City", Elements.city);
    allPayments.addElement("Shop", Elements.shop);
    allPayments.addElement("Method", Elements.method);
    try std.testing.assert(allPayments.hasElement("Item", Elements.item));
    try std.testing.assert(allPayments.hasElement("City", Elements.city));
    try std.testing.assert(allPayments.hasElement("Shop", Elements.shop));
    try std.testing.assert(allPayments.hasElement("Method", Elements.method));
}
