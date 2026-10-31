import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/error_state.dart';
import '../../data/models/service_definition.dart';
import '../../data/repositories/home_repository.dart';

class ServiceCatalogBuilder extends StatefulWidget {
  const ServiceCatalogBuilder({super.key, required this.builder});
  final Widget Function(
      BuildContext, List<ServiceDefinition>, Future<void> Function()) builder;

  @override
  State<ServiceCatalogBuilder> createState() => _ServiceCatalogBuilderState();
}

class _ServiceCatalogBuilderState extends State<ServiceCatalogBuilder> {
  late Future<List<ServiceDefinition>> _future;
  @override
  void initState() {
    super.initState();
    _future = context.read<HomeRepository>().getServices();
  }

  Future<void> _refresh() async {
    final future = context.read<HomeRepository>().getServices();
    setState(() {
      _future = future;
    });
    try {
      await future;
    } catch (_) {/* Render the retry state below. */}
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<ServiceDefinition>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return ErrorState(
                title: 'Could not load services', onRetry: _refresh);
          }
          return widget.builder(context, snapshot.data ?? [], _refresh);
        },
      );
}
