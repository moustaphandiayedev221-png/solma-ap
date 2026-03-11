import 'package:colways/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartItemKey', () {
    test('equality works with same values', () {
      const k1 = CartItemKey(productId: 'p1', size: 'M', color: 'red');
      const k2 = CartItemKey(productId: 'p1', size: 'M', color: 'red');
      expect(k1, equals(k2));
      expect(k1.hashCode, equals(k2.hashCode));
    });

    test('different size means different key', () {
      const k1 = CartItemKey(productId: 'p1', size: 'M');
      const k2 = CartItemKey(productId: 'p1', size: 'L');
      expect(k1, isNot(equals(k2)));
    });

    test('default size and color are empty strings', () {
      const k = CartItemKey(productId: 'p1');
      expect(k.size, '');
      expect(k.color, '');
    });
  });

  group('CartState', () {
    test('initial state is empty', () {
      const state = CartState();
      expect(state.items.isEmpty, true);
      expect(state.itemCount, 0);
    });

    test('addItem increases quantity', () {
      const key = CartItemKey(productId: 'p1');
      const state = CartState();
      final next = state.addItem(key);
      expect(next.items[key], 1);
      expect(next.itemCount, 1);
      final next2 = next.addItem(key);
      expect(next2.items[key], 2);
      expect(next2.itemCount, 2);
    });

    test('addItem different products', () {
      const k1 = CartItemKey(productId: 'p1');
      const k2 = CartItemKey(productId: 'p2');
      const state = CartState();
      final next = state.addItem(k1).addItem(k2);
      expect(next.items[k1], 1);
      expect(next.items[k2], 1);
      expect(next.itemCount, 2);
    });

    test('addItem same product different sizes are separate entries', () {
      const kM = CartItemKey(productId: 'p1', size: 'M');
      const kL = CartItemKey(productId: 'p1', size: 'L');
      const state = CartState();
      final next = state.addItem(kM).addItem(kL);
      expect(next.items[kM], 1);
      expect(next.items[kL], 1);
      expect(next.itemCount, 2);
      expect(next.quantityForProduct('p1'), 2);
    });

    test('removeItem decrements or removes', () {
      const key = CartItemKey(productId: 'p1');
      var state = const CartState().addItem(key).addItem(key);
      state = state.removeItem(key);
      expect(state.items[key], 1);
      state = state.removeItem(key);
      expect(state.items.containsKey(key), false);
      expect(state.itemCount, 0);
    });

    test('removeAll removes product variant', () {
      const key = CartItemKey(productId: 'p1', size: 'M');
      var state = const CartState().addItem(key).addItem(key);
      state = state.removeAll(key);
      expect(state.items.containsKey(key), false);
      expect(state.itemCount, 0);
    });

    test('clear empties cart', () {
      const k1 = CartItemKey(productId: 'p1');
      const k2 = CartItemKey(productId: 'p2');
      var state = const CartState().addItem(k1).addItem(k2);
      state = state.clear();
      expect(state.items.isEmpty, true);
      expect(state.itemCount, 0);
    });

    test('quantityForProduct sums all variants', () {
      const kM = CartItemKey(productId: 'p1', size: 'M');
      const kL = CartItemKey(productId: 'p1', size: 'L');
      const kOther = CartItemKey(productId: 'p2');
      final state = const CartState()
          .addItem(kM)
          .addItem(kM)
          .addItem(kL)
          .addItem(kOther);
      expect(state.quantityForProduct('p1'), 3);
      expect(state.quantityForProduct('p2'), 1);
    });
  });
}
