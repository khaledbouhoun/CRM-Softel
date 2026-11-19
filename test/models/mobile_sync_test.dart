import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/core/utils/file_access.dart';
import 'package:softel_crm/core/utils/formatters.dart';
import 'package:softel_crm/features/interventions/data/models/intervention.dart';
import 'package:softel_crm/features/products/data/models/product.dart';
import 'package:softel_crm/features/products/domain/pack_rules.dart';
import 'package:softel_crm/features/releases/data/models/product_release.dart';
import 'package:softel_crm/features/workflow_settings/data/models/settings_help.dart';

void main() {
  group('PackRules', () {
    const basic = Product(id: 1, name: 'Basic', packId: 7, packName: 'GestCom');
    const ultra = Product(id: 2, name: 'Ultra', packId: 7, packName: 'GestCom');
    const other = Product(id: 3, name: 'Other');
    const catalog = [basic, ultra, other];

    test('checking a pack product drops its siblings', () {
      var dropped = <Product>[];
      final next = PackRules.toggle(
        catalog: catalog,
        selected: {1, 3},
        productId: 2,
        checked: true,
        onReplaced: (p) => dropped = p,
      );
      expect(next, {2, 3});
      expect(dropped.map((p) => p.id), [1]);
    });

    test('unchecking and products without pack are unaffected', () {
      expect(
        PackRules.toggle(
          catalog: catalog,
          selected: {1},
          productId: 1,
          checked: false,
        ),
        <int>{},
      );
      expect(
        PackRules.toggle(
          catalog: catalog,
          selected: {1},
          productId: 3,
          checked: true,
        ),
        {1, 3},
      );
    });

    test('firstConflict names the pack', () {
      expect(PackRules.firstConflict(catalog: catalog, selected: [1, 2]), 'GestCom');
      expect(PackRules.firstConflict(catalog: catalog, selected: [1, 3]), isNull);
    });
  });

  group('file helpers', () {
    test('fileSize is human readable', () {
      expect(Formatters.fileSize(null), '—');
      expect(Formatters.fileSize(532), '532 B');
      expect(Formatters.fileSize(1536), '1.5 KB');
      expect(Formatters.fileSize(5 * 1024 * 1024), '5.0 MB');
      expect(Formatters.fileSize(120 * 1024 * 1024), '120 MB');
    });

    test('extensions and kinds', () {
      expect(FileAccess.extensionOf('Setup.EXE'), 'exe');
      expect(FileAccess.extensionOf('noext'), '');
      expect(FileAccess.isImage(name: 'a.PNG'), isTrue);
      expect(FileAccess.isPdf(mime: 'application/pdf'), isTrue);
      expect(FileAccess.isPdf(name: 'a.zip'), isFalse);
    });
  });

  group('intervention chat models', () {
    test('parses sender, attachments and status events', () {
      final msg = InterventionMessage.fromJson({
        'id': 1,
        'author_type': 'employee',
        'visibility': 'customer',
        'body': 'Bonjour',
        'sender': {'role': 'employee', 'name': 'Ahmed'},
        'attachments': [
          {
            'id': 9,
            'name': 'a.zip',
            'size': 2048,
            'is_previewable': false,
          },
        ],
      });
      expect(msg.isFromEmployee, isTrue);
      expect(msg.isEvent, isFalse);
      expect(msg.attachments.single.size, 2048);

      final event = InterventionMessage.fromJson({
        'id': 2,
        'kind': 'status_change',
        'body': '',
        'event': {
          'type': 'status_change',
          'actor': {'name': 'Ahmed', 'role': 'employee'},
          'old_status': {'id': 1, 'name': 'Open'},
          'new_status': {'id': 2, 'name': 'Closed'},
        },
      });
      expect(event.isEvent, isTrue);
      expect(event.event!.newStatus!.name, 'Closed');
      expect(event.event!.isReopen, isFalse);
    });

    test('is_status_event flag marks an event and nulls are tolerated', () {
      final m = InterventionMessage.fromJson({'id': 3, 'is_status_event': true});
      expect(m.isEvent, isTrue);
      expect(m.attachments, isEmpty);
    });
  });

  group('product releases', () {
    test('parses a release with an installer', () {
      final r = ProductRelease.fromJson({
        'id': 4,
        'product': {'id': 1, 'name': 'GestCom'},
        'version_number': '2.1.0',
        'audience': 'specific',
        'customer_ids': [5, 6],
        'installer': {'name': 'setup.exe', 'size': 1000},
        'is_published': true,
      });
      expect(r.hasInstaller, isTrue);
      expect(r.customerIds, [5, 6]);
      expect(r.audience, ReleaseAudience.specific);
    });

    test('payload omits customers unless the audience is specific', () {
      final base = ReleasePayload(
        productId: 1,
        versionNumber: ' 1.0 ',
        releaseDate: DateTime(2026, 11, 18),
        audience: ReleaseAudience.all,
        customerIds: const [3],
        downloadUrl: '  ',
      );
      final json = base.toJson();
      expect(json['version_number'], '1.0');
      expect(json.containsKey('customer_ids'), isFalse);
      expect(json['download_url'], isNull);
      expect(
        base.toFormFields().where((e) => e.key == 'customer_ids[]'),
        isEmpty,
      );
    });
  });

  group('settings help', () {
    test('parses fields and maps entity names to section keys', () {
      final h = SettingsHelp.fromJson({
        'title': 'Appointment types',
        'fields': {
          'color': {'label': 'Color', 'help': 'Hex', 'example': '#16A34A'},
        },
      });
      expect(h.fields.single.example, '#16A34A');
      expect(SettingsHelp.sectionKey('appointment-types'), 'appointment_types');
    });
  });
}
