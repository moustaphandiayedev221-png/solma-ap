import 'package:colways/features/product/data/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductRepository._sanitizeLikeQuery', () {
    test('escapes percent sign', () {
      expect(ProductRepository.sanitizeLikeQuery('100%'), r'100\%');
    });

    test('escapes underscore', () {
      expect(ProductRepository.sanitizeLikeQuery('my_product'), r'my\_product');
    });

    test('escapes backslash', () {
      expect(ProductRepository.sanitizeLikeQuery(r'a\b'), r'a\\b');
    });

    test('leaves normal text unchanged', () {
      expect(ProductRepository.sanitizeLikeQuery('Nike Air Max'), 'Nike Air Max');
    });

    test('handles empty string', () {
      expect(ProductRepository.sanitizeLikeQuery(''), '');
    });
  });

  group('PaginatedResult', () {
    test('stores items and hasMore', () {
      const result = PaginatedResult<int>(items: [1, 2, 3], hasMore: true);
      expect(result.items, [1, 2, 3]);
      expect(result.hasMore, true);
    });
  });
}
