const std = @import("std");

pub fn main() !void {
    var al = std.ArrayList(u32).init(std.heap.page_allocator);
    for (0..100) |i| {
        if (i % 2 == 0) {
            try al.append(@intCast(u32, i));
        }
    }
    std.debug.print("{any}\n", .{al.items});
    std.debug.print("10th item: {any}", .{al.items[10]});
    defer al.deinit();
}
