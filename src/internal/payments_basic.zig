const std = @import("std");
const pay = @import("./payments.zig");

pub const AllPaymentsBasic = struct {
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        _ = self;
    }

    pub fn allPayments(self: *Self) pay.AllPayments {
        return pay.AllPayments{
            .ptr = self,
            .vtable = &pay.AllPayments.Vtable{
                .hasElement = hasElement,
                .addElement = addElement,
            },
        };
    }

    pub fn addElement(self: *anyopaque, new_element: []const u8, elem_type: pay.Elements) !void {
        _ = self;
        _ = new_element;
        _ = elem_type;
    }

    pub fn hasElement(self: *anyopaque, element: []const u8, elem_type: pay.Elements) bool {
        _ = self;
        _ = element;
        _ = elem_type;
    }
};

test "AllPaymentBasic" {
    const allocator = std.testing.allocator;
    const allPaymentsBasic = AllPaymentsBasic.init(allocator);
    defer allPaymentsBasic.deinit();
    const allPayments = allPaymentsBasic.allPayments();

    pay.testImplementation(allPayments);
}
