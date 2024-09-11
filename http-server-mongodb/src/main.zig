//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const httpz = @import("httpz");

const users = @import("users.zig");
const App = @import("app.zig").App;

const c = @cImport({
    @cInclude("mongoc.h");
});

fn home(_: *App, _: *httpz.Request, res: *httpz.Response) !void {
    res.status = 200;
    res.body = "pewpewpew";
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // mongo connection
    c.mongoc_init();
    defer c.mongoc_cleanup();
    //TODO: connect with user and password.
    var err: c.bson_error_t = undefined;
    const uri = c.mongoc_uri_new_with_error("mongodb://localhost:27017", &err);
    _ = c.mongoc_client_new_from_uri(uri);

    // http server declaration
    var app = App{};
    var server = try httpz.Server(*App).init(allocator, .{ .port = 8080 }, &app);
    var router = server.router(.{});

    // router to register, login
    router.get("/auth/register", users.register, .{});
    router.get("/auth/login", users.login, .{});

    try server.listen();
}
