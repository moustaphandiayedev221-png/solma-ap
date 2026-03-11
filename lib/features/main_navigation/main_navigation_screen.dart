import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive/responsive_module.dart';
import '../home/presentation/screens/home_screen.dart';
import '../cart/presentation/screens/cart_screen.dart';
import '../profile/presentation/screens/profile_screen.dart';
import '../profile/presentation/screens/wishlist_screen.dart';
import '../search/presentation/screens/search_screen.dart';
import 'providers/main_nav_index_provider.dart';
import 'widgets/main_bottom_nav.dart';

/// Navigation principale avec bottom bar (Home, Search, Favoris, Cart, Profile)
/// Utilise IndexedStack lazy : ne construit que l'onglet visible + ceux déjà visités
/// pour éviter un freeze au chargement initial (5 écrans + providers en parallèle).
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  final Set<int> _visitedIndices = {0};

  static Widget _screenAt(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const SearchScreen();
      case 2:
        return const WishlistScreen(inMainNav: true);
      case 3:
        return const CartScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainNavIndexProvider);
    _visitedIndices.add(currentIndex);

    final width = MediaQuery.sizeOf(context).width;
    final useMaxWidth = width > Breakpoint.maxContentWidth;

    return Scaffold(
      extendBody: true,
      body: useMaxWidth
          ? Center(
              child: SizedBox(
                width: Breakpoint.maxContentWidth,
                height: double.infinity,
                child: IndexedStack(
                  index: currentIndex,
                  sizing: StackFit.expand,
                  children: List.generate(5, (i) {
                    if (_visitedIndices.contains(i)) {
                      return KeyedSubtree(key: ValueKey(i), child: _screenAt(i));
                    }
                    return const SizedBox.shrink();
                  }),
                ),
              ),
            )
          : SizedBox.expand(
              child: IndexedStack(
                index: currentIndex,
                sizing: StackFit.expand,
                children: List.generate(5, (i) {
                  if (_visitedIndices.contains(i)) {
                    return KeyedSubtree(key: ValueKey(i), child: _screenAt(i));
                  }
                  return const SizedBox.shrink();
                }),
              ),
            ),
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: MainBottomNav(
          currentIndex: currentIndex,
          onTap: (i) => ref.read(mainNavIndexProvider.notifier).state = i,
        ),
      ),
    );
  }
}
