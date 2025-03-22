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

    pub fn allPayments(self: *Self) pay.AllPayments {
        return .{
            .ptr = self,
            .vtable = &.{
                .hasElement = hasElement,
                .addElement = addElement,
            },
        };
    }

    fn addElement(self: *anyopaque, new_element: []const u8, elem_type: pay.Elements) !void {
        const selfTyped: *Self = @ptrCast(@alignCast(self));
        const stringHashMap = std.StringHashMap(void).init(selfTyped.allocator);
        _ = try selfTyped.elements.getOrPutValue(elem_type, stringHashMap);
        const stringSet = selfTyped.elements.getPtr(elem_type) orelse unreachable;
        _ = try stringSet.getOrPut(new_element);
    }

    fn hasElement(self: *anyopaque, element: []const u8, elem_type: pay.Elements) bool {
        const selfTyped: *Self = @ptrCast(@alignCast(self));
        const stringHashMap = selfTyped.elements.get(elem_type) orelse unreachable;
        return stringHashMap.contains(element);
    }
};

test "AllPaymentBasic" {
    const allocator = std.testing.allocator;
    var allPaymentsOptimized = AllPaymentsOptimized.init(allocator);
    defer allPaymentsOptimized.deinit();

    try pay.testImplementation(allPaymentsOptimized.allPayments());
}
