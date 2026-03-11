import 'package:colways/features/product/data/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductModel', () {
    test('fromJson parses minimal fields', () {
      final json = {'id': 'p1', 'name': 'Shoe', 'slug': 'shoe', 'price': 99.99};
      final p = ProductModel.fromJson(json);
      expect(p.id, 'p1');
      expect(p.name, 'Shoe');
      expect(p.slug, 'shoe');
      expect(p.price, 99.99);
      expect(p.imageUrls, isEmpty);
      expect(p.sizes, isEmpty);
      expect(p.colors, isEmpty);
      expect(p.stock, 0);
      expect(p.isFeatured, false);
    });

    test('price returns correct value', () {
      final product = ProductModel.fromJson({
        'id': 'p1',
        'name': 'S',
        'slug': 's',
        'price': 29.5,
      });
      expect(product.price, 29.5);
    });

    test('firstImageUrl returns first or null', () {
      final withImages = ProductModel.fromJson({
        'id': 'p1',
        'name': 'S',
        'slug': 's',
        'price': 1,
        'image_urls': ['https://a.jpg', 'https://b.jpg'],
      });
      expect(withImages.firstImageUrl, 'https://a.jpg');
      final noImages = ProductModel.fromJson({
        'id': 'p2',
        'name': 'S',
        'slug': 's2',
        'price': 1,
      });
      expect(noImages.firstImageUrl, null);
    });
  });
}
