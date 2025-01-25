import express from 'express';
import db from './db.js'; // Assuming you have a db connection file
import authenticateJWT from './authMiddleware.js';

const router = express.Router();

// Endpoint to update user location
router.post('/update-location', authenticateJWT, async (req, res) => {
    const { latitude, longitude } = req.body;
    const userId = req.user.id; // Extracted from JWT

    if (!userId || !latitude || !longitude) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const [result] = await db.query(
            `INSERT INTO user_locations (user_id, latitude, longitude, updated_at)
             VALUES (?, ?, ?, CURRENT_TIMESTAMP)
             ON DUPLICATE KEY UPDATE latitude = ?, longitude = ?, updated_at = CURRENT_TIMESTAMP`,
            [userId, latitude, longitude, latitude, longitude]
        );
        res.status(200).json({ message: 'Location updated successfully' });
    } catch (err) {
        console.error('Error updating location:', err);
        res.status(500).json({ message: 'Failed to update location' });
    }
});

// Endpoint to retrieve user locations
router.get('/get-locations', async (req, res) => {
    try {
        const [locations] = await db.query(
            `SELECT u.id AS user_id, u.name AS user_name, l.latitude, l.longitude, l.updated_at
             FROM users u
             JOIN user_locations l ON u.id = l.user_id
             WHERE u.location_access_granted = true`  // Only fetch users who granted location access
        );

        res.status(200).json(locations);
    } catch (err) {
        console.error('Error fetching locations:', err);
        res.status(500).json({ message: 'Failed to fetch locations' });
    }
});

export default router;
