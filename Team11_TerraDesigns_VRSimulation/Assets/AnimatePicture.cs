using UnityEngine;

public class AnimatePicture : MonoBehaviour
{

    public Animator _pictureAnimator;  // Drag your AudioSource here in Inspector

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        _pictureAnimator.SetTrigger("FadeIn");
        Debug.Log("PicFadeIn");
    }
}
