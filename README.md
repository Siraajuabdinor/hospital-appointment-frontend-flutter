# Hospital Appointment System (Flutter)

This Flutter app is a hospital appointment management system with separate
experiences for admins, doctors, and patients. It handles authentication,
dashboards, appointment booking, schedule management, and basic CRUD flows
for users and specialties.

## Roles and Main Screens

- Admin
  - `AdminDashboardPage` for system stats, appointment monitoring, and quick actions.
  - Doctor management (create, update, delete).
  - Specialty management (create, update, delete).
  - User management and search.
  - Schedule management.


- Patient
  - `PatientHomePage` to search doctors and view profiles.
  - Appointment booking and history.
  - Appointment detail view.

## Core Features

- Multi-role login with automatic routing based on saved session.
- Appointment booking workflow for patients.
- Appointment list and filtering for doctors and admins.
- Doctor schedules and specialty management.
- Consistent system colors using app-wide constants.

## Project Structure (Flutter)

```
lib/
  api/                    # API base config
  constants/              # App constants (colors, etc.)
  controller/             # State logic (if used)
  models/                 # Data models
  services/               # API services
  utils/                  # Helpers
  main.dart               # App entry
  loginPage.dart          # Login screen
  signupPage.dart         # Signup screen
  adminDashboard.dart
  doctorDashboard.dart
  patientDashboard.dart
  appointmentBookingPage.dart
  appointmentListPage.dart
  appointmentDemoPage.dart
  adminDoctorForm.dart
  adminDoctorManagement.dart
  specialtyManagementPage.dart
  scheduleManagementPage.dart
  usersManagementPage.dart
```

## Authentication and Routing

- Login is handled in `loginPage.dart`.
- On success, user data and role are saved in `SharedPreferences`.
- `main.dart` checks saved session and routes to:
  - Admin dashboard
  - Doctor dashboard
  - Patient dashboard
  - Login page if no session

## App Theme and Colors

System colors live in `lib/constants/app_colors.dart`:

- Primary: `#0F6CBD`
- Secondary: `#2CBFAE`
- Background: `#F5F9FC`
- Text: `#1E2A38`

All screens should use these constants for consistent UI.

## Running the App

From the `fluter/` directory:

```
flutter pub get
flutter run
```

## Building Launcher Icons

`pubspec.yaml` already points to `images/hospital.png`. To generate icons:

```
flutter pub run flutter_launcher_icons
```
