const std = @import("std");
const raylib = @import("raylib");

const ActiveAxis = enum { X, Y, Z, XY, XZ, YZ };

const InitialClickInfo = struct {
    activeAxis: ActiveAxis,
    position: raylib.Vector3,
};

// 3D world direction
xArrowDir: raylib.Vector3 = .{ .x = 1.0, .y = 0.0, .z = 0.0 },
yArrowDir: raylib.Vector3 = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
zArrowDir: raylib.Vector3 = .{ .x = 0.0, .y = 0.0, .z = 1.0 },

// Meshes
arrowXModel: raylib.Model,
arrowYModel: raylib.Model,
arrowZModel: raylib.Model,
planeXYModel: raylib.Model,
planeXZModel: raylib.Model,
planeYZModel: raylib.Model,

// State
position: raylib.Vector3,

// if not null, then user has selected one of the axis
initialClickInfo: ?InitialClickInfo,

pub fn init() !@This() {
    var arrowXModel = raylib.LoadModel("resources/translate_gizmo/Arrow_X+.glb");
    var arrowYModel = raylib.LoadModel("resources/translate_gizmo/Arrow_Y+.glb");
    var arrowZModel = raylib.LoadModel("resources/translate_gizmo/Arrow_Z+.glb");
    var planeXYModel = raylib.LoadModel("resources/translate_gizmo/Plane_XY.glb");
    var planeXZModel = raylib.LoadModel("resources/translate_gizmo/Plane_XZ.glb");
    var planeYZModel = raylib.LoadModel("resources/translate_gizmo/Plane_YZ.glb");

    // load a flat shader here ?
    // the default raylib shader is flat though

    return @This(){
        .arrowXModel = arrowXModel,
        .arrowYModel = arrowYModel,
        .arrowZModel = arrowZModel,
        .planeXYModel = planeXYModel,
        .planeXZModel = planeXZModel,
        .planeYZModel = planeYZModel,
        .position = raylib.Vector3.zero(),
        .initialClickInfo = null,
    };
}

/// This usually happens when user press and holding left click (handled by caller)
/// This function is paired with release()
pub fn tryHold(self: *@This(), camera: raylib.Camera3D) void {
    var mousePos = raylib.GetMousePosition();
    var ray = raylib.GetMouseRay(mousePos, camera);
    var rayHit = self.*.getCollisionHit(ray);

    if (rayHit != null and self.initialClickInfo == null) {
        // this is initial click, let's save the initial clickInfo
        self.*.initialClickInfo = .{
            .activeAxis = rayHit.?.activeAxis,
            .position = rayHit.?.rayCollision.point,
        };

        var p = rayHit.?.rayCollision.point;
        std.debug.print("{}\n", .{p});
    } else if (self.initialClickInfo.* != null) {
        // this is no longer initial hit, but is a dragging movement
        // TODO: get a ray to plane intersection. the plane should be the axis
        var rayPlaneHit = raylib.Vector3.zero();

        var initialOffset = self.*.initialClickInfo.?.position - self.*.position;
        _ = initialOffset;

        var draggingOffset = raylib.Vector3.zero();
        _ = draggingOffset;
        
        self.*.position = rayPlaneHit - 
    }
}

/// Release the gizmo, usually when user stop holding left click (handled by caller)
/// This function is paired with tryHold()
pub fn release(self: *@This()) void {
    self.*.initialClickInfo = null;
}

fn getCollisionHit(self: @This(), ray: raylib.Ray) ?struct { rayCollision: raylib.RayCollision, activeAxis: ActiveAxis } {
    var transform = raylib.MatrixTranslate(self.position.x, self.position.y, self.position.z);
    var coll = raylib.GetRayCollisionMesh(ray, self.arrowXModel.meshes.?[0], transform);
    if (coll.hit) {
        return .{ .rayCollision = coll, .activeAxis = .X };
    }
    coll = raylib.GetRayCollisionMesh(ray, self.arrowYModel.meshes.?[0], transform);
    if (coll.hit) {
        return .{ .rayCollision = coll, .activeAxis = .Y };
    }
    coll = raylib.GetRayCollisionMesh(ray, self.arrowZModel.meshes.?[0], transform);
    if (coll.hit) {
        return .{ .rayCollision = coll, .activeAxis = .Z };
    }

    return null;
}

fn rayPlaneIntersection(activeAxis: ActiveAxis) raylib.RayCollision {
    // Function to find the intersection of a ray with the XY plane (z=0)

}

pub fn tick(self: *@This()) void {
    _ = self;
}

pub fn render(self: @This()) void {
    // Must be called inside BeginMode3D render
    raylib.DrawModel(self.arrowXModel, raylib.Vector3.zero(), 1.0, raylib.RED);
    raylib.DrawModel(self.arrowYModel, raylib.Vector3.zero(), 1.0, raylib.GREEN);
    raylib.DrawModel(self.arrowZModel, raylib.Vector3.zero(), 1.0, raylib.BLUE);
    raylib.DrawModel(self.planeXYModel, raylib.Vector3.zero(), 1.0, raylib.BLUE);
    raylib.DrawModel(self.planeXZModel, raylib.Vector3.zero(), 1.0, raylib.GREEN);
    raylib.DrawModel(self.planeYZModel, raylib.Vector3.zero(), 1.0, raylib.RED);
}

pub fn deinit(self: @This()) void {
    raylib.UnloadModel(self.arrowXModel);
    raylib.UnloadModel(self.arrowYModel);
    raylib.UnloadModel(self.arrowZModel);
    raylib.UnloadModel(self.planeXYModel);
    raylib.UnloadModel(self.planeXZModel);
    raylib.UnloadModel(self.planeYZModel);
}
