using UnityEngine;
using UnityEngine.EventSystems;

public class SwipeDetection : MonoBehaviour
{
    private Vector2 startTouchPosition;
    public float swipeThreshold = 50f;

    private bool hasSwiped = false;

    public Movement forward;

    public void ManualBeginDrag(BaseEventData axisData)
    {
        PointerEventData eventData = axisData as PointerEventData;
        if (eventData == null) return;

        hasSwiped = false;
        startTouchPosition = eventData.position;
    }
    public void ManualDrag(BaseEventData axisData)
    {
        if (hasSwiped) return;

        PointerEventData eventData = axisData as PointerEventData;
        if (eventData == null) return;

        Vector2 currentTouchPosition = eventData.position;
        Vector2 distance = currentTouchPosition - startTouchPosition;
        if (distance.magnitude >= swipeThreshold)
        {
            hasSwiped = true;
            if (Mathf.Abs(distance.x) > Mathf.Abs(distance.y)) //Mathf.Abs = Absolute Value 
            {
                // Horizontal swipe
                if (distance.x > 0) OnSwipeRight();
                else OnSwipeLeft();

            }
            else
            {
                // Vertical swipe
                if (distance.y > 0) OnSwipeUp();
                else OnSwipeDown();
            }
        }
    }
    public void ManualEndDrag(BaseEventData axisData)
    {
        hasSwiped = false;
    }
    void OnSwipeLeft()
    {
        Debug.Log("Left Swipe Detected");
        forward.MoveLeft();

    }
    void OnSwipeRight()
    {
        Debug.Log("Right Swipe Detected");
        forward.MoveRight();
    }
    void OnSwipeUp()
    {
        Debug.Log("Up Swipe Detected");
        //forward.Jump();
    }
    void OnSwipeDown()
    {
        Debug.Log("Down Swipe Detected");

    }
}
