#version 330

#define PI 3.141592653589793238

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Output fragment color
out vec4 finalColor;

uniform vec2 offset;            // Offset of the scale.
uniform float zoom;             // Zoom of the scale.
uniform int fractalType;        // Fractal type (1: Mandelbrot, 2: Julia, 3: Koch)

uniform int recursionCount;

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

// Returns a normalized direction based on an angle
vec2 polarToCartesian(float angle) {
    return vec2(sin(angle), cos(angle));
}

// Reflects the UV based on a reflection line centered in the point p with a given angle
vec2 ref(vec2 uv, vec2 p, float angle) {
    vec2 dir = polarToCartesian(angle); // Direction of the reflection line
    return uv - dir * min(dot(uv - p, dir), 0.0) * 2.0; // Returns the reflected uv coordinate
}

// Folds the 2D space to generate the fractal and returns the distance to it
float kochsCurve(inout vec2 uv, int recursionCount) {
    float scale = 1.25; // Scale of the UV
    uv *= scale; // Scales the UV to make the fractal fit on the screen

    // This is here so that the first image is a straight line in the center
    if (recursionCount >= 0) {
        uv.y -= sqrt(3.0) / 6.0; // Translates the Y coordinate up
        uv.x = abs(uv.x); // Makes a reflection line in the Y axis
        uv = ref(uv, vec2(0.5, 0), 11.0 / 6.0 * PI); // Makes a reflection line to form a triangle
        uv.x += 0.5; // Translates the X coordinate to the center of the line
    }

    for (int i = 0; i < recursionCount; ++i) {
        uv.x -= 0.5; // Translates the X coordinate
        scale *= 3.0; // Increases the scale for each recursion loop
        uv *= 3.0; // Scales down the shape
        uv.x = abs(uv.x); // Creates a reflection line in the Y axis
        uv.x -= 0.5; // Translates the X coordinate
        uv = ref(uv, vec2(0, 0), (2.0 / 3.0) * PI); // Creates an angled reflection line to form the triangle
    }

    uv.x = abs(uv.x); // Creates a reflection line in the Y axis
    float d = length(uv - vec2(min(uv.x, 1.0), 0.0)) / scale; // Calculates distance to the fractal
    uv /= scale; // Resets the scaling in the uv
    return d; // Returns the distance
}

void main()
{
    vec2 c = vec2(0, 0);
    vec2 z = vec2(0, 0);

    if (fractalType == 1) {
        // Mandelbrot
        c = vec2((fragTexCoord.x - 0.5f) * 2.5f, (fragTexCoord.y - 0.5f) * 1.5f) / zoom;
        c.x += offset.x;
        c.y += offset.y;
        z = vec2(0.0f, 0.0f);
    } else if (fractalType == 2) {
        // Julia set
        c = vec2(0.355, 0.355); // You can change the constants for different Julia sets
        z = vec2((fragTexCoord.x - 0.5f) * 2.5f, (fragTexCoord.y - 0.5f) * 1.5f) / zoom;
        z.x += offset.x;
        z.y += offset.y;
    } else if (fractalType == 3) {
        // Koch curve
        vec2 uv = (fragTexCoord - 0.4) * 4.0 / zoom; // Scale and center the coordinates
        uv.x += offset.x;
        uv.y += offset.y;

        float d = kochsCurve(uv, recursionCount); // Distance from the fractal

        // Drawing the fractal
        float lineSmoothness = 4.0 / (recursionCount * 1000); // Smoothness / thickness of the line
        vec3 col = vec3(0); // Color to be drawn on screen
        col += smoothstep(lineSmoothness, 0.0, d) * 0.5;

        finalColor = vec4(col, 1.0); // Outputs the color of the pixel to the screen
        return;
    }

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
