const std = @import("std");

version: u64,
non_changing_name: []const u8,
owned_name: std.ArrayList(u8),

pub fn deinit(self: @This()) void {
    self.owned_name.deinit();
}
