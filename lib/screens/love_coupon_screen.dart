import 'package:flutter/material.dart';
import 'package:muchi/data/love_coupon.dart';
import 'package:muchi/providers/love_coupon_provider.dart';
import 'package:muchi/screens/add_edit_coupon_screen.dart';
import 'package:muchi/services/data_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class LoveCouponScreen extends StatefulWidget {
  const LoveCouponScreen({super.key});

  @override
  State<LoveCouponScreen> createState() => _LoveCouponScreenState();
}

class _LoveCouponScreenState extends State<LoveCouponScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoveCouponProvider>(
      builder: (context, provider, child) {
        final coupons = provider.coupons;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Love Coupons ❤️'),
            backgroundColor: const Color(0xFFFFF8F7),
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFFFF6B6B)),
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Import coupons',
                onPressed: () => DataService.importCoupons(context),
              ),
              if (coupons.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.upload),
                  tooltip: 'Export coupons',
                  onPressed: () => DataService.exportCoupons(context),
                ),
              if (coupons.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => _showClearAllDialog(context),
                ),
            ],
          ),
          backgroundColor: const Color(0xFFFFF8F7),
          body: coupons.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border,
                          size: 80, color: Color(0xFFFFB6C1)),
                      SizedBox(height: 16),
                      Text(
                        'No love coupons yet!',
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFFFF6B6B)),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap + to create one for your BF 💕',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: coupons.length,
                  itemBuilder: (context, index) {
                    final coupon = coupons[index];
                    final isExpired =
                        coupon.expirationDate.isBefore(DateTime.now());
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: isExpired ? Colors.grey.shade200 : Colors.white,
                      child: ListTile(
                        leading: Icon(
                          coupon.isRedeemed
                              ? Icons.check_circle
                              : Icons.card_giftcard,
                          color: coupon.isRedeemed
                              ? Colors.green
                              : const Color(0xFFFF6B6B),
                          size: 40,
                        ),
                        title: Text(
                          coupon.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isExpired
                                ? Colors.grey
                                : const Color(0xFF333333),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(coupon.description),
                            const SizedBox(height: 4),
                            Text(
                              'Expires: ${DateFormat('MMM dd, yyyy').format(coupon.expirationDate)}',
                              style: TextStyle(
                                color: isExpired ? Colors.red : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditCouponScreen(coupon: coupon),
                                ),
                              );
                            } else if (value == 'delete') {
                              _showDeleteDialog(context, coupon);
                            } else if (value == 'redeem') {
                              provider.toggleRedeem(coupon.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(
                                value: 'redeem', child: Text('Toggle Redeem')),
                            const PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddEditCouponScreen()),
              );
            },
            backgroundColor: const Color(0xFFFF6B6B),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, LoveCoupon coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon'),
        content:
            const Text('Are you sure you want to delete this love coupon?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<LoveCouponProvider>().deleteCoupon(coupon);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Coupons'),
        content:
            const Text('Are you sure you want to delete all love coupons?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<LoveCouponProvider>().clearAll();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
