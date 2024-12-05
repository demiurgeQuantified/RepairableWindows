#version 110

varying vec3 vertColour;
varying vec3 vertNormal;
varying vec2 texCoords;

uniform mat4 transform;
uniform float DepthBias;

uniform vec2 UVScale;

void main()
{
	vec4 position = vec4(gl_Vertex.xyz, 1);
	vec4 normal = vec4(gl_Normal.xyz, 0);

	texCoords = gl_MultiTexCoord0.st * UVScale.xy;

	vertNormal = (transform * normal).xyz;
	vertColour = vec3(1,1,1);

	vec4 o = gl_ModelViewProjectionMatrix * transform * position;
	o.z -= DepthBias;
	gl_Position = o;

}