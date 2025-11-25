import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// prevent duplicate registrations (VERY IMPORTANT)
final Set<String> _registeredViews = {};

Widget webImage(
    String url, {
      double? width,
      double? height,
      BoxFit fit = BoxFit.cover,
      Function()? onTap,
    }) {
  if (!kIsWeb) {
    return GestureDetector(
      onTap: onTap,
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }

  // convert BoxFit → CSS object-fit
  String fitString;
  switch (fit) {
    case BoxFit.cover:
      fitString = 'cover';
      break;
    case BoxFit.contain:
      fitString = 'contain';
      break;
    case BoxFit.fill:
      fitString = 'fill';
      break;
    default:
      fitString = 'cover';
  }

  final viewType = url + "_view";

  // IMPORTANT: register only once
  if (!_registeredViews.contains(viewType)) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final wrapper = DivElement()
        ..style.width = width != null ? '${width}px' : '100%'
        ..style.height = height != null ? '${height}px' : '100%'
        ..style.cursor = 'pointer'
        ..style.position = 'relative'
        ..style.overflow = 'hidden';

      final img = ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = fitString;

      wrapper.append(img);

      // HTML click listener (works always)
      wrapper.onClick.listen((event) {
        if (onTap != null) onTap();
      });

      return wrapper;
    });

    _registeredViews.add(viewType);
  }

  return SizedBox(
    width: width,
    height: height,
    child: Stack(
      children: [
        HtmlElementView(viewType: viewType),

        // Flutter tap catcher – ensures click works 100%
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
          ),
        ),
      ],
    ),
  );
}
