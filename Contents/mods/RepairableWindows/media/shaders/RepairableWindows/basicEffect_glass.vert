#version 120

varying vec3 vertColour;
varying vec3 vertNormal;
varying vec2 texCoords;

attribute vec4 boneIndices;
attribute vec4 boneWeights;
uniform float DepthBias;
uniform mat4 MatrixPalette[60];
uniform vec2 UVScale = vec2(1,1);

void main()
{
	vec4 position = vec4(gl_Vertex.xyz, 1.0);
	vec4 normal = vec4(gl_Normal.xyz, 0.0);

	texCoords = gl_MultiTexCoord0.st * UVScale.xy;

	mat4 boneEffect = mat4(0.0);
	if(boneWeights.x > 0.0)
		boneEffect += MatrixPalette[int(boneIndices.x)] * boneWeights.x;
	if(boneWeights.y > 0.0)
		boneEffect += MatrixPalette[int(boneIndices.y)] * boneWeights.y;
	if(boneWeights.z > 0.0)
		boneEffect += MatrixPalette[int(boneIndices.z)] * boneWeights.z;
	if(boneWeights.w > 0.0)
		boneEffect += MatrixPalette[int(boneIndices.w)] * boneWeights.w;

	normal = boneEffect * normal;
	vertNormal = normal.xyz;

#if 1
	vertColour = vec3(1.0);
#else
	vec3 scalevec;
	mat4 m = boneEffect;

    scalevec.x = length(vec3(m[0][0], m[0][1], m[0][2]));
    scalevec.y = length(vec3(m[1][0], m[1][1], m[1][2]));
    scalevec.z = length(vec3(m[2][0], m[2][1], m[2][2]));
    float scale = length(scalevec);
	float blood = scale;
	blood = clamp(blood, 0.0, 0.01)  * 100.0;
	vertColour = vec3(1.0,blood,blood);
#endif

	vec4 o = gl_ModelViewProjectionMatrix * boneEffect * position;
	o.z -= DepthBias;
	gl_Position = o;
}
