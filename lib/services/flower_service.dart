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
  
  // Fiyat aralığını bulmak için kullanılacak metod
  Future<Map<String, double>> getPriceRange() async {
    try {
      var snapshot = await _flowersCollection.get();
      List<Flower> flowers = snapshot.docs.map((doc) {
        return Flower.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      if (flowers.isEmpty) {
        return {'min': 0.0, 'max': 1000.0}; // Varsayılan değerler
      }
      
      double minPrice = flowers.first.price;
      double maxPrice = flowers.first.price;
      
      for (var flower in flowers) {
        if (flower.price < minPrice) minPrice = flower.price;
        if (flower.price > maxPrice) maxPrice = flower.price;
      }
      
      // Maksimum fiyatı biraz yuvarla ve marj ekle
      maxPrice = (maxPrice * 1.1).ceilToDouble();
      
      return {'min': minPrice, 'max': maxPrice};
    } catch (e) {
      print('Fiyat aralığı getirilirken hata oluştu: $e');
      return {'min': 0.0, 'max': 1000.0}; // Hata durumunda varsayılan değerler
    }
  }
} 