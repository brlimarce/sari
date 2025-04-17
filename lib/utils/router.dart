import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/utils/constants.dart';
import 'package:sari/views/dealers/login_view.dart';
import 'package:sari/views/dealers/profile_view.dart';
import 'package:sari/views/products/ar_view.dart';
import 'package:sari/views/products/product_scan_view.dart';
import 'package:sari/views/products/edit_product_form.dart';
import 'package:sari/views/products/home_view.dart';
import 'package:sari/views/products/product_form.dart';
import 'package:sari/views/products/product_profile.dart';
import 'package:sari/views/transactions/buyer_view.dart';
import 'package:sari/views/transactions/product_transaction_view.dart';
import 'package:sari/views/transactions/seller_view.dart';

class RouterService {
  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      // Login View
      GoRoute(
          path: LoginView.route,
          pageBuilder: (context, state) {
            return _buildRoute(const LoginView(), state);
          }),

      // Home View
      GoRoute(
          path: HomeView.route,
          pageBuilder: (context, state) {
            return _buildRoute(const HomeView(), state);
          }),

      // Buyer View
      GoRoute(
          path: BuyerView.route,
          pageBuilder: (context, state) {
            return _buildRoute(BuyerView(), state);
          }),

      // Seller View
      GoRoute(
          path: SellerView.route,
          pageBuilder: (context, state) {
            return _buildRoute(SellerView(), state);
          }),

      // Profile
      GoRoute(
          path: ProfileView.route,
          pageBuilder: (context, state) {
            final String id = state.pathParameters['id']!;
            final bool isOwner =
                id == context.read<DealerAuthProvider>().user?.uid;

            return _buildRoute(ProfileView(id: id, isOwner: isOwner), state);
          }),

      // Product Form
      GoRoute(
          path: ProductFormView.route,
          pageBuilder: (context, state) {
            return _buildRoute(ProductFormView(), state);
          }),

      // Product Edit Form
      GoRoute(
        path: EditProductFormView.route,
        pageBuilder: (context, state) {
          final String id = state.pathParameters['id']!;
          return _buildRoute(EditProductFormView(id: id), state);
        },
      ),

      // Product Profile
      GoRoute(
        path: ProductProfileView.route,
        pageBuilder: (context, state) {
          final String id = state.pathParameters['id']!;
          final bool isOwner = state.pathParameters['seller'] ==
              context.read<DealerAuthProvider>().user?.uid;

          return _buildRoute(
              ProductProfileView(id: id, isOwner: isOwner), state);
        },
      ),

      // Product Scan View
      GoRoute(
        path: ProductScanView.route,
        pageBuilder: (context, state) {
          final String id = state.pathParameters['id']!;
          final bool isFirst = state.pathParameters['priority'] == 'true';
          return _buildRoute(ProductScanView(id: id, isFirst: isFirst), state);
        },
      ),

      // AR View
      GoRoute(
        path: ArView.route,
        pageBuilder: (context, state) {
          final String id = state.pathParameters['id']!;
          final String scanUrl =
              Uri.decodeComponent(state.pathParameters['url']!);
          return _buildRoute(ArView(productId: id, scanUrl: scanUrl), state);
        },
      ),

      // Product Transactions
      GoRoute(
        path: ProductTransactionView.route,
        pageBuilder: (context, state) {
          final String id = state.pathParameters['id']!;
          final String name = state.pathParameters['name']!;
          return _buildRoute(ProductTransactionView(id: id, name: name), state);
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      const FlutterSecureStorage storage = FlutterSecureStorage();
      final bool loggedIn = await storage.read(key: FBID_HEADER) != null;
      final bool loggingIn = state.matchedLocation == LoginView.route;

      if (!loggedIn) return LoginView.route;
      if (loggingIn) return HomeView.route;
      return null;
    },
  );

  /// Add a page transition when redirecting to another route.
  ///
  /// Returns a [CustomTransitionPage].
  static CustomTransitionPage _buildRoute(Widget view, GoRouterState state) {
    return CustomTransitionPage(
        key: state.pageKey,
        child: view,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
              opacity: CurveTween(curve: Curves.easeIn).animate(animation),
              child: child);
        });
  }
}
