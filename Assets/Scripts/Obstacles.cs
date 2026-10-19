using Unity.Hierarchy;
using UnityEngine;

public class Obstacles : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
            gameObject.SetActive(false);
    }
}
