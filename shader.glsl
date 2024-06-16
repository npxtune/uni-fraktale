#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Output fragment color
out vec4 finalColor;

uniform vec2 offset;            // Offset of the scale.
uniform float zoom;             // Zoom of the scale.

const int maxIterations = 512;  // Max iterations to do.
const float colorCycles = 20.0f; // Number of times the color palette repeats. Can show higher detail for higher iteration numbers.
const float dbail = 1e6;        // Derivative bailout value.

// Convert Hue Saturation Value (HSV) color into RGB
vec3 Hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0f, 0.f, 1.0f/3.f, 3.0f);
    vec3 p = abs(fract(c.xxx + K.xyz)*6.0f - K.www);
    return c.z*mix(K.xxx, clamp(p - K.xxx, 0.0f, 1.0f), c.y);
}

void main()
{
    vec2 c = vec2((fragTexCoord.x - 0.5f) * 2.5f, (fragTexCoord.y - 0.5f) * 1.5f) / zoom;
    c.x += offset.x;
    c.y += offset.y;

    vec2 z = vec2(0.0f, 0.0f);
    vec2 dz = vec2(0.0f, 0.0f);
    vec2 epsilon = vec2(0.0f, 0.0f);

    int iterations = 0;
    for (iterations = 0; iterations < maxIterations; iterations++)
    {
        dz = (2.0f * z * dz) + vec2(1.0f, 0.0f);
        z = vec2(z.x * z.x - z.y * z.y, 2.0f * z.x * z.y) + c;

        epsilon = vec2(2.0f * z.x * epsilon.x - 2.0f * z.y * epsilon.y, 2.0f * z.x * epsilon.y + 2.0f * z.y * epsilon.x) + dz;

        if (length(dz) > dbail) break;
    }

    float smoothVal = float(iterations) + 1.0 - (log(log(length(z))) / log(2.0));
    float norm = smoothVal / float(maxIterations);

    if (norm > 0.999f) finalColor = vec4(0.0f, 0.0f, 0.0f, 1.0f);
    else finalColor = vec4(Hsv2rgb(vec3(norm * colorCycles, 1.0f, 1.0f)), 1.0f);
}
