# Hospital Login System

A complete authentication system that routes users to the appropriate dashboard based on their role (Admin or Doctor).

## Features

### 🔐 Authentication
- **Role-based login** - Automatically redirects to correct dashboard
- **Email validation** - Proper email format checking
- **Password validation** - Minimum length requirements
- **Loading states** - Visual feedback during authentication
- **Error handling** - User-friendly error messages

### 🎯 Role-Based Routing
- **Admin users** → Admin Dashboard
- **Doctor users** → Doctor Dashboard with their appointments
- **Automatic detection** based on user role from API response

### 🧪 Testing Mode
- **Mock login** for development and testing
- **Test credentials** built-in for easy testing
- **Toggle switch** between mock and real API

## Test Credentials

### Admin Account
- **Email**: `admin@hospital.com`
- **Password**: `admin123`
- **Redirects to**: Admin Dashboard

### Doctor Account
- **Email**: `doctor@hospital.com`
- **Password**: `doctor123`
- **Redirects to**: Doctor Dashboard (with appointments)

## Usage

### Starting the App
The app now starts with the login page automatically:

```dart
// main.dart
home: LoginPage(),
```

### Login Flow
1. User enters email and password
2. System validates input
3. API call (or mock) authenticates user
4. Based on role, user is redirected:
   - Admin → `AdminDashboardPage()`
   - Doctor → `DoctorDashboard(doctor: doctorData)`

### Integration with Real API

To use real authentication instead of mock data:

1. **Toggle off** "Use Mock Login" switch
2. **Ensure your API** returns the expected format:

```json
{
  "success": true,
  "message": "Login successful",
  "token": "jwt_token_here",
  "role": "doctor", // or "admin"
  "doctor": { // Only for doctor role
    "id": "1",
    "fullName": "Dr. John Doe",
    "tell": "+252612345678",
    "email": "doctor@hospital.com",
    "sex": "male",
    "qualification": "MBBS, MD",
    "experienceYears": 10,
    "bio": "Experienced physician",
    "status": "active",
    "spNo": "1"
  }
}
```

## File Structure

```
lib/
├── loginPage.dart              # Main login UI
├── services/
│   └── authService.dart        # Authentication logic
├── adminDashboard.dart         # Admin dashboard (existing)
├── doctorDashboard.dart        # Doctor dashboard (existing)
└── main.dart                   # App entry point
```

## API Integration

### AuthService Methods

#### `login(String email, String password)`
- Makes POST request to `/api/auth/login`
- Returns `LoginResponse` with user data and role
- Handles network errors gracefully

#### `mockLogin(String email, String password)`
- Testing method with predefined credentials
- Simulates network delay for realistic UX
- Returns mock user data based on credentials

### Error Handling

The system handles:
- **Network errors** - Connection issues, timeouts
- **Validation errors** - Invalid email/password format
- **Authentication errors** - Wrong credentials
- **Role errors** - Missing or invalid user role

## UI Features

### Login Form
- **Email field** with validation
- **Password field** with show/hide toggle
- **Loading indicator** during authentication
- **Error dialogs** for failed attempts

### Visual Design
- **Gradient background** with hospital theme
- **Card-based form** with elevation
- **Hospital icon** branding
- **Google Fonts** for typography
- **Responsive design** for all screen sizes

### Testing Mode
- **Switch toggle** for mock/real API
- **Test credentials display** when mock mode is active
- **Visual indicator** of current mode

## Security Features

### Input Validation
- **Email format** validation using regex
- **Password length** requirements (min 6 characters)
- **Empty field** validation

### API Security
- **JWT token** handling (prepared for real implementation)
- **HTTPS ready** (uses secure API client)
- **Error message sanitization** (doesn't expose sensitive info)

## Customization

### Adding New Roles
1. Update `LoginResponse` model
2. Add new navigation logic in `_login()` method
3. Create corresponding dashboard page
4. Update test credentials if needed

### Custom Styling
- Modify colors in `loginPage.dart`
- Update fonts via Google Fonts
- Adjust card styling and animations
- Customize error dialog appearance

## Dependencies

- `flutter` - Core framework
- `dio` - HTTP client for API calls
- `google_fonts` - Typography

## Next Steps

### Production Setup
1. **Disable mock mode** permanently
2. **Implement token storage** (shared_preferences/flutter_secure_storage)
3. **Add logout functionality** to dashboards
4. **Implement session management**
5. **Add password reset** feature

### Enhanced Features
- **Remember me** checkbox
- **Biometric authentication** option
- **Multi-language support**
- **Offline mode** handling
- **Account lockout** after failed attempts

## Troubleshooting

### Common Issues

**Login not working:**
- Check if mock mode is toggled correctly
- Verify test credentials are exact
- Check API endpoint configuration

**Navigation issues:**
- Ensure dashboard imports are correct
- Check role response format from API
- Verify doctor data structure

**Styling problems:**
- Run `flutter pub get` if fonts don't load
- Check Google Fonts import
- Verify gradient color definitions
