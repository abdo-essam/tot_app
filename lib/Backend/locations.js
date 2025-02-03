import express from 'express';
import db from './db.js';
import authenticateJWT from './authMiddleware.js';

const router = express.Router();

/**
 * Update user location endpoint
 * POST /update-location
 * Requires JWT authentication
 * Updates or creates a location record for the authenticated user
 */
router.post('/update-location', authenticateJWT, async (req, res) => {
    // Log incoming request for debugging
    console.log('Received location update request:', {
        body: req.body,
        user: req.user,
        headers: req.headers
    });

    // Extract required data from request body
    const { latitude, longitude, isTourGuide, tripId } = req.body;
    const userId = req.user.id;  // Get user ID from JWT token

    // Validate required fields
    if (!userId || latitude == null || longitude == null) {
        return res.status(400).json({
            success: false,
            message: 'Missing required fields',
            details: { userId, latitude, longitude }
        });
    }

    try {
        // Check if user already has a location record
        const [existingLocation] = await db.query(
            'SELECT id FROM user_locations WHERE user_id = ?',
            [userId]
        );

        let result;
        if (existingLocation.length > 0) {
            // Update existing location record
            [result] = await db.query(
                `UPDATE user_locations
                 SET latitude = ?,
                     longitude = ?,
                     updated_at = CURRENT_TIMESTAMP,
                     is_tour_guide = ?,
                     trip_id = ?
                 WHERE user_id = ?`,
                [latitude, longitude, isTourGuide ? 1 : 0, tripId, userId]
            );
        } else {
            // Create new location record
            [result] = await db.query(
                `INSERT INTO user_locations
                 (user_id, latitude, longitude, is_tour_guide, trip_id)
                 VALUES (?, ?, ?, ?, ?)`,
                [userId, latitude, longitude, isTourGuide ? 1 : 0, tripId]
            );
        }

        // Fetch the updated/inserted record for response
        const [updatedLocation] = await db.query(
            `SELECT * FROM user_locations WHERE user_id = ?`,
            [userId]
        );

        // Log success
        console.log('Location updated successfully:', updatedLocation[0]);

        // Send success response
        res.status(200).json({
            success: true,
            message: 'Location updated successfully',
            data: updatedLocation[0]
        });
    } catch (err) {
        // Log and handle errors
        console.error('Error updating location:', err);
        res.status(500).json({
            success: false,
            message: 'Failed to update location',
            error: err.message
        });
    }
});

/**
 * Get user location endpoint
 * GET /get-location/:userId
 * Requires JWT authentication
 * Retrieves the most recent location for a specific user
 */
router.get('/get-location/:userId', authenticateJWT, async (req, res) => {
    try {
        // Query to get the most recent location for the specified user
        const [locations] = await db.query(
            `SELECT
                id,
                user_id,
                latitude,
                longitude,
                is_tour_guide,
                trip_id,
                updated_at
             FROM user_locations
             WHERE user_id = ?
             ORDER BY updated_at DESC
             LIMIT 1`,
            [req.params.userId]
        );

        // Handle case where no location is found
        if (locations.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'No location found for this user'
            });
        }

        // Log found location
        console.log('Found location:', locations[0]);

        // Send success response with location data
        res.status(200).json({
            success: true,
            data: locations[0]
        });
    } catch (err) {
        // Log and handle errors
        console.error('Error fetching location:', err);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch location',
            error: err.message
        });
    }
});

// Database schema reference
/**
 * user_locations table schema:
 * - id: INT PRIMARY KEY AUTO_INCREMENT
 * - user_id: INT (foreign key to users table)
 * - latitude: DECIMAL(10,8)
 * - longitude: DECIMAL(11,8)
 * - is_tour_guide: BOOLEAN
 * - trip_id: INT (foreign key to trips table)
 * - updated_at: TIMESTAMP
 * - created_at: TIMESTAMP
 */

/**
 * Security considerations:
 * 1. JWT authentication required for all endpoints
 * 2. Input validation for required fields
 * 3. SQL injection prevention using parameterized queries
 * 4. Error handling and logging
 */

/**
 * Performance considerations:
 * 1. Index on user_id column
 * 2. Index on updated_at for efficient sorting
 * 3. Limit query results to most recent record
 * 4. Optimized update/insert operations
 */

export default router;