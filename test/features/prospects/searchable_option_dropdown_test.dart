import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/app/l10n/l10n.dart';
import 'package:softel_crm/features/prospects/presentation/widgets/searchable_option_dropdown.dart';
import 'package:softel_crm/features/settings/data/models/prospect_form_option.dart';

void main() {
  const options = [
    ProspectFormOption(
      id: 1,
      type: ProspectFormOption.typeBusinessActivity,
      name: 'Wholesale',
      requiresDetails: false,
      sortOrder: 1,
      isActive: true,
    ),
    ProspectFormOption(
      id: 2,
      type: ProspectFormOption.typeBusinessActivity,
      name: 'Retail',
      requiresDetails: false,
      sortOrder: 2,
      isActive: true,
    ),
    ProspectFormOption(
      id: 3,
      type: ProspectFormOption.typeBusinessActivity,
      name: 'Other',
      requiresDetails: true,
      sortOrder: 3,
      isActive: true,
    ),
  ];

  Widget buildTestWidget({
    String? currentValue,
    required ValueChanged<String?> onChanged,
    required Future<void> Function(String, {bool requiresDetails}) onAddNew,
  }) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SearchableOptionDropdown(
            type: ProspectFormOption.typeBusinessActivity,
            label: 'Business Activity',
            icon: Icons.storefront,
            options: options,
            currentValue: currentValue,
            onChanged: onChanged,
            onAddNew: onAddNew,
          ),
        ),
      ),
    );
  }

  testWidgets('renders SearchableOptionDropdown with initial value', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        currentValue: 'Wholesale',
        onChanged: (_) {},
        onAddNew: (_, {requiresDetails = false}) async {},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Business Activity'), findsOneWidget);
    expect(find.text('Wholesale'), findsOneWidget);
  });

  testWidgets('opens dropdown and displays all options on tap', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        currentValue: null,
        onChanged: (_) {},
        onAddNew: (_, {requiresDetails = false}) async {},
      ),
    );
    await tester.pumpAndSettle();

    // Tap on the field to open dropdown
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.text('Wholesale'), findsOneWidget);
    expect(find.text('Retail'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
  });

  testWidgets('filters options when typing and shows Add option when not found', (tester) async {
    String? addedName;
    bool? addedRequiresDetails;

    await tester.pumpWidget(
      buildTestWidget(
        currentValue: null,
        onChanged: (_) {},
        onAddNew: (name, {bool requiresDetails = false}) async {
          addedName = name;
          addedRequiresDetails = requiresDetails;
        },
      ),
    );
    await tester.pumpAndSettle();

    // Tap on field and enter search query
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Clinic');
    await tester.pumpAndSettle();

    // Existing options should be filtered out
    expect(find.text('Wholesale'), findsNothing);
    expect(find.text('Retail'), findsNothing);

    // Add option tile should be visible
    expect(find.textContaining('Clinic'), findsWidgets);

    // Tap on add option icon
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();

    expect(addedName, equals('Clinic'));
    expect(addedRequiresDetails, isFalse);
  });

  testWidgets('selects existing option on tap', (tester) async {
    String? selectedValue;

    await tester.pumpWidget(
      buildTestWidget(
        currentValue: null,
        onChanged: (val) => selectedValue = val,
        onAddNew: (_, {requiresDetails = false}) async {},
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Retail'));
    await tester.pumpAndSettle();

    expect(selectedValue, equals('Retail'));
  });

  testWidgets('adds new option with requiresDetails when clicking detail button', (tester) async {
    String? addedName;
    bool? addedRequiresDetails;

    await tester.pumpWidget(
      buildTestWidget(
        currentValue: null,
        onChanged: (_) {},
        onAddNew: (name, {bool requiresDetails = false}) async {
          addedName = name;
          addedRequiresDetails = requiresDetails;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Special Agency');
    await tester.pumpAndSettle();

    // Tap on the edit_note button inside the add tile
    await tester.tap(find.byIcon(Icons.edit_note));
    await tester.pumpAndSettle();

    expect(addedName, equals('Special Agency'));
    expect(addedRequiresDetails, isTrue);
  });

  testWidgets('pressing Enter on new text adds the option', (tester) async {
    String? addedName;

    await tester.pumpWidget(
      buildTestWidget(
        currentValue: null,
        onChanged: (_) {},
        onAddNew: (name, {bool requiresDetails = false}) async {
          addedName = name;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Pharmacy');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(addedName, equals('Pharmacy'));
  });

  testWidgets('clearing the selection invokes onChanged(null)', (tester) async {
    String? selectedValue = 'Wholesale';

    await tester.pumpWidget(
      buildTestWidget(
        currentValue: 'Wholesale',
        onChanged: (val) => selectedValue = val,
        onAddNew: (_, {requiresDetails = false}) async {},
      ),
    );
    await tester.pumpAndSettle();

    // Tap clear (X) icon in suffix
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(selectedValue, isNull);
  });
}
