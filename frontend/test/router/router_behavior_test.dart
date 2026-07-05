import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/utils/app_routers.dart';

void main() {
  test('redirect helpers enforce auth, company membership, and admin access', () {
    final signedOut = AuthState();
    final signedIn = AuthState(isSigned: true, user: _user());
    final companyMember = AuthState(
      isSigned: true,
      user: _user(isCompanyMember: true, company: _company()),
    );
    final admin = AuthState(isSigned: true, user: _user(isSuperUser: true));

    expect(
      appRedirectForRoute('/inventory', signedOut),
      '/auth?redirect_to=/inventory',
    );
    expect(appRedirectForRoute('/inventory', signedIn), '/home');
    expect(appRedirectForRoute('/inventory', companyMember), isNull);
    expect(appRedirectForRoute('/admin', companyMember), '/home');
    expect(appRedirectForRoute('/admin', admin), isNull);
    expect(
      appRedirectForRoute('/storefront/b2c/orders', signedOut),
      '/auth?redirect_to=/storefront/b2c/orders',
    );
  });

  testWidgets('inventory deep link without product extra shows fallback page', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/inventory/product/1',
      routes: [
        GoRoute(
          path: '/inventory/product/:id',
          builder: (context, state) => buildInventoryProductRoute(state),
        ),
      ],
    );
    await tester.pumpWidget(
      const ProviderScope(child: SizedBox.shrink()),
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Product Unavailable'), findsWidgets);
  });

  testWidgets('order result deep link without checkout payload shows fallback page', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/storefront/order-result?audience=b2b',
      routes: [
        GoRoute(
          path: '/storefront/order-result',
          builder: (context, state) => buildOrderResultRoute(state),
        ),
        GoRoute(
          path: '/storefront/:audience/orders',
          builder: (context, state) =>
              Text('Orders ${state.pathParameters['audience']}'),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order Result Unavailable'), findsWidgets);
    expect(find.text('Open My Orders'), findsOneWidget);
  });
}

Company _company() {
  return const Company(
    id: 10,
    name: 'Solar Hub Co',
    allowsB2B: true,
    allowsB2C: true,
    status: 'active',
  );
}

User _user({
  bool isSuperUser = false,
  bool isCompanyMember = false,
  Company? company,
}) {
  return User(
    id: 1,
    username: 'tester',
    email: 'tester@example.com',
    firstName: 'Test',
    lastName: 'User',
    phone: '123',
    isSuperUser: isSuperUser,
    isCompanyMember: isCompanyMember,
    company: company,
  );
}
