// screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/favorites_provider.dart';

import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = context.read<AuthProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();

    await authProvider.checkAuthStatus();

    if (authProvider.user != null) {
      await subscriptionProvider.checkSubscription(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _currentIndex == 0
              ? 'الرئيسية'
              : _currentIndex == 1
                  ? 'المفضلة'
                  : 'الملف الشخصي',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(
              IconData(0xf333, fontFamily: 'MyFlutterApp'),
            ),
            selectedIcon: Icon(
              IconData(0xf333, fontFamily: 'MyFlutterApp') ),
            label: 'المفضلة',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'الملف الشخصي',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _currentIndex == 0
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, '/level-one');
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 30),
                label: const Text(
                  'إبدأ المشاهدة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildFavoritesTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Consumer2<AuthProvider, SubscriptionProvider>(
      builder: (context, authProvider, subscriptionProvider, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.5),
                      colorScheme.surface,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      width: 3,
                      color: colorScheme.primary.withValues(alpha: 0.7)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: colorScheme.primary, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(
                              authProvider.user?.fullName.isNotEmpty == true
                                  ? authProvider.user!.fullName
                                      .substring(0, 1)
                                      .toUpperCase()
                                  : 'ز',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.user?.fullName ?? 'زائر جديد',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                authProvider.user == null
                                    ? 'أهلاً بك في منصة أستاذ معاذ'
                                    : 'مستعد لدرس اليوم؟',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (authProvider.user == null)
                      _buildStatusContainer(
                        context,
                        icon: Icons.login_rounded,
                        title: 'حساب زائر',
                        subtitle: 'سجل دخولك لحفظ تمارينك',
                        color: colorScheme.primary,
                        onAction: () => Navigator.pushNamed(context, '/login'),
                        actionLabel: 'دخول',
                      )
                    else if (subscriptionProvider.hasActiveSubscription)
                      _buildStatusContainer(
                        context,
                        icon: Icons.verified_rounded,
                        title: 'اشتراكك نشط',
                        subtitle: subscriptionProvider.activePlansSummary,
                        color: Colors.green,
                      )
                    else
                      _buildStatusContainer(
                        context,
                        icon: Icons.star_rounded,
                        title: 'اشتراك مجاني',
                        subtitle: 'احصل على المميزات الكاملة',
                        color: Colors.orange,
                        onAction: () =>
                            Navigator.pushNamed(context, '/payment'),
                        actionLabel: 'ترقية',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Promo Card (Now Second)
              const PromoAdCard(),

              const SizedBox(height: 15),

              // Tips Card (Now Third)
              SoftInfoCard(
                title: 'نصائح للطلاب',
                subtitle: 'لضمان أعلى إستفادة من التطبيق',
                items: [
                  'راجع درسك أولاً',
                  'استخدم الورقة والقلم في كل مسألة',
                  'سؤالك يكمل فهمك',
                ],
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusContainer(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 14)),
                Text(subtitle,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11)),
              ],
            ),
          ),
          if (onAction != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer2<FavoritesProvider, SubscriptionProvider>(
      builder: (context, favoritesProvider, subscriptionProvider, _) {
        final favorites = favoritesProvider.favoriteExamples;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        if (favorites.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconData(0xf333, fontFamily: 'MyFlutterApp'),
                      size: 60,
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'لا يوجد شيء هنا',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'احفظ التمارين الهامة لتجدها هنا بسرعة',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/level-one'),
                    icon: const Icon(Icons.explore_rounded),
                    label: const Text('ابدأ الاستكشاف'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final example = favorites[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/example-page',
                    arguments: {'examples': favorites, 'index': index},
                  );
                },
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(example.thumbnail, fit: BoxFit.cover),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: IconButton.filledTonal(
                          onPressed: () =>
                              favoritesProvider.toggleFavorite(example),
                          icon: const Icon(Icons.favorite_rounded,
                              color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle_outlined,
                    size: 80,
                    color:
                        colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                const SizedBox(height: 24),
                const Text('لم تسجل دخولك بعد',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('تسجيل الدخول'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        user.fullName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onPrimary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(user.fullName,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900)),
                    Text(user.email,
                        style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Consumer<SubscriptionProvider>(
                builder: (context, subProvider, _) {
                  return _buildProfileTile(
                    icon: Icons.card_membership_rounded,
                    title: 'حالة الاشتراك',
                    subtitle: subProvider.hasActiveSubscription
                        ? subProvider.activePlansSummary
                        : 'مجاني',
                    subtitleColor: subProvider.hasActiveSubscription
                        ? Colors.green
                        : Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/payment'),
                  );
                },
              ),
              _buildProfileTile(
                icon: Icons.settings_rounded,
                title: 'الإعدادات',
                onTap: () => _showSettingsDialog(context),
              ),
              _buildProfileTile(
                icon: Icons.support_agent_rounded,
                title: 'الدعم الفني',
                onTap: () => Navigator.pushNamed(context, '/feedback'),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text('تسجيل الخروج',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w900)),
                onTap: () => _showLogoutDialog(context, authProvider),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                tileColor: Colors.red.withValues(alpha: 0.05),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خروج'),
        content: const Text('هل تريد حقاً تسجيل الخروج؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/home');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تأكيد الخروج'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: const Text('الإعدادات'),
              content: ListTile(
                leading: const Icon(Icons.dark_mode_rounded),
                title: const Text('مظهر التطبيق'),
                onTap: () => _showThemeSelectionDialog(context, themeProvider),
              ),
            );
          },
        );
      },
    );
  }

  void _showThemeSelectionDialog(
      BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر المظهر'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('تلقائي'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (v) {
                  themeProvider.setThemeMode(v!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('فاتح'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (v) {
                  themeProvider.setThemeMode(v!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('داكن'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (v) {
                  themeProvider.setThemeMode(v!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: subtitle != null
            ? Text(subtitle, style: TextStyle(color: subtitleColor))
            : null,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class SoftInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String> items;
  final VoidCallback? onTap;

  const SoftInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: colorScheme.primary.withAlpha(40),
          border: Border.all(
              width: 3,
              color: colorScheme.primary
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900)),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: colorScheme.primary, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(item,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class PromoAdCard extends StatelessWidget {
  const PromoAdCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final blue = const Color(0xFFFFC486);
    final yellow = const Color(0xFFA639F0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          gradient: LinearGradient(
            colors: [yellow.withAlpha(90), blue],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: blue.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.calculate,
                    size: 150, color: Colors.yellow.withValues(alpha: 0.2)),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مجموعات 2027',
                                style: TextStyle(
                                    color:Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'الرياضيات ONLINE',
                                style: TextStyle(
                                    color:Colors.white70,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: yellow, width: 3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: Image.asset('assets/images/img_1.webp',
                                fit: BoxFit.cover),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _launchWhatsApp(
                            context, 'أود الاستفسار عن مجموعات 2027'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellow,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('احجز مكانك الآن',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: ThemeData.light().colorScheme.onPrimary
                                )),
                            SizedBox(width: 10),
                            Icon(Icons.phone, size: 28,
                              color: Colors.white,

                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _launchWhatsApp(BuildContext context, String massage) async {
  final String number = AppConstants.whatsappNumber;
  final String message = Uri.encodeComponent(massage);
  final Uri url = Uri.parse("https://wa.me/$number?text=$message");

  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch WhatsApp');
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح واتساب. يرجى التأكد من تثبيته.')),
      );
    }
  }
}
