#version 330

in vec3 pos;
in vec2 uv;
in vec3 normal;
in vec4 color;

uniform mat4 mvp;
uniform mat4 matModel;
uniform mat4 matNormal;

out vec3 fragPos;
out vec2 fragUv;
out vec4 fragColor;
out vec3 fragNormal;

void main(){
    fragPos = vec3(matModel * vec4(pos, 1.0));
    fragUv = uv;
    fragColor = color;
    fragNormal = normalize(vec3(matNormal*vec4(normal, 1.0)));

    gl_Position = mvp*vec4(pos, 1.0);
}