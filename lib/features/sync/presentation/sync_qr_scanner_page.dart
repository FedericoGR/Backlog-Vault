import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/design_system/bv_spacing.dart';

class SyncQrScannerPage extends StatefulWidget {
  const SyncQrScannerPage({
    required this.title,
    required this.unavailableMessage,
    super.key,
  });

  final String title;
  final String unavailableMessage;

  @override
  State<SyncQrScannerPage> createState() => _SyncQrScannerPageState();
}

class _SyncQrScannerPageState extends State<SyncQrScannerPage> {
  bool _returned = false;

  @override
  Widget build(BuildContext context) {
    final canUseCamera = Platform.isAndroid;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body:
          canUseCamera
              ? MobileScanner(
                onDetect: (capture) {
                  if (_returned) return;
                  String? value;
                  for (final barcode in capture.barcodes) {
                    final raw = barcode.rawValue?.trim();
                    if (raw != null && raw.isNotEmpty) {
                      value = raw;
                      break;
                    }
                  }
                  if (value == null) return;
                  _returned = true;
                  Navigator.pop(context, value);
                },
              )
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(BvSpacing.lg),
                  child: Text(
                    widget.unavailableMessage,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
    );
  }
}
