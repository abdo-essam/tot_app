import express from 'express';
import pool from './db.js';  // Import the database connection
import authenticateJWT from './authMiddleware.js';  // Import the JWT authentication middleware

const router = express.Router();

router.get('/dashboard', authenticateJWT, async (req, res) => {
    try {
        const userId = req.user.id; // Get user ID from the token

        // Query to fetch total orders and total payments related to the Guide
        const [rows] = await pool.execute(`
            SELECT
                COUNT(o.id) AS total_orders,
                COALESCE(SUM(p.total), 0) AS total_payments,
                COALESCE(AVG(r.Rate), 0) AS average_rating
            FROM orders o
            LEFT JOIN payment p ON o.id = p.Order_id
            LEFT JOIN ratings r ON o.id = r.Order_id
            WHERE o.Guide_id = ?
        `, [userId]);

        if (rows.length > 0) {
            res.status(200).json(rows[0]);
        } else {
            res.status(200).json({ total_orders: 0, total_payments: 0, average_rating: 0 });
        }
    } catch (err) {
        console.error('Dashboard error:', err); // Log error details for debugging
        res.status(500).json({ message: "An internal server error occurred." });
    }
});

export default router;
