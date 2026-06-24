import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/colors.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/scanner_provider.dart';
import '../inventory/add_product_screen.dart';
import '../sales/sale_screen.dart';

class ScannerScreen extends StatefulWidget {
  final bool returnBarcodeOnly;
  /// When true: if product found → pop(Product); if not found → pop(barcode string).
  final bool returnProductIfFound;
  const ScannerScreen({
    Key? key,
    this.returnBarcodeOnly = false,
    this.returnProductIfFound = false,
  }) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _cameraCtrl = MobileScannerController();

  late AnimationController _cardCtrl;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
  }

  @override
  void deactivate() {
    final scannerProvider = context.read<ScannerProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scannerProvider.reset();
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _cameraCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  void _handleCode(String code) {
    final scannerP = context.read<ScannerProvider>();
    if (!scannerP.canScan) return;
    if (code.isEmpty) return;

    scannerP.lockScan();
    HapticFeedback.mediumImpact();

    final product = context.read<ProductProvider>().getByBarcode(code);

    if (product != null) {
      if (widget.returnProductIfFound) {
        Navigator.pop(context, product);
        return;
      }
      scannerP.onProductFound(product);
      _cardCtrl.forward();
    } else {
      if (widget.returnProductIfFound) {
        // No match — return the raw barcode so the form can at least fill it
        Navigator.pop(context, code);
        return;
      }
      _showNotFound(code);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    _handleCode(code);
  }

  void _resetScanner() {
    _cardCtrl.reverse().then((_) {
      if (mounted) context.read<ScannerProvider>().reset();
    });
  }

  void _showNotFound(String barcode) {
    showDialog(
      context: context,
      barrierColor: AppColors.black,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: AppColors.darkRed, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Not Found',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No product matches:',
                style: TextStyle(color: AppColors.grey, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(barcode,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: Text('Scan Again', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldDark,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddProductScreen(initialBarcode: barcode),
                ),
              ).then((_) => _resetScanner());
            },
            child: const Text('Add Product',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _addToSale(Product product) {
    HapticFeedback.lightImpact();

    if (widget.returnBarcodeOnly) {
      Navigator.pop(context, product.barcode);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaleScreen(preselectedProduct: product),
      ),
    ).then((_) => _resetScanner());
  }

  void _showManualEntry() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Enter Barcode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Type barcode number manually',
                style: TextStyle(fontSize: 13, color: AppColors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 8901234567890',
                hintStyle: TextStyle(color: AppColors.grey),
                filled: true,
                fillColor: AppColors.lightGrey.withOpacity(0.3),
                prefixIcon: Icon(Icons.qr_code_rounded, color: AppColors.goldDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.goldDark, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldDark,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  final code = ctrl.text.trim();
                  if (code.isEmpty) return;
                  Navigator.pop(context);
                  _handleCode(code);
                },
                child: const Text('Search',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScannerProvider>(
      builder: (context, scannerP, _) {
        return Scaffold(
          backgroundColor: AppColors.black,
          body: Stack(
            children: [
              // camera
              MobileScanner(
                controller: _cameraCtrl,
                onDetect: _onDetect,
              ),

              // overlay
              _ScanOverlay(active: scannerP.canScan),

              // top bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TopBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Text('Scanner',
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3)),
                      _TopBtn(
                        icon: scannerP.flashOn
                            ? Icons.flashlight_on_rounded
                            : Icons.flashlight_off_rounded,
                        active: scannerP.flashOn,
                        onTap: () {
                          _cameraCtrl.toggleTorch();
                          scannerP.toggleFlash();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // hint
              if (scannerP.canScan)
                Positioned(
                  bottom: 240,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        'Align barcode within the frame to scan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.white.withOpacity(0.75),
                            fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _showManualEntry,
                        child: Text(
                          'ENTER BARCODE MANUALLY',
                          style: TextStyle(
                            color: AppColors.goldDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // product card
              if (scannerP.foundProduct != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: FadeTransition(
                      opacity: _cardFade,
                      child: _ProductCard(
                        product: scannerP.foundProduct!,
                        onAdd: () => _addToSale(scannerP.foundProduct!),
                        onDismiss: _resetScanner,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

//  Scan Overlay

class _ScanOverlay extends StatefulWidget {
  final bool active;
  const _ScanOverlay({required this.active});

  @override
  State<_ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<_ScanOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _lineCtrl;

  @override
  void initState() {
    super.initState();
    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _lineCtrl,
      builder: (_, __) => CustomPaint(
        painter: _OverlayPainter(
            lineProgress: _lineCtrl.value, active: widget.active),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double lineProgress;
  final bool active;
  static const double _fw = 260;
  static const double _fh = 200;
  static const double _cLen = 28;
  static const double _cThick = 3.5;

  _OverlayPainter({required this.lineProgress, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final left = (size.width - _fw) / 2;
    final top = (size.height - _fh) / 2 - 40;
    final frame = Rect.fromLTWH(left, top, _fw, _fh);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(frame, const Radius.circular(12))),
      ),
      Paint()..color = AppColors.black.withOpacity(0.55),
    );

    final cp = Paint()
      ..color = AppColors.goldDark
      ..strokeWidth = _cThick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void corner(Offset o, Offset h, Offset v) {
      canvas.drawLine(o, h, cp);
      canvas.drawLine(o, v, cp);
    }

    corner(frame.topLeft, frame.topLeft + const Offset(_cLen, 0),
        frame.topLeft + const Offset(0, _cLen));
    corner(frame.topRight, frame.topRight + const Offset(-_cLen, 0),
        frame.topRight + const Offset(0, _cLen));
    corner(frame.bottomLeft, frame.bottomLeft + const Offset(_cLen, 0),
        frame.bottomLeft + const Offset(0, -_cLen));
    corner(frame.bottomRight, frame.bottomRight + const Offset(-_cLen, 0),
        frame.bottomRight + const Offset(0, -_cLen));

    if (active) {
      final ly = top + _fh * lineProgress;
      canvas.drawLine(
        Offset(left + 10, ly),
        Offset(frame.right - 10, ly),
        Paint()
          ..shader = LinearGradient(colors: [
            AppColors.transparent,
            AppColors.goldLight.withOpacity(0.9),
            AppColors.transparent,
          ]).createShader(Rect.fromLTWH(left, ly, _fw, 2))
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_OverlayPainter o) =>
      o.lineProgress != lineProgress || o.active != active;
}

// Top Button 

class _TopBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _TopBtn({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: active
              ? AppColors.goldLight.withOpacity(0.9)
              : AppColors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? AppColors.goldDark
                : AppColors.white.withOpacity(0.2),
          ),
        ),
        child: Icon(icon, color: AppColors.white, size: 20),
      ),
    );
  }
}

// Product Card 

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  final VoidCallback onDismiss;

  const _ProductCard(
      {required this.product, required this.onAdd, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final low = product.quantity <= product.lowStockThreshold;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: AppColors.black, blurRadius: 20, offset: Offset(0, -4))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.backgroundBottom,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldDark.withOpacity(0.3)),
                ),
                child: product.imagePath != null && product.imagePath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(
                          File(product.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.inventory_2_rounded,
                            color: AppColors.goldDark,
                            size: 28,
                          ),
                        ),
                      )
                    : const Icon(Icons.inventory_2_rounded,
                        color: AppColors.goldDark, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 13,
                            color: low ? AppColors.darkRed : AppColors.grey),
                        const SizedBox(width: 4),
                        Text('${product.quantity} Units in stock',
                            style: TextStyle(
                                fontSize: 12,
                                color: low
                                    ? AppColors.darkRed
                                    : AppColors.grey,
                                fontWeight: low
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                        if (low) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.darkRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('LOW',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.darkRed,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${product.sellingPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldDark),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: product.quantity > 0 ? onAdd : null,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: product.quantity > 0
                            ? AppColors.goldDark
                            : AppColors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: AppColors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.grey!),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onDismiss,
              child: Text('Scan Another',
                  style: TextStyle(color: AppColors.grey, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}