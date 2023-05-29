import 'dart:math';
import 'package:image/image.dart' as img;

// This function returns a list in which at 0 index it contains the final image and at 1st index it contains shape of image without applying border
List letterbox(
  img.Image im, {
  List<int> newShape = const [640, 640], // [width, height]
}) {
  List<int> shape = [im.width, im.height]; // current shape [width, height]
  double r = min(newShape[0] / shape[0], newShape[1] / shape[1]);
  List<int> newUnpad = [
    (shape[0] * r).round(),
    (shape[1] * r).round(),
  ];
  if (shape.toList() != newUnpad) { //if current shape is not equal to new borderless shape
    // resize the image to desired width and height
    im = img.copyResize(im, width: newUnpad[0], height: newUnpad[1]);
  }
  // borderedImage is like canvas of required width and height
  final borderedImage = img.Image(width: newShape[0],height: newShape[1]);
  // Fill the borderedImage with the any color
  img.fill(borderedImage,color: img.ColorFloat64.rgb(0,0,0));
  // merged both image, resizedimage on boredered image
  img.compositeImage(borderedImage, im,center: true);
  return [borderedImage,newUnpad];
}