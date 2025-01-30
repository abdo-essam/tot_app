// locations.js
import express from 'express';
import db from './db.js';
import authenticateJWT from './authMiddleware.js';

const router = express.Router();

// locations.js
router.post('/update-location', authenticateJWT, async (req, res) => {
    console.log('Received location update request:', {
        body: req.body,
        user: req.user,
        headers: req.headers
    });

    const { latitude, longitude, isTourGuide, tripId } = req.body;
    const userId = req.user.id;

    if (!userId || latitude == null || longitude == null) {
        return res.status(400).json({
            success: false,
            message: 'Missing required fields',
            details: { userId, latitude, longitude }
        });
    }

    try {
        // Check if user has a location record
        const [existingLocation] = await db.query(
            'SELECT id FROM user_locations WHERE user_id = ?',
            [userId]
        );

        let result;
        if (existingLocation.length > 0) {
            // Update existing record
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
            // Insert new record
            [result] = await db.query(
                `INSERT INTO user_locations
                 (user_id, latitude, longitude, is_tour_guide, trip_id)
                 VALUES (?, ?, ?, ?, ?)`,
                [userId, latitude, longitude, isTourGuide ? 1 : 0, tripId]
            );
        }

        // Fetch the updated/inserted record
        const [updatedLocation] = await db.query(
            `SELECT * FROM user_locations WHERE user_id = ?`,
            [userId]
        );

        console.log('Location updated successfully:', updatedLocation[0]);

        res.status(200).json({
            success: true,
            message: 'Location updated successfully',
            data: updatedLocation[0]
        });
    } catch (err) {
        console.error('Error updating location:', err);
        res.status(500).json({
            success: false,
            message: 'Failed to update location',
            error: err.message
        });
    }
});

// Update the get location endpoint to include role information
router.get('/get-location/:userId', authenticateJWT, async (req, res) => {
    try {
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

        if (locations.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'No location found for this user'
            });
        }

        console.log('Found location:', locations[0]);

        res.status(200).json({
            success: true,
            data: locations[0]
        });
    } catch (err) {
        console.error('Error fetching location:', err);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch location',
            error: err.message
        });
    }
});

export default router;