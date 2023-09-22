const std = @import("std");
const raylib = @import("raylib");
const Character = @import("character.zig");
const Scene = @import("scene.zig").Scene;
const Gizmo = @import("3dgizmo.zig");

// physics import
const phys = @import("physics.zig");
const Physics = phys.Physics;
const zphy = @import("zphysics");

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

        raylib.SetWindowSize(1024, 1024);

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

const StaticMeshObject = struct {
    position: raylib.Vector3,
    model: raylib.Model,
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

    var blinnPhong = raylib.LoadShader("resources/blinn.vs", "resources/blinn.fs");
    defer raylib.UnloadShader(blinnPhong);

    blinnPhong.locs.?[@intFromEnum(raylib.ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW)] = raylib.GetShaderLocation(blinnPhong, "viewPos");
    var ambientLoc = raylib.GetShaderLocation(blinnPhong, "ambient");
    raylib.SetShaderValue(blinnPhong, ambientLoc, &[_]f32{ 0.1, 0.1, 0.1, 0.1 }, .SHADER_UNIFORM_VEC4);

    plane.materials.?[0].shader = blinnPhong;

    var char = Character.init(
        raylib.Vector3{ .x = 0.0, .y = 0.0, .z = 0.0 },
        raylib.LoadModelFromMesh(raylib.GenMeshCube(2.0, 4.0, 2.0)),
        blinnPhong,
    );
    defer char.deinit();

    //var staticModels = raylib.LoadModel("resources/assets/kenney_survival_kit/Models/GLTF format/sc.glb");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    //var staticModels = raylib.LoadModel("resources/assets/kenney_survival_kit/Scene/simple.glb");
    var sceneComplete = raylib.LoadModel("resources/scene/TranslateGizmo.glb");
    _ = sceneComplete;
    //var scene = try Scene.load(allocator, "resources/scene/basic.blend.json");
    //defer scene.deinit();

    var gizmo = try Gizmo.init();
    defer gizmo.deinit();

    var lights = [_]Light{
        Light{ .enabled = true, .type = LightType.POINT_LIGHT, .position = .{ .x = -2, .y = 1, .z = -2 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .color = raylib.YELLOW },
        Light{ .enabled = true, .type = LightType.POINT_LIGHT, .position = .{ .x = 2, .y = 1, .z = 2 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .color = raylib.RED },
        Light{ .enabled = true, .type = LightType.POINT_LIGHT, .position = .{ .x = -2, .y = 1, .z = 2 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .color = raylib.GREEN },
        Light{ .enabled = true, .type = LightType.POINT_LIGHT, .position = .{ .x = 2, .y = 1, .z = -2 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .color = raylib.BLUE },
    };

    var physics = try Physics.init(allocator);
    defer physics.deinit();

    const body_interface = physics.physics_system.getBodyInterfaceMut();

    const floor_shape_settings = try zphy.BoxShapeSettings.create(.{ 100.0, 1.0, 100.0 });
    defer floor_shape_settings.release();

    const floor_shape = try floor_shape_settings.createShape();
    defer floor_shape.release();

    _ = try body_interface.createAndAddBody(.{
        .position = .{ 0.0, -1.0, 0.0, 1.0 },
        .rotation = .{ 0.0, 0.0, 0.0, 1.0 },
        .shape = floor_shape,
        .motion_type = .static,
        .object_layer = phys.object_layers.non_moving,
    }, .activate);

    const box_shape_settings = try zphy.BoxShapeSettings.create(.{ 0.5, 0.5, 0.5 });
    defer box_shape_settings.release();

    const box_shape = try box_shape_settings.createShape();
    defer box_shape.release();

    // for (0..scene.objects.items.len) |i| {
    //     // scene.objects.items[i].addPhysicsBody(try body_interface.createAndAddBody(.{
    //     //     .position = .{ scene.objects.items[i].position.x, scene.objects.items[i].position.y, scene.objects.items[i].position.z, 0.0 },
    //     //     .rotation = .{ 0.0, 0.0, 0.0, 1.0 },
    //     //     .shape = box_shape,
    //     //     .motion_type = .dynamic,
    //     //     .object_layer = phys.object_layers.moving,
    //     //     .angular_velocity = .{ 0.0, 0.0, 0.0, 0 },
    //     //     //.allow_sleeping = false,
    //     // }, .activate));

    //     scene.objects.items[i].model.materials.?[0].shader = blinnPhong;
    // }

    // physics.physics_system.optimizeBroadPhase();

    var ray: ?raylib.Ray = null;
    while (!raylib.WindowShouldClose()) {
        var dt = raylib.GetFrameTime();

        // Input
        char.handleInput();

        // Tick
        // char.updateCharacter(dt);
        char.updateCamera(dt);

        // Physics Tick
        if (char.physicsSim) {
            physics.physics_system.update(dt, .{}) catch unreachable;
        }

        // Render
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.BLACK);
        raylib.DrawFPS(10, 10);

        raylib.BeginMode3D(char.getCamera());
        defer raylib.EndMode3D();

        raylib.UpdateCamera(&char.camera, .CAMERA_FREE);
        //char.useCamera(blinnPhong);

        if (raylib.IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) {
            ray = raylib.GetMouseRay(raylib.GetMousePosition(), char.camera);
        }

        if (ray != null) {
            // std.debug.print("pos:{} dir:{}\n", .{ char.camera.position, ray.direction });
            raylib.DrawSphere(ray.?.position, 1, raylib.WHITE);
            raylib.DrawRay(ray.?, raylib.PURPLE);
        }

        // for (0..scene.objects.items.len) |i| {
        //     // update position from physics engine first, before rendering
        //     // var ppos = body_interface.getPosition(scene.objects.items[i].physicsBodyId.?);
        //     // scene.objects.items[i].position = raylib.Vector3{ .x = ppos[0], .y = ppos[1], .z = ppos[2] };

        //     raylib.DrawModel(scene.objects.items[i].model, scene.objects.items[i].position, 1.0, raylib.WHITE);
        // }
        gizmo.render();
        //raylib.DrawModel(sceneComplete, raylib.Vector3.zero(), 1.0, raylib.WHITE);

        for (0..lights.len) |i| {
            try lights[i].UpdateLightValues(blinnPhong, @as(i32, @intCast(i)));
            raylib.DrawSphereEx(lights[i].position, 0.2, 8, 8, lights[i].color);
        }

        raylib.DrawModel(plane, .{ .x = 0.0, .y = 0.0, .z = 0.0 }, 1.0, raylib.WHITE);
        char.render();
        raylib.DrawGrid(10, 1.0);
    }
}
