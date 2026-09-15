import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_app/core/constants/app_constants.dart';
import 'package:property_app/features/auth/domain/entities/app_user.dart';
import 'package:property_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:property_app/features/auth/presentation/screens/login_screen.dart';
import 'package:property_app/features/property/domain/entities/property.dart';
import 'package:property_app/features/property/domain/entities/property_filter.dart';
import 'package:property_app/features/property/presentation/providers/property_providers.dart';
import 'package:property_app/features/property/presentation/screens/property_detail_screen.dart';

class MockAuthNotifier extends AuthNotifier {
  final AppUser? initialUser;
  MockAuthNotifier(this.initialUser);

  @override
  FutureOr<AppUser?> build() => initialUser;
}

void main() {
  group('AppConstants Unit Tests', () {
    test('formatCurrency formats Indian Crores and Lakhs correctly', () {
      expect(AppConstants.formatCurrency(12500000), '₹1.25 Cr');
      expect(AppConstants.formatCurrency(4500000), '₹45 Lakh');
      expect(AppConstants.formatCurrency(2800000), '₹28 Lakh');
    });

    test('formatArea formats square footage correctly', () {
      expect(AppConstants.formatArea(1250), '1,250 sqft');
      expect(AppConstants.formatArea(3200, 'sq.ft'), '3,200 sq.ft');
    });

    test('PropertyType and PropertyStatus enum mapping', () {
      expect(PropertyType.fromString('Apartment'), PropertyType.apartment);
      expect(PropertyType.fromString('Villa'), PropertyType.villa);
      expect(PropertyType.fromString('Row House'), PropertyType.rowHouse);

      expect(PropertyStatus.fromString('Available'), PropertyStatus.available);
      expect(PropertyStatus.fromString('Sold'), PropertyStatus.sold);
      expect(PropertyStatus.fromString('Under Construction'),
          PropertyStatus.underConstruction);
    });
  });

  group('PropertyFilter Domain Tests', () {
    test('Filter active count and hasActiveFilters flag', () {
      const filter = PropertyFilter(
        keyword: 'Jaipur',
        type: PropertyType.villa,
        configuration: '4BHK',
      );

      expect(filter.hasActiveFilters, isTrue);
      expect(filter.activeFilterCount, 3);

      final cleared = filter.copyWith(
          clearKeyword: true, clearType: true, clearConfiguration: true);
      expect(cleared.hasActiveFilters, isFalse);
      expect(cleared.activeFilterCount, 0);
    });
  });

  group('Property Entity Tests', () {
    test('Property calculates pricePerSqft accurately', () {
      const property = Property(
        id: 'p001',
        name: 'Test Villa',
        type: 'Villa',
        location: 'Jaipur',
        price: 10000000,
        area: 2500,
        areaUnit: 'sqft',
        configuration: '4BHK',
        status: 'Available',
        description: 'Test description',
        imagePlaceholder: 'assets/images/img-1.png',
        ownerId: 'o001',
      );

      expect(property.pricePerSqft, 4000);
      expect(property.isAvailable, isTrue);
      expect(property.isSold, isFalse);
    });
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders PropertyApp branding, fields, and quick demo tiles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify branding and app name
      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      // Verify form fields and sign in button
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      await tester.enterText(textFields.first, 'mytest@example.com');
      await tester.enterText(textFields.last, 'password123');
      await tester.pumpAndSettle();

      expect(find.text('mytest@example.com'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });
  });

  group('PropertyDetailScreen Role & Ownership Tests', () {
    const testProperty = Property(
      id: 'p001',
      name: 'Sunrise Residency',
      type: 'Apartment',
      location: 'Vaishali Nagar, Jaipur',
      price: 4500000,
      area: 1250,
      areaUnit: 'sqft',
      configuration: '2BHK',
      status: 'Available',
      description: 'A nice 2BHK apartment',
      imagePlaceholder: 'assets/images/img-1.png',
      ownerId: 'o001',
    );

    final testDetailData = PropertyDetailData(
      property: testProperty,
      owner: {'id': 'o001', 'name': 'Priya Mehta', 'contact': '+91-9800011122'},
    );

    testWidgets('Regular user sees "Submit Interest" button',
        (WidgetTester tester) async {
      const regularUser = AppUser(
        id: 'u001',
        name: 'Aarav Sharma',
        email: 'user@test.com',
        role: 'user',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => MockAuthNotifier(regularUser)),
            propertyDetailProvider('p001')
                .overrideWith((ref) => Future.value(testDetailData)),
          ],
          child: const MaterialApp(
            home: PropertyDetailScreen(propertyId: 'p001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Submit Interest'), findsOneWidget);
      expect(find.text('Your Listing • View Inquiries'), findsNothing);
    });

    testWidgets(
        'Property owner sees "Your Listing • View Inquiries" instead of "Submit Interest"',
        (WidgetTester tester) async {
      const ownerUser = AppUser(
        id: 'o001',
        name: 'Priya Mehta',
        email: 'owner@test.com',
        role: 'owner',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => MockAuthNotifier(ownerUser)),
            propertyDetailProvider('p001')
                .overrideWith((ref) => Future.value(testDetailData)),
          ],
          child: const MaterialApp(
            home: PropertyDetailScreen(propertyId: 'p001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Listing • View Inquiries'), findsOneWidget);
      expect(find.text('Submit Interest'), findsNothing);
      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('Another owner sees "Owner View Only" and disabled action',
        (WidgetTester tester) async {
      const otherOwner = AppUser(
        id: 'o002',
        name: 'Rohan Kapoor',
        email: 'owner2@test.com',
        role: 'owner',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => MockAuthNotifier(otherOwner)),
            propertyDetailProvider('p001')
                .overrideWith((ref) => Future.value(testDetailData)),
          ],
          child: const MaterialApp(
            home: PropertyDetailScreen(propertyId: 'p001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Owner View Only'), findsOneWidget);
      expect(find.text('Submit Interest'), findsNothing);
      expect(find.text('You'), findsNothing);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isFalse);
    });
  });
}
