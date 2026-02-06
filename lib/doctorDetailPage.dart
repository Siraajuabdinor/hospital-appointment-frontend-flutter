import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'package:fluter/api/api.dart';
import 'models/doctorModel.dart';
import 'models/doctorScheduleModel.dart';
import 'services/doctorScheduleService.dart';
import 'appointmentBookingPage.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;
  final String? patientId;

  const DoctorDetailPage({
    super.key, 
    required this.doctor,
    this.patientId,
  });

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  List<DoctorSchedule> schedules = [];
  bool isLoadingSchedules = true;
  String? scheduleError;

  @override
  void initState() {
    super.initState();
    _loadDoctorSchedules();
  }

  Future<void> _loadDoctorSchedules() async {
    try {
      final doctorSchedules = await DoctorScheduleService.getDoctorSchedules(widget.doctor.id!);
      setState(() {
        schedules = doctorSchedules;
        isLoadingSchedules = false;
        scheduleError = null;
      });
    } catch (e) {
      setState(() {
        isLoadingSchedules = false;
        scheduleError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Profile Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Profile Image
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: ApiClient.resolveImageUrl(widget.doctor.image).isNotEmpty
                            ? NetworkImage(ApiClient.resolveImageUrl(widget.doctor.image))
                            : null,
                        child: ApiClient.resolveImageUrl(widget.doctor.image).isEmpty
                            ? Text(
                                widget.doctor.fullName.substring(0, 2).toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Name and Status
                    Column(
                      children: [
                        Text(
                          widget.doctor.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.doctor.status == 'active'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.doctor.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.doctor.status == 'active'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Qualification
                    Text(
                      widget.doctor.qualification ?? 'General Practitioner',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Professional Information
            _buildSectionCard(
              title: 'Professional Information',
              children: [
                if (widget.doctor.specialtyName != null &&
                    widget.doctor.specialtyName!.isNotEmpty)
                  _buildInfoRow(Icons.medical_services, 'Specialty', widget.doctor.specialtyName!),
                _buildInfoRow(Icons.person, 'Gender', widget.doctor.sex),
                _buildInfoRow(Icons.work, 'Experience', '${widget.doctor.experienceYears} years'),
                if (widget.doctor.bio != null && widget.doctor.bio!.isNotEmpty)
                  _buildBioRow(Icons.description, 'Bio', widget.doctor.bio!),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Schedule Information
            _buildScheduleSection(),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (widget.patientId == null) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please log in as a patient to book appointments'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentBookingPage(
                              doctor: widget.doctor,
                              patientId: widget.patientId,
                            ),
                          ),
                        );
                        
                        if (result != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Appointment booked successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Book Appointment',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back to List',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioRow(IconData icon, String label, String bio) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                '$label:',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              bio,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return _buildSectionCard(
      title: 'Schedule Information',
      children: [
        if (isLoadingSchedules)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (scheduleError != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Error loading schedule: $scheduleError',
                style: TextStyle(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (schedules.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No schedule available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...schedules.map((schedule) => _buildScheduleRow(schedule)).toList(),
      ],
    );
  }

  Widget _buildScheduleRow(DoctorSchedule schedule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.day,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${schedule.startTime} - ${schedule.endTime}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (schedule.maxAppointments != null) ...[
                        const SizedBox(width: 8),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        //   decoration: BoxDecoration(
                        //     color: Colors.green[100],
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   child: Text(
                        //     'Max: ${schedule.maxAppointments}',
                        //     style: TextStyle(
                        //       fontSize: 11,
                        //       color: Colors.green[800],
                        //       fontWeight: FontWeight.w500,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
