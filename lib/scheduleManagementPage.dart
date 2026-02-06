import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_colors.dart';
import '../models/doctorScheduleModel.dart';
import '../models/doctorModel.dart';
import '../services/doctorScheduleService.dart';
import '../services/doctorService.dart';

class ScheduleManagementPage extends StatefulWidget {
  const ScheduleManagementPage({super.key});

  @override
  State<ScheduleManagementPage> createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends State<ScheduleManagementPage> {
  List<DoctorSchedule> schedules = [];
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  String? error;
  String? selectedDoctorId;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('Loading doctor schedules...');
      final List<DoctorSchedule> schedulesData = await DoctorScheduleService.getAllDoctorSchedules();
      print('Loaded ${schedulesData.length} schedules');
      
      print('Loading doctors...');
      final List<Doctor> doctorsData = await DoctorService.getAllDoctors();
      print('Loaded ${doctorsData.length} doctors');

      setState(() {
        schedules = schedulesData;
        doctors = doctorsData.map((doctor) => {
          'id': doctor.id ?? '',
          'fullName': doctor.fullName,
        }).cast<Map<String, dynamic>>().toList();
        isLoading = false;
      });
      
      print('State updated. Schedules: ${schedules.length}, Doctors: ${doctors.length}');
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  List<DoctorSchedule> get filteredSchedules {
    var filtered = schedules;
    
    if (selectedDoctorId != null && selectedDoctorId!.isNotEmpty) {
      filtered = filtered.where((schedule) => schedule.docNo == selectedDoctorId).toList();
    }
    
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((schedule) => 
        schedule.day.toLowerCase().contains(searchQuery.toLowerCase()) ||
        schedule.startTime.toLowerCase().contains(searchQuery.toLowerCase()) ||
        schedule.endTime.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Schedule Management",
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: _showAddScheduleDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(error!, style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildFilters(),
                    Expanded(child: _buildScheduleList()),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search schedules...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  hint: const Text('All Doctors'),
                  value: selectedDoctorId,
                  underline: Container(),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Doctors'),
                    ),
                    ...doctors.map((doctor) => DropdownMenuItem<String>(
                      value: doctor['id'],
                      child: Text(doctor['fullName']),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedDoctorId = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    final filtered = filteredSchedules;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.schedule, size: 48, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              "No schedules found",
              style: GoogleFonts.manrope(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your filters or add a new schedule",
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  'Schedules',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  '${filtered.length} items',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        final schedule = filtered[index - 1];
        String doctorName = 'Unknown Doctor';
        
        // Try to find doctor in the list
        if (doctors.isNotEmpty) {
          try {
            final doctor = doctors.firstWhere(
              (doc) => doc['id'] == schedule.docNo,
              orElse: () => {'fullName': 'Unknown Doctor'},
            );
            doctorName = doctor['fullName'];
          } catch (e) {
            doctorName = 'Unknown Doctor';
          }
        }
        
        return _ScheduleCard(
          schedule: schedule,
          doctorName: doctorName,
          onEdit: () => _showEditScheduleDialog(schedule),
          onDelete: () => _showDeleteDialog(schedule),
        );
      },
    );
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => _ScheduleDialog(
        doctors: doctors,
        schedules: schedules,
        onSave: (schedule) async {
          try {
            await DoctorScheduleService.createDoctorSchedule(schedule);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Schedule created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error creating schedule: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditScheduleDialog(DoctorSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleDialog(
        doctors: doctors,
        schedules: schedules,
        existingSchedule: schedule,
        onSave: (updatedSchedule) async {
          try {
            await DoctorScheduleService.updateDoctorSchedule(schedule.id!, updatedSchedule);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Schedule updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating schedule: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteDialog(DoctorSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text('Are you sure you want to delete the schedule for ${schedule.day}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await DoctorScheduleService.deleteDoctorSchedule(schedule.id!);
                Navigator.of(context).pop();
                _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Schedule deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting schedule: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final DoctorSchedule schedule;
  final String doctorName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.doctorName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final initials = doctorName.isNotEmpty
        ? doctorName.trim().split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase()
        : 'DR';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFF7F9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    initials,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _InfoPill(
                            icon: Icons.calendar_today,
                            label: schedule.day,
                          ),
                          _InfoPill(
                            icon: Icons.access_time,
                            label: '${schedule.startTime} - ${schedule.endTime}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            if (schedule.maxAppointments != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'Max appointments: ${schedule.maxAppointments}',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleDialog extends StatefulWidget {
  final List<Map<String, dynamic>> doctors;
  final List<DoctorSchedule> schedules;
  final DoctorSchedule? existingSchedule;
  final Function(DoctorSchedule) onSave;

  const _ScheduleDialog({
    required this.doctors,
    required this.schedules,
    this.existingSchedule,
    required this.onSave,
  });

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  String? selectedDoctorId;
  String selectedDay = 'Monday';
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);
  final maxAppointmentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingSchedule != null) {
      selectedDoctorId = widget.existingSchedule!.docNo;
      selectedDay = widget.existingSchedule!.day;
      
      final startParts = widget.existingSchedule!.startTime.split(':');
      startTime = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
      
      final endParts = widget.existingSchedule!.endTime.split(':');
      endTime = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
      
      if (widget.existingSchedule!.maxAppointments != null) {
        maxAppointmentsController.text = widget.existingSchedule!.maxAppointments.toString();
      }
    }
  }

  @override
  void dispose() {
    maxAppointmentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingSchedule == null ? 'Add Schedule' : 'Edit Schedule'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Doctor',
                  border: OutlineInputBorder(),
                ),
                value: selectedDoctorId,
                items: widget.doctors.map((doctor) => DropdownMenuItem<String>(
                  value: doctor['id'],
                  child: Text(doctor['fullName']),
                )).toList(),
                validator: (value) => value == null ? 'Please select a doctor' : null,
                onChanged: (value) {
                  setState(() {
                    selectedDoctorId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Day',
                  border: OutlineInputBorder(),
                ),
                value: selectedDay,
                items: DoctorSchedule.days.map((day) => DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDay = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start Time'),
                      subtitle: Text(startTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (picked != null) {
                          setState(() {
                            startTime = picked;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListTile(
                      title: const Text('End Time'),
                      subtitle: Text(endTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (picked != null) {
                          setState(() {
                            endTime = picked;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: maxAppointmentsController,
                decoration: const InputDecoration(
                  labelText: 'Max Appointments (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final existing = widget.schedules.any((s) {
                if (widget.existingSchedule != null && s.id == widget.existingSchedule!.id) {
                  return false;
                }
                return s.docNo == selectedDoctorId && s.day == selectedDay;
              });

              if (existing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Schedule already exists for $selectedDay'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final schedule = DoctorSchedule(
                docNo: selectedDoctorId!,
                day: selectedDay,
                startTime: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                endTime: '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                maxAppointments: maxAppointmentsController.text.isNotEmpty 
                    ? int.parse(maxAppointmentsController.text) 
                    : null,
              );
              widget.onSave(schedule);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
