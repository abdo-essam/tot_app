import express from 'express';
import bcrypt from 'bcrypt';
import pool from './db.js';  // Import the database connection

const router = express.Router();

router.post('/register', async (req, res) => {
    try {
        const { name, email, mobile, password, user_type, country } = req.body;

        // Check if the user already exists in the database
        const [rows] = await pool.execute('SELECT * FROM user WHERE email = ?', [email]);
        if (rows.length > 0) {
            return res.status(400).send("User already exists!");
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert new user into the database
        const [result] = await pool.execute('INSERT INTO user (name, email, mobile, password, user_type) VALUES (?, ?, ?, ?, ?)', 
            [name, email, mobile, hashedPassword, user_type]);

        const userId = result.insertId; // Get the auto-generated id

        // If user type is 'tourist', insert into tourist table as well
        if (user_type === 'tourist' && country) {
            await pool.execute('INSERT INTO tourist (id, country) VALUES (?, ?)', [userId, country]);
        }

        res.status(201).send('Registered successfully');
    } catch (err) {
        res.status(500).send({ message: err.message });
    }
});

export default router;
