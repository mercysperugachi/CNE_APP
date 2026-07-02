import 'dart:io';
import 'package:image/image.dart' as img;

class SharpnessValidator {
  // Umbral empírico: < 80 = borrosa, > 100 = nítida (rango 0-255 sobre varianza)
  static const double threshold = 100.0;

  bool isSharp(String imagePath) {
    try {
      final bytes = File(imagePath).readAsBytesSync();
      final src = img.decodeImage(bytes);
      if (src == null) return false;

      // Ensure grayscale conversion works correctly in image package v4+
      // In version 4+, decodeImage returns an Image object.
      // We can iterate over pixels directly to get luminance
      
      final w = src.width;
      final h = src.height;
      final luma = List.generate(h, (_) => List<int>.filled(w, 0));
      
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          final p = src.getPixel(x, y);
          // Luminance = 0.2126*R + 0.7152*G + 0.0722*B
          final r = p.r;
          final g = p.g;
          final b = p.b;
          luma[y][x] = (0.2126 * r + 0.7152 * g + 0.0722 * b).round();
        }
      }

      var sum = 0.0;
      var sumSq = 0.0;
      var count = 0;
      
      // Aplica kernel Laplaciano 3x3 [[0,1,0],[1,-4,1],[0,1,0]]
      for (var y = 1; y < h - 1; y++) {
        for (var x = 1; x < w - 1; x++) {
          final v = (luma[y-1][x] + luma[y+1][x] +
                     luma[y][x-1] + luma[y][x+1] - 4 * luma[y][x]).toDouble();
          sum += v.abs();
          sumSq += v * v;
          count++;
        }
      }
      
      if (count == 0) return false;
      final variance = (sumSq / count) - (sum / count) * (sum / count);
      return variance.abs() > threshold;
    } catch (e) {
      // In case of any decoding errors or read errors, default to false
      return false;
    }
  }
}