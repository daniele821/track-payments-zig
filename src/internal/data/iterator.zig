const std = @import("std");

pub fn Iterator(T: type) type {
    return struct {
        ptr: *anyopaque,
        vtable: *const Vtable,

        const Self = @This();

        pub const Vtable = struct {
            next: *const fn (self: *anyopaque) ?*const T,
            elem_left: *const fn (self: *anyopaque) u32,
        };

        pub fn next(self: Self) ?*const T {
            return self.vtable.next(self.ptr);
        }
    };
}

pub fn IterGen(T: type) type {
    return struct {
        ptr: *anyopaque,
        vtable: *const Vtable,

        const Self = @This();

        pub const Vtable = struct {
            iterator: *const fn (self: *anyopaque) Iterator(T),
            sorted_iterator: *const fn (self: *anyopaque, from: ?*const T, to: ?*const T) Iterator(T),
        };

        pub fn iterator(self: Self) Iterator(T) {
            return self.vtable.iterator(self.ptr);
        }

        pub fn sorted_iterator(self: Self, from: ?*const T, to: ?*const T) Iterator(T) {
            return self.vtable.sorted_iterator(self.ptr, from, to);
        }
    };
}
