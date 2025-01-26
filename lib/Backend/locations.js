import express from 'express';
import db from './db.js';
import authenticateJWT from './authMiddleware.js';

const router = express.Router();

// Endpoint to update user location
router.post('/update-location', authenticateJWT, async (req, res) => {
    const { latitude, longitude } = req.body;
    const userId = req.user.id;

    if (!userId || !latitude || !longitude) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        // First check if user has a location record
        const [existingLocation] = await db.query(
            'SELECT id FROM user_locations WHERE user_id = ?',
            [userId]
        );

        if (existingLocation.length > 0) {
            // Update existing record
            const [result] = await db.query(
                `UPDATE user_locations
                 SET latitude = ?,
                     longitude = ?,
                     updated_at = CURRENT_TIMESTAMP
                 WHERE user_id = ?`,
                [latitude, longitude, userId]
            );

            if (result.affectedRows > 0) {
                res.status(200).json({
                    success: true,
                    message: 'Location updated successfully'
                });
            } else {
                throw new Error('Update failed');
            }
        } else {
            // Insert new record if none exists
            const [result] = await db.query(
                `INSERT INTO user_locations (user_id, latitude, longitude)
                 VALUES (?, ?, ?)`,
                [userId, latitude, longitude]
            );

            if (result.affectedRows > 0) {
                res.status(200).json({
                    success: true,
                    message: 'Location created successfully'
                });
            } else {
                throw new Error('Insert failed');
            }
        }
    } catch (err) {
        console.error('Error updating location:', err);
        res.status(500).json({
            success: false,
            message: 'Failed to update location',
            error: err.message
        });
    }
});

// Get current location
router.get('/get-location/:userId', authenticateJWT, async (req, res) => {
    try {
        // Use db instead of pool and execute instead of query
        const [locations] = await db.execute(
            `SELECT
                id,
                user_id,
                latitude,
                longitude,
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

        console.log('Found location:', locations[0]); // Debug log

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