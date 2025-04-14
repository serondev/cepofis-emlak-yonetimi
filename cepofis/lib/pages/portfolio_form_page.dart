import 'package:flutter/material.dart';
import 'package:cepofis/services/firestore_service.dart';
import 'package:cepofis/models/portfolio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PortfolioFormPage extends StatefulWidget {
  final Portfolio? portfolio;

  const PortfolioFormPage({super.key, this.portfolio});

  @override
  State<PortfolioFormPage> createState() => _PortfolioFormPageState();
}

class _PortfolioFormPageState extends State<PortfolioFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();
  final _roomCountController = TextEditingController();
  String _type = 'satilik';
  String _propertyType = 'daire';
  final List<String> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.portfolio != null) {
      _titleController.text = widget.portfolio!.title;
      _priceController.text = widget.portfolio!.price.toString();
      _descriptionController.text = widget.portfolio!.description;
      _locationController.text = widget.portfolio!.location;
      _areaController.text = widget.portfolio!.area.toString();
      _roomCountController.text = widget.portfolio!.roomCount.toString();
      _type = widget.portfolio!.type;
      _propertyType = widget.portfolio!.propertyType;
      _images.addAll(widget.portfolio!.images);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _roomCountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(image.path);
      });
    }
  }

  Future<void> _savePortfolio() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final portfolio = Portfolio(
          id: widget.portfolio?.id ?? '',
          userId: widget.portfolio?.userId ?? '',
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          location: _locationController.text,
          area: double.parse(_areaController.text),
          roomCount: int.parse(_roomCountController.text),
          type: _type,
          propertyType: _propertyType,
          images: _images,
          createdAt: widget.portfolio?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final firestoreService = FirestoreService();
        if (portfolio.id.isNotEmpty) {
          await firestoreService.updatePortfolio(portfolio);
        } else {
          await firestoreService.addPortfolio(portfolio);
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
          widget.portfolio == null ? 'Yeni Portföy' : 'Portföy Düzenle',
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
              // Üst bölüm - Resim Seçimi
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
                      'Portföy Görselleri',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_images.isNotEmpty) ...[
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_images[index]),
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 150,
                                          height: 150,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 16,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Resim Ekle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A237E),
                        side: const BorderSide(color: Color(0xFF1A237E)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Form Bölümü
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
                      'Portföy Bilgileri',
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
                        hintText: 'Portföy başlığını girin',
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
                    
                    // Satılık/Kiralık seçimi
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: InputDecoration(
                        labelText: 'Tür',
                        prefixIcon: const Icon(Icons.sell),
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
                        DropdownMenuItem(value: 'satilik', child: Text('Satılık')),
                        DropdownMenuItem(value: 'kiralik', child: Text('Kiralık')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _type = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Konut türü seçimi
                    DropdownButtonFormField<String>(
                      value: _propertyType,
                      decoration: InputDecoration(
                        labelText: 'Konut Türü',
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
                      items: const [
                        DropdownMenuItem(value: 'daire', child: Text('Daire')),
                        DropdownMenuItem(value: 'villa', child: Text('Villa')),
                        DropdownMenuItem(value: 'arsa', child: Text('Arsa')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _propertyType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Fiyat ve alan (grid)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: 'Fiyat',
                              hintText: '1500000',
                              prefixIcon: const Icon(Icons.attach_money),
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
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Fiyat girin';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Geçerli fiyat girin';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _areaController,
                            decoration: InputDecoration(
                              labelText: 'Alan (m²)',
                              hintText: '120',
                              prefixIcon: const Icon(Icons.square_foot),
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
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alan girin';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Geçerli alan girin';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Oda sayısı
                    TextFormField(
                      controller: _roomCountController,
                      decoration: InputDecoration(
                        labelText: 'Oda Sayısı',
                        hintText: '3',
                        prefixIcon: const Icon(Icons.meeting_room),
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
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Oda sayısı girin';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Geçerli oda sayısı girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Konum
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Konum',
                        hintText: 'Portföy konumunu girin',
                        prefixIcon: const Icon(Icons.location_on),
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
                          return 'Konum girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Açıklama
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Açıklama',
                        hintText: 'Portföy hakkında detaylı bilgi girin',
                        prefixIcon: const Icon(Icons.description),
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
                          return 'Açıklama girin';
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
                    onPressed: _isLoading ? null : _savePortfolio,
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