import jwt from 'jsonwebtoken';
import { JWT_SECRET } from './config.js';

const authenticateJWT = (req, res, next) => {
    const token = req.headers['authorization'] && req.headers['authorization'].split(' ')[1];

    if (token) {
        jwt.verify(token, JWT_SECRET, (err, user) => {
            if (err) {
                return res.sendStatus(403); // Forbidden
            }
            req.user = user; // Save user info to request for use in other routes
            next();
        });
    } else {
        res.sendStatus(401); // Unauthorized
    }
};

export default authenticateJWT;
