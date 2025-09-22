import 'package:get/get.dart';
import '../controllers/generation_controller.dart';

class GenerationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GenerationController>(() => GenerationController());
  }
}
