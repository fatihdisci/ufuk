import 'dart:ui' as ui;
import 'dart:typed_data'; // Explicit for ByteData
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ufuk/app/atmosphere/segment.dart';
import 'package:ufuk/data/repository/content_repository.dart';
import '../../features/share/share_card.dart';

class ShareService {
  Future<void> shareContent(
    BuildContext context, 
    DailyContent content, 
    TimeSegment segment
  ) async {
    debugPrint("ShareService: 1. Setup Overlay");
    final overlayState = Overlay.of(context);
    final GlobalKey boundaryKey = GlobalKey();
    
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: -2000, // Explicitly far off-screen
        child: RepaintBoundary(
          key: boundaryKey,
          child: Material(
            type: MaterialType.transparency,
            child: ShareCard(content: content, segment: segment),
          ),
        ),
      ),
    );

    try {
      overlayState.insert(entry);
      debugPrint("ShareService: 2. Overlay Inserted, Waiting for Render");
      
      // Wait for 2 frames to ensure mostly rendered? 100ms is safe.
      await Future.delayed(const Duration(milliseconds: 150));

      debugPrint("ShareService: 3. Capturing Image");
      final RenderRepaintBoundary? boundary = 
          boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint("ShareService: ERROR - Boundary not found");
        throw Exception("Boundary not found");
      }

      // Pixel Ratio 3.0 for sharp 1080p width
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        debugPrint("ShareService: ERROR - Encoding failed");
        throw Exception("Image encoding failed");
      }
      
      final buffer = byteData.buffer.asUint8List();
      debugPrint("ShareService: 4. Image Captured (${buffer.length} bytes)");

      // Create XFile from data (Web/Mobile compatible)
      final now = DateTime.now();
      final filename = 'ufuk_share_${now.millisecondsSinceEpoch}.png';
      
      final xFile = XFile.fromData(
        buffer,
        name: filename,
        mimeType: 'image/png',
      );

      debugPrint("ShareService: 5. Sharing XFile");
      await Share.shareXFiles(
        [xFile], 
        text: 'UFUK ile huzur olun.',
      );
      debugPrint("ShareService: 6. Share Triggered Successfully");

    } catch (e) {
      debugPrint("ShareService: CRITICAL ERROR: $e");
      rethrow;
    } finally {
      entry.remove();
      debugPrint("ShareService: Cleanup Complete");
    }
  }
}
