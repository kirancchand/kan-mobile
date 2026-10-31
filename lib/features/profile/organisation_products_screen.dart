import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/error_state.dart';
import '../../data/models/organisation_content.dart';
import '../../data/models/organisation_draft.dart';
import '../../data/models/shop_org.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/services/organisation_content_api.dart';

class OrganisationProductsScreen extends StatefulWidget {
  const OrganisationProductsScreen({super.key, required this.organisation});
  final ShopOrg organisation;

  @override
  State<OrganisationProductsScreen> createState() =>
      _OrganisationProductsScreenState();
}

class _OrganisationProductsScreenState
    extends State<OrganisationProductsScreen> {
  late final OrganisationContentApi _api;
  Future<(List<OrganisationProduct>, List<OrganisationOption>)>? _future;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _api = context.read<HomeRepository>().organisationContent;
    if (widget.organisation.canEditOrganisation) _future = _load();
  }

  Future<(List<OrganisationProduct>, List<OrganisationOption>)> _load() async {
    final values = await Future.wait<Object>([
      _api.products(widget.organisation),
      _api.productOptions(widget.organisation),
    ]);
    return (
      values[0] as List<OrganisationProduct>,
      values[1] as List<OrganisationOption>
    );
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() {
      _future = future;
    });
    try {
      await future;
    } catch (_) {/* Display retry state. */}
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Organisation products')),
        body: !widget.organisation.canEditOrganisation
            ? const Center(child: Text('You cannot manage this organisation.'))
            : FutureBuilder<
                (List<OrganisationProduct>, List<OrganisationOption>)>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ErrorState(
                        title: 'Could not load products', onRetry: _refresh);
                  }
                  final (products, options) = snapshot.data!;
                  final labels = {
                    for (final option in options) option.value: option.label
                  };
                  final query = _search.text.trim().toLowerCase();
                  final filteredProducts = products.where((product) {
                    final name = product.name.isNotEmpty
                        ? product.name
                        : labels[product.productId] ??
                            'Product ${product.productId}';
                    return query.isEmpty ||
                        name.toLowerCase().contains(query) ||
                        product.description.toLowerCase().contains(query) ||
                        product.productId.toLowerCase().contains(query);
                  }).toList();
                  return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(widget.organisation.name,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _search,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Search products',
                              suffixIcon: _search.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear search',
                                      onPressed: () {
                                        _search.clear();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add product'),
                            onPressed: options.isEmpty
                                ? null
                                : () async {
                                    final saved = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => _AddProductScreen(
                                                organisation:
                                                    widget.organisation,
                                                options: options,
                                                api: _api)));
                                    if (saved == true && mounted) {
                                      await _refresh();
                                    }
                                  },
                          ),
                          if (options.isEmpty)
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                    'No products are available to select.')),
                          if (products.isEmpty)
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Text('No products added yet.')),
                          if (products.isNotEmpty && filteredProducts.isEmpty)
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Text('No products match your search.')),
                          for (final product in filteredProducts)
                            Card(
                                child: ListTile(
                              title: Text(product.name.isNotEmpty
                                  ? product.name
                                  : labels[product.productId] ??
                                      'Product ${product.productId}'),
                              subtitle: Text(
                                  '${product.description}\nPrice: ${product.price} • Quantity: ${product.quantity}'),
                              isThreeLine: true,
                            )),
                        ],
                      ));
                },
              ),
      );
}

class _AddProductScreen extends StatefulWidget {
  const _AddProductScreen(
      {required this.organisation, required this.options, required this.api});
  final ShopOrg organisation;
  final List<OrganisationOption> options;
  final OrganisationContentApi api;
  @override
  State<_AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<_AddProductScreen> {
  final _form = GlobalKey<FormState>();
  final _price = TextEditingController(),
      _quantity = TextEditingController(),
      _description = TextEditingController();
  String? _productId;
  bool _saving = false;
  bool _unconfirmed = false;

  @override
  void dispose() {
    _price.dispose();
    _quantity.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _unconfirmed || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final result = await widget.api.addProduct(widget.organisation,
          productId: _productId!,
          price: num.parse(_price.text.trim()),
          quantity: int.parse(_quantity.text.trim()),
          description: _description.text);
      if (!mounted) return;
      if (result == ProductSaveResult.unconfirmed) {
        setState(() {
          _saving = false;
          _unconfirmed = true;
        });
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Product added')));
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error is ProductSaveException
              ? error.message
              : 'Could not save or verify the product. Check the product list before trying again.')));
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Add product')),
        body: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text(widget.organisation.name),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Product'),
                isExpanded: true,
                items: widget.options
                    .map((p) =>
                        DropdownMenuItem(value: p.value, child: Text(p.label)))
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _productId = value),
                validator: (value) => value == null ? 'Select a product' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _price,
                  enabled: !_saving,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final n = num.tryParse(value?.trim() ?? '');
                    return n == null || !n.isFinite || n < 0
                        ? 'Enter a valid price of zero or more'
                        : null;
                  }),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _quantity,
                  enabled: !_saving,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final n = int.tryParse(value?.trim() ?? '');
                    return n == null || n < 0
                        ? 'Enter a whole quantity of zero or more'
                        : null;
                  }),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _description,
                  enabled: !_saving,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 2,
                  maxLines: 4,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a description'
                      : null),
              const SizedBox(height: 24),
              if (_unconfirmed) ...[
                const Text(
                    'The request was sent, but the new product could not be confirmed in the organisation’s product list. Refresh the list before trying again.'),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('View products')),
              ],
              FilledButton(
                  onPressed: _saving || _unconfirmed ? null : _save,
                  child: Text(_saving ? 'Saving…' : 'Add product')),
            ])),
      ));
}
