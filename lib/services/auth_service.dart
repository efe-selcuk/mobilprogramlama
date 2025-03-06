import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobilprogramlama/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  // Kullanıcı oturum durumu stream'i
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Kullanıcı kaydı
  Future<UserModel?> registerUser({
    required String email,
    required String password,
    String role = 'user', // Varsayılan rol
  }) async {
    try {
      // Firebase Auth ile kullanıcı oluştur
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Firestore'da kullanıcı verilerini sakla
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Kullanıcı modelini döndür
        return UserModel(
          uid: user.uid,
          email: email,
          role: role,
        );
      }
    } catch (e) {
      print("Kayıt hatası: $e");
      rethrow;
    }
    return null;
  }

  // Kullanıcı girişi
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Firebase Auth ile giriş yap
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Firestore'dan kullanıcı verilerini al
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return UserModel.fromMap(data, user.uid);
        }
      }
    } catch (e) {
      print("Giriş hatası: $e");
      rethrow;
    }
    return null;
  }

  // Mevcut kullanıcının rolünü getir
  Future<String> getCurrentUserRole() async {
    try {
      User? user = _auth.currentUser;
      
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return data['role'] ?? 'user';
        }
      }
      return 'user'; // Varsayılan olarak normal kullanıcı rolü
    } catch (e) {
      print("Rol kontrolü hatası: $e");
      return 'user'; // Hata durumunda varsayılan rol
    }
  }

  // Oturumu kapat
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Admin yetki doğrulama metodu
  Future<bool> isUserAdmin() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final role = await getCurrentUserRole();
      return role == 'admin';
    } catch (e) {
      print('Yetki kontrolü hatası: $e');
      return false;
    }
  }

  // Yetki kontrolü yardımcı metodu
  Future<bool> checkPermission(String requiredRole) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final role = await getCurrentUserRole();
      
      // Admin her şeyi yapabilir
      if (role == 'admin') return true;
      
      // Normal kullanıcılar sadece 'user' rolü gerektiren işlemleri yapabilir
      if (requiredRole == 'user' && role == 'user') return true;
      
      return false;
    } catch (e) {
      print('Yetki kontrolü hatası: $e');
      return false;
    }
  }
} 