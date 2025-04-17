import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final Widget child;
  final RefreshController controller;
  final Function() onLoading;

  const CustomRefreshIndicator({
    required this.controller,
    required this.onLoading,
    required this.child,
    super.key,
  });

  /// Load the data from the server.
  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    onLoading();
    controller.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
        controller: controller,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: _loadData,
        onLoading: _loadData,
        header: const MaterialClassicHeader(),
        child: child);
  }
}
