const std = @import("std");
const builtin = @import("builtin");

pub const Elements = enum { item, city, shop, method };

pub const AllPayments = struct {
    ptr: *anyopaque,
    vtable: *const Vtable,

    pub const Vtable = struct {
        addElement: *const fn (ptr: *anyopaque, new_element: []const u8, elem_type: Elements) anyerror!void,
        hasElement: *const fn (ptr: *anyopaque, element: []const u8, elem_type: Elements) bool,
    };

    pub fn addElement(self: AllPayments, new_element: []const u8, elem_type: Elements) !void {
        return self.vtable.addElement(self.ptr, new_element, elem_type);
    }

    pub fn hasElement(self: AllPayments, element: []const u8, elem_type: Elements) bool {
        return self.vtable.hasElement(self.ptr, element, elem_type);
    }
};

pub fn testImplementation(allPayments: AllPayments) void {
    std.debug.assert(builtin.is_test);

    // try inserting some elements
    try allPayments.addElement("Item", Elements.item);
    try allPayments.addElement("City", Elements.city);
    try allPayments.addElement("Shop", Elements.shop);
    try allPayments.addElement("Method", Elements.method);
    try std.testing.assert(allPayments.hasElement("Item", Elements.item));
    try std.testing.assert(allPayments.hasElement("City", Elements.city));
    try std.testing.assert(allPayments.hasElement("Shop", Elements.shop));
    try std.testing.assert(allPayments.hasElement("Method", Elements.method));
}
