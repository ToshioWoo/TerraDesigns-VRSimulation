using UnityEngine;

public class switchObjective : MonoBehaviour
{
    public GameObject objectiveOff;
    public GameObject objectiveOn;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            objectiveOff.SetActive(false);
            objectiveOn.SetActive(true);
        }
    }
}
