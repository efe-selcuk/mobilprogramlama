import 'package:flutter/material.dart';
import 'package:mobilprogramlama/models/flower_model.dart';
import 'package:mobilprogramlama/pages/admin/add_flower_page.dart';
import 'package:mobilprogramlama/pages/flower_detail_page.dart';
import 'package:mobilprogramlama/services/auth_service.dart';
import 'package:mobilprogramlama/pages/auth/login_page.dart';
import 'package:mobilprogramlama/services/flower_service.dart';
import 'package:mobilprogramlama/widgets/custom_button.dart';
import 'package:mobilprogramlama/widgets/flower_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FlowerService _flowerService = FlowerService();
  late TabController _tabController;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chakra Çiçek Admin Paneli"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.local_florist), text: 'Çiçek Yönetimi'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.red,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chakra Çiçek Yönetimi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Yönetici İşlemleri',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Ana Panel'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                _tabController.animateTo(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_florist),
              title: const Text('Çiçek Yönetimi'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Kullanıcı Yönetimi'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kullanıcı yönetimi yakında eklenecek')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ayarlar yakında eklenecek')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Çıkış Yap'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Dashboard tab
          _buildDashboardTab(),
          
          // Flower management tab
          _buildFlowerManagementTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFlowerPage()),
          );
        },
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hoş Geldiniz, Admin!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Flower stats
          StreamBuilder<List<Flower>>(
            stream: _flowerService.getFlowers(),
            builder: (context, snapshot) {
              int flowerCount = 0;
              int outOfStockCount = 0;
              
              if (snapshot.hasData) {
                flowerCount = snapshot.data!.length;
                outOfStockCount = snapshot.data!.where((flower) => !flower.isAvailable).length;
              }
              
              return Column(
                children: [
                  _buildStatCard(
                    title: "Toplam Çiçek",
                    value: flowerCount.toString(),
                    icon: Icons.local_florist,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 15),
                  _buildStatCard(
                    title: "Tükenen Çiçekler",
                    value: outOfStockCount.toString(),
                    icon: Icons.remove_shopping_cart,
                    color: Colors.red,
                  ),
                ],
              );
            }
          ),
          
          const SizedBox(height: 15),
          _buildStatCard(
            title: "Toplam Kullanıcı",
            value: "0",
            icon: Icons.people,
            color: Colors.blue,
          ),
          const SizedBox(height: 15),
          _buildStatCard(
            title: "Yeni Siparişler",
            value: "0",
            icon: Icons.shopping_bag,
            color: Colors.orange,
          ),
          const Spacer(),
          CustomButton(
            text: "Çıkış Yap",
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowerManagementTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Çiçek ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        
        // Flower list
        Expanded(
          child: StreamBuilder<List<Flower>>(
            stream: _flowerService.getFlowers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Henüz çiçek bulunmuyor. Yeni çiçek ekleyin.'),
                );
              }
              
              // Filter by search query if provided
              List<Flower> flowers = snapshot.data!;
              if (_searchQuery.isNotEmpty) {
                flowers = flowers.where((flower) => 
                  flower.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              }
              
              if (flowers.isEmpty) {
                return const Center(child: Text('Arama sonucu bulunamadı'));
              }
              
              // Use ListView for admin list (better for management)
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: flowers.length,
                itemBuilder: (context, index) {
                  final flower = flowers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      leading: flower.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                flower.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image),
                            ),
                      title: Text(flower.name),
                      subtitle: Text(
                        '${flower.price.toStringAsFixed(2)} ₺ - ${flower.category}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: flower.isAvailable ? Colors.green[100] : Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              flower.isAvailable ? 'Stokta' : 'Tükendi',
                              style: TextStyle(
                                color: flower.isAvailable ? Colors.green[800] : Colors.red[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FlowerDetailPage(flower: flower),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Silme Onayı'),
                                  content: const Text('Bu çiçeği silmek istediğinize emin misiniz?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('İptal'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Sil', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (confirmed == true) {
                                try {
                                  await _flowerService.deleteFlower(flower.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Çiçek başarıyla silindi')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Silme hatası: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlowerDetailPage(flower: flower),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 