import express from 'express';
import pool from './db.js'; // Import the database connection
import authenticateJWT from './authMiddleware.js'; // Middleware to authenticate JWT

const router = express.Router();

// Endpoint to get tour guide details
router.get('/tour-guides', authenticateJWT, async (req, res) => {
    try {
        const [rows] = await pool.execute(`
            SELECT 
                u.name,
                TO_BASE64(u.img) AS user_profile_pic,  -- Convert binary image to Base64 string
                tg.age,
                tg.language,
                (
                    SELECT 
                        JSON_OBJECT(
                            'total_orders', COUNT(o.id),
                            'total_payments', COALESCE(SUM(p.total), 0),
                            'average_rating', COALESCE(AVG(r.Rate), 0)
                        )
                    FROM orders o
                    LEFT JOIN payment p ON o.id = p.Order_id
                    LEFT JOIN ratings r ON o.id = r.Order_id
                    WHERE o.Guide_id = tg.id
                ) AS rating
            FROM 
                user u
            INNER JOIN 
                tour_guide tg ON u.id = tg.id
            WHERE 
                u.user_type = 'Tour Guide' 
                AND tg.is_available = 1;
        `);

        if (rows.length > 0) {
            res.status(200).json(rows);
        } else {
            res.status(200).json([]); // Return an empty array if no tour guides are found
        }
    } catch (err) {
        console.error('Error fetching tour guides:', err); // Log error for debugging
        res.status(500).json({ message: 'An internal server error occurred.' });
    }
});

// Endpoint to fetch all restaurants
router.get('/restaurants', authenticateJWT, async (req, res) => {
    try {
        const [rows] = await pool.execute(`SELECT * FROM resturants`);
        res.status(200).json(rows);
    } catch (err) {
        console.error('Error fetching restaurants:', err); // Log error for debugging
        res.status(500).json({ message: 'An internal server error occurred.' });
    }
});

// Endpoint to fetch all trips
router.get('/trips', authenticateJWT, async (req, res) => {
    try {
        const [rows] = await pool.execute(`SELECT * FROM trips`);
        res.status(200).json(rows);
    } catch (err) {
        console.error('Error fetching trips:', err); // Log error for debugging
        res.status(500).json({ message: 'An internal server error occurred.' });
    }
});

export default router;
