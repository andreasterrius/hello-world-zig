const std = @import("std");

// Not sure how can I make string parsed to enum directly or whether it's even possible.
const Method = enum{
    Get,
    Post,
};

const EventInfo = struct {
    apiInfo: ApiInfo,
    isEnabled: bool,
    lastElapsedTime : f32,
    count: i32,
};

const ApiInfo = struct {
    url : []const u8,
    method : []const u8,
};

const Api = struct {
    api: []EventInfo,
};

const Something = struct {
    api: []i32,
};

const MethodTest = struct {
    method: Method
};

pub fn readSimple(path: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const data = try std.fs.cwd().readFileAlloc(allocator, path, 512);
    defer allocator.free(data);

    const api = try std.json.parseFromSlice(Something, allocator, data, .{});
    defer api.deinit();

    std.debug.print("{any}\n", .{api.value});
}

pub fn readComplex(path: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const data = try std.fs.cwd().readFileAlloc(allocator, path, 512);
    defer allocator.free(data);

    const api = try std.json.parseFromSlice(Api, allocator, data, .{});
    defer api.deinit();

    std.debug.print("{any}\n", .{api.value});
}

pub fn readEnum(path: []const u8) ! void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const data = try std.fs.cwd().readFileAlloc(allocator, path, 512);
    defer allocator.free(data);

    const api = try std.json.parseFromSlice(MethodTest, allocator, data, .{});
    defer api.deinit();

    std.debug.print("{any}\n", .{api.value});
}

pub fn main() !void {
    try readComplex("try-json-read.json");
    try readSimple("try-json-read2.json");
    try readSimple("try-json-read3.json");
    try readEnum("try-json-enum.json");
}
