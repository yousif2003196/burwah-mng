import 'package:flutter/material.dart';

enum ServiceProviderCategory { maintenance, electrical, moving, plumbing }

class ServiceProvider {
  final String id;
  final String nameAr;
  final String nameEn;
  final String tradeAr;
  final String tradeEn;
  final String cityAr;
  final String cityEn;
  final String taskCount;
  final String rating;
  final String completionRate;
  final String responseTime;
  final String phone;
  final ServiceProviderCategory category;
  final IconData icon;
  final bool available;
  final bool verified;
  final bool featured;
  final String featureAr;
  final String featureEn;

  const ServiceProvider({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.tradeAr,
    required this.tradeEn,
    required this.cityAr,
    required this.cityEn,
    required this.taskCount,
    required this.rating,
    required this.completionRate,
    required this.responseTime,
    required this.phone,
    required this.category,
    required this.icon,
    required this.available,
    required this.verified,
    required this.featured,
    required this.featureAr,
    required this.featureEn,
  });
}
