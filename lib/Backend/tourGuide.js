import express from 'express';
import pool from './db.js'; // Import the database connection
import authenticateJWT from './authMiddleware.js'; // JWT middleware to authenticate

const router = express.Router();

router.get('/tourGuide', authenticateJWT, async (req, res) => {
    try {
        const guideId = req.user.id; // Get the Guide ID from the token

        // SQL Query to get tour guide's data
        const [rows] = await pool.execute(`
            SELECT 
                u.name,
                u.img,
                u.user_type
            FROM 
                user u
            WHERE 
                u.id = ?;  -- Filter by the logged-in guide's ID
        `, [guideId]);

        // If guide exists, return it; otherwise return an error
        if (rows.length > 0) {
            // Convert the longblob to a base64 string
            const imgBase64 = rows[0].img.toString('base64');
            const guideData = {
                name: rows[0].name,
                img: imgBase64,
                user_type: rows[0].user_type,
            };
            res.status(200).json(guideData);
        } else {
            res.status(404).json({ message: 'Tour guide not found.' });
        }
    } catch (err) {
        console.error('Error fetching tour guide data:', err);
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

export default router;
