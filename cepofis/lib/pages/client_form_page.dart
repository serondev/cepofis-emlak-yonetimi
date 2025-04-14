import 'package:flutter/material.dart';
import 'package:cepofis/services/firestore_service.dart';
import 'package:cepofis/models/client.dart';

class ClientFormPage extends StatefulWidget {
  final Client? client;

  const ClientFormPage({super.key, this.client});

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final List<String> _interestedTypes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _nameController.text = widget.client!.name;
      _phoneController.text = widget.client!.phone;
      _notesController.text = widget.client!.notes;
      _interestedTypes.addAll(widget.client!.interestedTypes);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final firestoreService = FirestoreService();
        final user = await firestoreService.getCurrentUser();
        if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

        final client = Client(
          id: widget.client?.id ?? '',
          name: _nameController.text,
          phone: _phoneController.text,
          interestedTypes: _interestedTypes,
          notes: _notesController.text,
          userId: widget.client?.userId ?? user.uid, // Mevcut userId'yi koru veya yeni kullanıcı ID'sini kullan
          createdAt: widget.client?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.client == null) {
          await firestoreService.addClient(client);
        } else {
          // Düzenleme işlemi için ID'nin boş olmadığından emin olalım
          if (client.id.isEmpty) {
            throw Exception('Düzenlenecek müşteri ID\'si bulunamadı');
          }
          await firestoreService.updateClient(client);
        }

        if (mounted) {
          Navigator.pop(context, true); // Başarılı işlem sonrası true döndür
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.client == null ? 'Yeni Müşteri' : 'Müşteri Düzenle',
          style: const TextStyle(color: Color(0xFF1A237E)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A237E)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Müşteri Bilgileri Formu
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
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Müşteri Bilgileri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Ad Soyad
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Ad Soyad',
                        hintText: 'Müşterinin adı soyadı',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen ad soyad girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Telefon
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefon',
                        hintText: '05XX XXX XX XX',
                        prefixIcon: const Icon(Icons.phone),
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
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen telefon girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // İlgilendiği Portföy Türleri
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'İlgilendiği Portföy Türleri',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildPropertyTypeChip('daire', 'Daire', Icons.apartment),
                            _buildPropertyTypeChip('villa', 'Villa', Icons.home),
                            _buildPropertyTypeChip('arsa', 'Arsa', Icons.terrain),
                            _buildPropertyTypeChip('is_yeri', 'İş Yeri', Icons.business),
                            _buildPropertyTypeChip('yazlik', 'Yazlık', Icons.beach_access),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Notlar
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Notlar',
                        hintText: 'Müşteri hakkında notlar',
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
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              
              // Kaydet Butonu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveClient,
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPropertyTypeChip(String type, String label, IconData icon) {
    bool isSelected = _interestedTypes.contains(type);
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : const Color(0xFF1A237E),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _interestedTypes.add(type);
          } else {
            _interestedTypes.remove(type);
          }
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1A237E),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF2D3748),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF1A237E) : Colors.grey.shade300,
        ),
      ),
      elevation: isSelected ? 2 : 0,
    );
  }
} 