const App = @import("app.zig").App;
const httpz = @import("httpz");

pub fn register(_: *App, _: *httpz.Request, res: *httpz.Response) !void {
    res.status = 200;
    res.body = "pewpewpew";
}

pub fn login(_: *App, _: *httpz.Request, res: *httpz.Response) !void {
    res.status = 200;
    res.body = "pewpewpew";
}
