import 'package:flutter/material.dart';
import 'package:cepofis/services/firestore_service.dart';
import 'package:cepofis/models/appointment.dart';
import 'package:cepofis/models/client.dart';
import 'package:cepofis/models/portfolio.dart';
import 'package:intl/intl.dart';

class AppointmentFormPage extends StatefulWidget {
  final Appointment? appointment;

  const AppointmentFormPage({super.key, this.appointment});

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  String? _selectedClientId;
  final List<String> _selectedPortfolioIds = [];
  final List<Client> _clients = [];
  final List<Portfolio> _portfolios = [];
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _selectedClientId = widget.appointment!.clientId;
      _selectedPortfolioIds.addAll(widget.appointment!.portfolioIds);
      _notesController.text = widget.appointment!.notes;
      _date = widget.appointment!.date;
    }
    _loadClientsAndPortfolios();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadClientsAndPortfolios() async {
    try {
      final clients = await _firestoreService.getClients().first;
      final portfolios = await _firestoreService.getPortfolios().first;
      if (mounted) {
        setState(() {
          _clients.addAll(clients);
          _portfolios.addAll(portfolios);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken bir hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _date.hour, minute: _date.minute),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(
          _date.year,
          _date.month,
          _date.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (_formKey.currentState!.validate() && _selectedClientId != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final user = await _firestoreService.getCurrentUser();
        if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

        final appointment = Appointment(
          id: widget.appointment?.id ?? '',
          clientId: _selectedClientId!,
          portfolioIds: _selectedPortfolioIds,
          date: _date,
          notes: _notesController.text,
          userId: user.uid,
          createdAt: widget.appointment?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.appointment == null) {
          await _firestoreService.addAppointment(appointment);
        } else {
          if (appointment.id.isEmpty) {
            throw Exception('Düzenlenecek randevu ID\'si bulunamadı');
          }
          await _firestoreService.updateAppointment(appointment);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bir hata oluştu: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointment == null ? 'Yeni Randevu' : 'Randevu Düzenle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedClientId,
              decoration: const InputDecoration(labelText: 'Müşteri'),
              items: _clients.map((client) {
                return DropdownMenuItem(
                  value: client.id,
                  child: Text(
                    client.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClientId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Lütfen müşteri seçin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectDate,
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_date),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectTime,
                    child: Text(
                      DateFormat('HH:mm').format(_date),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Gösterilecek Portföyler'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _portfolios.map((portfolio) {
                return FilterChip(
                  label: Text(
                    portfolio.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: _selectedPortfolioIds.contains(portfolio.id),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPortfolioIds.add(portfolio.id);
                      } else {
                        _selectedPortfolioIds.remove(portfolio.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notlar'),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen not ekleyin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAppointment,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
} 