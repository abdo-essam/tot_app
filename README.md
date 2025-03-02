# 🏕️ TOT App

### A Flutter-based mobile app for trip planning and location management.

## 📌 Overview
TOT App is a cross-platform mobile application built using **Flutter** for the frontend and **Node.js + SQL** for the backend.  
It helps users manage trips, explore locations, and provide feedback.

## 🚀 Features
- 🔐 **User Authentication** (Register/Login)
- 📍 **Location-based Services**
- 🗺️ **Trip Management** (Booking and History)
- 📝 **User Feedback System**
- 🌎 **Cross-Platform Support** (Android & iOS)

## 🏗️ Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Node.js, Express.js
- **Database**: SQLite

## 🔧 Installation & Setup

## Project Structure

abdo-essam-tot_app/
│── README.md                   # Project introduction
│── analysis_options.yaml        # Dart analysis options
│── pubspec.yaml                 # Flutter dependencies
│── android/                     # Android-specific code
│── ios/                         # iOS-specific code
│── lib/                         # Flutter app source code
│   ├── main.dart                # App entry point
│   ├── screens/                 # UI screens
│   ├── models/                  # Data models
│   ├── services/                # Business logic & API calls
│   ├── utils/                   # Utility functions
│── assets/                      # Fonts and images
│── Backend/                     # Node.js backend
│   ├── index.js                 # Server entry point
│   ├── db.js                    # Database connection
│   ├── authMiddleware.js         # Authentication middleware
│   ├── routes/                   # API endpoints
│── tot.sql                       # Database schema


### **Frontend (Flutter)**
1. Install [Flutter](https://flutter.dev/)
2. Clone the repository:
   ```sh
   git clone https://github.com/your-username/tot_app.git
   cd tot_app
