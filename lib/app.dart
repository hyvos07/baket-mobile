import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baket_mobile/features/articles/pages/articlemain.dart';
import 'package:baket_mobile/features/product/pages/product_page.dart';
import 'package:baket_mobile/features/product/pages/cart_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: "BaKet",
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text('Katalog'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProductPage()),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  ElevatedButton(
                    child: const Text('Forum'),
                    onPressed: () {},
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  ElevatedButton(
                    child: const Text('Artikel'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ArticleMain()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Beranda'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartPage()),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  ElevatedButton(
                    child: const Text('Profile'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
