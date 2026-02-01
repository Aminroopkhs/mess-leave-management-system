# 🍽️ Mess Leave Management System

A comprehensive digital solution for managing hostel mess leaves with QR-based food access control. The system streamlines leave applications, mess billing, and attendance tracking for educational institutions.

## 📱 Screenshots

<div align="center">

### Student Dashboard
![Student Dashboard](public/student_dashboard.png)
*Dashboard showing mess access status, current month usage, and applied leaves*

### Navigation Menu
![Navigation Menu](public/navigation_menu.png)
*Quick access to weekly menu, QR code, leave applications, and bills*

### Leave Application
![Leave Application](public/leave_application.png)
*Simple interface to apply for mess leave with date selection*

### Student Profile
![Student Profile](public/student_profile.png)
*Student profile with QR code for mess counter verification*

### Leave Calendar
![Leave Calendar](public/leave_calendar.png)
*Visual calendar showing applied leaves and savings summary*

### Date Picker
![Date Picker](public/date_picker.png)
*Intuitive date selection for leave applications*

</div>

## ✨ Features

### For Students
- 📊 **Dashboard Overview**: View mess access status, monthly usage, and current leave balance
- 🍴 **Weekly Menu**: Check the mess menu for the week
- 📅 **Leave Management**: Apply for mess leave at least 24 hours in advance
- 💰 **Billing & Savings**: Track mess bills and savings from leave days
- 🎫 **QR Code Access**: Generate unique QR code for mess counter verification
- 📱 **Google Sign-In**: Secure authentication using institutional email
- 📆 **Leave Calendar**: Visual representation of applied leaves with savings calculation

### For Management
- 📷 **QR Scanner**: Scan student QR codes to verify mess access
- 📊 **Dashboard**: Monitor daily mess attendance and leave statistics
- ✅ **Access Control**: Real-time verification of student mess access rights

### Analytics Dashboard
- 📈 **Usage Analytics**: Comprehensive charts and metrics for mess usage
- 📊 **Leave Trends**: Visualize leave patterns and attendance statistics
- 💹 **Cost Analysis**: Track mess expenses and savings

## 🏗️ Architecture

The system consists of three main components:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Student App   │────▶│   Backend API   │◀────│ Management App  │
│   (Flutter)     │     │  (FastAPI/Python)     │   (Flutter)     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌──────────────┐
                        │   Supabase   │
                        │  (Database)  │
                        └──────────────┘
                               ▲
                               │
                        ┌──────────────┐
                        │  Analytics   │
                        │  Dashboard   │
                        │   (React)    │
                        └──────────────┘
```

## 🛠️ Tech Stack

### Student App (Flutter)
- **Framework**: Flutter 3.10.3+
- **Key Packages**:
  - `qr_flutter`: QR code generation
  - `supabase_flutter`: Database integration
  - `google_sign_in`: Authentication
  - `table_calendar`: Calendar UI
  - `flutter_dotenv`: Environment configuration

### Management App (Flutter)
- **Framework**: Flutter 3.10.3+
- **Key Packages**:
  - `mobile_scanner`: QR code scanning
  - `supabase_flutter`: Database integration
  - `flutter_dotenv`: Environment configuration

### Backend API (Python)
- **Framework**: FastAPI
- **Database**: PostgreSQL (via Supabase)
- **Authentication**: Google OAuth, JWT tokens
- **Key Libraries**:
  - `sqlalchemy`: ORM
  - `asyncpg`: Async PostgreSQL driver
  - `python-jose`: JWT handling
  - `passlib`: Password hashing
  - `google-auth`: Google authentication

### Analytics Dashboard (React)
- **Framework**: React 18
- **Build Tool**: Vite
- **UI Components**: Lucide React icons
- **Charts**: Recharts
- **Database**: Supabase client

## 📁 Project Structure

```
.
├── student_app/              # Flutter app for students
│   ├── lib/
│   │   ├── screens/         # UI screens
│   │   │   ├── home_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── qr_screen.dart
│   │   │   ├── leave_screen.dart
│   │   │   ├── leave_applications_screen.dart
│   │   │   ├── menu_screen.dart
│   │   │   └── bill_screen.dart
│   │   ├── services/        # API and business logic
│   │   ├── widgets/         # Reusable UI components
│   │   └── config/          # Configuration files
│   └── pubspec.yaml
│
├── management_app/           # Flutter app for management
│   ├── lib/
│   │   ├── screens/
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── scan_qr_screen.dart
│   │   │   └── sidebar_drawer.dart
│   │   ├── services/
│   │   ├── widgets/
│   │   └── config/
│   └── pubspec.yaml
│
├── backend/                  # FastAPI backend
│   ├── main.py              # Application entry point
│   ├── requirements.txt
│   ├── api/
│   │   ├── api.py           # API router configuration
│   │   ├── routes/
│   │   │   ├── auth.py      # Authentication endpoints
│   │   │   └── health.py    # Health check endpoints
│   │   ├── models/          # Pydantic models
│   │   └── utils/           # Utility functions
│   ├── domain/
│   │   └── interfaces/      # Business logic interfaces
│   └── infrastructure/
│       ├── database/        # Database connection
│       ├── models/          # SQLAlchemy models
│       └── repositories/    # Data access layer
│
├── analytics/                # React analytics dashboard
│   └── reactApp/
│       ├── src/
│       │   ├── App.jsx
│       │   ├── main.jsx
│       │   └── index.css
│       ├── index.html
│       ├── package.json
│       └── vite.config.js
│
└── public/                   # Screenshots and assets
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.3 or higher
- Python 3.11+
- Node.js 18+
- Supabase account
- Google OAuth credentials (for student authentication)

### Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd backend
   ```

2. **Create virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment variables**:
   Create a `.env` file in the backend directory:
   ```env
   DATABASE_URL=postgresql://user:password@host:port/database
   SECRET_KEY=your-secret-key-here
   GOOGLE_CLIENT_ID=your-google-client-id
   GOOGLE_CLIENT_SECRET=your-google-client-secret
   ```

5. **Run the server**:
   ```bash
   uvicorn main:app --reload
   ```

   The API will be available at `http://localhost:8000`

### Student App Setup

1. **Navigate to student app directory**:
   ```bash
   cd student_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure environment**:
   Create a `.env` file in `student_app/`:
   ```env
   SUPABASE_URL=your-supabase-url
   SUPABASE_ANON_KEY=your-supabase-anon-key
   API_URL=http://localhost:8000/api
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### Management App Setup

1. **Navigate to management app directory**:
   ```bash
   cd management_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure environment**:
   Create a `.env` file in `management_app/`:
   ```env
   SUPABASE_URL=your-supabase-url
   SUPABASE_ANON_KEY=your-supabase-anon-key
   API_URL=http://localhost:8000/api
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### Analytics Dashboard Setup

1. **Navigate to analytics directory**:
   ```bash
   cd analytics/reactApp
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Configure environment**:
   Create a `.env` file in `analytics/reactApp/`:
   ```env
   VITE_SUPABASE_URL=your-supabase-url
   VITE_SUPABASE_ANON_KEY=your-supabase-anon-key
   ```

4. **Run the development server**:
   ```bash
   npm run dev
   ```

   The dashboard will be available at `http://localhost:5173`

## 🗄️ Database Setup

The system uses Supabase (PostgreSQL) for data storage. You'll need to set up the following tables:

- **users**: Student and staff information
- **leaves**: Leave applications and status
- **mess_access**: Daily mess access logs
- **bills**: Monthly mess billing records
- **menu**: Weekly mess menu items

## 🔐 Authentication Flow

1. **Student Login**: Google Sign-In with institutional email
2. **Token Generation**: JWT token issued by backend
3. **QR Code**: Unique QR containing student ID and access token
4. **Verification**: Management app scans QR and verifies access rights

## 📊 Key Business Rules

- Leave must be applied **at least 24 hours in advance**
- Mess rate is ₹100 per day
- Savings are calculated as: `leave_days × daily_rate`
- Students can view their leave calendar and total savings
- QR codes are generated per student for mess counter verification

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is developed for Poornima College of Engineering hostel mess management.

## 👥 Authors

- Development Team: Aminroop KHS and Pranav

## 🙏 Acknowledgments

- Flutter team for the amazing cross-platform framework
- FastAPI for the high-performance Python backend
- Supabase for the backend-as-a-service platform
- React and Vite for the analytics dashboard

---

**Note**: This system is designed specifically for educational institution hostel mess management. Make sure to configure all environment variables and database credentials before deployment.

