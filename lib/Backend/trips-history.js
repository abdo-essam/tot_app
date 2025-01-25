import express from 'express';
import pool from './db.js';  // Import the database connection
import authenticateJWT from './authMiddleware.js';  // Import the JWT authentication middleware

const router = express.Router();

router.get('/trips-history', authenticateJWT, async (req, res) => {
    try {
        const userId = req.user.id; // Get user ID from the token

        // Query to fetch tourist name, Date, trip ID, and number of tourists
        const [rows] = await pool.execute(`
            SELECT 
    u.name AS tourist_name, 
    o.date, 
    o.id AS trip_id, 
    o.tourists_num 
FROM 
    orders o
JOIN 
    tourist t ON o.Tourist_id = t.id
JOIN 
    user u ON t.id = u.id  -- Ensure this matches your actual schema
WHERE 
    o.Guide_id = ? 
AND 
    o.date < CURRENT_DATE;  -- Only past trips

        `, [userId]);

        if (rows.length > 0) {
            res.status(200).json(rows);
        } else {
            res.status(200).json([]); // Return an empty array if no past trips found
        }
    } catch (err) {
        console.error('Trips history error:', err); // Log error details for debugging
        res.status(500).json({ message: "An internal server error occurred." });
    }
});

export default router;
