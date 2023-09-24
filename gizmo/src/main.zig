const std = @import("std");
const raylib = @import("raylib");
const Gizmo = @import("transform_gizmo.zig");

const Object = struct {
    position: raylib.Vector3,
    model: raylib.Model,
};

pub fn main() !void {

    // Window Creation
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.InitWindow(800, 800, "hello world!");
    defer raylib.CloseWindow();
    raylib.SetTargetFPS(60);

    var camera = raylib.Camera3D{
        .position = .{ .x = 2.0, .y = 4.0, .z = -10.0 },
        .target = raylib.Vector3.zero(),
        .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .fovy = 45.0,
        .projection = .CAMERA_PERSPECTIVE,
    };

    var object = Object{
        .position = raylib.Vector3.zero(),
        .model = raylib.LoadModelFromMesh(raylib.GenMeshCube(1.0, 1.0, 1.0)),
    };

    var gizmo = try Gizmo.init();
    defer gizmo.deinit();

    while (!raylib.WindowShouldClose()) {
        raylib.UpdateCamera(&camera, .CAMERA_THIRD_PERSON);

        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.SKYBLUE);
        raylib.DrawFPS(10, 10);

        if (raylib.IsMouseButtonDown(.MOUSE_BUTTON_LEFT)) {
            gizmo.tryHold(camera, &object.position);
        } else {
            gizmo.release();
        }

        raylib.DrawText("gizmo demo!", 100, 100, 20, raylib.YELLOW);
        raylib.BeginMode3D(camera);
        defer raylib.EndMode3D();

        gizmo.render();
        raylib.DrawModel(object.model, object.position, 1.0, raylib.WHITE);
        raylib.DrawGrid(10, 1.0);
    }
}
