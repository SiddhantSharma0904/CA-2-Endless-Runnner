using System.Collections.Generic;
using System;
using Unity.Mathematics;
using UnityEngine;

public class BaseGeneration : MonoBehaviour
{

    public void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            this.gameObject.SetActive(false);

            int randomIndex = UnityEngine.Random.Range(0, GameManager.instance.basePrefabList.Count);
            GameObject currentbase = GameManager.instance.basePool[randomIndex];

            GameManager.instance.basePool.Remove(currentbase);
            currentbase.transform.position = GameManager.instance.nextBasePosition.position;
            currentbase.transform.rotation = Quaternion.Euler(0, 0, 0);
            GameManager.instance.nextBasePosition = currentbase.GetComponent<BaseManager>().nextBasePosition;
            currentbase.SetActive(true);

            currentbase.transform.parent = GameManager.instance.baseParent;
            GameManager.instance.baseList.Add(currentbase);
            currentbase.name = "Base " + (GameManager.instance.baseList.Count - 1);

            if (GameManager.instance.baseList.Count >= 8)
            {
                GameObject baseToPool = GameManager.instance.baseList[GameManager.instance.baseToRemoveCount];
                GameManager.instance.baseList[GameManager.instance.baseToRemoveCount] = null;
                baseToPool.SetActive(false);

                if (baseToPool.GetComponent<BaseManager>().IsPooled)
                {
                    baseToPool.transform.position = new Vector3(0, -1000, 0);
                    baseToPool.transform.parent = GameManager.instance.basePoolParent;
                    GameManager.instance.basePool.Add(baseToPool);
                }

                GameManager.instance.baseToRemoveCount += 1;
            }

        }


    }
}
