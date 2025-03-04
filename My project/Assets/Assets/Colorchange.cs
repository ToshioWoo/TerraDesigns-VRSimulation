using UnityEngine;
using UnityEngine.UI;

using UnityEngine;
using UnityEngine.UI;

public class ChangeImageColorOnToggle : MonoBehaviour
{
    public Image imageComponent;    // Reference to the Image component
    public Toggle toggleButton;     // Reference to the Toggle button

    // Store the original color of the image
    private Color originalColor;

    // Set the color when toggle is on
    public Color toggledColor = new Color(0.4f, 0.36f, 0.28f, 1f);  // Example: Red color when toggled on

    void Start()
    {
        // Store the original color of the image
        if (imageComponent != null)
        {
            originalColor = imageComponent.color;
        }

        // Add a listener to the Toggle to react to state changes
        if (toggleButton != null)
        {
            toggleButton.onValueChanged.AddListener(OnToggleChanged);
        }
    }

    void OnToggleChanged(bool isToggledOn)
    {
        // Change the color based on whether the toggle is on or off
        if (isToggledOn)
        {
            imageComponent.color = toggledColor;  // Set to the toggled color (e.g., Red)
        }
        else
        {
            imageComponent.color = originalColor;  // Revert to the original color
        }
    }
}