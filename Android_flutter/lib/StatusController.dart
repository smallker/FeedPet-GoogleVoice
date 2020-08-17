import 'package:get/get.dart';

class StatusController extends GetxController {
  var status = 'Push to start';
  updateStatus(int state) {
    switch (state) {
      case 0:
        status = 'The food is empty ❌😿';
        break;
      case 1:
        status = 'The food is full 💗😻';
        break;
      case 2:
        status = 'Feeding your pet 🥧🐈';
        break;
      default:
        status = 'Push to Start';
    }
    update();
  }
}
