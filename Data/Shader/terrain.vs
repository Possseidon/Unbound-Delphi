#version 430

uniform mat3 model_rmatrix;
uniform mat4 model_matrix:
uniform mat4 mvp_matrix;

in vec3 vpos;
// in vec2 vtexcoord;
// in vec3 vnormal;
in vec3 vcolor;

/*
out vec3 fpos;
out vec2 ftexcoord;
out vec3 fnormal;
*/
out vec3 fcolor;

void main()
{
  /*
  vec4 p = model_matrix * vec4(vpos, 1);
  fpos = p.xyz / p.w;
  ftexcoord = vtexcoord;
  fnormal = normalize(model_rmatrix * vnormal);
  */
  fcolor = vcolor;
  gl_Position = mvp_matrix * vec4(vpos, 1);
}

