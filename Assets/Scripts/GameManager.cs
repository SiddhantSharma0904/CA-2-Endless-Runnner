using NUnit.Framework;
using UnityEngine;
using System.Collections.Generic;
using Unity.VisualScripting;

public class GameManager : MonoBehaviour
{
    public static GameManager instance;
    public List<GameObject> baseList = new List<GameObject>();
    public Transform nextBasePosition;
    public GameObject basePrefab;
    public Transform baseParent;
    public List<GameObject> basePrefabList = new List<GameObject>();
    public int baseToRemoveCount = 0;
    public int CollectablesCount = 0;

    public Transform basePoolParent;
    public List<GameObject> basePool = new List<GameObject>();


    private void Start()
    {
        LoadBasePool();
        if (instance == true)
        {
            DestroyImmediate(gameObject);
            return;
        }
        else
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
    }

    private void LoadBasePool()
    {
        if (basePrefabList.Count == 0)
        {
            Debug.LogError("Base prefab list is empty");
            return;
        }

        foreach (GameObject baseprefab in basePrefabList)
        {
            for (int i = 0; i < 5; i++)
            {
                GameObject newbase = Instantiate(baseprefab, new Vector3(0, -1000, 0), Quaternion.identity, basePoolParent);
                newbase.gameObject.SetActive(false);
                newbase.GetComponent<BaseManager>().IsPooled = true;
                basePool.Add(newbase);
            }
        }
    }
}
