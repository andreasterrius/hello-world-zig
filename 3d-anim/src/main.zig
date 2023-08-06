const std = @import("std");
const raylib = @import("raylib");

pub fn main() !void {
    raylib.InitWindow(1024, 800, "3D Anim");
    defer raylib.CloseWindow();

    raylib.SetConfigFlags(.{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.SetTargetFPS(60);

    var camera: raylib.Camera3D = .{
        .position = .{ .x = 10.0, .y = 20.0, .z = 10.0 },
        .target = .{ .x = 0.0, .y = 5.0, .z = 0.0 },
        .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .fovy = 45.0,
        .projection = .CAMERA_PERSPECTIVE,
    };

    var guy = raylib.LoadModel("resources/anim/guy.iqm");
    defer raylib.UnloadModel(guy);
    var guyTexture = raylib.LoadTexture("resources/anim/guytex.png");
    defer raylib.UnloadTexture(guyTexture);
    raylib.SetMaterialTexture(guy.materials, raylib.MATERIAL_MAP_DIFFUSE, guyTexture);

    //TODO: This should be just a ?*u32 no ?
    var animsCount: u32 = 0;
    var anims = raylib.LoadModelAnimations("resources/anim/guyanim.iqm", @as(?[*]u32, @ptrCast(&animsCount)));
    defer raylib.UnloadModelAnimations(anims, animsCount);
    var animFrameCounter: u64 = 0;

    raylib.DisableCursor();
    raylib.SetTargetFPS(60);

    while (!raylib.WindowShouldClose()) {
        raylib.UpdateCamera(&camera, .CAMERA_ORBITAL);

        if (raylib.IsKeyDown(.KEY_SPACE)) {
            animFrameCounter += 1;
            raylib.UpdateModelAnimation(guy, anims.?[0], @as(i32, @intCast(animFrameCounter)));
            if (animFrameCounter >= anims.?[0].frameCount) animFrameCounter = 0;
        }

        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);
        raylib.DrawText("Testing", 10, 10, 20, raylib.MAROON);

        raylib.BeginMode3D(camera);
        defer raylib.EndMode3D();

        raylib.DrawModelEx(
            guy,
            raylib.Vector3{ .x = 0.0, .y = 0.0, .z = 0.0 },
            raylib.Vector3{ .x = 1.0, .y = 0.0, .z = 0.0 },
            -90.0,
            raylib.Vector3{ .x = 1.0, .y = 1.0, .z = 1.0 },
            raylib.WHITE,
        );
        for (0..@as(usize, @intCast(guy.boneCount))) |i| {
            raylib.DrawCube(anims.?[0].framePoses.?[animFrameCounter][i].translation, 0.2, 0.2, 0.2, raylib.RED);
        }

        raylib.DrawGrid(10, 1.0);
    }
}
