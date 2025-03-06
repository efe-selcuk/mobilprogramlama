import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobilprogramlama/models/flower_model.dart';
import 'package:mobilprogramlama/pages/auth/login_page.dart';
import 'package:mobilprogramlama/pages/flower_detail_page.dart';
import 'package:mobilprogramlama/services/auth_service.dart';
import 'package:mobilprogramlama/services/flower_service.dart';
import 'package:mobilprogramlama/widgets/flower_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlowerService _flowerService = FlowerService();
  final AuthService _authService = AuthService();
  String _searchQuery = '';
  String _selectedCategory = '';
  bool _isExpanded = false;
  
  final List<String> _categories = [
    'Tümü',
    'Güller',
    'Orkideler',
    'Laleler',
    'Papatyalar',
    'Buketler',
    'Aranjmanlar'
  ];

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern sliver app bar
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.green[700],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _isExpanded ? "Chakra Çiçek" : "",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1508610048659-a06b669e3321?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 16,
                    child: const Text(
                      "Chakra Çiçek",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 16,
                    child: const Text(
                      "En taze çiçekleri sizin için özenle hazırlıyoruz",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => logout(context),
                tooltip: 'Çıkış Yap',
              ),
            ],
          ),
          
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Çiçek ara...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Category filter
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = 
                    (category == 'Tümü' && _selectedCategory.isEmpty) || 
                    category == _selectedCategory;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected 
                            ? (category == 'Tümü' ? '' : category)
                            : '';
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.green[100],
                      checkmarkColor: Colors.green[700],
                      side: BorderSide(color: isSelected ? Colors.green.shade400 : Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.green[700] : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory.isEmpty 
                        ? "Tüm Çiçekler" 
                        : "$_selectedCategory Koleksiyonu",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Flower list
          StreamBuilder<List<Flower>>(
            stream: _selectedCategory.isNotEmpty
              ? _flowerService.getFlowersByCategory(_selectedCategory)
              : _flowerService.getFlowers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Hata: ${snapshot.error}')),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Çiçek bulunamadı')),
                );
              }
              
              // Filter by search query if provided
              List<Flower> flowers = snapshot.data!;
              if (_searchQuery.isNotEmpty) {
                flowers = flowers.where((flower) => 
                  flower.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              }
              
              if (flowers.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Arama sonucu bulunamadı')),
                );
              }
              
              // Grid layout for flowers
              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final flower = flowers[index];
                      return FlowerCard(
                        flower: flower,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlowerDetailPage(flower: flower),
                            ),
                          );
                        },
                      );
                    },
                    childCount: flowers.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sepet özelliği yakında eklenecek')),
          );
        },
        label: const Text('Sepetim'),
        icon: const Icon(Icons.shopping_cart),
        backgroundColor: Colors.green[700],
      ),
    );
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Add NotificationListener to detect scroll changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ScrollController? controller = PrimaryScrollController.of(context);
      if (controller != null) {
        controller.addListener(() {
          final bool isExpanded = controller.offset > 100;
          if (isExpanded != _isExpanded) {
            setState(() {
              _isExpanded = isExpanded;
            });
          }
        });
      }
    });
  }
}
