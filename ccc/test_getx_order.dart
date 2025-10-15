import 'package:get/get.dart';

class ServiceA extends GetxService {
  Future<ServiceA> init() async {
    print('ServiceA init start');
    await Future.delayed(Duration(seconds: 1));
    print('ServiceA init done');
    return this;
  }
}

class ServiceB extends GetxService {
  ServiceA get _serviceA => Get.find<ServiceA>();
  
  Future<ServiceB> init() async {
    print('ServiceB init start');
    print('ServiceB accessing ServiceA: ${_serviceA.toString()}');
    print('ServiceB init done');
    return this;
  }
}

void main() async {
  print('=== Test: putAsync without await ===');
  Get.putAsync(() => ServiceA().init(), permanent: true);
  Get.putAsync(() => ServiceB().init(), permanent: true);
  
  await Future.delayed(Duration(seconds: 3));
  print('Done');
}
