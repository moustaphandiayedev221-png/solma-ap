import 'package:colways/features/profile/data/address_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressModel', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'id1',
        'user_id': 'user1',
        'label': 'Maison',
        'full_name': 'Jean Dupont',
        'line1': '10 rue Example',
        'line2': 'Apt 2',
        'city': 'Paris',
        'postal_code': '75001',
        'country': 'France',
        'phone': '+33600000000',
        'is_default': true,
      };
      final a = AddressModel.fromJson(json);
      expect(a.id, 'id1');
      expect(a.userId, 'user1');
      expect(a.label, 'Maison');
      expect(a.fullName, 'Jean Dupont');
      expect(a.line1, '10 rue Example');
      expect(a.line2, 'Apt 2');
      expect(a.city, 'Paris');
      expect(a.postalCode, '75001');
      expect(a.country, 'France');
      expect(a.phone, '+33600000000');
      expect(a.isDefault, true);
    });

    test('singleLine concatenates address parts', () {
      const a = AddressModel(
        id: '1',
        userId: 'u1',
        fullName: 'Jean',
        line1: '10 rue X',
        line2: 'Apt 1',
        city: 'Paris',
        postalCode: '75001',
        country: 'France',
      );
      expect(a.singleLine, contains('10 rue X'));
      expect(a.singleLine, contains('75001'));
      expect(a.singleLine, contains('Paris'));
      expect(a.singleLine, contains('France'));
    });

    test('copyWith preserves unchanged fields', () {
      const a = AddressModel(
        id: '1',
        userId: 'u1',
        fullName: 'Jean',
        line1: 'Rue',
        city: 'Paris',
        country: 'FR',
      );
      final b = a.copyWith(fullName: 'Marie');
      expect(b.fullName, 'Marie');
      expect(b.line1, 'Rue');
      expect(b.city, 'Paris');
    });
  });
}
