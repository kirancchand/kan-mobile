import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../core/widgets/error_state.dart';
import '../../data/models/shop_org.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/home_repository.dart';
import '../home/add_organisation_screen.dart';
import '../home/organisation_detail_screen.dart';
import 'organisation_products_screen.dart';
import 'organisation_advertisements_screen.dart';

class MyOrganisationsScreen extends StatefulWidget {
  const MyOrganisationsScreen({super.key});

  @override
  State<MyOrganisationsScreen> createState() => _MyOrganisationsScreenState();
}

class _MyOrganisationsScreenState extends State<MyOrganisationsScreen> {
  Future<List<ShopOrg>>? _organisations;
  int? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.watch<AuthRepository>().tokens?.userId;
    if (_userId != userId) {
      _userId = userId;
      _organisations = userId == null
          ? null
          : context.read<HomeRepository>().getMyOrganisations(userId);
    }
  }

  Future<void> _refresh() async {
    if (_userId == null) return;
    final future = context.read<HomeRepository>().getMyOrganisations(_userId!);
    setState(() => _organisations = future);
    try {
      await future;
    } catch (_) {
      // The FutureBuilder displays the retry state.
    }
  }

  String _errorMessage(Object? error) {
    if (error is FormatException || error is TypeError) {
      return 'The server returned organisation details in an unexpected format.';
    }
    if (error is TimeoutException) {
      return 'The organisation server took too long to respond. Please try again.';
    }
    if (error is StateError) {
      return 'Your session is unavailable. Please sign in again.';
    }
    if (error is http.ClientException) {
      final status =
          RegExp(r'HTTP (\d{3})').firstMatch(error.message)?.group(1);
      if (status == '401') {
        return 'Your session has expired. Please sign in again.';
      }
      if (status == '403') {
        return 'You do not have permission to view these organisations.';
      }
      if (status != null) {
        return 'The organisation server could not load the list (HTTP $status).';
      }
    }
    return 'Could not connect to the organisation server. Check your connection and try again.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('My organisations')),
        body: _userId == null
            ? const Center(child: Text('Sign in to see your organisations.'))
            : FutureBuilder<List<ShopOrg>>(
                future: _organisations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ErrorState(
                      title: 'Could not load your organisations',
                      message: _errorMessage(snapshot.error),
                      onRetry: _refresh,
                    );
                  }
                  final organisations = snapshot.data ?? [];
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (organisations.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                                'You are not a member of any organisations yet.'),
                          ),
                        for (final organisation in organisations)
                          ListTile(
                            title: Text(organisation.name),
                            subtitle: Text(organisation.address),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => OrganisationDetailScreen(
                                        organisation: organisation))),
                            trailing: organisation.canEditOrganisation
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        IconButton(
                                          tooltip: 'Edit organisation',
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: () async {
                                            final saved = await Navigator.push<
                                                    bool>(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        AddOrganisationScreen(
                                                            organisation:
                                                                organisation)));
                                            if (saved == true && mounted) {
                                              await _refresh();
                                            }
                                          },
                                        ),
                                        PopupMenuButton<String>(
                                          tooltip: 'Manage organisation',
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                                value: 'products',
                                                child: Text('Products')),
                                            PopupMenuItem(
                                                value: 'advertisements',
                                                child: Text('Ads / events')),
                                          ],
                                          onSelected: (value) => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => value ==
                                                          'products'
                                                      ? OrganisationProductsScreen(
                                                          organisation:
                                                              organisation)
                                                      : OrganisationAdvertisementsScreen(
                                                          organisation:
                                                              organisation))),
                                        ),
                                      ])
                                : null,
                          ),
                      ],
                    ),
                  );
                },
              ),
      );
}
