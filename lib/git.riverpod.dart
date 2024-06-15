import 'package:clean_git/models/branch.dart';
import 'package:clean_git/models/commit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authorProvider = StateProvider<String>((ref) {
  return '';
});

final commitsProvider = StateProvider<List<CustomCommit>>((ref) {
  return [];
});

final branchesProvider = StateProvider<List<Branch>>((ref) {
  return [];
});
