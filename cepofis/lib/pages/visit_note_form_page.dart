import 'package:flutter/material.dart';
import 'package:cepofis/services/firestore_service.dart';
import 'package:cepofis/models/visit_note.dart';
import 'package:cepofis/models/client.dart';
import 'package:cepofis/models/portfolio.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class VisitNoteFormPage extends StatefulWidget {
  final VisitNote? visitNote;

  const VisitNoteFormPage({super.key, this.visitNote});

  @override
  State<VisitNoteFormPage> createState() => _VisitNoteFormPageState();
}

class _VisitNoteFormPageState extends State<VisitNoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  String? _selectedClientId;
  String? _selectedPortfolioId;
  String _status = 'active';
  final List<Client> _clients = [];
  final List<Portfolio> _portfolios = [];
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    if (widget.visitNote != null) {
      _titleController.text = widget.visitNote!.title;
      _notesController.text = widget.visitNote!.notes;
      _date = widget.visitNote!.date;
      _selectedClientId = widget.visitNote!.clientId;
      _selectedPortfolioId = widget.visitNote!.portfolioId;
      _status = widget.visitNote!.status;
    }
    _loadClientsAndPortfolios();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadClientsAndPortfolios() async {
    setState(() {
      _isLoadingData = true;
    });
    
    try {
      final firestoreService = FirestoreService();
      final clients = await firestoreService.getClients().first;
      final portfolios = await firestoreService.getPortfolios().first;
      
      if (mounted) {
        setState(() {
          _clients.addAll(clients);
          _portfolios.addAll(portfolios);
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata oluştu: $e')),
        );
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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

  Future<void> _saveVisitNote() async {
    if (_formKey.currentState!.validate() && _selectedClientId != null && _selectedPortfolioId != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final firestoreService = FirestoreService();
        final currentUser = await firestoreService.getCurrentUser();
        
        if (currentUser == null) {
          throw Exception('Kullanıcı oturumu bulunamadı');
        }

        final visitNote = VisitNote(
          id: widget.visitNote?.id ?? '',
          title: _titleController.text,
          notes: _notesController.text,
          date: _date,
          clientId: _selectedClientId!,
          portfolioId: _selectedPortfolioId!,
          userId: currentUser.uid,
          createdAt: widget.visitNote?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          status: _status,
        );

        if (visitNote.id.isNotEmpty) {
          await firestoreService.updateVisitNote(visitNote);
        } else {
          await firestoreService.addVisitNote(visitNote);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bir hata oluştu. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.red,
            ),
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.visitNote == null ? 'Yeni Ziyaret Notu' : 'Ziyaret Notu Düzenle',
          style: const TextStyle(color: Color(0xFF1A237E)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A237E)),
      ),
      body: _isLoadingData
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.indigo.shade700,
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Üst kısım - Tarih seçimi
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ziyaret Tarihi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _selectDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.indigo.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(_date),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Ana form alanı
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ziyaret Bilgileri',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Başlık
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Başlık',
                              hintText: 'Ziyaret başlığını girin',
                              prefixIcon: const Icon(Icons.title),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1A237E)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen başlık girin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Müşteri seçimi
                          DropdownButtonFormField<String>(
                            value: _selectedClientId,
                            decoration: InputDecoration(
                              labelText: 'Müşteri',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1A237E)),
                              ),
                            ),
                            items: _clients.map((client) {
                              return DropdownMenuItem(
                                value: client.id,
                                child: Text(client.name),
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
                          
                          // Portföy seçimi
                          DropdownButtonFormField<String>(
                            value: _selectedPortfolioId,
                            decoration: InputDecoration(
                              labelText: 'Portföy',
                              prefixIcon: const Icon(Icons.home),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1A237E)),
                              ),
                            ),
                            items: _portfolios.map((portfolio) {
                              return DropdownMenuItem(
                                value: portfolio.id,
                                child: Text(portfolio.title),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPortfolioId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Lütfen portföy seçin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Durum seçimi
                          DropdownButtonFormField<String>(
                            value: _status,
                            decoration: InputDecoration(
                              labelText: 'Durum',
                              prefixIcon: const Icon(Icons.flag),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1A237E)),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'active',
                                child: Text('Aktif'),
                              ),
                              DropdownMenuItem(
                                value: 'favorite',
                                child: Text('Favori'),
                              ),
                              DropdownMenuItem(
                                value: 'not_interested',
                                child: Text('İlgilenmiyor'),
                              ),
                              DropdownMenuItem(
                                value: 'want_to_see_again',
                                child: Text('Tekrar Görmek İstiyor'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _status = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Notlar
                          TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: 'Notlar',
                              hintText: 'Ziyaret hakkında notlar girin',
                              prefixIcon: const Icon(Icons.note),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1A237E)),
                              ),
                            ),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen not girin';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Kaydet Butonu
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveVisitNote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.indigo.shade300,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Kaydet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
} 