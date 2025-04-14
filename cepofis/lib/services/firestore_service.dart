import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/portfolio.dart';
import '../models/client.dart';
import '../models/appointment.dart';
import '../models/visit_note.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Portfolio işlemleri
  Future<void> addPortfolio(Portfolio portfolio) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    final docRef = _firestore.collection('portfolios').doc();
    await docRef.set({
      ...portfolio.toMap(),
      'id': docRef.id,
      'userId': user.uid,
    });
  }

  Stream<List<Portfolio>> getPortfolios() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    return _firestore
        .collection('portfolios')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Portfolio.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> updatePortfolio(Portfolio portfolio) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    await _firestore.collection('portfolios').doc(portfolio.id).update(portfolio.toMap());
  }

  Future<void> deletePortfolio(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    await _firestore.collection('portfolios').doc(id).delete();
  }

  // Client işlemleri
  Future<void> addClient(Client client) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    final docRef = _firestore.collection('clients').doc();
    await docRef.set({
      ...client.toMap(),
      'id': docRef.id,
      'userId': user.uid,
    });
  }

  Stream<List<Client>> getClients() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    return _firestore
        .collection('clients')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Client.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> updateClient(Client client) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    await _firestore.collection('clients').doc(client.id).update(client.toMap());
  }

  Future<void> deleteClient(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    await _firestore.collection('clients').doc(id).delete();
  }

  // Appointment işlemleri
  Future<void> addAppointment(Appointment appointment) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    final docRef = _firestore.collection('appointments').doc();
    await docRef.set({
      ...appointment.toMap(),
      'id': docRef.id,
      'userId': user.uid,
    });
  }

  Stream<List<Appointment>> getAppointments() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    await _firestore.collection('appointments').doc(appointment.id).update(appointment.toMap());
  }

  Future<void> deleteAppointment(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    await _firestore.collection('appointments').doc(id).delete();
  }

  // VisitNote işlemleri
  Future<void> addVisitNote(VisitNote visitNote) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    final docRef = _firestore.collection('visitNotes').doc();
    await docRef.set({
      ...visitNote.toMap(),
      'id': docRef.id,
      'userId': user.uid,
    });
  }

  Stream<List<VisitNote>> getVisitNotes() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    return _firestore
        .collection('visitNotes')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VisitNote.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> updateVisitNote(VisitNote visitNote) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    await _firestore.collection('visitNotes').doc(visitNote.id).update(visitNote.toMap());
  }

  Future<void> deleteVisitNote(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    await _firestore.collection('visitNotes').doc(id).delete();
  }

  // Tekil bir Client almak için
  Stream<Client?> getClientById(String id) {
    return _firestore
        .collection('clients')
        .doc(id)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Client.fromMap({
          'id': snapshot.id,
          ...snapshot.data()!,
        });
      }
      return null;
    });
  }

  // Tekil bir Portfolio almak için
  Stream<Portfolio?> getPortfolioById(String id) {
    return _firestore
        .collection('portfolios')
        .doc(id)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Portfolio.fromMap({
          'id': snapshot.id,
          ...snapshot.data()!,
        });
      }
      return null;
    });
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
} 