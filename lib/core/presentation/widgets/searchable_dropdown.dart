import 'package:flutter/material.dart';

/// A fully custom, reusable searchable dropdown widget.
/// Opens a search dialog when tapped. No external packages required.
class SearchableDropdown<T extends Object> extends StatelessWidget {
  final String label;
  final T? selectedItem;
  final List<T> items;
  final String Function(T) itemAsString;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool isEnabled;
  final String? hint;
  final bool isRequired;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.itemAsString,
    required this.onChanged,
    this.selectedItem,
    this.validator,
    this.isEnabled = true,
    this.hint,
    this.isRequired = false,
  });

  Future<T?> _openSearchDialog(BuildContext context, T? current) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _SearchDialog<T>(
        label: label,
        items: items,
        itemAsString: itemAsString,
        selectedItem: current,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : Colors.grey.shade400;
    final fillColor = isDark
        ? theme.inputDecorationTheme.fillColor ?? const Color(0xFF1E2435)
        : Colors.white;
    final textColor =
        isDark ? Colors.white : theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final labelColor = textColor.withOpacity(0.7);

    return FormField<T>(
      initialValue: selectedItem,
      validator: validator,
      builder: (state) {
        final displayText = state.value != null
            ? itemAsString(state.value as T)
            : null;
        final hasError = state.errorText != null;

        return GestureDetector(
          onTap: isEnabled
              ? () async {
                  final result =
                      await _openSearchDialog(context, state.value);
                  if (result != null) {
                    state.didChange(result);
                    onChanged(result);
                  }
                }
              : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: isRequired ? '$label *' : label,
              hintText: hint ?? 'Select $label',
              errorText: hasError ? state.errorText : null,
              filled: true,
              fillColor: isEnabled ? fillColor : fillColor.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: borderColor.withOpacity(0.4)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              labelStyle: TextStyle(color: labelColor),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: isEnabled ? labelColor : labelColor.withOpacity(0.4),
              ),
            ),
            isEmpty: displayText == null,
            child: Text(
              displayText ?? '',
              style: TextStyle(
                color: isEnabled ? textColor : textColor.withOpacity(0.5),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}

/// Internal search dialog shown when the field is tapped.
class _SearchDialog<T extends Object> extends StatefulWidget {
  final String label;
  final List<T> items;
  final String Function(T) itemAsString;
  final T? selectedItem;

  const _SearchDialog({
    super.key,
    required this.label,
    required this.items,
    required this.itemAsString,
    this.selectedItem,
  });

  @override
  State<_SearchDialog<T>> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T extends Object>
    extends State<_SearchDialog<T>> {
  late List<T> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items
              .where((item) =>
                  widget.itemAsString(item).toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF1A2235) : Colors.white;
    final borderColor = isDark ? Colors.white24 : Colors.grey.shade300;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Dialog(
      backgroundColor: bgColor,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 480, maxHeight: 520),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Select ${widget.label}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon:
                        Icon(Icons.close, color: textColor.withOpacity(0.6)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle:
                      TextStyle(color: textColor.withOpacity(0.45)),
                  prefixIcon: Icon(Icons.search,
                      size: 20, color: textColor.withOpacity(0.6)),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              size: 18,
                              color: textColor.withOpacity(0.6)),
                          onPressed: () => _searchCtrl.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF252D3D)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: theme.colorScheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Divider(height: 1, color: borderColor),
            // Results list
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 36,
                              color: textColor.withOpacity(0.3)),
                          const SizedBox(height: 8),
                          Text(
                            'No results found',
                            style: TextStyle(
                                color: textColor.withOpacity(0.45),
                                fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        final item = _filtered[i];
                        final isSelected = widget.selectedItem == item;
                        return InkWell(
                          onTap: () => Navigator.pop(context, item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            color: isSelected
                                ? theme.colorScheme.primary
                                    .withOpacity(0.12)
                                : Colors.transparent,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.itemAsString(item),
                                    style: TextStyle(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : textColor,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check,
                                      size: 18,
                                      color: theme.colorScheme.primary),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
