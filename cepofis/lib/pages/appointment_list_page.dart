import 'package:flutter/material.dart';
import 'package:cepofis/services/firestore_service.dart';
import 'package:cepofis/models/appointment.dart';
import 'package:cepofis/pages/appointment_form_page.dart';
import 'package:intl/intl.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  final FirestoreService firestoreService = FirestoreService();

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
          'Randevularım',
          style: TextStyle(fontSize: titleFontSize),
        ),
        backgroundColor: Colors.deepPurple.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade800,
              Colors.deepPurple.shade200,
            ],
          ),
        ),
        child: StreamBuilder<List<Appointment>>(
          stream: firestoreService.getAppointments(),
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

            final appointments = snapshot.data ?? [];

            if (appointments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 72,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Henüz randevu eklenmemiş',
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
                            builder: (context) => const AppointmentFormPage(),
                          ),
                        ).then((result) {
                          if (result == true) {
                            setState(() {});
                          }
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Randevu Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
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
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];

                  // Tarih formatlarını hazırlama
                  final dateFormat = DateFormat('dd.MM.yyyy');
                  final timeFormat = DateFormat('HH:mm');
                  
                  String formattedDate = dateFormat.format(appointment.date);
                  String formattedTime = timeFormat.format(appointment.date);
                  String formattedCreatedAt = dateFormat.format(appointment.createdAt);

                  return FutureBuilder<Map<String, dynamic>>(
                    future: _getAppointmentDetails(appointment, firestoreService),
                    builder: (context, detailsSnapshot) {
                      String clientName = 'Yükleniyor...';
                      List<String> portfolioNames = ['Yükleniyor...'];
                      
                      if (detailsSnapshot.hasData) {
                        clientName = detailsSnapshot.data!['clientName'];
                        portfolioNames = List<String>.from(detailsSnapshot.data!['portfolioNames']);
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
                              // Tarih ve Saat
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: iconSize,
                                        color: Colors.deepPurple.shade800,
                                      ),
                                      SizedBox(width: padding / 2),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontSize: subtitleFontSize + 2,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: padding / 2),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                          fontSize: subtitleFontSize + 2,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.deepPurple.shade800,
                                          size: iconSize,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AppointmentFormPage(
                                                appointment: appointment,
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
                                          color: Colors.deepPurple.shade800,
                                          size: iconSize,
                                        ),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(
                                            context,
                                            appointment,
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
                                    backgroundColor: Colors.deepPurple.shade100,
                                    radius: avatarRadius,
                                    child: Icon(
                                      Icons.person,
                                      size: iconSize,
                                      color: Colors.deepPurple.shade900,
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
                                    backgroundColor: Colors.deepPurple.shade100,
                                    radius: avatarRadius,
                                    child: Icon(
                                      Icons.home_work,
                                      size: iconSize,
                                      color: Colors.deepPurple.shade900,
                                    ),
                                  ),
                                  SizedBox(width: padding),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Portföyler:',
                                          style: TextStyle(
                                            fontSize: subtitleFontSize,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          portfolioNames.join(', '),
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
                              if (appointment.notes.isNotEmpty) ...[
                                Text(
                                  'Notlar:',
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: padding / 2),
                                Text(
                                  appointment.notes,
                                  style: TextStyle(
                                    fontSize: subtitleFontSize + 2,
                                  ),
                                ),
                                SizedBox(height: padding),
                              ],
                              
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppointmentFormPage(),
            ),
          ).then((result) {
            if (result == true) {
              setState(() {});
            }
          });
        },
        backgroundColor: Colors.deepPurple.shade800,
        child: Icon(Icons.add, size: isSmallPhone ? 20 : 24),
      ),
    );
  }

  Future<Map<String, dynamic>> _getAppointmentDetails(
    Appointment appointment, 
    FirestoreService firestoreService
  ) async {
    String clientName = 'Bilinmeyen Müşteri';
    List<String> portfolioNames = [];
    
    try {
      // Müşteri ve portföy verilerini paralel olarak al
      final futures = <Future>[];
      
      if (appointment.clientId.isNotEmpty) {
        futures.add(
          firestoreService.getClientById(appointment.clientId)
            .first
            .then((client) {
              if (client != null) {
                clientName = client.name;
              }
            })
        );
      }
      
      if (appointment.portfolioIds.isNotEmpty) {
        final portfolioFutures = appointment.portfolioIds.map((portfolioId) {
          return firestoreService.getPortfolioById(portfolioId)
            .first
            .then((portfolio) {
              if (portfolio != null) {
                portfolioNames.add(portfolio.title);
              }
            });
        });
        futures.addAll(portfolioFutures);
      }
      
      // Tüm sorguları paralel olarak bekle
      await Future.wait(futures);
      
      if (portfolioNames.isEmpty) {
        portfolioNames = ['Portföy seçilmemiş'];
      }
    } catch (e) {
      debugPrint('Randevu detayları alınırken hata: $e');
    }
    
    return {
      'clientName': clientName,
      'portfolioNames': portfolioNames,
    };
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    Appointment appointment,
    FirestoreService firestoreService,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Randevu Silinecek'),
          content: const Text(
            'Bu randevuyu silmek istediğinizden emin misiniz?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sil'),
              onPressed: () async {
                Navigator.of(context).pop(); // Dialog'u kapat
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                try {
                  await firestoreService.deleteAppointment(appointment.id);
                  if (!mounted) return;
                  setState(() {}); // Listeyi yenile
                } catch (e) {
                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Randevu silinirken bir hata oluştu.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
} 