import 'package:dartz/dartz.dart';

import '../../models/errors/custom_exception.dart';
import '../../models/incoming_inspection/barcode_coil.dart';
import '../../models/incoming_inspection/coil_scan_result.dart';
import '../../models/incoming_inspection/inspection_form.dart';
import '../../models/incoming_inspection/inspection_option.dart';
import '../../models/incoming_inspection/vendor.dart';
import '../data_providers/rest_api/incoming_inspection/incoming_inspection_rest.dart';

class IncomingInspectionRepository {
  final IncomingInspectionRest incomingInspectionRest;

  IncomingInspectionRepository({required this.incomingInspectionRest});

  /// Rentang tanggal default saat layar pertama kali dibuka:
  /// end date = hari ini, start date = seminggu lalu.
  static InspectionDateRange defaultRange() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    return InspectionDateRange(
      start: end.subtract(const Duration(days: 7)),
      end: end,
    );
  }

  Future<Either<CustomException, List<Vendor>>> getVendors({
    required String keyword,
  }) {
    return incomingInspectionRest.getVendors(keyword: keyword.trim());
  }

  Future<Either<CustomException, List<BarcodeCoil>>> getBarcodeCoils({
    String? vendorId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return incomingInspectionRest.getBarcodeCoils(
      vendorId: vendorId,
      startDate: formatApiDate(startDate),
      endDate: formatApiDate(endDate),
    );
  }

  Future<Either<CustomException, CoilScanResult>> getCoilByBarcode({
    required String barcode,
  }) {
    return incomingInspectionRest.getCoilByBarcode(barcode: barcode.trim());
  }

  Future<Either<CustomException, InspectionOption>> getInspectionOption({
    String? millId,
  }) {
    return incomingInspectionRest.getInspectionOption(millId: millId);
  }

  Future<Either<CustomException, String>> submitInspection({
    required InspectionForm form,
  }) {
    return incomingInspectionRest.submitInspection(form: form);
  }

  /// Format tanggal yang diterima backend: yyyy-MM-dd.
  static String formatApiDate(DateTime value) {
    final yyyy = value.year.toString().padLeft(4, '0');
    final mm = value.month.toString().padLeft(2, '0');
    final dd = value.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }
}

/// Pasangan tanggal awal - akhir untuk filter.
/// Sengaja TIDAK memakai DateTimeRange dari flutter/material supaya lapis data
/// tidak bergantung pada package UI, dan tidak bertabrakan nama saat layar
/// mengimpor material.
class InspectionDateRange {
  final DateTime start;
  final DateTime end;

  const InspectionDateRange({required this.start, required this.end});
}
