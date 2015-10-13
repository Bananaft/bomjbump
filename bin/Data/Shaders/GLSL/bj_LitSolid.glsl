#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "Lighting.glsl"


varying vec4 vCol1; // alpha stores TexCoord.x
varying vec4 vCol2; // alpha stores TexCoord.y
varying vec3 vCol3;


void VS()
{
  mat4 modelMatrix = iModelMatrix;
  vec3 worldPos = GetWorldPos(modelMatrix);
  gl_Position = GetClipPos(worldPos);

  vec3 normal = GetWorldNormal(modelMatrix);
  vec3 tangent = GetWorldTangent(modelMatrix);
  vec3 bitangent = cross(tangent, normal) * iTangent.w;



  vec3 ambientCol = GetAmbient(GetZonePos(worldPos));
  vCol1.rgb = ambientCol;
  vCol2.rgb = ambientCol;
  vCol3.rgb = ambientCol;

  #ifdef NUMVERTEXLIGHTS
      for (int i = 0; i < NUMVERTEXLIGHTS; ++i)
      {
          vCol1.rgb += GetVertexLight(i, worldPos, normal) * cVertexLights[i * 3].rgb;
          vCol2.rgb += GetVertexLight(i, worldPos, tangent) * cVertexLights[i * 3].rgb;
          vCol3.rgb += GetVertexLight(i, worldPos, bitangent) * cVertexLights[i * 3].rgb;
      }
  #endif

  vec2 TexCoord = iTexCoord;
  vCol1.a = TexCoord.x;
  vCol2.a = TexCoord.y;
}

void PS()
{
  vec4 nmMap = texture2D(sNormalMap, vec2(vCol1.a,vCol2.a));
  vec3 diffColor = vCol1.rgb * nmMap.r + vCol2.rgb * nmMap.g + vCol3.rgb * nmMap.b;

  gl_FragColor = vec4(diffColor.rgb, 0.0);
}
