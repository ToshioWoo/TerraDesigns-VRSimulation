using UnityEngine;

public class ProceduralSkybox : MonoBehaviour
{
    public Material skyboxMaterial; // Reference to the blended skybox material
    public float blendSpeed = 0.1f; // Speed of blending between skyboxes
    private float blendFactor = 0f; // Current blend factor (0 = Day, 1 = Evening, 2 = Night)

    void Start()
    {

        ResetToDay();
    }

    void Update()
    {
        // Update the blend factor over time
        blendFactor += blendSpeed * Time.deltaTime;

        // Loop the blend factor between 0 and 2
        if (blendFactor > 2f)
        {
            blendFactor = 0f;
        }

        // Update the blend factor in the material
        skyboxMaterial.SetFloat("_BlendFactor", blendFactor);
    }

    // Public method to get the blend factor
    public float GetBlendFactor()
    {
        return blendFactor;
    }

    public void ResetToDay()
    {
        blendFactor = 0f;
        skyboxMaterial.SetFloat("_BlendFactor", blendFactor);
    }
}