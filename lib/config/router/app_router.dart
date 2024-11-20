import 'package:go_router/go_router.dart';

import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/product_screen.dart';


final appRouter = GoRouter(
  initialLocation: '/',
  routes: [

    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/product/:id', // /product/new
      builder: (context, state) => ProductScreen(
        productId: state.pathParameters['id'] ?? 'no-id',
      ),
    ),



  ]
);