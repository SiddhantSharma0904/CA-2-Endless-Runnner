using UnityEngine;

public class Collectables : MonoBehaviour
{
    void Update()
    {
        this.transform.Rotate(Vector3.up * 100 * Time.deltaTime);
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            GameManager.instance.CollectablesCount += 1;
            this.gameObject.SetActive(false);
        }
    }
}
