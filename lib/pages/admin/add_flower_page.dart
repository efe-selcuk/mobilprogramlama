import 'package:flutter/material.dart';
import 'package:mobilprogramlama/models/flower_model.dart';
import 'package:mobilprogramlama/services/flower_service.dart';

class AddFlowerPage extends StatefulWidget {
  const AddFlowerPage({Key? key}) : super(key: key);

  @override
  State<AddFlowerPage> createState() => _AddFlowerPageState();
}

class _AddFlowerPageState extends State<AddFlowerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  
  String _selectedCategory = 'Güller'; // Default category
  final List<String> _categories = [
    'Güller',
    'Orkideler',
    'Laleler',
    'Papatyalar',
    'Buketler',
    'Aranjmanlar'
  ];
  
  final FlowerService _flowerService = FlowerService();
  bool _isLoading = false;
  
  Future<void> _saveFlower() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Create a unique ID (will be replaced by Firestore's auto-ID)
        final String tempId = DateTime.now().millisecondsSinceEpoch.toString();
        
        final flower = Flower(
          id: tempId,
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          imageUrl: _imageUrlController.text,
          category: _selectedCategory,
          isAvailable: int.parse(_stockQuantityController.text) > 0,
          stockQuantity: int.parse(_stockQuantityController.text),
        );
        
        await _flowerService.addFlower(flower);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Çiçek başarıyla eklendi'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear form after successful save
          _nameController.clear();
          _descriptionController.clear();
          _priceController.clear();
          _imageUrlController.clear();
          _stockQuantityController.clear();
          setState(() {
            _selectedCategory = 'Güller';
          });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chakra Çiçek - Yeni Ürün Ekle'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Kaydet', style: TextStyle(color: Colors.white)),
            onPressed: _saveFlower,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form section header
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Çiçek Bilgileri',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Preview image if provided
                    if (_imageUrlController.text.isNotEmpty) ...[
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
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black.withOpacity(0.5),
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  child: const Text(
                                    'Önizleme',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Çiçek Adı',
                        hintText: 'Örn: Kırmızı Gül Buketi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: const Icon(Icons.local_florist),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen çiçek adını giriniz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Category dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: const Icon(Icons.category),
                      ),
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir kategori seçin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Açıklama',
                        hintText: 'Çiçeğin özelliklerini ve kullanım alanlarını yazınız',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: const Icon(Icons.description),
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
                              hintText: '0.00',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.monetization_on),
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
                              hintText: '0',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.inventory),
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
                    
                    // Image URL field
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'Resim URL',
                        hintText: 'https://example.com/image.jpg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.image),
                        filled: true,
                        fillColor: Colors.grey[50],
                        suffixIcon: _imageUrlController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _imageUrlController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        // Refresh to update preview
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Çiçeği Kaydet',
                          style: TextStyle(fontSize: 18),
                        ),
                        onPressed: _saveFlower,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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