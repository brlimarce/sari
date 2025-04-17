import 'dart:io';

import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/widgets/model_viewer_widget.dart';
import 'package:vector_math/vector_math_64.dart';

class ArView extends StatefulWidget {
  static const String route = '/product/ar/:id/:url';
  int step = 1;

  final String productId;
  final String scanUrl;

  ArView({required this.productId, required this.scanUrl, super.key});

  @override
  ArViewState createState() => ArViewState();
}

class ArViewState extends State<ArView> {
  ARSessionManager? _sessionManager;
  ARObjectManager? _objectManager;
  ARAnchorManager? _anchorManager;

  ARAnchor? _currentAnchor;
  ARNode? _currentNode;

  HttpClient? _httpClient;
  bool _isModelPresent = false;

  @override
  void dispose() {
    super.dispose();
    if (_sessionManager != null) _sessionManager!.dispose();
  }

  /// Create and initialize the AR view.
  void _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    // Initialize the managers.
    _sessionManager = sessionManager;
    _objectManager = objectManager;
    _anchorManager = anchorManager;

    sessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      handleRotation: true,
      handlePans: true,
    );

    // Initialize the object manager.
    _objectManager!.onInitialize();

    // Set the tap handlers.
    sessionManager.onPlaneOrPointTap = _onPlaneOrPointTapped;

    // Download the model.
    _httpClient = HttpClient();
    _downloadFile(widget.scanUrl, "product.glb");
  }

  /// Download the model from a network URL.
  Future<File> _downloadFile(String url, String filename) async {
    final request = await _httpClient!.getUrl(Uri.parse(url));
    final response = await request.close();

    final bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;

    File file = File('$dir/$filename');
    await file.writeAsBytes(bytes);

    return file;
  }

  /// Relocate the 3D model to the tapped plane or point.
  Future<void> _onPlaneOrPointTapped(List<ARHitTestResult> hits) async {
    try {
      // Get the first plane hit.
      final singleHit = hits.firstWhere(
          (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
      final ARPlaneAnchor newAnchor =
          ARPlaneAnchor(transformation: singleHit.worldTransform);

      // Remove the old anchor to relocate the model.
      if (_currentAnchor != null) {
        await _anchorManager!.removeAnchor(_currentAnchor!);
      }

      // Add the new anchor.
      bool? didAddAnchor = await _anchorManager!.addAnchor(newAnchor);
      if (didAddAnchor!) {
        setState(() {
          _currentAnchor = newAnchor;
        });
      }

      final ARNode newNode = ARNode(
        type: NodeType.webGLB,
        uri: widget.scanUrl,
        scale: Vector3(0.4, 0.4, 0.4),
        position: Vector3(0.0, 0.0, 0.0),
        eulerAngles: Vector3(radians(120), radians(-270), radians(180)),
      );

      if (_currentNode != null) {
        _objectManager!.removeNode(_currentNode!);
      }

      // Add the new node to the anchor.
      bool? didAddNodeToAnchor =
          await _objectManager!.addNode(newNode, planeAnchor: newAnchor);
      if (didAddNodeToAnchor!) {
        setState(() {
          _currentNode = newNode;
          _isModelPresent = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ToastAlert.error(context, "Surface not detected. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(SariTheme.primaryPalette.get(98)),
        body: Container(
            decoration: const BoxDecoration(
                gradient: RadialGradient(colors: [
                  Color.fromRGBO(250, 245, 255, 1),
                  Color.fromRGBO(197, 177, 225, 1)
                ]),
                image: DecorationImage(
                    image: AssetImage('assets/logo_overlay.png'),
                    fit: BoxFit.cover)),
            child: Stack(children: [
              /// [AR View]
              if (widget.step == 0)
                ARView(
                    onARViewCreated: _onARViewCreated,
                    planeDetectionConfig: PlaneDetectionConfig.horizontal),

              /// [3D Model View]
              if (widget.step == 1)
                ModelViewerWidget(url: widget.scanUrl, zoom: '3m'),

              /// [Back Button]
              Positioned(
                  left: 16,
                  top: 60,
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back_rounded,
                          color: SariTheme.white))),

              /// [AR Instructions]
              if (widget.step == 0)
                Positioned(
                    bottom: 132,
                    left: MediaQuery.of(context).size.width ~/ 2 - 148,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: SariTheme.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Tap the white dots to display the object.',
                            style: TextStyle(
                                color: SariTheme.white,
                                fontWeight: FontWeight.bold)))),

              /// [View Button]
              Positioned(
                  right: MediaQuery.of(context).size.width ~/ 2 - 100,
                  bottom: 60,
                  child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          widget.step = widget.step == 0 ? 1 : 0;
                        });
                      },
                      style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4))),
                          elevation: WidgetStateProperty.all(16)),
                      label: Text(
                          widget.step == 1
                              ? 'View in your space'
                              : 'View the 3D Model',
                          style: TextStyle(
                              color: SariTheme.secondary,
                              fontWeight: FontWeight.bold)),
                      icon: Icon(
                        widget.step == 0
                            ? Icons.donut_large_rounded
                            : Icons.view_in_ar_rounded,
                        color: SariTheme.primary,
                      ))),

              /// [Node Instructions]
              if (_isModelPresent)
                Positioned(
                    top: 140,
                    left: MediaQuery.of(context).size.width ~/ 2 - 142,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: SariTheme.tertiary.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                            'Tap the object to rotate or reposition it.',
                            style: TextStyle(
                                color: SariTheme.white,
                                fontWeight: FontWeight.bold)))),

              /// [Remove Node Button]
              if (widget.step == 0 && _isModelPresent)
                Positioned(
                    top: 60,
                    right: 24,
                    child: Container(
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: SariTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                            onPressed: () {
                              _anchorManager!.removeAnchor(_currentAnchor!);
                              _objectManager!.removeNode(_currentNode!);
                              setState(() {
                                _isModelPresent = false;
                              });
                            },
                            icon: Icon(FontAwesomeIcons.rotateRight,
                                size: 20, color: SariTheme.white))))
            ])));
  }
}
