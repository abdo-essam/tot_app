import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import registerRouter from './Register.js';
import loginRouter from './login.js';
import dashboardRouter from './dashboard.js';
import requestsRouter from './requests.js';
import tripshistoryRouter from './trips-history.js';
import feedbackRouter from './feedback.js';
import tourGuideRouter from './tourGuide.js';
import locationsRouter from './locations.js';
import setplanReadRouter from './setplanRead.js'; // Import the new API router
import trips from './trips.js';

// Load environment variables from .env file
dotenv.config();

const app = express();
const port = 8080;
app.use(cors());
app.use(express.json());

// Add logging middleware
app.use((req, res, next) => {
    console.log(`${req.method} ${req.url}`);
    next();
});

// Use route handlers
app.use('/api', registerRouter);
app.use('/api', loginRouter);
app.use('/api', dashboardRouter);
app.use('/api', requestsRouter);
app.use('/api', tripshistoryRouter);
app.use('/api', feedbackRouter);
app.use('/api', tourGuideRouter);
app.use('/api', locationsRouter);
app.use('/api', setplanReadRouter);
app.use('/api', trips); // Add the new API router here

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        success: false,
        message: 'Internal server error'
    });
});

// Handle 404
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'Route not found'
    });
});

app.listen(port, () => {
    console.log(`Server is started on port ${port}`);
});
