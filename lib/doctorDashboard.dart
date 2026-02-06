import 'package:fluter/models/userModel.dart';
import 'package:fluter/api/api.dart';
import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'package:intl/intl.dart';
import '../models/appointmentModel.dart';
import '../services/appointmentService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginPage.dart';

class DoctorDashboard extends StatefulWidget {
  final UserModel doctor;

  const DoctorDashboard({Key? key, required this.doctor}) : super(key: key);


  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  List<AppointmentModel> appointments = [];
  List<AppointmentModel> filteredAppointments = [];
  bool isLoading = true;
  String selectedFilter = 'confirmed';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() {
        isLoading = true;
      });

      final doctorAppointments = await AppointmentService.getAppointmentsByDoctor(widget.doctor.id);
      
      setState(() {
        appointments = doctorAppointments;
        // Automatically filter confirmed appointments by default
        filteredAppointments = doctorAppointments.where((appointment) => 
          appointment.status == 'confirmed').toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading appointments: $e')),
      );
    }
  }

  void _filterAppointments(String filter) {
    setState(() {
      selectedFilter = filter;
      selectedDate = null;
      
      switch (filter) {
        case 'today':
          final today = DateTime.now();
          filteredAppointments = appointments.where((appointment) {
            return appointment.date.year == today.year &&
                   appointment.date.month == today.month &&
                   appointment.date.day == today.day;
          }).toList();
          break;
        case 'pending':
          filteredAppointments = appointments.where((appointment) => 
            appointment.status == 'pending').toList();
          break;
        case 'confirmed':
          filteredAppointments = appointments.where((appointment) => 
            appointment.status == 'confirmed').toList();
          break;
        case 'completed':
          filteredAppointments = appointments.where((appointment) => 
            appointment.status == 'completed').toList();
          break;
        case 'cancelled':
          filteredAppointments = appointments.where((appointment) => 
            appointment.status == 'cancelled').toList();
          break;
        default:
          filteredAppointments = appointments;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedFilter = 'date';
        filteredAppointments = appointments.where((appointment) {
          return appointment.date.year == picked.year &&
                 appointment.date.month == picked.month &&
                 appointment.date.day == picked.day;
        }).toList();
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return Colors.red;
      case 'walk-in':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      await AppointmentService.updateAppointmentStatus(appointmentId, newStatus);
      await _loadAppointments();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating appointment: $e')),
      );
    }
  }

  void _showAppointmentDetails(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appointment Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Patient ID:', appointment.pNo),
                if (appointment.patientName != null)
                  _buildDetailRow('Patient Name:', appointment.patientName!),
                _buildDetailRow('Date:', DateFormat('EEEE, MMM dd, yyyy').format(appointment.date)),
                _buildDetailRow('Status:', appointment.status.toUpperCase()),
                _buildDetailRow('Fee:', '\$${appointment.fee.toStringAsFixed(2)}'),
                if (appointment.createdAt != null)
                  _buildDetailRow('Booked on:', DateFormat('MMM dd, yyyy HH:mm').format(appointment.createdAt!)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            if (appointment.status == 'confirmed')
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _updateAppointmentStatus(appointment.id!, 'completed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text('Mark as Completed'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: ApiClient.resolveImageUrl(widget.doctor.image).isNotEmpty
                  ? NetworkImage(ApiClient.resolveImageUrl(widget.doctor.image))
                  : null,
              child: ApiClient.resolveImageUrl(widget.doctor.image).isEmpty
                  ? Text(
                      widget.doctor.fullName.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Dr. ${widget.doctor.fullName} Dashboard',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildStatsSection(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredAppointments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              selectedFilter == 'confirmed' 
                                  ? 'No confirmed appointments found'
                                  : 'No appointments found',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                            if (selectedFilter == 'confirmed')
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Only confirmed appointments are shown by default',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: filteredAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = filteredAppointments[index];
                          return _buildAppointmentCard(appointment);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!context.mounted) return;
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Appointments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Today', 'today'),
                _buildFilterChip('Pending', 'pending'),
                _buildFilterChip('Confirmed', 'confirmed'),
                _buildFilterChip('Completed', 'completed'),
                _buildFilterChip('Cancelled', 'cancelled'),
                _buildDateFilterChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selectedFilter == value,
        onSelected: (selected) {
          if (selected) {
            _filterAppointments(value);
          }
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDateFilterChip() {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(selectedDate != null 
            ? DateFormat('MMM dd, yyyy').format(selectedDate!)
            : 'Select Date'),
        selected: selectedFilter == 'date',
        onSelected: (selected) {
          if (selected) {
            _selectDate(context);
          }
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildStatsSection() {
    final todayCount = appointments.where((apt) {
      final today = DateTime.now();
      return apt.date.year == today.year &&
             apt.date.month == today.month &&
             apt.date.day == today.day;
    }).length;

    final pendingCount = appointments.where((apt) => apt.status == 'pending').length;
    final confirmedCount = appointments.where((apt) => apt.status == 'confirmed').length;

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Today', todayCount.toString(), AppColors.primary),
          _buildStatItem('Pending', pendingCount.toString(), Colors.orange),
          _buildStatItem('Confirmed', confirmedCount.toString(), Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName ?? 'Patient ID: ${appointment.pNo}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (appointment.patientName == null)
                        SizedBox(height: 4),
                      if (appointment.patientName == null)
                        Text(
                          'Patient ID: ${appointment.pNo}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(appointment.date),
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fee: \$${appointment.fee.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => _showAppointmentDetails(appointment),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                      ),
                      child: Text('View Details'),
                    ),
                    if (appointment.status == 'confirmed') ...[
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _updateAppointmentStatus(appointment.id!, 'completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Complete'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}