import 'package:flutter/material.dart';
import 'package:cepofis/services/firestore_service.dart';
import 'package:cepofis/models/visit_note.dart';
import 'package:cepofis/pages/visit_note_form_page.dart';
import 'package:intl/intl.dart';

class VisitNotesPage extends StatefulWidget {
  const VisitNotesPage({super.key});

  @override
  State<VisitNotesPage> createState() => _VisitNotesPageState();
}

class _VisitNotesPageState extends State<VisitNotesPage> {
  final firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    // Ekran boyutlarını al
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final bool isSmallPhone = screenWidth < 360;
    
    // Responsive boyutlar
    final double padding = isSmallPhone ? 8.0 : 12.0;
    final double titleFontSize = isSmallPhone ? 16.0 : 20.0;
    final double subtitleFontSize = isSmallPhone ? 12.0 : 14.0;
    final double iconSize = isSmallPhone ? 20.0 : 24.0;
    final double avatarRadius = isSmallPhone ? 16.0 : 20.0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ziyaret Notlarım',
          style: TextStyle(fontSize: titleFontSize),
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepOrange,
              Colors.deepOrange.shade200,
            ],
          ),
        ),
        child: StreamBuilder<List<VisitNote>>(
          stream: firestoreService.getVisitNotes(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Hata: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            final visitNotes = snapshot.data ?? [];

            if (visitNotes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 72,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Henüz ziyaret notu eklenmemiş',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VisitNoteFormPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Not Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(padding),
              child: ListView.builder(
                itemCount: visitNotes.length,
                itemBuilder: (context, index) {
                  final visitNote = visitNotes[index];
                  String formattedDate = DateFormat('dd.MM.yyyy')
                      .format(visitNote.date);
                  String formattedCreatedAt = DateFormat('dd.MM.yyyy')
                      .format(visitNote.createdAt);

                  return FutureBuilder<Map<String, dynamic>>(
                    future: _getVisitNoteDetails(visitNote, firestoreService),
                    builder: (context, detailsSnapshot) {
                      String clientName = 'Yükleniyor...';
                      String portfolioTitle = 'Yükleniyor...';
                      
                      if (detailsSnapshot.hasData) {
                        clientName = detailsSnapshot.data!['clientName'];
                        portfolioTitle = detailsSnapshot.data!['portfolioTitle'];
                      }

                      return Card(
                        margin: EdgeInsets.only(bottom: padding),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Başlık ve Tarih
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      visitNote.title,
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: subtitleFontSize,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.deepOrange,
                                          size: iconSize,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => VisitNoteFormPage(
                                                visitNote: visitNote,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.deepOrange,
                                          size: iconSize,
                                        ),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(
                                            context,
                                            visitNote,
                                            firestoreService,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: padding),
                              
                              // Müşteri Bilgisi
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.deepOrange.shade100,
                                    radius: avatarRadius,
                                    child: Icon(
                                      Icons.person,
                                      size: iconSize,
                                      color: Colors.deepOrange.shade900,
                                    ),
                                  ),
                                  SizedBox(width: padding),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Müşteri:',
                                          style: TextStyle(
                                            fontSize: subtitleFontSize,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          clientName,
                                          style: TextStyle(
                                            fontSize: subtitleFontSize + 2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: padding),
                              
                              // Portföy Bilgisi
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.deepOrange.shade100,
                                    radius: avatarRadius,
                                    child: Icon(
                                      Icons.home_work,
                                      size: iconSize,
                                      color: Colors.deepOrange.shade900,
                                    ),
                                  ),
                                  SizedBox(width: padding),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Portföy:',
                                          style: TextStyle(
                                            fontSize: subtitleFontSize,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          portfolioTitle,
                                          style: TextStyle(
                                            fontSize: subtitleFontSize + 2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: padding),
                              
                              // Notlar
                              Text(
                                'Notlar:',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: padding / 2),
                              Text(
                                visitNote.notes,
                                style: TextStyle(
                                  fontSize: subtitleFontSize + 2,
                                ),
                              ),
                              SizedBox(height: padding),
                              
                              // Oluşturulma Tarihi
                              Text(
                                'Oluşturulma: $formattedCreatedAt',
                                style: TextStyle(
                                  fontSize: subtitleFontSize - 2,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VisitNoteFormPage(),
            ),
          );
        },
        backgroundColor: Colors.deepOrange,
        icon: Icon(Icons.add, size: isSmallPhone ? 20 : 24),
        label: Text(
          'Yeni Not',
          style: TextStyle(fontSize: isSmallPhone ? 14 : 16),
        ),
      ),
    );
  }
  
  Future<Map<String, dynamic>> _getVisitNoteDetails(
    VisitNote visitNote, 
    FirestoreService firestoreService
  ) async {
    String clientName = 'Bilinmeyen Müşteri';
    String portfolioTitle = 'Bilinmeyen Portföy';
    
    try {
      // Müşteri adını al
      if (visitNote.clientId.isNotEmpty) {
        final clientStream = firestoreService.getClientById(visitNote.clientId).first;
        final client = await clientStream;
        if (client != null) {
          clientName = client.name;
        }
      }
      
      // Portföy adını al
      if (visitNote.portfolioId.isNotEmpty) {
        final portfolioStream = firestoreService.getPortfolioById(visitNote.portfolioId).first;
        final portfolio = await portfolioStream;
        if (portfolio != null) {
          portfolioTitle = portfolio.title;
        }
      }
    } catch (e) {
      debugPrint('Ziyaret notu detayları alınırken hata: $e');
    }
    
    return {
      'clientName': clientName,
      'portfolioTitle': portfolioTitle,
    };
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    VisitNote visitNote,
    FirestoreService firestoreService,
  ) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    String formattedDate = dateFormat.format(visitNote.date);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ziyaret Notunu Sil'),
        content: Text(
          '$formattedDate tarihli ziyaret notunu silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              firestoreService.deleteVisitNote(visitNote.id);
              Navigator.pop(context);
            },
            child: const Text('Sil'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
} 