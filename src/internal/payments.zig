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

pub fn testImplementation(allPayments: AllPayments) !void {
    std.debug.assert(builtin.is_test);

    // try inserting some elements
    inline for (std.meta.fields(Elements)) |elem| {
        try allPayments.addElement(elem.name, @enumFromInt(elem.value));
        try std.testing.expect(allPayments.hasElement(elem.name, @enumFromInt(elem.value)));
    }
}
