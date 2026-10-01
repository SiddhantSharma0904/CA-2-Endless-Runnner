using UnityEngine;


public class MainMenu : MonoBehaviour
{
    public AudioSource buttonClick;

    public void OnStartDown()
    {
        UnityEngine.SceneManagement.SceneManager.LoadScene("Gameplay");
    }
}
