using UnityEngine;

public class LightingController : MonoBehaviour
{
    public ProceduralSkybox skyboxController; // Reference to the procedural skybox script
    public Light directionalLight; // Reference to the directional light (sun/moon)
    public Light backlight;

    public Color dayAmbientLight = new Color(0.8f, 0.8f, 0.8f); // Bright white for day
    public Color eveningAmbientLight = new Color(0.6f, 0.4f, 0.4f); // Warm orange for evening
    public Color nightAmbientLight = new Color(0.1f, 0.1f, 0.2f); // Dark blue for night

    public Color dayLightColor = new Color(1f, 1f, 0.9f); // Bright yellow for sun
    public Color eveningLightColor = new Color(1f, 0.6f, 0.4f); // Orange for sunset
    public Color nightLightColor = new Color(0.4f, 0.4f, 0.8f); // Soft blue for moon

    public float dayReflectionIntensity = 1f; // Full reflections during the day
    public float nightReflectionIntensity = 0.07f; // Dim reflections at night

    public float dayBacklightIntensity = 1f; // Backlight intensity during the day
    public float nightBacklightIntensity = 0.1f; // Backlight intensity at night

    public float sunRotationSpeed = 10f; // Speed of sun/moon rotation

    void Start()
    {
        ResetToDay();

    }

    void Update()
    {
        // Check if skyboxController and directionalLight are assigned
        if (skyboxController == null || directionalLight == null || backlight == null)
        {
            Debug.LogError("Skybox Controller or Directional Light is not assigned!");
            return;
        }

        // Get the current blend factor from the skybox controller
        float blendFactor = skyboxController.GetBlendFactor();

        // Adjust ambient light
        Color ambientLight;
        if (blendFactor <= 1)
        {
            ambientLight = Color.Lerp(dayAmbientLight, eveningAmbientLight, blendFactor);
        }
        else
        {
            ambientLight = Color.Lerp(eveningAmbientLight, nightAmbientLight, blendFactor - 1);
        }
        RenderSettings.ambientLight = ambientLight;

        // Adjust directional light color and intensity
        Color lightColor;
        if (blendFactor <= 1)
        {
            lightColor = Color.Lerp(dayLightColor, eveningLightColor, blendFactor);
        }
        else
        {
            lightColor = Color.Lerp(eveningLightColor, nightLightColor, blendFactor - 1);
        }
        directionalLight.color = lightColor;

        // Adjust directional light intensity
        float lightIntensity = Mathf.Lerp(1f, 0.05f, blendFactor / 2f); // Dim light at night
        directionalLight.intensity = lightIntensity;

        // Adjust reflection intensity
        float reflectionIntensity = Mathf.Lerp(dayReflectionIntensity, nightReflectionIntensity, blendFactor / 2f);
        RenderSettings.reflectionIntensity = reflectionIntensity;

        // Adjust backlight intensity
        float backlightIntensity = Mathf.Lerp(dayBacklightIntensity, nightBacklightIntensity, blendFactor / 2f);
        backlight.intensity = backlightIntensity;

        // Rotate the directional light to mimic the sun/moon position
        RotateDirectionalLight(blendFactor);
    }

    void RotateDirectionalLight(float blendFactor)
    {
        // Calculate the rotation angle based on the blend factor
        float rotationAngle = Mathf.Lerp(90f, 180, blendFactor / 2f); // 90° = sunrise, 180° = noon, 270° = sunset

        // Rotate the directional light around the X-axis
        directionalLight.transform.rotation = Quaternion.Euler(rotationAngle, -30f, 0f); // Adjust Y and Z rotations as needed
    }

    public void ResetToDay()
    {
        {
            // Reset the skybox to daytime
            skyboxController.ResetToDay();

            // Reset the lighting to daytime values
            RenderSettings.ambientLight = dayAmbientLight;
            directionalLight.color = dayLightColor;
            directionalLight.intensity = 1f;
            RenderSettings.reflectionIntensity = dayReflectionIntensity;
        }
    }
}