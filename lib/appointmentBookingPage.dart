import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:fluter/api/api.dart';
import 'models/appointmentModel.dart';
import 'models/doctorModel.dart';
import 'models/doctorScheduleModel.dart';
import 'services/appointmentService.dart';
import 'services/doctorScheduleService.dart';

class AppointmentBookingPage extends StatefulWidget {
  final Doctor doctor;
  final String? patientId;

  const AppointmentBookingPage({
    super.key, 
    required this.doctor, 
    this.patientId
  });

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final _feeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<DoctorSchedule> _doctorSchedules = [];
  bool _isLoadingSchedules = true;

  @override
  void initState() {
    super.initState();
    // Set default fee (you might want to get this from doctor data)
    _feeController.text = '50.00'; // Default consultation fee
    _loadDoctorSchedules();
  }

  @override
  void dispose() {
    _feeController.dispose();
    super.dispose();
  }

  // Load doctor's schedule
  Future<void> _loadDoctorSchedules() async {
    try {
      print('Loading schedules for doctor: ${widget.doctor.id}');
      final schedules = await DoctorScheduleService.getDoctorSchedules(widget.doctor.id!);
      print('Loaded ${schedules.length} schedules');
      setState(() {
        _doctorSchedules = schedules;
        _isLoadingSchedules = false;
      });
    } catch (e) {
      print('Error loading schedules: $e');
      setState(() {
        _isLoadingSchedules = false;
        _errorMessage = 'Failed to load doctor schedule: $e';
      });
    }
  }


  // Check if a date is a working day for the doctor
  List<String> get _workingDays {
    if (_doctorSchedules.isEmpty) return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return _doctorSchedules.map((schedule) => schedule.day).toList();
  }

  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Monday';
    }
  }


  // Helper to check if a date is selectable (is a working day)
  bool _isDateSelectable(DateTime date) {
    if (_doctorSchedules.isEmpty) return true;
    
    final dayOfWeek = _getDayOfWeek(date);
    return _doctorSchedules.any((schedule) => 
      schedule.day.toLowerCase() == dayOfWeek.toLowerCase()
    );
  }

  // Helper to find the first available date to use as initialDate
  DateTime _getInitialDate() {
    final now = DateTime.now();
    // Default start searching from tomorrow
    DateTime candidate = now.add(const Duration(days: 1));
    
    // If we already have a selected date and it's valid/future, try to use it
    if (_selectedDate != null && _selectedDate!.isAfter(now)) {
       if (_isDateSelectable(_selectedDate!)) {
         return _selectedDate!;
       }
    }
    
    // Otherwise search for the next valid working day within 90 days
    for (int i = 0; i < 90; i++) {
      if (_isDateSelectable(candidate)) {
        return candidate;
      }
      candidate = candidate.add(const Duration(days: 1));
    }
    
    // Fallback: return tomorrow even if invalid (will cause picker to behave oddly but avoids infinite loops)
    return now.add(const Duration(days: 1));
  }

  Future<void> _selectDate() async {
    print('Opening date picker...');
    
    // Find a valid initial date. 
    // Flutter's showDatePicker crashes if initialDate is not allowed by selectableDayPredicate.
    final initialDate = _getInitialDate();
    final firstDate = DateTime.now();
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      selectableDayPredicate: _isDateSelectable,
    );
    
    if (picked != null && picked != _selectedDate) {
      print('Date selected: ${picked.day}/${picked.month}/${picked.year}');
      setState(() {
        _selectedDate = picked;
      });
    } else {
      print('No date selected or same date');
    }
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.patientId == null || widget.patientId!.isEmpty) {
      setState(() {
        _errorMessage = 'Patient ID is required for booking';
      });
      return;
    }

    // Validate that patientId is a valid MongoDB ObjectId (24 character hex string)
    if (!RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(widget.patientId!)) {
      setState(() {
        _errorMessage = 'Invalid patient ID format. Please use a valid MongoDB ObjectId.';
      });
      return;
    }

    // Validate Date Selection
    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Please select a date for the appointment';
      });
      return;
    }

    // Validate Doctor ID
    if (widget.doctor.id == null) {
       setState(() {
        _errorMessage = 'Doctor ID is missing';
      });
      return; 
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appointment = AppointmentModel(
        pNo: widget.patientId!,
        docNo: widget.doctor.id!,
        date: _selectedDate!,
        fee: double.tryParse(_feeController.text) ?? 50.0,
        status: 'pending',
      );

      final createdAppointment = await AppointmentService.createAppointment(appointment);

      if (mounted) {
        final serialNumber = createdAppointment.serialNumber;
        final serialText = serialNumber != null
            ? 'Your number is $serialNumber'
            : 'Your number will be assigned shortly';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment booked successfully! $serialText'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Navigate back or to appointment details
        Navigator.of(context).pop(createdAppointment);
      }
    } catch (e) {
      setState(() {
        final message = e.toString().replaceFirst('Exception: ', '');
        _errorMessage = message.isNotEmpty
            ? message
            : 'Failed to book appointment. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Information Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.doctor.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.doctor.qualification ?? 'General Practitioner',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Doctor's Working Days Information
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
                        'Doctor\'s Working Days',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_isLoadingSchedules)
                        const Center(child: CircularProgressIndicator())
                      else if (_doctorSchedules.isEmpty)
                        Text(
                          'No schedule information available',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _workingDays.map((day) {
                            final isToday = _selectedDate != null && 
                                _getDayOfWeek(_selectedDate!).toLowerCase() == day.toLowerCase();
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isToday ? AppColors.primary : Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isToday ? AppColors.primary : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isToday ? Colors.white : Colors.black87,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'You can only book appointments on highlighted working days.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Date Selection
              _buildSectionTitle('Select Date'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Choose appointment date',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate != null ? Colors.black : Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Fee Information
              _buildSectionTitle('Consultation Fee'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _feeController,
                readOnly: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter consultation fee';
                  }
                  final fee = double.tryParse(value);
                  if (fee == null || fee <= 0) {
                    return 'Please enter a valid fee';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Book Button - Fixed at bottom with proper spacing
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                  left: 16,
                  right: 16,
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Booking...'),
                          ],
                        )
                      : const Text(
                          'Book Appointment',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}
