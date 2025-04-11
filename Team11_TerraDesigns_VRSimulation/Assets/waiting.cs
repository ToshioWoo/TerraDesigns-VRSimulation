using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.XR.Interaction.Toolkit;
public class waiting : MonoBehaviour
{
    public GameObject objectiveOff;
    public GameObject objectiveOn;
    public float Delay;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    private void Start()
    {

        StartCoroutine(WAITINGTIME());

    }

    IEnumerator WAITINGTIME()
    {
        yield return new WaitForSeconds(Delay);

        objectiveOff.SetActive(true);
        objectiveOn.SetActive(true);

    }
    

}
