using UnityEngine;
using UnityEngine.Rendering;

public class CameraFollow : MonoBehaviour
{

    public Transform target;
    public float smoothSpeed = 0.125f;
    public float offsetZ = 5f;
    public bool useSmoothing = true;
    private float fixedXPosition;
    private float fixedYPosition;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        fixedYPosition = transform.position.y;
        fixedXPosition = transform.position.x;
    }

    // Update is called once per frame
    void LateUpdate()
    {
        if (target == null) return;

        float desiredZposition = target.position.z - offsetZ;
        Vector3 targetPosition = new Vector3(fixedXPosition, fixedYPosition, desiredZposition);

        if (useSmoothing)
            transform.position = Vector3.Lerp(transform.position, targetPosition, smoothSpeed * Time.deltaTime);
        else
            transform.position = targetPosition;
    }
}
