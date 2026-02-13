import 'package:flutter/material.dart';
import 'package:muchi/data/love_coupon.dart';
import 'package:muchi/services/storage_service.dart'; // Reuse existing storage, but we'll add methods

class LoveCouponProvider extends ChangeNotifier {
  List<LoveCoupon> _coupons = [];

  List<LoveCoupon> get coupons => List.unmodifiable(_coupons);
  int get count => _coupons.length;

  LoveCouponProvider() {
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    _coupons = await StorageService.loadCoupons();
    _sortCoupons();
    notifyListeners();
  }

  Future<void> addCoupon(LoveCoupon coupon) async {
    _coupons.add(coupon);
    _sortCoupons();
    await StorageService.saveCoupons(_coupons);
    notifyListeners();
  }

  Future<void> deleteCoupon(LoveCoupon coupon) async {
    _coupons.remove(coupon);
    await StorageService.saveCoupons(_coupons);
    notifyListeners();
  }

  Future<void> updateCoupon(String id, LoveCoupon newCoupon) async {
    final index = _coupons.indexWhere((c) => c.id == id);
    if (index != -1) {
      _coupons[index] = newCoupon;
      _sortCoupons();
      await StorageService.saveCoupons(_coupons);
      notifyListeners();
    }
  }

  Future<void> toggleRedeem(String id) async {
    final index = _coupons.indexWhere((c) => c.id == id);
    if (index != -1) {
      final coupon = _coupons[index];
      _coupons[index] = LoveCoupon(
        id: coupon.id,
        title: coupon.title,
        description: coupon.description,
        expirationDate: coupon.expirationDate,
        isRedeemed: !coupon.isRedeemed,
        createdAt: coupon.createdAt,
      );
      await StorageService.saveCoupons(_coupons);
      notifyListeners();
    }
  }

  void _sortCoupons() {
    _coupons.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
  }

  Future<void> clearAll() async {
    _coupons.clear();
    await StorageService.clearCoupons();
    notifyListeners();
  }
}