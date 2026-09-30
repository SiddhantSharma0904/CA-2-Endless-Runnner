using UnityEngine;

public class Movement : MonoBehaviour
{
    public float speed = 5f;
    public float sideDistance = 3f;
    public float sideSpeed = 1f;
    public float gravity = 9.81f;
    private int currentLane = 1; //0: left & 2: right ,1: middle
    private float verticalVelocity = 0f;
    private float startX;
    private float groundY;
    void Start()
    {
        groundY = transform.position.y;
        startX = transform.position.x;
    }
    // Update is called once per frame
    void Update()
    {
        transform.Translate(transform.forward * speed * Time.deltaTime);
        HandleSlideMovement();
    }

    public void MoveLeft()
    {
        if(currentLane > 0)
        {
            currentLane--;
        }
    }

    public void MoveRight()
    {
        if(currentLane < 2)
        {
            currentLane++;
        }
    }

    void HandleSlideMovement()
    {
        float targetX = startX + (currentLane - 1) * sideDistance;
        float newX = Mathf.MoveTowards(transform.position.x, targetX, sideSpeed * Time.deltaTime);
        transform.position = new Vector3(newX, transform.position.y, transform.position.z);
    }
}
