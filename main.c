#include "raylib.h"

const float ZOOM_SPEED = 1.01f;
const float OFFSET_SPEED_MUL = 2.0f;
const float STARTING_ZOOM = 0.75f;

int OldWidht = 0, OldHeight = 0;
int OldX = 0, OldY = 0;

int main(void) {
    // Initialization
    //--------------------------------------------------------------------------------------
    SetConfigFlags(FLAG_WINDOW_RESIZABLE);
    InitWindow(800, 450, "Mandelbrot");

    // Load Mandelbrot set shader
    const Shader shader = LoadShader(0, TextFormat("../shader.glsl", 330));

    // Create a RenderTexture2D to be used for render to texture
    RenderTexture2D target = LoadRenderTexture(GetScreenWidth(), GetScreenHeight());

    float offset[2] = {-0.5f, 0.0f};
    float zoom = STARTING_ZOOM;

    // Get variable (uniform) locations on the shader to connect with the program
    const int zoomLoc = GetShaderLocation(shader, "zoom");
    const int offsetLoc = GetShaderLocation(shader, "offset");

    // Upload the shader uniform values!
    SetShaderValue(shader, zoomLoc, &zoom, SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, offsetLoc, offset, SHADER_UNIFORM_VEC2);

    int incrementSpeed = 2; // Multiplier of speed to change c value
    bool showControls = true; // Show controls

    SetTargetFPS(60); // Set our "game" to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    // Detect window close button or ESC key
    while (!WindowShouldClose()) {

        // Window events
        if (IsWindowResized()) {
            target.texture.width = GetScreenWidth();
            target.texture.height = GetScreenHeight();
            OldWidht = GetScreenWidth();
            OldHeight = GetScreenHeight();
        }
        if (IsKeyReleased(KEY_F11)) {
            if (!IsWindowFullscreen()) {
                OldWidht = GetScreenWidth();
                OldHeight = GetScreenHeight();
                OldX = GetWindowPosition().x;
                OldY = GetWindowPosition().y;
                SetWindowSize(GetMonitorWidth(GetCurrentMonitor()), GetMonitorHeight(GetCurrentMonitor()));
                target.texture.width = GetMonitorWidth(GetCurrentMonitor());
                target.texture.height = GetMonitorHeight(GetCurrentMonitor());
                ToggleFullscreen();
            }
            else {
                ToggleFullscreen();
                SetWindowSize(OldWidht, OldHeight);
                SetWindowPosition(OldX, OldHeight);
                target.texture.width = OldWidht;
                target.texture.height = OldHeight;
            }
        }

        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(KEY_R)) {
            zoom = STARTING_ZOOM;
            offset[0] = -0.5f;
            offset[1] = 0.0f;
            SetShaderValue(shader, zoomLoc, &zoom, SHADER_UNIFORM_FLOAT);
            SetShaderValue(shader, offsetLoc, offset, SHADER_UNIFORM_VEC2);
        }

        if (IsKeyPressed(KEY_SPACE)) incrementSpeed = 0; // Pause animation (c change)
        if (IsKeyPressed(KEY_F1)) showControls = !showControls; // Toggle whether or not to show controls

        if (IsKeyPressed(KEY_RIGHT)) incrementSpeed++;
        else if (IsKeyPressed(KEY_LEFT)) incrementSpeed--;

        if (IsMouseButtonDown(MOUSE_BUTTON_LEFT) || IsMouseButtonDown(MOUSE_BUTTON_RIGHT)) {
            zoom *= IsMouseButtonDown(MOUSE_BUTTON_LEFT) ? ZOOM_SPEED : 1.0f / ZOOM_SPEED;

            const Vector2 mousePos = GetMousePosition();
            Vector2 offsetVelocity;
            offsetVelocity.x = (mousePos.x / (float)GetScreenWidth() - 0.5f) * OFFSET_SPEED_MUL / zoom;
            offsetVelocity.y = (mousePos.y / (float)GetScreenHeight() - 0.5f) * OFFSET_SPEED_MUL / zoom;

            offset[0] += GetFrameTime() * offsetVelocity.x;
            offset[1] += GetFrameTime() * offsetVelocity.y;

            SetShaderValue(shader, zoomLoc, &zoom, SHADER_UNIFORM_FLOAT);
            SetShaderValue(shader, offsetLoc, offset, SHADER_UNIFORM_VEC2);
        }

        //----------------------------------------------------------------------------------
        // Draw
        //----------------------------------------------------------------------------------
        BeginTextureMode(target); // Enable drawing to texture
        ClearBackground(BLACK); // Clear the render texture
        DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), BLACK);
        EndTextureMode();

        BeginDrawing();
        ClearBackground(BLACK); // Clear screen background
        BeginShaderMode(shader);
        DrawTextureEx(target.texture, (Vector2){0.0f, 0.0f}, 0.0f, 1.0f, WHITE);
        EndShaderMode();

        if (!showControls) {
            DrawText("Press Mouse buttons right/left to zoom in/out and move", 10, 15, 10, RAYWHITE);
            DrawText("Press KEY_F1 to toggle these controls", 10, 30, 10, RAYWHITE);
            DrawText("Press KEYS [1 - 6] to change point of interest", 10, 45, 10, RAYWHITE);
            DrawText("Press KEY_R to recenter the camera", 10, 90, 10, RAYWHITE);
        }
        // TODO show zoom level via DrawText
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    UnloadShader(shader); // Unload shader
    UnloadRenderTexture(target); // Unload render texture

    CloseWindow(); // Close window and OpenGL context
    return 0;
}
