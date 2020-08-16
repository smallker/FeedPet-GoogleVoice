import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
class View{
  MediaQueryData _mediaQueryData;
  static double x;
  static double y;
  static double blockX;
  static double blockY;
  void init(BuildContext context){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _mediaQueryData = MediaQuery.of(context);
    x = _mediaQueryData.size.width;
    y = _mediaQueryData.size.height;
    blockX = x/100;
    blockY = y/100;
  }
}

class CustomColor{
  final text = Color(0xFF707070);
  final primary = Color(0xFF1D99A7);
  final primary80 = Color(0xBF1D99A7);
  final warning = Color(0xFFE27070);
  final diklat = Color(0xFF184164);
  final litbang = Color(0xFF1DB8B8);
  final robotika = Color(0xFF0F4442);
  final danus = Color(0xFFEC5353);
  final humas = Color(0xFF1A0D50);
  final hrd = Color(0xFF0D4E50);
  final ki = Color(0xFF166141);
  final rt = Color(0xFFC4512C);
}