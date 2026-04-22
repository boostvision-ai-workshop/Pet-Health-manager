import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/pet_repository.dart';
import '../features/events/add_health_event_screen.dart';
import '../features/home/home_screen.dart';
import '../features/pet_profile/pet_profile_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/reminders/reminders_list_screen.dart';
import '../features/timeline/timeline_screen.dart';
import 'router_refresh.dart';

final _rootKey = GlobalKey<NavigatorState>();

GoRouter buildAppRouter(PetRepository repository) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    refreshListenable: routerRefreshNotifier,
    redirect: (context, state) {
      final pet = repository.getPet();
      final path = state.uri.path;
      if (pet == null) {
        if (path == '/pet/create' || path == '/pet/edit') return null;
        return '/pet/create';
      }
      if (path == '/pet/create') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/pet/create',
        builder: (context, state) => const PetProfileScreen(isEditing: false),
      ),
      GoRoute(
        path: '/pet/edit',
        builder: (context, state) => const PetProfileScreen(isEditing: true),
      ),
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/timeline',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TimelineScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/events/add',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const AddHealthEventScreen(),
      ),
      GoRoute(
        path: '/reminders',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const RemindersListScreen(),
      ),
    ],
  );
}

class _MainShell extends StatefulWidget {
  const _MainShell({required this.child});

  final Widget child;

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  static const _paths = ['/home', '/timeline', '/profile'];

  int _indexForLocation(String location) {
    if (location.startsWith('/timeline')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _indexForLocation(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_paths[i]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: '大事记',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
