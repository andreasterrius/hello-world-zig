const std = @import("std");
const Character = @import("character.zig");
const print = std.debug.print;

pub fn main() !void {
    var me = Character{
        .non_changing_name = "abc",
        .owned_name = std.ArrayList(u8).init(std.heap.page_allocator),
        .version = 123,
    };
    defer me.deinit();
    try me.owned_name.appendSlice("hello hello");

    print("me.non_changing_name: {s}\n", .{me.non_changing_name});
    print("me.owned_name: {s}\n", .{me.owned_name.items});
    print("me.version: {}\n", .{me.version});
}
