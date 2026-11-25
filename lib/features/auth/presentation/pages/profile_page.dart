// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_notifier.dart';

/// User profile screen. Reads [AuthNotifier] state; sign-out is delegated
/// to the notifier without touching tokens directly.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const _heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(2.792),
    colors: [
      Color(0xFF7C3AED),
      Color(0xFF6750A4),
      Color(0xFF4A3580),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final user = switch (authState) {
      AuthStateAuthenticated(:final user) => user,
      _ => null,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Stack(
        children: [
          // Hero
          Container(
            height: 200,
            decoration: const BoxDecoration(gradient: _heroGradient),
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0x26FFFFFF),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 164), // 200 - 36dp overlap
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F5FF),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name section with avatar overlap
                  Container(
                    color: const Color(0xFFF7F5FF),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user != null
                                      ? '${user.firstName} ${user.lastName}'
                                      : 'Loading...',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1C1B1F),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.email ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF79747E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE7FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Username chip
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Text(
                        '@${user.username}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF79747E),
                        ),
                      ),
                    ),
                  // Menu items card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _menuItem(
                            icon: Icons.shopping_bag_outlined,
                            iconBg: const Color(0xFFEDE7FF),
                            iconColor: const Color(0xFF6750A4),
                            label: 'My Orders',
                            isFirst: true,
                          ),
                          _menuItem(
                            icon: Icons.bookmark_outline,
                            iconBg: const Color(0xFFFFF3E0),
                            iconColor: const Color(0xFFF97316),
                            label: 'Saved Items',
                          ),
                          _menuItem(
                            icon: Icons.location_on_outlined,
                            iconBg: const Color(0xFFE0F2FE),
                            iconColor: const Color(0xFF0284C7),
                            label: 'My Addresses',
                          ),
                          _menuItem(
                            icon: Icons.security_outlined,
                            iconBg: const Color(0xFFF0FDF4),
                            iconColor: const Color(0xFF16A34A),
                            label: 'Security & Privacy',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sign out button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () => ref
                            .read(authProvider.notifier)
                            .logout(),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF1F2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Avatar overlapping hero + card
          Positioned(
            top: 164,
            left: 20,
            child: _buildAvatar(user),
          ),
        ],
      ),
    );
  }


  Widget _buildAvatar(User? user) {
    final initials = user != null
        ? '${user.firstName[0]}${user.lastName[0]}'.toUpperCase()
        : '?';

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B7AEF), Color(0xFF6750A4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFFBFE),
          width: 4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFF4EFF4),
                  width: 1,
                ),
              ),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1C1B1F),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF79747E),
        ),
        onTap: () {},
      ),
    );
  }
}
