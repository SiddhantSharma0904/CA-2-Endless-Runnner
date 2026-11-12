using UnityEngine;

/// <summary>
/// Enum for different power-up types.
/// Extend this as needed.
/// </summary>
public enum PowerUpType
{
    SpeedBoost,
    Shield,
    CoinMagnet
}

/// <summary>
/// Power-up pickup behaviour.
/// Attach this to your power-up prefab.
/// </summary>
public class PowerUps : MonoBehaviour
{
    public PowerUpType type;       // Type of power-up
    public float duration = 5f;    // Duration in seconds

    private void OnTriggerEnter(Collider other)
    {
        // Check if player collided
        if (other.CompareTag("Player"))
        {
            PlayerPowerUpController controller = other.GetComponent<PlayerPowerUpController>();
            if (controller != null)
            {
                controller.ActivatePowerUp(type, duration);
            }

            // Destroy pickup after activation
            Destroy(gameObject);
        }
    }
}
