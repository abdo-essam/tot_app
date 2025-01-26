import express from 'express';
import pool from './db.js'; // Import the database connection
import authenticateJWT from './authMiddleware.js'; // JWT middleware to authenticate

const router = express.Router();

router.get('/tour-guides', authenticateJWT, async (req, res) => {
    try {
        const [rows] = await pool.execute(`
            SELECT
                u.id,
                u.name,
                u.user_type
            FROM
                user u
            WHERE
                u.user_type = 'Tour Guide'
        `);

        const guides = rows.map(guide => ({
            id: guide.id,
            name: guide.name,
        }));

        res.status(200).json(guides);
    } catch (err) {
        console.error('Error fetching tour guides:', err);
        res.status(500).json({ message: 'An internal server error occurred.' });
    }
});

router.post('/guideAvailability', authenticateJWT, async (req, res) => {
    const { guide_id, unavailability_date } = req.body; // Expect an array of dates

    if (!guide_id || !unavailability_date || !Array.isArray(unavailability_date)) {
        return res.status(400).json({ message: 'Guide ID and an array of unavailability dates are required.' });
    }

    try {
        // Prepare the SQL query for inserting multiple rows
        const insertPromises = unavailability_date.map(date => {
            return pool.execute(
                'INSERT INTO guide_availability (Guide_id, unavailability_date) VALUES (?, ?)',
                [guide_id, date]
            );
        });

        // Execute all insertions in parallel
        await Promise.all(insertPromises);

        res.status(201).json({ message: 'Unavailable dates added successfully' });
    } catch (err) {
        console.error('Error adding unavailable dates:', err);
        res.status(500).json({ message: 'An internal server error occurred.' });
    }
});

// Fetch active trips for a guide
router.get('/active-trips/:guideId', authenticateJWT, async (req, res) => {
    try {
        const guideId = req.params.guideId;

        const [trips] = await pool.query(
            `SELECT
                o.id as trip_id,
                o.Tourist_id,
                u.name as tourist_name,
                o.date,
                ul.latitude,
                ul.longitude,
                ul.updated_at as location_updated_at
             FROM orders o
             JOIN user u ON o.Tourist_id = u.id
             LEFT JOIN user_locations ul ON u.id = ul.user_id
             WHERE o.Guide_id = ?
             AND o.status = 1
             ORDER BY o.date DESC`,
            [guideId]
        );

        res.status(200).json(trips);
    } catch (err) {
        console.error('Error fetching active trips:', err);
        res.status(500).json({ message: 'Failed to fetch active trips' });
    }
});


// Get tourist's current location
router.get('/tourist-location/:touristId', authenticateJWT, async (req, res) => {
    try {
        const [location] = await pool.query(
            `SELECT user_id, latitude, longitude, updated_at
             FROM user_locations
             WHERE user_id = ?`,
            [req.params.touristId]
        );

        if (location.length === 0) {
            return res.status(404).json({ message: 'Location not found' });
        }

        res.status(200).json(location[0]);
    } catch (err) {
        console.error('Error fetching tourist location:', err);
        res.status(500).json({ message: 'Failed to fetch location' });
    }
});

export default router;
