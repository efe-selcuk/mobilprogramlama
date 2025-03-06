import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobilprogramlama/models/flower_model.dart';
import 'package:mobilprogramlama/services/auth_service.dart';

class FlowerService {
  final CollectionReference _flowersCollection = 
      FirebaseFirestore.instance.collection('flowers');
  final AuthService _authService = AuthService();

  // Create a new flower (Admin only)
  Future<void> addFlower(Flower flower) async {
    bool isAdmin = await _authService.isUserAdmin();
    if (!isAdmin) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }
    await _flowersCollection.add(flower.toMap());
  }

  // Get all flowers (Public)
  Stream<List<Flower>> getFlowers() {
    return _flowersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Flower.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get flowers by category (Public)
  Stream<List<Flower>> getFlowersByCategory(String category) {
    return _flowersCollection
      .where('category', isEqualTo: category)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Flower.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
  }

  // Search flowers by name (Public)
  Stream<List<Flower>> searchFlowers(String query) {
    // Converting the query to lowercase for case-insensitive search
    String searchQuery = query.toLowerCase();
    
    return _flowersCollection.snapshots().map((snapshot) {
      return snapshot.docs
        .map((doc) => Flower.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .where((flower) => flower.name.toLowerCase().contains(searchQuery))
        .toList();
    });
  }

  // Update a flower (Admin only)
  Future<void> updateFlower(Flower flower) async {
    bool isAdmin = await _authService.isUserAdmin();
    if (!isAdmin) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }
    await _flowersCollection.doc(flower.id).update(flower.toMap());
  }

  // Delete a flower (Admin only)
  Future<void> deleteFlower(String flowerId) async {
    bool isAdmin = await _authService.isUserAdmin();
    if (!isAdmin) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }
    await _flowersCollection.doc(flowerId).delete();
  }
} 