import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/features/products/data/models/product.dart';

void main() {
  group('Product catalog fields', () {
    test('fromJson parses image, features and i18n texts', () {
      final p = Product.fromJson({
        'id': 3,
        'name': 'GestCom',
        'slug': 'gestcom',
        'image_path': 'https://x.test/storage/products/images/a.png',
        'gallery': ['https://x.test/1.png'],
        'features': ['Invoices', 'Stock', ''],
        'full_description': 'Full',
        'specifications': {'os': 'Windows'},
        'summary_i18n': {'ar': 'ملخص', 'fr': 'Résumé', 'en': ''},
        'description_i18n': {'en': 'Desc'},
        'sort_order': 4,
      });
      expect(p.hasImage, isTrue);
      expect(p.features, ['Invoices', 'Stock']);
      expect(p.gallery, hasLength(1));
      expect(p.summaryI18n, {'ar': 'ملخص', 'fr': 'Résumé'});
      expect(p.descriptionI18n, {'en': 'Desc'});
      expect(p.titleI18n, isNull);
      expect(p.sortOrder, 4);
      expect(p.specifications, {'os': 'Windows'});
    });

    test('fromJson tolerates a product without catalog data', () {
      final p = Product.fromJson({'id': 1, 'name': 'Basic'});
      expect(p.hasImage, isFalse);
      expect(p.features, isEmpty);
      expect(p.gallery, isEmpty);
      expect(p.sortOrder, 0);
    });

    test('payload leaves unmanaged catalog fields out', () {
      final json = const ProductPayload(name: ' A ').toJson();
      expect(json.containsKey('image_path'), isFalse);
      expect(json.containsKey('features'), isFalse);
      expect(json.containsKey('summary_i18n'), isFalse);
    });

    test('payload cleans blanks and clears the image when empty', () {
      final json = const ProductPayload(
        name: 'A',
        imagePath: '',
        features: [' Stock ', ''],
        summaryI18n: {'ar': ' ملخص ', 'fr': '  ', 'en': ''},
        sortOrder: 2,
      ).toJson();
      expect(json['image_path'], isNull);
      expect(json.containsKey('image_path'), isTrue);
      expect(json['features'], ['Stock']);
      expect(json['summary_i18n'], {'ar': 'ملخص'});
      expect(json['sort_order'], 2);
    });
  });
}
