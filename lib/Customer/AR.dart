import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart'; // Add this

class ARViewScreen extends StatefulWidget {
  final String productId;
  const ARViewScreen({super.key, required this.productId});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  bool _isLoading = false;
  String? _error;

  // ================== AR LAUNCHER ==================
  
  Future<void> _launchARViewer(int productId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Request camera permission for Android
      if (Platform.isAndroid) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          throw Exception('Camera permission required for AR');
        }
      }

      const baseUrl = 'http://localhost:5000';
      final fileName = _getModelFileName(productId);
      final modelUrl = '$baseUrl/ar-models/$fileName';

      String arUrl = modelUrl;

      if (Platform.isAndroid) {
        arUrl =
            'https://arvr.google.com/scene-viewer/1.0?file=$modelUrl&mode=ar_only';
      }

      if (await canLaunchUrl(Uri.parse(arUrl))) {
        await launchUrl(Uri.parse(arUrl));
      } else {
        throw Exception('Could not launch AR viewer');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Map product IDs to GLB filenames
  String _getModelFileName(int productId) {
    switch (productId) {
      case 1:
        return 'canba7.glb'; // For product ID 1
      case 2:
        return 'table.glb'; // Add more mappings as needed
      default:
        throw Exception('Model not found');
    }
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Furniture in AR'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFurnitureButton(1, 'Modern Sofa'),
            const SizedBox(height: 20),
            _buildFurnitureButton(2, 'Wooden Table'),
            if (_isLoading) ...[
              const SizedBox(height: 30),
              const CircularProgressIndicator(),
            ],
            if (_error != null) ...[
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFurnitureButton(int productId, String label) {
    return ElevatedButton.icon(
        icon: const Icon(Icons.view_in_ar),
        label: Text('View $label'),
        onPressed: _isLoading ? null : () => _launchARViewer(productId),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ));
  }
}
