const std = @import("std");

version: u64,
non_changing_name: []const u8,
owned_name: std.ArrayList(u8),

pub fn deinit(self: @This()) void {
    self.owned_name.deinit();
}

pub fn addToName(self: *@This(), arr: []const u8) !void {
    try self.owned_name.appendSlice(arr);
}
