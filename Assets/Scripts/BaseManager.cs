using System.Collections.Generic;
using UnityEngine;

public class BaseManager : MonoBehaviour
{
    public Transform nextBasePosition;
       [SerializeField] BaseGeneration baseGeneration;
    public bool IsPooled;

    private void OnEnable()
    {
        baseGeneration.gameObject.SetActive(true);
    }


    private void Update()
    {

    }
}
