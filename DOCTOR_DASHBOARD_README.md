# Doctor Dashboard

A comprehensive Flutter dashboard for doctors to view and manage their appointments.

## Features

### 📋 Appointment Management
- **View all appointments** assigned to the doctor
- **Filter appointments** by status (pending, confirmed, completed, cancelled)
- **Filter by date** - view today's appointments or select a specific date
- **Real-time statistics** showing today's count, pending, and confirmed appointments

### 🎯 Status Management
- **Confirm pending appointments** with one click
- **Cancel appointments** when necessary
- **Mark appointments as completed** after the visit

### 📊 Dashboard Statistics
- Today's appointments count
- Pending appointments count
- Confirmed appointments count

## Usage

### Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'doctorDashboard.dart';
import 'models/doctorModel.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create a doctor instance
    final doctor = Doctor(
      id: 'doctor_id_here',
      fullName: 'Dr. John Doe',
      tell: '+252612345678',
      email: 'doctor@hospital.com',
      sex: 'male',
      qualification: 'MBBS, MD',
      experienceYears: 10,
      bio: 'Experienced physician',
      status: 'active',
      spNo: '1',
    );

    return MaterialApp(
      home: DoctorDashboard(doctor: doctor),
    );
  }
}
```

### Integration Steps

1. **Ensure dependencies** are installed:
   ```bash
   flutter pub get
   ```

2. **Import the dashboard** in your navigation:
   ```dart
   import 'doctorDashboard.dart';
   ```

3. **Pass doctor data** to the dashboard:
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => DoctorDashboard(doctor: currentDoctor),
     ),
   );
   ```

## API Integration

The dashboard automatically integrates with your existing API through:
- `AppointmentService.getAppointmentsByDoctor()` - Fetches doctor's appointments
- `AppointmentService.updateAppointmentStatus()` - Updates appointment status

## UI Components

### Filter Section
- Filter chips for quick status filtering
- Date picker for specific day filtering
- Scrollable horizontal filter list

### Statistics Cards
- Real-time appointment counts
- Color-coded status indicators
- Clean card-based layout

### Appointment Cards
- Patient information display
- Appointment date and time
- Status badges with color coding
- Action buttons for status updates
- Fee information display

## Status Colors

- **Pending**: Orange 🟠
- **Confirmed**: Green 🟢
- **Completed**: Blue 🔵
- **Cancelled**: Red 🔴
- **Walk-in**: Purple 🟣

## Error Handling

The dashboard includes comprehensive error handling:
- Network error notifications
- Loading states during API calls
- User-friendly error messages
- Graceful fallbacks for empty states

## Dependencies

- `flutter` - Flutter framework
- `intl` - Date formatting
- `http` - API calls
- `cupertino_icons` - iOS-style icons

## Notes

- The dashboard automatically refreshes when appointment status is updated
- Uses the existing `AppointmentModel` and `DoctorModel` from your project
- Integrates seamlessly with your current API structure
- Responsive design works on all screen sizes
