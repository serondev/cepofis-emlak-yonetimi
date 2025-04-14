import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  
  AuthProvider() {
    _checkCurrentUser();
  }
  
  Future<void> _checkCurrentUser() async {
    _user = _auth.currentUser;
    notifyListeners();
  }
  
  // Email ve şifre ile kayıt olma
  Future<bool> registerWithEmail(String email, String password, String name) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Firebase Auth ile kullanıcı oluştur
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      
      // Kullanıcı adını güncelle
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      
      _user = _auth.currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (e.code == 'weak-password') {
        _errorMessage = 'Şifre çok zayıf.';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'Bu e-posta adresi zaten kullanımda.';
      } else {
        _errorMessage = 'Kayıt olma başarısız: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Kayıt olma başarısız: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Email ve şifre ile giriş yapma
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Firebase Auth ile giriş yap
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      
      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();
      
      // Başarılı girişi kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (e.code == 'user-not-found') {
        _errorMessage = 'Bu e-posta adresine sahip kullanıcı bulunamadı.';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Yanlış şifre.';
      } else {
        _errorMessage = 'Giriş başarısız: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Giriş başarısız: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Google ile giriş yapma
  Future<bool> loginWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Google hesabını seç
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        _errorMessage = 'Google ile giriş iptal edildi.';
        notifyListeners();
        return false;
      }
      
      // Google hesabından kimlik bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Google kimlik bilgilerini Firebase'e bağla
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Firebase ile giriş yap
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;
      
      _isLoading = false;
      notifyListeners();
      
      // Başarılı girişi kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Google ile giriş başarısız: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Çıkış yapma
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      
      _user = null;
      
      // Giriş durumunu sıfırla
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Çıkış yapılırken hata oluştu: $e';
      notifyListeners();
    }
  }
  
  // Hata mesajını sıfırla
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
} 