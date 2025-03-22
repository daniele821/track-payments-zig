const std = @import("std");

pub fn Iterator(T: type) type {
    return struct {
        ptr: *anyopaque,
        vtable: *const Vtable,

        const Self = @This();

        pub const Vtable = struct {
            next: *const fn (self: *anyopaque) ?*T,
        };

        pub fn next(self: Self) ?*T {
            return self.vtable.next(self);
        }
    };
}
