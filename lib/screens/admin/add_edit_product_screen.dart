import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _careInstructionsController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;

  late String _selectedCategory;
  String? _selectedShopId;
  bool _inStock = true;
  bool _featured = false;
  bool _isLoading = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleController = TextEditingController(text: p?.title ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _careInstructionsController = TextEditingController(
      text: p?.careInstructions ??
          'Držati na svetlom mestu bez direktnog jakog sunca. Umereno zalivati.',
    );
    _imageUrlController = TextEditingController(
      text: p?.imageUrl ??
          'https://images.unsplash.com/photo-1561181286-d3fee7d55364?auto=format&fit=crop&w=800&q=80',
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _selectedCategory = p?.category ?? 'Buketi';
    _selectedShopId = p?.shopId;
    _inStock = p?.inStock ?? true;
    _featured = p?.featured ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedShopId == null) {
      final shops = Provider.of<ShopProvider>(context, listen: false).florists;
      if (shops.isNotEmpty) {
        _selectedShopId = shops.first.shopId;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _careInstructionsController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedShopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izaberite cvećaru kojoj artikal pripada.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final id = isEditing
        ? widget.product!.id
        : 'prod_${DateTime.now().millisecondsSinceEpoch}';

    final productToSave = Product(
      id: id,
      title: _titleController.text.trim(),
      price: price,
      careInstructions: _careInstructionsController.text.trim(),
      shopId: _selectedShopId!,
      imageUrl: _imageUrlController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      inStock: _inStock,
      featured: _featured,
    );

    if (isEditing) {
      await productProvider.updateProduct(productToSave);
    } else {
      await productProvider.addProduct(productToSave);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Artikal je uspešno ažuriran (Update)!'
                : 'Novi artikal je dodat u bazu (Create)!',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Izmena artikla (Update)' : 'Novi artikal (Create)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Naziv cveća / biljke',
                prefixIcon: Icons.local_florist,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite naziv' : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _priceController,
                label: 'Cena u RSD',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Unesite cenu';
                  if (double.tryParse(v.trim()) == null) return 'Unesite validan broj';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Cvećara dropdown
              const Text(
                'Cvećara (shopId)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedShopId,
                items: shopProvider.florists.map((f) {
                  return DropdownMenuItem(
                    value: f.shopId,
                    child: Text(f.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedShopId = val),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.storefront, size: 20),
                ),
              ),
              const SizedBox(height: 14),

              // Kategorija dropdown
              const Text(
                'Kategorija',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: AppConstants.categories
                    .where((c) => c != 'Sve')
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category, size: 20),
                ),
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _careInstructionsController,
                label: 'Saveti za negu i održavanje (Care instructions)',
                prefixIcon: Icons.eco,
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite savet za održavanje' : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _imageUrlController,
                label: 'URL slike cveća',
                prefixIcon: Icons.image,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite URL fotografije' : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _descriptionController,
                label: 'Kratak opis artikla',
                prefixIcon: Icons.description,
                maxLines: 2,
              ),
              const SizedBox(height: 14),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Izdvojen artikal na početnoj (Featured)'),
                value: _featured,
                onChanged: (val) => setState(() => _featured = val),
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: isEditing ? 'Sačuvaj izmene artikla' : 'Dodaj artikal u ponudu',
                isLoading: _isLoading,
                icon: isEditing ? Icons.save : Icons.add_circle,
                onPressed: _isLoading ? null : _saveProduct,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

