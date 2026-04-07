import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context, provider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearch,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          if (provider.filterType != 'all' || provider.filterCategory != 'all')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  if (provider.filterType != 'all')
                    _FilterChip(
                      label: provider.filterType,
                      onRemove: () => provider.setFilterType('all'),
                    ),
                  if (provider.filterCategory != 'all')
                    _FilterChip(
                      label: provider.filterCategory,
                      onRemove: () => provider.setFilterCategory('all'),
                    ),
                  TextButton(
                    onPressed: provider.clearFilters,
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: provider.state == LoadingState.loading
                ? const LoadingWidget()
                : provider.filtered.isEmpty
                    ? EmptyState(
                        emoji: '🔍',
                        title: 'No transactions found',
                        subtitle: provider.transactions.isEmpty
                            ? 'Add your first transaction'
                            : 'Try adjusting your search or filters',
                        action: provider.transactions.isEmpty
                            ? ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AddTransactionScreen()),
                                ),
                                child: const Text('Add Transaction'),
                              )
                            : null,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.filtered.length,
                        itemBuilder: (_, i) {
                          final tx = provider.filtered[i];
                          return TransactionTile(
                            transaction: tx,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddTransactionScreen(transaction: tx),
                              ),
                            ),
                            onDelete: () => provider.deleteTransaction(tx.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, TransactionProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const _FilterSheet(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Transactions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['all', 'income', 'expense'].map((type) {
              final selected = provider.filterType == type;
              return ChoiceChip(
                label: Text(type[0].toUpperCase() + type.substring(1)),
                selected: selected,
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(color: selected ? Colors.white : null),
                onSelected: (_) {
                  provider.setFilterType(type);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: {'all', ...AppConstants.expenseCategories, ...AppConstants.incomeCategories}
                .map((cat) {
              final selected = provider.filterCategory == cat;
              return ChoiceChip(
                label: Text(cat[0].toUpperCase() + cat.substring(1)),
                selected: selected,
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(color: selected ? Colors.white : null),
                onSelected: (_) {
                  provider.setFilterCategory(cat);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
