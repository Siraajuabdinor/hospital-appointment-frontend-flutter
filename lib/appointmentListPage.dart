import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'models/appointmentModel.dart';
import 'services/appointmentService.dart';

class AppointmentListPage extends StatefulWidget {
  final String? patientId;
  final String? doctorId;

  const AppointmentListPage({
    super.key,
    this.patientId,
    this.doctorId,
  });

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  // Store appointments with their resolved names
  List<Map<String, dynamic>> _enrichedAppointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<AppointmentModel> appointments;
      final isPatientView = widget.patientId != null;
      
      if (widget.patientId != null) {
        appointments = await AppointmentService.getAppointmentsByPatient(widget.patientId!);
      } else if (widget.doctorId != null) {
        appointments = await AppointmentService.getAppointmentsByDoctor(widget.doctorId!);
      } else {
        appointments = await AppointmentService.getAllAppointments();
      }

      // Enrich appointments with Doctor and Patient names
      List<Map<String, dynamic>> enriched = [];
      
      for (var app in appointments) {
        String docName = app.doctorName?.trim() ?? '';
        if (docName.isEmpty) {
          docName = 'Unknown Doctor';
        }

        String patName = app.patientName?.trim() ?? '';
        if (patName.isEmpty) {
          patName = 'Unknown Patient';
        }

        // Avoid protected lookups in patient view
        if (!isPatientView) {
          // Fallback: if names are still unknown, keep placeholders
          // (Admin/doctor views typically get populated names from backend.)
        }

        enriched.add({
          'appointment': app,
          'doctorName': docName,
          'patientName': patName,
        });
      }

      if (mounted) {
        setState(() {
          _enrichedAppointments = enriched;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load appointments: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      await AppointmentService.updateAppointmentStatus(appointmentId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAppointments(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadAppointments, child: const Text('Retry'))
                  ],
                ),
              )
            : _enrichedAppointments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No appointments found', style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _enrichedAppointments.length,
                  itemBuilder: (context, index) {
                    final item = _enrichedAppointments[index];
                    final AppointmentModel appointment = item['appointment'];
                    final String doctorName = item['doctorName'];
                    final String patientName = item['patientName'];
                    
                    final canUpdateStatus = widget.patientId == null;
                    return _SimplifiedAppointmentCard(
                      appointment: appointment,
                      doctorName: doctorName,
                      patientName: patientName,
                      index: index + 1,
                      canUpdateStatus: canUpdateStatus,
                      onStatusUpdate: canUpdateStatus
                          ? (newStatus) => _updateAppointmentStatus(appointment.id!, newStatus)
                          : null,
                    );
                  },
                ),
    );
  }
}

class _SimplifiedAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final String doctorName;
  final String patientName;
  final int index;
  final bool canUpdateStatus;
  final Function(String)? onStatusUpdate;

  const _SimplifiedAppointmentCard({
    required this.appointment,
    required this.doctorName,
    required this.patientName,
    required this.index,
    required this.canUpdateStatus,
    this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Serial Number Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  (appointment.serialNumber ?? index).toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Main Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Name
                  Text(
                    '$patientName',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Doctor Name
                  Text(
                    'Dr. $doctorName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Serial Number
                  Text(
                    'Number: ${appointment.serialNumber ?? index}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _formatDate(appointment.date),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Status Badge
            const SizedBox(width: 8), // Reduced spacing to save space
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(appointment.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(appointment.status).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(appointment.status),
                    size: 14,
                    color: _getStatusColor(appointment.status),
                  ),
                  const SizedBox(width: 6),
                  Flexible( // Also make status text flexible just in case
                    child: Text(
                      appointment.status.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(appointment.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (canUpdateStatus) ...[
              // Update Status Button
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  onSelected: onStatusUpdate,
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'pending', child: Text('Pending')),
                    const PopupMenuItem(value: 'confirmed', child: Text('Confirmed')),
                    const PopupMenuItem(value: 'completed', child: Text('Completed')),
                    const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_outlined;
      case 'confirmed':
        return Icons.event_available_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return AppColors.primary;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
