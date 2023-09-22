const std = @import("std");
const raylib = @import("raylib");

arrowXModel: raylib.Model,
arrowYModel: raylib.Model,
arrowZModel: raylib.Model,
planeXYModel: raylib.Model,
planeXZModel: raylib.Model,
planeYZModel: raylib.Model,
location: raylib.Vector3,

pub fn init() !@This() {
    var arrowXModel = raylib.LoadModel("resources/translate_gizmo/Arrow_X+.glb");
    var arrowYModel = raylib.LoadModel("resources/translate_gizmo/Arrow_Y+.glb");
    var arrowZModel = raylib.LoadModel("resources/translate_gizmo/Arrow_Z+.glb");
    var planeXYModel = raylib.LoadModel("resources/translate_gizmo/Plane_XY.glb");
    var planeXZModel = raylib.LoadModel("resources/translate_gizmo/Plane_XZ.glb");
    var planeYZModel = raylib.LoadModel("resources/translate_gizmo/Plane_YZ.glb");

    // load a flat shader here ?

    return @This(){
        .arrowXModel = arrowXModel,
        .arrowYModel = arrowYModel,
        .arrowZModel = arrowZModel,
        .planeXYModel = planeXYModel,
        .planeXZModel = planeXZModel,
        .planeYZModel = planeYZModel,
        .location = raylib.Vector3.zero(),
    };
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
