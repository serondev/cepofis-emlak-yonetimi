import 'package:flutter/material.dart';
import 'package:cepofis/services/firestore_service.dart';
import 'package:cepofis/models/client.dart';
import 'package:cepofis/pages/client_form_page.dart';
import 'package:intl/intl.dart';

class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  final firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşterilerim'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo,
              Colors.indigo.shade200,
            ],
          ),
        ),
        child: StreamBuilder<List<Client>>(
          stream: firestoreService.getClients(),
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

            final clients = snapshot.data ?? [];

            if (clients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_alt_outlined,
                      size: 72,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Henüz müşteri eklenmemiş',
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
                            builder: (context) => const ClientFormPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Müşteri Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal,
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
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  String formattedDate = DateFormat('dd.MM.yyyy')
                      .format(client.createdAt);

                  return Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.white,
                    shadowColor: Colors.black.withOpacity(0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık ve işlemler
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  client.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClientFormPage(
                                        client: client,
                                      ),
                                    ),
                                  ).then((result) {
                                    // Düzenleme işlemi başarılı olduysa sayfayı yenile
                                    if (result == true) {
                                      setState(() {});
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                    context,
                                    client,
                                    firestoreService,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // İçerik
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // İletişim bilgileri
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.indigo.shade100,
                                    radius: 24,
                                    child: Icon(
                                      Icons.person,
                                      size: 28,
                                      color: Colors.indigo.shade800,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              size: 16,
                                              color: Colors.indigo.shade800,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              client.phone,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // İlgilendiği emlak türleri
                              if (client.interestedTypes.isNotEmpty) ...[
                                const Text(
                                  'İlgilendiği Emlak Türleri:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: client.interestedTypes
                                      .map((type) => _buildPropertyTypeChip(type))
                                      .toList(),
                                ),
                                const SizedBox(height: 12),
                              ],
                              // Notlar
                              if (client.notes.isNotEmpty) ...[
                                const Text(
                                  'Notlar:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  client.notes,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                              ],
                              // Tarih
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  'Eklenme: $formattedDate',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
              builder: (context) => const ClientFormPage(),
            ),
          );
        },
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Müşteri'),
      ),
    );
  }

  Widget _buildPropertyTypeChip(String propertyType) {
    String label;
    Color color;

    switch (propertyType) {
      case 'apartment':
        label = 'Daire';
        color = Colors.blue;
        break;
      case 'house':
        label = 'Ev';
        color = Colors.green;
        break;
      case 'land':
        label = 'Arsa';
        color = Colors.amber;
        break;
      case 'commercial':
        label = 'Ticari';
        color = Colors.purple;
        break;
      default:
        label = 'Diğer';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color is MaterialColor ? color.shade800 : color,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    Client client,
    FirestoreService firestoreService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Müşteriyi Sil'),
        content: Text(
          '${client.name} müşterisini silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              firestoreService.deleteClient(client.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
} 