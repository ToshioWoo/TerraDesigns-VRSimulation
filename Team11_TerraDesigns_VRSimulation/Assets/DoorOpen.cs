using UnityEngine;

public class DoorController : MonoBehaviour
{
    public Transform hinge; // Reference to the hinge empty GameObject
    public float openAngle = 90f; // Angle to rotate the door (in degrees)
    public float rotationSpeed = 90f; // Rotation speed in degrees per second

    private bool isOpening = false; // Track if the door is opening
    private Quaternion initialRotation; // Initial rotation of the door
    private Quaternion targetRotation; // Target rotation of the door

    private void Start()
    {
        // Store the initial rotation of the door
        initialRotation = hinge.rotation;
        // Calculate the target rotation
        targetRotation = initialRotation * Quaternion.Euler(0, openAngle, 0);
    }

    private void Update()
    {
        if (isOpening)
        {
            // Smoothly rotate the door towards the target rotation
            hinge.rotation = Quaternion.RotateTowards(hinge.rotation, targetRotation, rotationSpeed * Time.deltaTime);

            // Stop rotating once the target rotation is reached
            if (Quaternion.Angle(hinge.rotation, targetRotation) < 0.1f)
            {
                isOpening = false;
            }
        }
    }

    private void OnTriggerEnter(Collider collision)
    {
            // Start opening the door
            isOpening = true;
        
    }
}