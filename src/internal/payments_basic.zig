const std = @import("std");
const pay = @import("./payments.zig");

pub const AllPaymentsBasic = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) AllPaymentsBasic {
        return .{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *AllPaymentsBasic) void {
        _ = self;
    }

    pub fn allPayments(self: *AllPaymentsBasic) pay.AllPayments {
        return .{
            .ptr = self,
            .vtable = &.{
                .hasElement = hasElement,
                .addElement = addElement,
            },
        };
    }

    fn addElement(self: *anyopaque, new_element: []const u8, elem_type: pay.Elements) !void {
        _ = self;
        _ = new_element;
        _ = elem_type;
    }

    fn hasElement(self: *anyopaque, element: []const u8, elem_type: pay.Elements) bool {
        _ = self;
        _ = element;
        _ = elem_type;
        return true;
    }
};

test "AllPaymentBasic" {
    const allocator = std.testing.allocator;
    var allPaymentsBasic = AllPaymentsBasic.init(allocator);
    defer allPaymentsBasic.deinit();
    const allPayments = allPaymentsBasic.allPayments();

    try pay.testImplementation(allPayments);
}
