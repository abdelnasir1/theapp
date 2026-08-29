import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/constants.dart';
import '../../providers/subscription_provider.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('خطط الاشتراك')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Active Plans Section ---
            if (subProvider.hasActiveSubscription) ...[
              const Text(
                'اشتراكاتك الحالية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildCommonTile(
                context,
                icon: Icons.check_circle_rounded,
                title: 'الخطط النشطة',
                subtitle: subProvider.activePlansSummary,
                subtitleColor: Colors.green,
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                onTap: () {},
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
            ],

            const Text(
              'اختر الخطة المناسبة لك',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنك الاشتراك في أكثر من خطة في نفس الوقت',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            _buildPlanCard(
              context,
              name: 'الرياضيات الأساسية',
              code: 'basicbook',
              price: '50,000',
              features: ['مشاهدة فيديوهات الرياضيات الأساسية'],
              color: Colors.blue,
              isActive: subProvider.isPlanActive('basicbook'),
            ),
            _buildPlanCard(
              context,
              name: 'متخصصة الكتاب الأول',
              code: 'firstbook_advance',
              price: '50,000',
              features: ['مشاهدة فيديوهات الكتاب الأول'],
              color: Colors.purple,
              isActive: subProvider.isPlanActive('firstbook_advance'),
            ),
            _buildPlanCard(
              context,
              name: 'متخصصة الكتاب الثاني',
              code: 'secondbook_advance',
              price: '50,000',
              features: ['مشاهدة فيديوهات الكتاب الثاني'],
              color: Colors.teal,
              isActive: subProvider.isPlanActive('secondbook_advance'),
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // --- Contact Support Section ---
            _buildCommonTile(
              context,
              icon: Icons.help_outline_rounded,
              title: 'التواصل مع الدعم',
              subtitle: 'واجهتك مشكلة في الدفع؟ تواصل معنا عبر واتساب',
              onTap: () => _launchWhatsApp(context),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final String number = AppConstants.whatsappNumber;
    final String message = Uri.encodeComponent("السلام عليكم، أود الاستفسار عن الدفع في تطبيق أستاذ معاذ");
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

  Widget _buildCommonTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    Color? backgroundColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: backgroundColor ?? colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: subtitleColor ?? colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              )
            : null,
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String name,
    required String code,
    required String price,
     List<String>? features,
    required Color color,
    required bool isActive,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: isActive ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isActive ? BorderSide(color: color, width: 3) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                    child: const Text('نشط', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$price جنيه',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 32),
            ...?features?.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 18, color: color),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f)),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isActive
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          '/receipt-upload',
                          arguments: {'planName': code, 'price': price},
                        );
                      },
                style: FilledButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(isActive ? 'الخطة الحالية' : 'اشترك الآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
