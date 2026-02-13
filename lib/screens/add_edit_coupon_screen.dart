import 'package:flutter/material.dart';
import 'package:muchi/data/love_coupon.dart';
import 'package:muchi/providers/love_coupon_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddEditCouponScreen extends StatefulWidget {
  final LoveCoupon? coupon;

  const AddEditCouponScreen({super.key, this.coupon});

  @override
  State<AddEditCouponScreen> createState() => _AddEditCouponScreenState();
}

class _AddEditCouponScreenState extends State<AddEditCouponScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    if (widget.coupon != null) {
      _titleController.text = widget.coupon!.title;
      _descriptionController.text = widget.coupon!.description;
      _expirationDate = widget.coupon!.expirationDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coupon == null ? 'New Love Coupon' : 'Edit Love Coupon'),
        backgroundColor: const Color(0xFFFFF8F7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFF6B6B)),
      ),
      backgroundColor: const Color(0xFFFFF8F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title (e.g., "Free Hug")',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Expiration Date'),
                subtitle: Text(DateFormat('MMMM dd, yyyy').format(_expirationDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectExpirationDate,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final provider = context.read<LoveCouponProvider>();
                    final id = widget.coupon?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                    final coupon = LoveCoupon(
                      id: id,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      expirationDate: _expirationDate,
                      isRedeemed: widget.coupon?.isRedeemed ?? false,
                      createdAt: widget.coupon?.createdAt,
                    );
                    if (widget.coupon == null) {
                      provider.addCoupon(coupon);
                    } else {
                      provider.updateCoupon(id, coupon);
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(widget.coupon == null ? 'Create Coupon' : 'Update Coupon'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}