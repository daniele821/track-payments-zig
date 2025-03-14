const std = @import("std");

const StringSet = std.StringHashMap(void);

const ValueSet = struct {
    allocator: std.mem.Allocator,
    cities: StringSet,
    shops: StringSet,
    methods: StringSet,
    items: StringSet,

    pub fn init(allocator: std.mem.Allocator) ValueSet {
        return .{
            .allocator = allocator,
            .cities = StringSet.init(allocator),
            .shops = StringSet.init(allocator),
            .methods = StringSet.init(allocator),
            .items = StringSet.init(allocator),
        };
    }
    pub fn deinit(self: *ValueSet) void {
        self.cities.deinit();
        self.shops.deinit();
        self.methods.deinit();
        self.items.deinit();
    }
};

const AllPayments = struct {
    allocator: std.mem.Allocator,
    value_set: ValueSet,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) AllPayments {
        return Self{
            .allocator = allocator,
            .value_set = ValueSet.init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.value_set.deinit();
    }
};

test "init" {
    const allocator = std.testing.allocator;
    var allPayments = AllPayments.init(allocator);
    defer _ = allPayments.deinit();
}
