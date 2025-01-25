import express from 'express';
import pool from './db.js'; // Import the database connection
import authenticateJWT from './authMiddleware.js'; // JWT middleware to authenticate

const router = express.Router();

router.get('/feedback', authenticateJWT, async (req, res) => {
    try {
        const guideId = req.user.id; // Get the Guide ID from the token

        // SQL Query to get img, Rate, Feedback, and date related to the tour guide
        const [rows] = await pool.execute(`
            SELECT 
                u.name,
                TO_BASE64(u.img) AS user_profile_pic,  -- Convert binary image to Base64 string
                r.Feedback,
                r.Rate,
                o.date
            FROM 
                ratings r
            JOIN 
                orders o ON r.Order_id = o.id
            JOIN 
                tourist t ON o.Tourist_id = t.id
            JOIN 
                user u ON t.id = u.id  -- Ensure this matches your actual schema
            WHERE 
                o.Guide_id = ?;  -- Filter by the logged-in tour guide's ID
        `, [guideId]);

        // If feedback exists, return it; otherwise return an empty array
        if (rows.length > 0) {
            res.status(200).json(rows);
        } else {
            res.status(200).json([]); // Return an empty array if no feedback found
        }
    } catch (err) {
        console.error('Feedback error:', err); // Log error for debugging
        res.status(500).json({ message: 'An internal server error occurred.' });
    }
});

export default router;
