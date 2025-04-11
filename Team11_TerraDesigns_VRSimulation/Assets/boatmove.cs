using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.XR.Interaction.Toolkit; // Required for Grab Interactable

public class DynamicFollow : MonoBehaviour
{
    public Vector3 playerOffset; // Set in the Inspector
    public GameObject Move;  // Public GameObject to assign in Unity Inspector
    public GameObject Tablet;
    public GameObject TabletOff;
    public GameObject OBJBoat;
    public GameObject OBJLookTablet;
    public LightingController Lighting;
    public ProceduralSkybox skyboxController;

    public Animator _canvasAnimator;


    public List<Transform> targets; // Targets
    public float moveSpeed; // Speed of movement
    public float rotationSpeed; // Speed of rotation
    public float delayBeforeSceneSwitch; // Delay before switching scenes (public)
    private int currentTargetIndex = 0; // Index of the current target
    private bool hasReachedFinalTarget = false;
    [Header("Audio Settings")]
    public AudioSource audioSource;  // Drag your AudioSource here in Inspector
    public float initialVolume = 1.0f;
    public float fadeDuration = 2.0f;

    private bool shouldFade = false;
    private float fadeTimer = 0f;

    private UnityEngine.XR.Interaction.Toolkit.Interactables.XRGrabInteractable tabletGrabInteractable; // Reference to the tablet's grab interactable

    private void Start()
    {
        Lighting.ResetToDay();
        skyboxController.ResetToDay();


    // Start is called once before the first execution of Update after the MonoBehaviour is created
        //_canvasAnimator = GetComponent<Animator>();
    }

    private void OnTriggerEnter(Collider other)
    {
        Move.SetActive(false);
        Tablet.SetActive(true);
        TabletOff.SetActive(false);
        OBJBoat.SetActive(false);
        OBJLookTablet.SetActive(true);
        Lighting.enabled = true;
        skyboxController.enabled = true;

        // Move the XR Origin to the center of the boat (parent's position)
        other.transform.position = transform.position + playerOffset; // Use the boat's position
        other.transform.SetParent(transform, true);

        if (audioSource != null)
        {
            audioSource.volume = initialVolume;
        }
        else
        {
            Debug.LogError("AudioSource not assigned!", this);
        }

        StartFade();

    }

    private void OnTriggerStay(Collider other)
    {
        if (currentTargetIndex < targets.Count && !hasReachedFinalTarget)
        {
            // Move towards the current target
            MoveTowardsTarget(targets[currentTargetIndex]);

            // Rotate towards the current target
            RotateTowardsTarget(targets[currentTargetIndex]);

            // Check if the boat has reached the current target
            if (Vector3.Distance(transform.position, targets[currentTargetIndex].position) < 0.1f)
            {
                // Move to the next target
                currentTargetIndex++;

                // Check if the final target has been reached
                if (currentTargetIndex == targets.Count)
                {
                    hasReachedFinalTarget = true;
                    CanvasOpacity();
                    StartCoroutine(SwitchSceneAfterDelay());
                }
            }
        }

        if (shouldFade && audioSource != null && fadeTimer < fadeDuration)
        {
            fadeTimer += Time.deltaTime;
            audioSource.volume = Mathf.Lerp(initialVolume, 0f, fadeTimer / fadeDuration);

            if (fadeTimer >= fadeDuration)
            {
                audioSource.Stop();
                shouldFade = false;
            }
        }
    }

    void MoveTowardsTarget(Transform target)
    {
        // Calculate the direction to the target
        Vector3 direction = (target.position - transform.position).normalized;

        // Move towards the target at the specified speed
        transform.position = Vector3.MoveTowards(transform.position, target.position, moveSpeed * Time.deltaTime);
    }

    void RotateTowardsTarget(Transform target)
    {
        // Calculate the direction to the target
        Vector3 direction = (target.position - transform.position).normalized;

        // Calculate the rotation to look at the target
        Quaternion targetRotation = Quaternion.LookRotation(direction);

        // Smoothly rotate towards the target
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
    }

    IEnumerator SwitchSceneAfterDelay()
    {
        // Wait for the specified delay
        yield return new WaitForSeconds(delayBeforeSceneSwitch);

        // Load the next scene
        SceneManager.LoadScene("Scene2");
    }

    public void StartFade()
    {
        if (audioSource != null && !shouldFade && audioSource.isPlaying)
        {
            shouldFade = true;
            fadeTimer = 0f;
        }
    }

    private void CanvasOpacity()
    {
        Debug.Log("2100");
        _canvasAnimator.SetTrigger("FadeIn");
        Tablet.SetActive(false);

    }
}