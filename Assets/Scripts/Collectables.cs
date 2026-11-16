using UnityEngine;

public class Collectables : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            GameManager.instance.CollectablesCount += 1;
            this.gameObject.SetActive(false);
        }
    }
}
