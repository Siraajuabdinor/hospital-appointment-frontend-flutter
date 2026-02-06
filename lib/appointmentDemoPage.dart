import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'models/doctorModel.dart';
import 'models/appointmentModel.dart';
import 'services/appointmentService.dart';
import 'appointmentListPage.dart';
import 'appointmentBookingPage.dart';

class AppointmentDemoPage extends StatefulWidget {
  const AppointmentDemoPage({super.key});

  @override
  State<AppointmentDemoPage> createState() => _AppointmentDemoPageState();
}

class _AppointmentDemoPageState extends State<AppointmentDemoPage> {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Sample doctor for demo
  final Doctor _sampleDoctor = Doctor(
    id: 'sample_doctor_id',
    fullName: 'Dr. Ahmed Hassan',
    qualification: 'MBBS, MD - General Medicine',
    sex: 'male',
    experienceYears: 10,
    status: 'active',
    image: 'https://randomuser.me/api/portraits/men/32.jpg',
    bio: 'Experienced general practitioner with expertise in internal medicine.',
    tell: '+252612345678',
    email: 'dr.ahmed@hospital.com',
    sp_no: 'general_medicine',
  );

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appointments = await AppointmentService.getAllAppointments();
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load appointments: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentBookingPage(
          doctor: _sampleDoctor,
          patientId: '6968d8826a687707b466d2d8', // Real patient ID from API
        ),
      ),
    ).then((result) {
      if (result != null) {
        _loadAppointments(); // Refresh the list after booking
      }
    });
  }

  void _navigateToAppointmentList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AppointmentListPage(),
      ),
    ).then((_) {
      _loadAppointments(); // Refresh when coming back
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Booking Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              color: AppColors.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to Appointment Booking System',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This demo showcases the appointment booking functionality. You can:\n\n• Book new appointments with doctors\n• View all appointments\n• Update appointment status\n• Delete appointments',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateToBooking,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Book Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _navigateToAppointmentList,
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View All'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Appointments Section
            const Text(
              'Recent Appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _loadAppointments,
                            ),
                          ],
                        ),
                      )
                    : _appointments.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No appointments yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Book your first appointment to get started',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _appointments.length > 3 ? 3 : _appointments.length,
                            itemBuilder: (context, index) {
                              final appointment = _appointments[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getStatusColor(appointment.status).withOpacity(0.1),
                                    child: Icon(
                                      Icons.event,
                                      color: _getStatusColor(appointment.status),
                                    ),
                                  ),
                                  title: Text(
                                    'Appointment #${appointment.id?.substring(0, 8) ?? 'Unknown'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date: ${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(appointment.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      appointment.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getStatusColor(appointment.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

            if (_appointments.length > 3) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _navigateToAppointmentList,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View All Appointments'),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Features Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(Icons.calendar_month, 'Easy date selection'),
                    _buildFeatureItem(Icons.access_time, 'Flexible time slots'),
                    _buildFeatureItem(Icons.attach_money, 'Transparent pricing'),
                    _buildFeatureItem(Icons.sync, 'Real-time status updates'),
                    _buildFeatureItem(Icons.phone, 'Mobile-friendly interface'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return AppColors.primary;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'walk-in':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
