import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewerWidget extends StatelessWidget {
  final int exposure = 3;
  final String style = '''
    model-viewer {
      width: 100%;
      height: 100%;
      background: transparent;
    }
  ''';

  final String url;
  final String zoom;

  const ModelViewerWidget({
    required this.url,
    required this.zoom,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String angle = '280deg 100deg $zoom';
    return ModelViewer(
      src: url,
      cameraOrbit: angle,
      orientation: '80 0 20',
      autoRotate: false,
      autoPlay: true,
      loading: Loading.lazy,
      disableZoom: true,
      exposure: exposure,
      relatedCss: style,
    );
  }
}
