import 'package:fireflutter/ViewModels/fireflutterviewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fireFlutterProvider =
    ChangeNotifierProvider<FireFlutterViewModelNotifier>(
        (_) => FireFlutterViewModelNotifier());
