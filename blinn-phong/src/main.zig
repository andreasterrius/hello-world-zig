const std = @import("std");
const raylib = @import("raylib");

const Light = extern struct { //extern for C ABI
    enabled: bool,
    type: LightType,
    position: raylib.Vector3,
    target: raylib.Vector3,
    color: raylib.Color,
    fn UpdateLightValues(self: *Light, shader: raylib.Shader, lightsCount: i32) !void {
        var buf: [50]u8 = undefined;

        var enabledLoc = raylib.GetShaderLocation(shader, try std.fmt.bufPrintZ(&buf, "lights[{}].enabled", .{lightsCount}));
        var typeLoc = raylib.GetShaderLocation(shader, try std.fmt.bufPrintZ(&buf, "lights[{}].type", .{lightsCount}));
        var positionLoc = raylib.GetShaderLocation(shader, try std.fmt.bufPrintZ(&buf, "lights[{}].position", .{lightsCount}));
        var targetLoc = raylib.GetShaderLocation(shader, try std.fmt.bufPrintZ(&buf, "lights[{}].target", .{lightsCount}));
        var colorLoc = raylib.GetShaderLocation(shader, try std.fmt.bufPrintZ(&buf, "lights[{}].color", .{lightsCount}));

        raylib.SetShaderValue(shader, enabledLoc, &self.enabled, .SHADER_UNIFORM_INT);
        raylib.SetShaderValue(shader, typeLoc, &self.type, .SHADER_UNIFORM_INT);
        var position = [_]f32{ self.position.x, self.position.y, self.position.z };
        raylib.SetShaderValue(shader, positionLoc, &position, .SHADER_UNIFORM_VEC3);
        var target = [_]f32{ self.target.x, self.target.y, self.target.z };
        raylib.SetShaderValue(shader, targetLoc, &target, .SHADER_UNIFORM_VEC3);
        var color = [_]f32{
            @as(f32, @floatFromInt(self.color.r)) / 255.0,
            @as(f32, @floatFromInt(self.color.g)) / 255.0,
            @as(f32, @floatFromInt(self.color.b)) / 255.0,
            @as(f32, @floatFromInt(self.color.a)) / 255.0,
        };
        raylib.SetShaderValue(shader, colorLoc, &color, .SHADER_UNIFORM_VEC4);
    }
};

const LightType = enum(i32) {
    DIRECTIONAL_LIGHT = 0,
    POINT_LIGHT = 1,
};

pub fn main() !void {
    raylib.InitWindow(1024, 800, "Blinn Phong");
    defer raylib.CloseWindow();

    raylib.SetConfigFlags(.{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.SetTargetFPS(60);

    var plane = raylib.LoadModelFromMesh(raylib.GenMeshPlane(10.0, 10.0, 3, 3));
    defer raylib.UnloadModel(plane);
    var cube = raylib.LoadModelFromMesh(raylib.GenMeshCube(2.0, 4.0, 2.0));
    defer raylib.UnloadModel(cube);

    var blinnPhong = raylib.LoadShader("resources/blinn.vs", "resources/blinn.fs");
    defer raylib.UnloadShader(blinnPhong);

    blinnPhong.locs.?[@intFromEnum(raylib.ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW)] = raylib.GetShaderLocation(blinnPhong, "viewPos");
    var ambientLoc = raylib.GetShaderLocation(blinnPhong, "ambient");
    raylib.SetShaderValue(blinnPhong, ambientLoc, &[_]f32{ 0.1, 0.1, 0.1, 0.1 }, .SHADER_UNIFORM_VEC4);

    plane.materials.?[0].shader = blinnPhong;
    cube.materials.?[0].shader = blinnPhong;

    var camera: raylib.Camera3D = .{
        .position = .{ .x = 2.0, .y = 4.0, .z = 6.0 },
        .target = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .fovy = 45.0,
        .projection = .CAMERA_PERSPECTIVE,
    };

    var lights = [_]Light{
        Light{ .enabled = true, .type = LightType.POINT_LIGHT, .position = .{ .x = -2, .y = 1, .z = -2 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .color = raylib.YELLOW },
        Light{ .enabled = true, .type = LightType.POINT_LIGHT, .position = .{ .x = 2, .y = 1, .z = 2 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .color = raylib.RED },
        Light{ .enabled = true, .type = LightType.POINT_LIGHT, .position = .{ .x = -2, .y = 1, .z = 2 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .color = raylib.GREEN },
        Light{ .enabled = true, .type = LightType.POINT_LIGHT, .position = .{ .x = 2, .y = 1, .z = -2 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .color = raylib.BLUE },
    };

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.DARKBLUE);
        raylib.DrawFPS(10, 10);

        raylib.BeginMode3D(camera);
        defer raylib.EndMode3D();

        raylib.UpdateCamera(&camera, .CAMERA_ORBITAL);

        var cameraPos = [_]f32{ camera.position.x, camera.position.y, camera.position.z };
        raylib.SetShaderValue(blinnPhong, blinnPhong.locs.?[@intFromEnum(raylib.ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW)], &cameraPos, .SHADER_UNIFORM_VEC3);

        for (0..lights.len) |i| {
            try lights[i].UpdateLightValues(blinnPhong, @as(i32, @intCast(i)));
            raylib.DrawSphereEx(lights[i].position, 0.2, 8, 8, lights[i].color);
        }

        raylib.DrawModel(plane, .{ .x = 0.0, .y = 0.0, .z = 0.0 }, 1.0, raylib.WHITE);
        raylib.DrawModel(cube, .{ .x = 0.0, .y = 0.0, .z = 0.0 }, 1.0, raylib.WHITE);
        raylib.DrawGrid(10, 1.0);
    }
}
