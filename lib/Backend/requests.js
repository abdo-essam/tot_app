import express from 'express';
import pool from './db.js';  // Import the database connection
import authenticateJWT from './authMiddleware.js';  // Import the JWT authentication middleware

const router = express.Router();

router.get('/requests', authenticateJWT, async (req, res) => {
    try {
        const userId = req.user.id; // Get user ID from the token

        // Query to fetch Hotel, Date, tourists_num, status, days_until_trip, and tourist name
        const [rows] = await pool.execute(`
            SELECT 
                u.name AS tourist_name,  -- Tourist name from 'user' table
                t.Hotel, 
                o.date, 
                o.tourists_num, 
                o.status, 
                DATEDIFF(o.date, CURRENT_DATE) AS days_until_trip
            FROM 
                orders o
            JOIN 
                tourist t ON o.Tourist_id = t.id
            JOIN 
                user u ON o.Tourist_id = u.id  -- Join with 'user' table
            WHERE 
                o.Guide_id = ? 
            AND 
                o.date > CURRENT_DATE;  -- Only future trips
        `, [userId]);

        if (rows.length > 0) {
            res.status(200).json(rows);
        } else {
            res.status(200).json([]); // Return an empty array if no future trips found
        }
    } catch (err) {
        console.error('Requests error:', err); // Log error details for debugging
        res.status(500).json({ message: "An internal server error occurred." });
    }
});

export default router;
