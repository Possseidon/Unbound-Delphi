#version 430


in vec3 fpos;
in vec2 ftexcoord;
in vec3 fnormal;
in vec3 fcolor;
in vec3 fsmooth;

out vec4 outcolor;

void main()
{
  outcolor = fcolor;
}

