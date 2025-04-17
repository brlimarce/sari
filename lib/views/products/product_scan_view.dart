import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/main.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/views/transactions/seller_view.dart';
import 'package:sari/widgets/custom_alert_dialog.dart';
import 'package:sari/widgets/placeholder/icon_placeholder.dart';

class ProductScanView extends StatefulWidget {
  static const String route = '/product/scan/:id/:priority';
  static const int softLimit = 30;
  static const int hardLimit = 80;

  final String id;
  final bool isFirst;

  const ProductScanView({required this.id, required this.isFirst, super.key});

  @override
  ProductScanViewState createState() => ProductScanViewState();
}

class ProductScanViewState extends State<ProductScanView> {
  CameraController? _controller;
  int imageCount = 0;

  bool _isCameraReady = false;
  List<File> images = [];

  @override
  void initState() {
    context.loaderOverlay.show();
    onCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Selects the camera to use.
  ///
  /// [description] The camera description to use.
  void onCameraSelected(CameraDescription description) async {
    final previousController = _controller;

    // Instantiate the controller.
    final CameraController newController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    // Dispose the previous controller.
    await previousController?.dispose();

    // Replace with the new controller
    if (!mounted) return;
    setState(() {
      _controller = newController;
    });

    // Update the interface if camera is updated.
    newController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize the new camera.
    try {
      await newController.initialize();
    } on CameraException catch (_) {
      if (!mounted) return;
      ToastAlert.error(
          context, 'Please allow camera access in your device settings.');
    }

    // Update the camera state.
    if (!mounted) return;
    setState(() {
      _isCameraReady = _controller!.value.isInitialized;
    });

    // Hide the loader overlay.
    Timer(const Duration(milliseconds: 1000), () {
      context.loaderOverlay.hide();
    });
  }

  /// Handles the tap event on the camera view finder.
  ///
  /// [details] The tap down details.
  /// [constraints] The constraints of the camera view finder.
  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (_controller == null) return;
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    _controller!.setExposurePoint(offset);
    _controller!.setFocusPoint(offset);
  }

  /// Display a success dialog after processing the video.
  void _displaySuccessDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: 'Almost there...',
            icon: FontAwesomeIcons.spinner,
            iconColor: SariTheme.green,
            body: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Color(SariTheme.neutralPalette.get(40))),
                  children: const <TextSpan>[
                    TextSpan(text: 'Check if the 3D model has '),
                    TextSpan(
                        text: 'finished processing.',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' You may '),
                    TextSpan(
                        text: 'publish',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' the post or '),
                    TextSpan(
                        text: 're-scan',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' if you\'re not satisfied.'),
                  ],
                )),
            activeButtonLabel: 'Go Back',
            inactiveButtonLabel: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
              context.replace(SellerView.route);
            },
            onInactivePressed: () {
              Navigator.of(context).pop();
              context.replace(SellerView.route);
            },
          );
        });
  }

  /// Capture an image from the camera.
  void _captureImage() async {
    final CameraController? controller = _controller;

    // Prevent to capture if the # of images exceeds the limit.
    if (imageCount >= ProductScanView.hardLimit) {
      ToastAlert.error(context, 'You\'ve reached the $imageCount-photo limit.');
      return;
    }

    // Check if the capture is already pending.
    if (controller!.value.isTakingPicture) return null;

    // Capture the image.
    try {
      XFile image = await controller.takePicture();
      File file = File(image.path);

      // Add the image to the list.
      images.add(file);
      imageCount++;
    } on CameraException catch (_) {
      if (!mounted) return;
      ToastAlert.error(context,
          'There was an error while taking the picture. Please try again.');
    }
  }

  /// Process the images to reconstruct the product.
  void _processImages() async {
    // Show the loader overlay.
    context.loaderOverlay.show();

    // Process the images.
    int status = await context
        .read<ProductProvider>()
        .reconstructProduct(widget.id, images);

    // Complete the transaction.
    if (status == StatusCode.ACCEPTED) {
      if (!mounted) return;
      context.loaderOverlay.hide();
      _displaySuccessDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(builder: (context, provider, child) {
      if (context.loaderOverlay.visible) {
        context.loaderOverlay.hide();
      }

      if (provider.error.active) {
        ToastAlert.error(context, provider.error.error);
        provider.error.clear();
      }

      return Scaffold(
          extendBody: true,
          body: _isCameraReady
              ? Stack(alignment: Alignment.center, children: [
                  /// [Camera]
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: CameraPreview(_controller!, child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (details) =>
                              onViewFinderTap(details, constraints),
                        );
                      }))),

                  /// [Bounding Box]
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    height: MediaQuery.of(context).size.height - 300,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: SariTheme.black.withOpacity(0.5),
                            width: 300,
                            strokeAlign: BorderSide.strokeAlignOutside),
                        borderRadius: BorderRadius.circular(2)),
                  ),

                  /// [Exit Button]
                  if (!widget.isFirst)
                    Positioned(
                        left: 24,
                        top: 60,
                        child: IconButton(
                            icon: const Icon(FontAwesomeIcons.arrowLeft),
                            color: Color(SariTheme.neutralPalette.get(88)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })),

                  /// [Help Button]
                  Positioned(
                      right: 24,
                      top: 60,
                      child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(SariTheme.tertiaryPalette.get(92))),
                          child: IconButton(
                              icon: const Icon(Icons.question_mark_rounded,
                                  size: 20),
                              color: Color(SariTheme.tertiaryPalette.get(60)),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomAlertDialog(
                                        title: 'How to Scan',
                                        icon: FontAwesomeIcons.spinner,
                                        body: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              /// [Description]
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 0, 28),
                                                  child: Text(
                                                      'Follow these steps to elevate the look of your product\'s 3D model:',
                                                      textAlign:
                                                          TextAlign.justify,
                                                      style: TextStyle(
                                                          color: Color(SariTheme
                                                              .neutralPalette
                                                              .get(40))))),

                                              /// [Step A]
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 0, 8, 0),
                                                        child: Text(
                                                            'A.',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: SariTheme
                                                                    .primary))),
                                                    Flexible(
                                                        child: RichText(
                                                            textAlign: TextAlign
                                                                .justify,
                                                            text: TextSpan(
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                              children: const <TextSpan>[
                                                                TextSpan(
                                                                    text:
                                                                        ' Take '),
                                                                TextSpan(
                                                                    text:
                                                                        'at least 30 photos',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text:
                                                                        ' to showcase the product you\'re selling.\n'),
                                                              ],
                                                            )))
                                                  ]),

                                              /// [Step B]
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 0, 8, 0),
                                                        child: Text(
                                                            'B.',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: SariTheme
                                                                    .primary))),
                                                    Flexible(
                                                        child: RichText(
                                                            textAlign: TextAlign
                                                                .justify,
                                                            text: TextSpan(
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                              children: const <TextSpan>[
                                                                TextSpan(
                                                                    text:
                                                                        ' Make sure the product is centered '),
                                                                TextSpan(
                                                                    text:
                                                                        'within the border.\n',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ],
                                                            )))
                                                  ]),

                                              /// [Step C]
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 0, 8, 0),
                                                        child: Text(
                                                            'C.',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: SariTheme
                                                                    .primary))),
                                                    Flexible(
                                                        child: RichText(
                                                            textAlign: TextAlign
                                                                .justify,
                                                            text: TextSpan(
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                              children: const <TextSpan>[
                                                                TextSpan(
                                                                    text:
                                                                        ' Press the '),
                                                                TextSpan(
                                                                    text:
                                                                        'right arrow button',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text:
                                                                        ' to process the images.\n'),
                                                              ],
                                                            )))
                                                  ]),

                                              /// [Step D]
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 0, 8, 0),
                                                        child: Text(
                                                            'D.',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: SariTheme
                                                                    .primary))),
                                                    Flexible(
                                                        child: RichText(
                                                            textAlign: TextAlign
                                                                .justify,
                                                            text: TextSpan(
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                              children: const <TextSpan>[
                                                                TextSpan(
                                                                    text:
                                                                        ' Check the '),
                                                                TextSpan(
                                                                    text:
                                                                        'lower-left corner',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text:
                                                                        ' to see how many images you\'ve taken. '),
                                                              ],
                                                            )))
                                                  ]),
                                            ]),
                                        activeButtonLabel: 'Got it!',
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      );
                                    });
                              }))),

                  /// [Capture Button]
                  Positioned(
                    bottom: 40,
                    child: InkWell(
                        onTap: _captureImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.transparent, width: 2)),
                                child: const Icon(FontAwesomeIcons.solidCircle,
                                    size: 80, color: Colors.white38),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: Icon(FontAwesomeIcons.solidCircle,
                                  color: SariTheme.white, size: 66),
                            ),
                          ],
                        )),
                  ),

                  /// [Proceed Button]
                  Positioned(
                      right: 80,
                      bottom: 56,
                      child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: SariTheme.primary),
                          child: IconButton(
                              icon: const Icon(FontAwesomeIcons.arrowRight,
                                  size: 22),
                              color: SariTheme.white,
                              onPressed: () {
                                if (imageCount < ProductScanView.softLimit) {
                                  ToastAlert.error(context,
                                      'Take at least ${ProductScanView.softLimit - imageCount} photos for more accurate results.');
                                } else {
                                  _processImages();
                                }
                              }))),

                  /// [Image Count]
                  Positioned(
                    left: 60,
                    bottom: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(80),
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),

                        /// [Label]
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                  child: Icon(FontAwesomeIcons.images,
                                      color: SariTheme.white, size: 14)),
                              Text(
                                imageCount.toString().padLeft(2, '0'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: imageCount < 30
                                          ? Theme.of(context).colorScheme.error
                                          : SariTheme.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              )
                            ]),
                      ],
                    ),
                  ),

                  /// [Progress Bar]
                ])
              : const Center(
                  child: IconPlaceholder(
                      iconPath: 'assets/camera.png',
                      title: 'Looking for a camera...',
                      message:
                          'To use this feature, please allow camera access in your device settings.'),
                ));
    });
  }
}
