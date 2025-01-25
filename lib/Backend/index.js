import express from 'express';
import dotenv from 'dotenv';
import registerRouter from './Register.js';
import loginRouter from './login.js';
import dashboardRouter from './dashboard.js';
import requestsRouter from './requests.js';
import tripshistoryRouter from './trips-history.js';
import feedbackRouter from './feedback.js';
import tourGuideRouter from './tourGuide.js';
import locationsRouter from './locations.js';
import setplanReadRouter from './setplanRead.js'; // Import the new API router


// Load environment variables from .env file
dotenv.config();

const app = express();
const port = 8080;

app.use(express.json());

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

app.listen(port, () => {
    console.log(`Server is started on port ${port}`);
});
