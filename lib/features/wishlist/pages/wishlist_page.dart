// lib/features/wishlist/pages/wishlist_page.dart

import 'package:baket_mobile/core/bases/widgets/_widgets.dart';
import 'package:baket_mobile/core/constants/_constants.dart';
import 'package:baket_mobile/features/wishlist/models/wishlist_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../widgets/wishlist_card.dart';
import 'dart:async'; // For debounce

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  // State variables for search and filters
  String searchQuery = '';
  List<String> selectedCategories = [];
  String? sortOption;
  String sortField = 'price';   // "price" or "date"
  String sortDirection = 'asc'; // "asc" or "desc"

  static const String baseUrl = Endpoints.baseUrl;

  // List of available categories (should match Django's CATEGORY_CHOICES)
  final List<String> categories = [
    'smartphone',
    'laptop',
    'tablet',
    'smartwatch',
    'television',
  ];

  // Controllers for the SearchField
  late TextEditingController searchController;
  late FocusNode searchFocusNode;

  // Debounce timer
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Cancel the debounce timer if active
    _debounce?.cancel();
    // Dispose of the controllers to free up resources
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  // Debounced onQueryChanged function
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = query;
      });
    });
  }

  // Fetch products with query parameters
  Future<List<WishlistProduct>> fetchProducts(CookieRequest request) async {
    try {
      print('Fetching products with query: $searchQuery, categories: $selectedCategories, sort: $sortOption');
      
      // Build query parameters
      Map<String, dynamic> queryParams = {};
      if (searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }
      if (selectedCategories.isNotEmpty) {
        queryParams['category'] = selectedCategories;
      }

      // Convert query parameters to URL
      Uri uri = Uri.parse('$baseUrl/wishlist/json/').replace(queryParameters: {
        ...queryParams.map((key, value) => MapEntry(key, value is List ? value.join(',') : value)),
      });

      print('Fetching from URL: $uri');
      var response = await request.get(uri.toString());
      print('Full response: $response');
      
      if (response == null) {
        print('Response is null');
        return [];
      }

      if (!response.containsKey('products')) {
        print('Response does not contain products key');
        print('Response keys: ${response.keys}');
        return [];
      }

      List<dynamic> jsonList = response['products'];
      print('JsonList length: ${jsonList.length}');
      print('First item in jsonList: ${jsonList.isNotEmpty ? jsonList.first : "empty"}');

      List<WishlistProduct> products = [];
      for (var item in jsonList) {
        print('Processing item: $item');
        products.add(WishlistProduct.fromJson(item));
      }
      
      print('Processed products length: ${products.length}');
      // Local Sorting (no server involvement)
      if (sortOption == 'price_asc') {
        products.sort((a, b) => a.price.compareTo(b.price));
      } else if (sortOption == 'price_desc') {
        products.sort((a, b) => b.price.compareTo(a.price));
      } else if (sortOption == 'date_asc') {
        products.sort((a, b) => a.addedOn.compareTo(b.addedOn)); // Oldest first
      } else if (sortOption == 'date_desc') {
        products.sort((a, b) => b.addedOn.compareTo(a.addedOn)); // Newest first
      }
      return products;
      
    } catch (e, stackTrace) {
      print('Error fetching products: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  void _updateSortOption() {
    sortOption = '${sortField}_${sortDirection}';
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: const Color(0xFF01aae8),
      ),
      body: Column(
        children: [
          // Search and Filter Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Replace the existing Expanded TextField with SearchField
                Expanded(
                  child: SearchField(
                    searchController: searchController,
                    focusNode: searchFocusNode,
                    hintText: 'Cari Barang', // Custom hint text
                    onQueryChanged: _onSearchChanged, // Use the debounced function
                  ),
                ),
                // Filter Button remains unchanged
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setModalState) {
                                return Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 400,
                                    maxHeight: 600,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Header Row
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Opsi Filter',
                                              style: GoogleFonts.raleway(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w900,
                                                // color: const Color(0xFF01aae8),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ],
                                        ),

                                        const Divider(
                                          thickness: 1,
                                          color: Colors.black26,
                                          height: 50,
                                        ),

                                        // Sort Berdasarkan
                                        Row(
                                          children: [
                                            // Label
                                            const Text(
                                              'Sort Berdasarkan',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),

                                            // Toggle Icon for ascending/descending
                                            IconButton(
                                              icon: Icon(
                                                sortDirection == 'asc' ? Icons.arrow_upward : Icons.arrow_downward,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () {
                                                setModalState(() {
                                                  sortDirection = (sortDirection == 'asc') ? 'desc' : 'asc';
                                                  _updateSortOption();
                                                });
                                              },
                                            ),
                                          ],
                                        ),

                                        // Radio Buttons for sortField
                                        RadioListTile<String>(
                                          title: const Text('Harga'),
                                          value: 'price',
                                          groupValue: sortField,
                                          onChanged: (value) {
                                            setModalState(() {
                                              sortField = value!;
                                              _updateSortOption();
                                            });
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: const Text('Waktu di-wishlist'),
                                          value: 'date',
                                          groupValue: sortField,
                                          onChanged: (value) {
                                            setModalState(() {
                                              sortField = value!;
                                              _updateSortOption();
                                            });
                                          },
                                        ),

                                        const Divider(),

                                        // Categories
                                        const Text(
                                          'Kategori',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ...categories.map((category) {
                                          return CheckboxListTile(
                                            title: Text(
                                              category[0].toUpperCase() + category.substring(1),
                                            ),
                                            value: selectedCategories.contains(category),
                                            onChanged: (bool? value) {
                                              setModalState(() {
                                                if (value == true) {
                                                  selectedCategories.add(category);
                                                } else {
                                                  selectedCategories.remove(category);
                                                }
                                              });
                                              setState(() {});
                                            },
                                          );
                                        }),

                                        const SizedBox(height: 16),

                                        // Footer Row (Reset & Apply)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                setModalState(() {
                                                  sortOption = null;
                                                  selectedCategories.clear();
                                                  // Reset sorting
                                                  sortField = 'price';
                                                  sortDirection = 'asc';
                                                });
                                                setState(() {});
                                              },
                                              child: const Text('Reset'),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF01aae8),
                                              ),
                                              child: const Text(
                                                'Terapkan',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
            ),
          ),

          // Product Grid
          Expanded(
            child: FutureBuilder<List<WishlistProduct>>(
              future: fetchProducts(request),
              builder: (context, snapshot) {
                // Add debug prints for snapshot state
                print('Connection state: ${snapshot.connectionState}');
                print('Has error: ${snapshot.hasError}');
                print('Has data: ${snapshot.hasData}');
                if (snapshot.hasData) {
                  print('Data length: ${snapshot.data!.length}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Error in snapshot: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // This will trigger a rebuild
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                final products = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: products.map((product) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 15,
                          child: WishListCard(
                            product: product,
                            onRemove: () {  
                              setState(() {});
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
