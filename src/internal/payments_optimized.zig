const std = @import("std");
const pay = @import("./payments.zig");

pub const AllPaymentsOptimized = struct {
    allocator: std.mem.Allocator,
    elements: std.AutoHashMap(pay.Elements, std.StringHashMap(void)),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
            .elements = std.AutoHashMap(pay.Elements, std.StringHashMap(void)).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        var elemIter = self.elements.valueIterator();
        while (elemIter.next()) |elemPtr| {
            elemPtr.deinit();
        }
        self.elements.deinit();
    }
};

test "AllPaymentBasic" {
    const allocator = std.testing.allocator;
    var allPaymentsOptimized = AllPaymentsOptimized.init(allocator);
    defer allPaymentsOptimized.deinit();

    // pay.testImplementation(allPaymentsOptimized);
}
