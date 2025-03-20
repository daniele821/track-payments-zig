const std = @import("std");

const Elements = enum { items, cities, shops, methods };

const Vtable = struct {
    addElement: *const fn (ptr: *anyopaque, new_element: []const u8, type: Elements) void,
};

pub const AllPayments = struct {
    ptr: *anyopaque,
    vtable: *const Vtable,
};
