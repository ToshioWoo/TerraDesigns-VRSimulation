using UnityEngine;

public class DoorAnimate : MonoBehaviour
{

    public AudioSource audioSource;  // Drag your AudioSource here in Inspector

    private Animator _doorAnimator;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        _doorAnimator = GetComponent<Animator>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            _doorAnimator.SetTrigger("Open");
            audioSource.Play();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            _doorAnimator.SetTrigger("Close");
            audioSource.Play();
        }
    }
}

