import 'package:flutter/material.dart';
import 'package:mobilprogramlama/models/flower_model.dart';
import 'package:mobilprogramlama/services/auth_service.dart';
import 'package:mobilprogramlama/services/flower_service.dart';

class FlowerDetailPage extends StatefulWidget {
  final Flower flower;
  
  const FlowerDetailPage({super.key, required this.flower});

  @override
  State<FlowerDetailPage> createState() => _FlowerDetailPageState();
}

class _FlowerDetailPageState extends State<FlowerDetailPage> {
  late Flower _flower;
  final FlowerService _flowerService = FlowerService();
  final AuthService _authService = AuthService();
  bool _isEditing = false;
  bool _isAdmin = false;
  bool _isLoading = true;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _stockQuantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _flower = widget.flower;
    _loadFlowerData();
    _checkAdmin();
  }
  
  Future<void> _checkAdmin() async {
    final isAdmin = await _authService.isUserAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isLoading = false;
      });
    }
  }
  
  void _loadFlowerData() {
    _nameController.text = _flower.name;
    _descriptionController.text = _flower.description;
    _priceController.text = _flower.price.toString();
    _imageUrlController.text = _flower.imageUrl;
    _stockQuantityController.text = _flower.stockQuantity.toString();
  }

  Future<void> _updateFlower() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final updatedFlower = Flower(
          id: _flower.id,
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          imageUrl: _imageUrlController.text,
          category: _flower.category, // Keep the existing category
          isAvailable: int.parse(_stockQuantityController.text) > 0, // Update availability based on stock
          stockQuantity: int.parse(_stockQuantityController.text),
        );
        
        await _flowerService.updateFlower(updatedFlower);
        setState(() {
          _flower = updatedFlower;
          _isEditing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chakra Çiçek ürünü başarıyla güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
            ),
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
  }
  
  Future<void> _deleteFlower() async {
    setState(() {
      _isLoading = true;
    });
    
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
        await _flowerService.deleteFlower(_flower.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chakra Çiçek ürünü başarıyla silindi'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate deletion
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silme hatası: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      body: _isEditing 
          ? _buildEditForm() 
          : CustomScrollView(
              slivers: [
                // Image app bar
                SliverAppBar(
                  expandedHeight: 300.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'flower_image_${_flower.id}',
                      child: _flower.imageUrl.isNotEmpty
                          ? Image.network(
                              _flower.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.local_florist, size: 50, color: Colors.grey),
                              ),
                            ),
                    ),
                  ),
                  actions: _isAdmin 
                      ? [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => setState(() => _isEditing = true),
                            tooltip: 'Düzenle',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: _deleteFlower,
                            tooltip: 'Sil',
                          ),
                        ]
                      : null,
                ),
                
                // Content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product info section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _flower.name,
                                    style: const TextStyle(
                                      fontSize: 24, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: Text(
                                    '${_flower.price.toStringAsFixed(2)} ₺',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Badges section
                            Wrap(
                              spacing: 8,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Text(
                                    _flower.category,
                                    style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _flower.isAvailable ? Colors.green[50] : Colors.red[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _flower.isAvailable ? Colors.green.shade200 : Colors.red.shade200),
                                  ),
                                  child: Text(
                                    _flower.isAvailable ? 'Stokta var' : 'Tükendi',
                                    style: TextStyle(
                                      color: _flower.isAvailable ? Colors.green[800] : Colors.red[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (_flower.isAvailable) 
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[50],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.amber.shade200),
                                    ),
                                    child: Text(
                                      'Stok: ${_flower.stockQuantity}',
                                      style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.w500),
                                    ),
                                  ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Description
                            const Text(
                              'Ürün Açıklaması',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                _flower.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                                                        
                            // Related products could be added here
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildEditForm() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çiçeği Düzenle'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Kaydet', style: TextStyle(color: Colors.white)),
            onPressed: _updateFlower,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview image if available
              if (_imageUrlController.text.isNotEmpty)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.network(
                      _imageUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ),
                
              const SizedBox(height: 16),
              
              // Form fields
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Çiçek Adı',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen çiçek adını giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir açıklama giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Price and stock in a row
              Row(
                children: [
                  // Price field
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Fiyat (₺)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixText: '₺',
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Fiyat giriniz';
                        }
                        try {
                          final price = double.parse(value);
                          if (price <= 0) {
                            return 'Pozitif değer giriniz';
                          }
                        } catch (e) {
                          return 'Geçerli bir fiyat giriniz';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Stock quantity field
                  Expanded(
                    child: TextFormField(
                      controller: _stockQuantityController,
                      decoration: InputDecoration(
                        labelText: 'Stok Miktarı',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stok miktarı giriniz';
                        }
                        try {
                          final stock = int.parse(value);
                          if (stock < 0) {
                            return 'Negatif olamaz';
                          }
                        } catch (e) {
                          return 'Geçerli bir sayı giriniz';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Resim URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'https://example.com/image.jpg',
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  // URL validation is optional
                  return null;
                },
                onChanged: (value) {
                  // Update preview when URL changes
                  setState(() {});
                },
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _isEditing = false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateFlower,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Güncelle'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }
} 