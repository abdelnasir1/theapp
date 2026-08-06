import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          children: [
            const Text(
              'اختر الخطة المناسبة لك',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'يمكنك الاشتراك في أكثر من خطة في نفس الوقت',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildPlanCard(
              context,
              name: 'أساسية',
              code: 'basicbook',
              price: '100,000',
              features: ['مشاهدة فيديوهات المستوى الأساسي', 'حفظ التمارين المفضلة'],
              color: Colors.blue,
              isActive: subProvider.isPlanActive('أساسية'),
            ),
            _buildPlanCard(
              context,
              name: 'متخصصة كتاب أول',
              code: 'firstbook_advance',
              price: '200,000',
              features: ['مشاهدة فيديوهات الكتاب الأول', 'دعم فني متخصص'],
              color: Colors.purple,
              isActive: subProvider.isPlanActive('متخصصة كتاب أول'),
            ),
            _buildPlanCard(
              context,
              name: 'متخصصة كتاب ثاني',
              code: 'secondbook_advance',
              price: '200,000',
              features: ['مشاهدة فيديوهات الكتاب الثاني', 'دعم فني متخصص'],
              color: Colors.teal,
              isActive: subProvider.isPlanActive('متخصصة كتاب ثاني'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String name,
    required String code,
    required String price,
    required List<String> features,
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
            ...features.map((f) => Padding(
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
