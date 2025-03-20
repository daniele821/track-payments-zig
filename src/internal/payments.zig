const std = @import("std");

const Elements = enum { items, cities, shops, methods };

const Vtable = struct {
    addElement: *const fn (ptr: *anyopaque, new_element: []const u8, elem_type: Elements) void,
    hasElement: *const fn (ptr: *anyopaque, element: []const u8, elem_type: Elements) bool,
};

pub const AllPayments = struct {
    ptr: *anyopaque,
    vtable: *const Vtable,

    pub const Self = @This();

    pub fn addElement(self: *Self, new_element: []const u8, elem_type: Elements) void {
        return self.vtable.addElement(self, new_element, elem_type);
    }

    pub fn hasElement(self: *Self, element: []const u8, elem_type: Elements) bool {
        return self.vtable.hasElement(self, element, elem_type);
    }
};
