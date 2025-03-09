using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoatNav : MonoBehaviour
{
    public GameObject Move;  // Public GameObject to assign in Unity Inspector
    private Rigidbody rb;    // Declare Rigidbody variable at class level

    void Start()
    {
        rb = GetComponent<Rigidbody>();  // Initialize Rigidbody correctly
    }

    void OnCollisionEnter(Collision collision) // Use correct collision detection
    {
        if (collision.gameObject.CompareTag("Player")) // Safer way to check tags
        {
            rb.AddForce(Vector3.right * 10);
            Move.SetActive(false);
        }
    }
}
