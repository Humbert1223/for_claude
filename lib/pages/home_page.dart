import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/auth/profile_page.dart';
import 'package:novacole/pages/components/home/events_today_notification_widget.dart';
import 'package:novacole/pages/components/home/home_page_menu.dart';
import 'package:novacole/pages/components/home/welcome_page.dart';
import 'package:novacole/pages/notification_page.dart';
import 'package:novacole/theme/theme_model.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/constants.dart';
import 'package:provider/provider.dart';

const List<Widget> _tabs = [
  WelcomePage(),
  HomePageMenu(),
  NotificationPage(),
  ProfilePage(),
];

const List<String> _titles = [kAppName, 'Outils', 'Notifications', 'Profil'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _page = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    _checkLastNotification();
    Get.find<AuthController>().refreshUser();
  }

  Future<void> _checkLastNotification() async {
    try {
      final pref = await Http().local();
      final data = pref.getString(LocalStorageKeys.lastNotification);

      if (data != null && data.isNotEmpty) {
        final notification = jsonDecode(data) as Map<String, dynamic>;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed('/notification', arguments: notification);
        });
        await pref.remove(LocalStorageKeys.lastNotification);
      }
    } catch (e) {
      debugPrint('Erreur notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        final isDark = themeModel.isDark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: isDark ? Colors.grey[900] : Colors.white,
            systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
          ),
          child: Scaffold(
            extendBody: true,
            backgroundColor: _getBackgroundColor(context, isDark),
            appBar: _buildAppBar(context, isDark),
            body: Stack(
              children: [
                _buildBackgroundGradient(context, isDark),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.03, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(_page),
                    padding: const EdgeInsets.only(bottom: 100),
                    child: _tabs[_page],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundGradient(BuildContext context, bool isDark) {
    if (_page != 0) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 300,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              Theme.of(context).primaryColor.withValues(alpha:0.15),
              Colors.transparent,
            ]
                : [
              Theme.of(context).primaryColor.withValues(alpha:0.08),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context, bool isDark) {
    if (isDark) {
      return _page == 0 ? Colors.grey[900]! : Colors.grey[850]!;
    }
    return _page == 0 ? Colors.grey[50]! : Colors.white;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      toolbarHeight: 75,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha:0.85),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha:0.4)
                  : Theme.of(context).primaryColor.withValues(alpha:0.3),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              _buildTitleIcon(),
              size: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _titles[_page],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                if (_page == 0 && authController.currentUser.value?.name != null)
                  Text(
                    'Bienvenue, ${authController.currentUser.value!.name!.split(' ').first} 👋',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha:0.9),
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        const EventTodayNotificationWidget(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha:0.5)
                : Colors.black.withValues(alpha:0.12),
            blurRadius: 32,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
        ],
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha:0.1)
              : Colors.black.withValues(alpha:0.05),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SafeArea(
          child: Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 0, 'Accueil', isDark),
                _buildNavItem(Icons.grid_view_rounded, 1, 'Outils', isDark),
                _buildNotificationNavItem(isDark),
                _buildProfileNavItem(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon,
      int index,
      String label,
      bool isDark,
      ) {
    final isSelected = _page == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_page != index) {
            _animationController.forward().then((_) {
              _animationController.reverse();
            });
            if (mounted) {
              setState(() => _page = index);
            }
            HapticFeedback.mediumImpact();
          }
        },
        child: ScaleTransition(
          scale:
          isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha:0.18),
                  Theme.of(context).primaryColor.withValues(alpha:0.08),
                ],
              )
                  : null,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  padding: EdgeInsets.all(isSelected ? 8 : 6),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha:0.8),
                      ],
                    )
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha:0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : [],
                  ),
                  child: Icon(
                    icon,
                    size: isSelected ? 24 : 22,
                    color: isSelected
                        ? Colors.white
                        : isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: isSelected ? 11 : 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isDark
                        ? Colors.grey[500]
                        : Colors.grey[600],
                    letterSpacing: isSelected ? 0.3 : 0,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationNavItem(bool isDark) {
    final isSelected = _page == 2;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_page != 2) {
            _animationController.forward().then((_) {
              _animationController.reverse();
            });
            if (mounted) {
              setState(() => _page = 2);
            }
            HapticFeedback.mediumImpact();
          }
        },
        child: ScaleTransition(
          scale:
          isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha:0.18),
                  Theme.of(context).primaryColor.withValues(alpha:0.08),
                ],
              )
                  : null,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  padding: EdgeInsets.all(isSelected ? 8 : 6),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha:0.8),
                      ],
                    )
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha:0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : [],
                  ),
                  child: NotificationWidget(isSelected: isSelected, isDark: isDark),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: isSelected ? 11 : 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isDark
                        ? Colors.grey[500]
                        : Colors.grey[600],
                    letterSpacing: isSelected ? 0.3 : 0,
                  ),
                  child: const Text(
                    'Notifications',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileNavItem(bool isDark) {
    final isSelected = _page == 3;
    final imageProvider = authController.currentUser.value?.avatar == null
        ? const AssetImage('assets/images/person.jpeg') as ImageProvider
        : CachedNetworkImageProvider(authController.currentUser.value!.avatar!);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_page != 3) {
            _animationController.forward().then((_) {
              _animationController.reverse();
            });
            if (mounted) {
              setState(() => _page = 3);
            }
            HapticFeedback.mediumImpact();
          }
        },
        child: ScaleTransition(
          scale:
          isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha:0.18),
                  Theme.of(context).primaryColor.withValues(alpha:0.08),
                ],
              )
                  : null,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSelected ? 38 : 34,
                  height: isSelected ? 38 : 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha:0.8),
                      ],
                    )
                        : null,
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : isDark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: isSelected ? 3 : 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha:0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : [],
                  ),
                  child: ClipOval(
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: isSelected ? 11 : 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isDark
                        ? Colors.grey[500]
                        : Colors.grey[600],
                    letterSpacing: isSelected ? 0.3 : 0,
                  ),
                  child: const Text(
                    'Profil',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _buildTitleIcon() {
    switch (_page) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.grid_view_rounded;
      case 2:
        return Icons.notifications_rounded;
      case 3:
        return Icons.person_rounded;
      default:
        return Icons.home_rounded;
    }
  }
}

class NotificationWidget extends StatefulWidget {
  final bool isSelected;
  final bool isDark;

  const NotificationWidget({
    super.key,
    required this.isSelected,
    required this.isDark,
  });

  @override
  NotificationWidgetState createState() => NotificationWidgetState();
}

class NotificationWidgetState extends State<NotificationWidget> {
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> filters = [];

  @override
  void initState() {
    super.initState();
    UserModel.fromLocalStorage().then((user) {
      filters = [
        {'field': 'notifiable_id', 'operator': '=', 'value': user?.id},
        {'field': 'read_at', 'operator': '=', 'value': null}
      ];
      loadNotifications().then((value) {
        if (mounted) {
          setState(() {
            notifications = value;
          });
        }
      });
    });
  }

  Future<List<Map<String, dynamic>>> loadNotifications() async {
    List? response = await MasterCrudModel('notification')
        .search(paginate: '0', filters: filters);

    return response != null
        ? List<Map<String, dynamic>>.from(response)
        : [];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.notifications_rounded,
          size: widget.isSelected ? 24 : 22,
          color: widget.isSelected
              ? Colors.white
              : widget.isDark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
        if (notifications.isNotEmpty)
          Positioned(
            right: -15,
            top: -20,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.redAccent],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha:0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  notifications.length > 99
                      ? '99+'
                      : notifications.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}