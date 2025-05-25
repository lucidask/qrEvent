import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

import 'event.dart';
import 'event_provider.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  bool isScanned = false;
  bool showScanline = false;
  final AudioPlayer _player = AudioPlayer();
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
    autoStart: true,
  );

  late AnimationController _scanlineController;
  late Animation<double> _scanlineAnimation;

  @override
  void initState() {
    super.initState();

    _scanlineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _scanlineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanlineController, curve: Curves.linear),
    );

    _scanlineController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scanlineController.reset();
        showScanline = false;
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.setZoomScale(0.5); // Réduction du zoom
    });
  }

  @override
  void dispose() {
    _scanlineController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isScanned) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    setState(() {
      isScanned = true;
      showScanline = true;
    });

    _scanlineController.forward();

    await Future.delayed(const Duration(seconds: 1)); // attente fin animation
    await _validateQRCode(code);
    if (mounted) setState(() => isScanned = false);
  }

  Future<void> _validateQRCode(String qrCode) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final now = DateTime.now();

    for (final event in eventProvider.events) {
      if (!event.qrCodes.contains(qrCode)) continue;

      final start = _combineDateAndTime(event.date, event.startTime);
      final end = _combineDateAndTime(
        event.type == EventType.short ? event.date : event.endDate!,
        event.endTime,
      );

      // Already used: Show regardless of time
      if (event.usedQRCodes[qrCode] == true) {
        await _player.play(AssetSource('sounds/used.mp3'));
        return _showDialog(
          'QR Already Used',
          'This QR code has already been used.',
          Icons.warning,
          Colors.orange,
        );
      }

      // ⏳ Too early
      if (now.isBefore(start)) {
        await _player.play(AssetSource('sounds/not_found.mp3'));
        return _showDialog(
          'Too Early',
          'This QR code is not valid yet. Wait for ${event.date} at ${event.startTime}',
          Icons.schedule,
          Colors.blueGrey,
        );
      }

      // ❌ Expired
      if (now.isAfter(end)) {
        await _player.play(AssetSource('sounds/expired.mp3'));
        return _showDialog(
          'QR Expired',
          'This QR code is expired.',
          Icons.error,
          Colors.red,
        );
      }

      // ✅ First valid scan
      event.usedQRCodes[qrCode] = true;
      await _player.play(AssetSource('sounds/valid.mp3'));
      return _showDialog(
        'QR Valid',
        'This QR code is valid.',
        Icons.check_circle,
        Colors.green,
      );
    }

    // 🚫 Not Found
    await _player.play(AssetSource('sounds/not_found.mp3'));
    return _showDialog(
      'QR Not Found',
      'This QR code does not match any event.',
      Icons.error,
      Colors.grey,
    );
  }

  Future<void> _showDialog(String title, String message, IconData icon, Color color) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
      ),
    );
  }

  DateTime _combineDateAndTime(String date, String time) {
    final d = DateTime.parse(date);
    final t = TimeOfDay(
      hour: int.parse(time.split(':')[0]),
      minute: int.parse(time.split(':')[1]),
    );
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flashlight_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          _buildOverlay(),
          if (showScanline) _buildScanline(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildScanline() {
    return AnimatedBuilder(
      animation: _scanlineAnimation,
      builder: (_, __) {
        return Positioned(
          top: MediaQuery.of(context).size.height / 2 - 125 + (_scanlineAnimation.value * 250),
          left: MediaQuery.of(context).size.width / 2 - 125,
          child: Container(
            width: 250,
            height: 2,
            color: Colors.greenAccent,
          ),
        );
      },
    );
  }
}
