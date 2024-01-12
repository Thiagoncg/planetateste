import 'package:flutter/material.dart';
import 'package:page_testes/custom/controllers/capture_box_controller.dart';

class CaptureBox extends StatelessWidget {
  const CaptureBox({
    super.key,
    required this.controller,
    required this.child,
  });

  final CaptureBoxController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    key: controller.boxKey,
    child: child,
  );
}