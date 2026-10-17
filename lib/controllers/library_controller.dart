import 'package:get/get.dart';

class LibraryController extends GetxController {
  final RxString selectedFilter = ''.obs;

  void toggleFilter(String filter) {
    if (selectedFilter.value == filter) {
      selectedFilter.value = '';
    } else {
      selectedFilter.value = filter;
    }
  }
}
