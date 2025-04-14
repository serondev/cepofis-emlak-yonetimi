import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cepofis/pages/portfolio_list_page.dart';
import 'package:cepofis/pages/client_list_page.dart';
import 'package:cepofis/pages/appointment_list_page.dart';
import 'package:cepofis/pages/visit_notes_page.dart';
import 'package:cepofis/pages/login_page.dart';
import 'package:cepofis/pages/portfolio_form_page.dart';
import 'package:cepofis/pages/client_form_page.dart';
import 'package:cepofis/pages/appointment_form_page.dart';
import 'package:cepofis/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:cepofis/utils/responsive_utils.dart';
import 'package:cepofis/widgets/stat_card.dart';
import 'package:cepofis/widgets/quick_action_button.dart';
import 'package:cepofis/widgets/main_menu_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  
  // Dashboard verileri
  int _totalClients = 0;
  int _totalPortfolios = 0;
  int _todayAppointments = 0;
  bool _isLoadingData = true;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Türkçe karakter desteği için
    Intl.defaultLocale = 'tr_TR';
    _loadDashboardData();
    
    // Sayfa açıldığında scroll pozisyonunu sıfırla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingData = true;
    });
    
    try {
      // Bugünün tarihini alıp saat 00:00 olarak ayarlayalım
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      
      // Firestore sorguları
      final clientsQuery = FirebaseFirestore.instance
          .collection('clients')
          .where('userId', isEqualTo: _auth.currentUser?.uid);
          
      final portfoliosQuery = FirebaseFirestore.instance
          .collection('portfolios')
          .where('userId', isEqualTo: _auth.currentUser?.uid);
          
      final appointmentsQuery = FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .where('date', isGreaterThanOrEqualTo: today)
          .where('date', isLessThan: tomorrow);
      
      // Sorguları çalıştır
      final clientsSnapshot = await clientsQuery.get();
      final portfoliosSnapshot = await portfoliosQuery.get();
      final appointmentsSnapshot = await appointmentsQuery.get();
      
      if (mounted) {
        setState(() {
          _totalClients = clientsSnapshot.docs.length;
          _totalPortfolios = portfoliosSnapshot.docs.length;
          _todayAppointments = appointmentsSnapshot.docs.length;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Çıkış yapılırken hata oluştu: $e')),
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

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      _loadDashboardData();
      // Sayfaya döndükten sonra scroll pozisyonunu sıfırla
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Ekran boyutlarını al
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final bool isTablet = screenWidth > 600;
    final bool isSmallPhone = screenWidth < 360;
    final bool isMediumPhone = screenWidth >= 360 && screenWidth < 400;
    final bool isLargePhone = screenWidth >= 400 && screenWidth < 600;
    final String userName = _auth.currentUser?.displayName ?? 
        _auth.currentUser?.email?.split('@').first ?? 
        "Kullanıcı";
    
    // Responsive boyutlar - daha detaylı
    final double padding = isSmallPhone ? 10.0 : (isMediumPhone ? 12.0 : (isLargePhone ? 14.0 : 16.0));
    final double logoHeight = isSmallPhone ? 22.0 : (isMediumPhone ? 24.0 : (isLargePhone ? 28.0 : 32.0));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: logoHeight),
            SizedBox(width: isSmallPhone ? 4 : 8),
            Text(
              'Cep Ofis',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade900,
                fontSize: ResponsiveUtils.getTitleFontSize(context),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.indigo.shade700),
            onPressed: () {
              setState(() {
                _isLoadingData = true;
              });
              _loadDashboardData();
            },
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.indigo.shade700,
                    ),
                  )
                : Icon(Icons.logout, color: Colors.indigo.shade700),
            onPressed: _isLoading ? null : _logout,
            tooltip: 'Çıkış Yap',
          ),
          SizedBox(width: isSmallPhone ? 4 : 8),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: Colors.indigo.shade700,
        child: ListView(
          padding: EdgeInsets.all(padding),
          children: [
            _buildWelcomeSection(userName, isSmallPhone),
            SizedBox(height: isSmallPhone ? 16 : 24),
            _isLoadingData
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(isSmallPhone ? 24.0 : 32.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            color: Colors.indigo.shade700,
                          ),
                          SizedBox(height: isSmallPhone ? 12 : 16),
                          Text(
                            'Veriler yükleniyor...',
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                              fontSize: isSmallPhone ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildStatsCards(isTablet, isSmallPhone),
            SizedBox(height: isSmallPhone ? 24 : 32),
            _buildSectionTitle("Hızlı İşlemler", isSmallPhone),
            _buildQuickActionButtons(isTablet, isSmallPhone),
            SizedBox(height: isSmallPhone ? 24 : 32),
            _buildSectionTitle("Tüm Sayfalar", isSmallPhone),
            _buildMainMenuCards(isTablet, isSmallPhone),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, bool isSmallPhone) {
    return Padding(
      padding: EdgeInsets.only(left: isSmallPhone ? 4.0 : 8.0, bottom: isSmallPhone ? 12.0 : 16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: isSmallPhone ? 16 : 20,
            decoration: BoxDecoration(
              color: Colors.indigo.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: isSmallPhone ? 4 : 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallPhone ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeSection(String userName, bool isSmallPhone) {
    String greeting;
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      greeting = "Günaydın";
    } else if (hour < 18) {
      greeting = "İyi Günler";
    } else {
      greeting = "İyi Akşamlar";
    }
    
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3949AB),
            Color(0xFF1A237E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade200.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$greeting,",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallPhone ? 14 : 16,
                  ),
                ),
                SizedBox(height: isSmallPhone ? 4 : 8),
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallPhone ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallPhone ? 4 : 8),
                Text(
                  DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isSmallPhone ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isSmallPhone ? 8 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_circle,
              color: Colors.white,
              size: isSmallPhone ? 36 : 48,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCards(bool isTablet, bool isSmallPhone) {
    final statCards = [
      StatCard(
        title: 'Bugünkü\nRandevular',
        value: _todayAppointments.toString(),
        iconData: Icons.calendar_today_rounded,
        color: const Color(0xFF4CAF50),
        isSmallPhone: isSmallPhone,
      ),
      StatCard(
        title: 'Toplam\nMüşteriler',
        value: _totalClients.toString(),
        iconData: Icons.people_alt_rounded,
        color: const Color(0xFF2196F3),
        isSmallPhone: isSmallPhone,
      ),
      StatCard(
        title: 'Toplam\nPortföyler',
        value: _totalPortfolios.toString(),
        iconData: Icons.home_rounded,
        color: const Color(0xFFFF9800),
        isSmallPhone: isSmallPhone,
      ),
    ];
    
    return Column(
      children: statCards.map((card) => Padding(
        padding: EdgeInsets.only(bottom: isSmallPhone ? 8.0 : 12.0),
        child: card,
      )).toList(),
    );
  }
  
  Widget _buildQuickActionButtons(bool isTablet, bool isSmallPhone) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double aspectRatio = screenHeight / screenWidth;
    final bool isPortrait = aspectRatio > 1.5;
    
    final buttons = [
      QuickActionButton(
        title: 'Yeni\nPortföy',
        iconData: Icons.add_home_rounded,
        color: const Color(0xFF2196F3),
        onTap: () => _navigateToPage(const PortfolioFormPage()),
        isSmallPhone: isSmallPhone,
        screenWidth: screenWidth,
      ),
      QuickActionButton(
        title: 'Müşteri\nEkle',
        iconData: Icons.person_add_rounded,
        color: const Color(0xFF4CAF50),
        onTap: () => _navigateToPage(const ClientFormPage()),
        isSmallPhone: isSmallPhone,
        screenWidth: screenWidth,
      ),
      QuickActionButton(
        title: 'Randevu\nPlanla',
        iconData: Icons.calendar_month_rounded,
        color: const Color(0xFF9C27B0),
        onTap: () => _navigateToPage(const AppointmentFormPage()),
        isSmallPhone: isSmallPhone,
        screenWidth: screenWidth,
      ),
      QuickActionButton(
        title: 'Ziyaret\nNotu',
        iconData: Icons.note_add_rounded,
        color: const Color(0xFFFF9800),
        onTap: () => _navigateToPage(const VisitNotesPage()),
        isSmallPhone: isSmallPhone,
        screenWidth: screenWidth,
      ),
    ];
    
    int crossAxisCount;
    double childAspectRatio;
    
    if (screenWidth > 600) {
      crossAxisCount = isPortrait ? 2 : 4;
      childAspectRatio = isPortrait ? 1.3 : 1.5;
    } else if (screenWidth > 450) {
      crossAxisCount = 2;
      childAspectRatio = 1.3;
    } else if (screenWidth > 350) {
      crossAxisCount = 2;
      childAspectRatio = 1.2;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 1.0;
    }
    
    if (screenHeight < 600) {
      childAspectRatio = childAspectRatio * 1.2;
    }
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: screenWidth * 0.025,
      mainAxisSpacing: screenWidth * 0.025,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: buttons,
    );
  }
  
  Widget _buildMainMenuCards(bool isTablet, bool isSmallPhone) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double aspectRatio = screenHeight / screenWidth;
    final bool isPortrait = aspectRatio > 1.5;
    
    final menuItems = [
      MainMenuCard(
        title: 'Portföylerim',
        icon: Icons.home_work_rounded,
        color: const Color(0xFF3949AB),
        onTap: () => _navigateToPage(const PortfolioListPage()),
        isSmallPhone: isSmallPhone,
        screenWidth: screenWidth,
      ),
      MainMenuCard(
        title: 'Müşterilerim',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF00897B),
        onTap: () => _navigateToPage(const ClientListPage()),
        isSmallPhone: isSmallPhone,
        screenWidth: screenWidth,
      ),
      MainMenuCard(
        title: 'Randevularım',
        icon: Icons.calendar_month_rounded,
        color: const Color(0xFF7B1FA2),
        onTap: () => _navigateToPage(const AppointmentListPage()),
        isSmallPhone: isSmallPhone,
        screenWidth: screenWidth,
      ),
      MainMenuCard(
        title: 'Ziyaret\nNotları',
        icon: Icons.note_alt_rounded,
        color: const Color(0xFFEF6C00),
        onTap: () => _navigateToPage(const VisitNotesPage()),
        isSmallPhone: isSmallPhone,
        screenWidth: screenWidth,
      ),
    ];
    
    int crossAxisCount;
    double childAspectRatio;
    
    if (screenWidth > 600) {
      crossAxisCount = isPortrait ? 2 : 4;
      childAspectRatio = isPortrait ? 1.3 : 1.5;
    } else if (screenWidth > 450) {
      crossAxisCount = 2;
      childAspectRatio = 1.3;
    } else if (screenWidth > 350) {
      crossAxisCount = 2;
      childAspectRatio = 1.2;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 1.0;
    }
    
    if (screenHeight < 600) {
      childAspectRatio = childAspectRatio * 1.2;
    }
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: screenWidth * 0.025,
      mainAxisSpacing: screenWidth * 0.025,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: menuItems,
    );
  }
} 