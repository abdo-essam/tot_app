import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import pool from './db.js';  // Import the database connection
import { JWT_SECRET } from './config.js';  // Import the JWT secret

const router = express.Router();

router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Ensure both email and password are provided
        if (!email || !password) {
            return res.status(400).json({ message: "Email and password are required." });
        }

        // Find user by email in the database
        const [rows] = await pool.execute('SELECT * FROM user WHERE email = ?', [email]);

        if (rows.length === 0) {
            return res.status(400).json({ message: "Couldn't find user with that email." });
        }

        const user = rows[0];

        // Compare the provided password with the stored hashed password
        const passwordMatch = await bcrypt.compare(password, user.Password);

        if (passwordMatch) {
            const token = jwt.sign({ id: user.id, email: user.email, user_type: user.user_type }, JWT_SECRET, { expiresIn: '1h' });
        
            res.status(200).json({
                message: "Logged in successfully",
                token: token,
                user_type: user.user_type // Include user_type in response
            });
        }
         else {
            res.status(400).json({ message: "Wrong email or password." });
        }
    } catch (err) {
        console.error('Login error:', err); // Log error details for debugging
        res.status(500).json({ message: "An internal server error occurred." });
    }
});

export default router;
