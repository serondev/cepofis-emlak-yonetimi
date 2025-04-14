import 'package:flutter/material.dart';
import 'package:cepofis/services/firestore_service.dart';
import 'package:cepofis/models/portfolio.dart';
import 'package:cepofis/pages/portfolio_form_page.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için
import 'package:cepofis/utils/responsive_utils.dart';
import 'package:cepofis/widgets/feature_chip.dart';

class PortfolioListPage extends StatelessWidget {
  const PortfolioListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Portföylerim',
          style: TextStyle(
            fontSize: ResponsiveUtils.getTitleFontSize(context),
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade200,
            ],
          ),
        ),
        child: StreamBuilder<List<Portfolio>>(
          stream: firestoreService.getPortfolios(),
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

            final portfolios = snapshot.data ?? [];

            if (portfolios.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_work_outlined,
                      size: 72,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Henüz portföy eklenmemiş',
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
                            builder: (context) => const PortfolioFormPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Portföy Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
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
              padding: EdgeInsets.all(ResponsiveUtils.getCardPadding(context)),
              child: ListView.builder(
                itemCount: portfolios.length,
                itemBuilder: (context, index) {
                  final portfolio = portfolios[index];
                  String formattedDate = DateFormat('dd.MM.yyyy')
                      .format(portfolio.createdAt);
                  String priceText = NumberFormat.currency(
                    locale: 'tr_TR',
                    symbol: '₺',
                    decimalDigits: 0,
                  ).format(portfolio.price);

                  return Card(
                    margin: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.getCardPadding(context) / 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(ResponsiveUtils.getCardPadding(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Başlık ve Tarih
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  portfolio.title,
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getTitleFontSize(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getSubtitleFontSize(context),
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
                                      color: Colors.blue.shade800,
                                      size: ResponsiveUtils.getIconSize(context),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PortfolioFormPage(
                                            portfolio: portfolio,
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
                                      color: Colors.blue.shade800,
                                      size: ResponsiveUtils.getIconSize(context),
                                    ),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                        context,
                                        portfolio,
                                        firestoreService,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Özellikler
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FeatureChip(
                                icon: Icons.location_on,
                                label: portfolio.location,
                              ),
                              FeatureChip(
                                icon: Icons.home,
                                label: _getPropertyTypeText(portfolio.propertyType),
                              ),
                              FeatureChip(
                                icon: Icons.attach_money,
                                label: priceText,
                              ),
                              if (portfolio.area > 0)
                                FeatureChip(
                                  icon: Icons.aspect_ratio,
                                  label: '${portfolio.area} m²',
                                ),
                              FeatureChip(
                                icon: Icons.king_bed,
                                label: '${portfolio.roomCount} Oda',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Açıklama
                          if (portfolio.description.isNotEmpty) ...[
                            Text(
                              'Açıklama:',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getSubtitleFontSize(context),
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              portfolio.description,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getSubtitleFontSize(context) + 2,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                          ],
                          
                          // Durum
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.getCardPadding(context),
                              vertical: ResponsiveUtils.getCardPadding(context) / 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(portfolio.type).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getTypeColor(portfolio.type),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getTypeText(portfolio.type),
                              style: TextStyle(
                                color: _getTypeColor(portfolio.type),
                                fontSize: ResponsiveUtils.getSubtitleFontSize(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
              builder: (context) => const PortfolioFormPage(),
            ),
          );
        },
        backgroundColor: Colors.blue.shade800,
        child: Icon(Icons.add, size: ResponsiveUtils.getIconSize(context)),
      ),
    );
  }

  String _getPropertyTypeText(String propertyType) {
    switch (propertyType) {
      case 'apartment':
        return 'Daire';
      case 'house':
        return 'Ev';
      case 'land':
        return 'Arsa';
      case 'commercial':
        return 'Ticari';
      default:
        return 'Diğer';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'sale':
        return Colors.green;
      case 'rent':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'sale':
        return 'SATILIK';
      case 'rent':
        return 'KİRALIK';
      default:
        return type.toUpperCase();
    }
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    Portfolio portfolio,
    FirestoreService firestoreService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Portföyü Sil'),
        content: Text(
          '${portfolio.title} portföyünü silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              firestoreService.deletePortfolio(portfolio.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
} 