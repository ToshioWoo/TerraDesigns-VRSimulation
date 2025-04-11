using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoatNav : MonoBehaviour
{
    public GameObject Move;  // Public GameObject to assign in Unity Inspector
    public GameObject xrOrigin;

 
    private void OnTriggerEnter(Collider other)
    {
        Move.SetActive(false);

        //Parent = other.GetComponentInParent<XROrigin>();
        if (xrOrigin != null)
        {
            // Parent the XR Origin to the boat
            xrOrigin.transform.SetParent(transform, true);
        }
    }
}
