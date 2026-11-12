using UnityEngine;
using System.Collections;
public class PlayerPowerUpController : MonoBehaviour
{
    private bool isSpeedBoostActive;
    public bool isShieldActive;
    private bool isCoinMagnetActive;
    public Movement playerMovement; // Reference to the player's movement script
    public GameObject MagnetRange; // Reference to the magnet range GameObject
    public GameObject shieldVisual; // Reference to shield visual GameObject
    public ParticleSystem coinMagnetVisual;
    public float currentspeed;
    public float boostedSpeed;

    private void Start()
    {
        MagnetRange.SetActive(false); // Ensure magnet range is off at start
        shieldVisual.SetActive(false); // Ensure shield visual is off at start
        currentspeed = playerMovement.speed;
    }

    /// <summary>
    /// Activates a power-up with a given duration.
    /// </summary>
    public void ActivatePowerUp(PowerUpType type, float duration)
    {
        StopCoroutine(nameof(PowerUpTimer)); // Prevent overlapping timers for same type
        StartCoroutine(PowerUpTimer(type, duration));
    }

    /// <summary>
    /// Timer coroutine for power-up effects.
    /// </summary>
    private IEnumerator PowerUpTimer(PowerUpType type, float duration)
    {
        switch (type)
        {
            case PowerUpType.SpeedBoost:
                isSpeedBoostActive = true;
                boostedSpeed = currentspeed += 10f;
                break;

            case PowerUpType.Shield:
                isShieldActive = true;
                shieldVisual.SetActive(true); // Enable shield visual
                break;

            case PowerUpType.CoinMagnet:
                isCoinMagnetActive = true;
                MagnetRange.SetActive(true); // Enable magnet range
                coinMagnetVisual.Play(); // Play magnet visual/effect here
                break;
        }

        yield return new WaitForSeconds(duration);

        // Reset after duration
        switch (type)
        {
            case PowerUpType.SpeedBoost:
                isSpeedBoostActive = false;
                break;

            case PowerUpType.Shield:
                isShieldActive = false;
                shieldVisual.SetActive(false); // Disable shield visual
                break;

            case PowerUpType.CoinMagnet:
                isCoinMagnetActive = false;
                MagnetRange.SetActive(false); // Disable magnet range
                coinMagnetVisual.Stop(); // Stop magnet visual/effect here
                break;
        }
    }

    // Example: check shield before taking damage
    public bool CanTakeDamage()
    {
        return !isShieldActive;
    }

    // Example: coin magnet logic
    public bool IsMagnetActive()
    {
        return isCoinMagnetActive;
    }
}
