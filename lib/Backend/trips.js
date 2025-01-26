import express from 'express';
import db from './db.js';
import authenticateJWT from './authMiddleware.js';

const router = express.Router();

// Create new trip order
router.post('/create-trip', authenticateJWT, async (req, res) => {
    const {
        tourist_id,
        guide_id,
        tourists_num,
        date
    } = req.body;

    try {
        const [result] = await db.execute(
            `INSERT INTO orders (Tourist_id, Guide_id, tourists_num, date, status)
             VALUES (?, ?, ?, ?, 1)`, // status 1 for active trip
            [tourist_id, guide_id, tourists_num, date]
        );

        res.status(201).json({
            success: true,
            message: 'Trip created successfully',
            data: {
                trip_id: result.insertId,
                tourist_id,
                guide_id,
                tourists_num,
                date,
                status: 1
            }
        });
    } catch (err) {
        console.error('Error creating trip:', err);
        res.status(500).json({
            success: false,
            message: 'Failed to create trip',
            error: err.message
        });
    }
});

// Update trip status
router.put('/update-trip-status/:tripId', authenticateJWT, async (req, res) => {
    const { status } = req.body;
    const tripId = req.params.tripId;

    try {
        await db.execute(
            'UPDATE orders SET status = ? WHERE id = ?',
            [status, tripId]
        );

        res.status(200).json({
            success: true,
            message: 'Trip status updated successfully'
        });
    } catch (err) {
        console.error('Error updating trip status:', err);
        res.status(500).json({
            success: false,
            message: 'Failed to update trip status'
        });
    }
});

export default router;