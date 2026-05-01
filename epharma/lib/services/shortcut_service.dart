import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchIntent extends Intent {
  const SearchIntent();
}

class NewProductIntent extends Intent {
  const NewProductIntent();
}

class ShortcutManagerWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onSearch;
  final VoidCallback onNewProduct;

  const ShortcutManagerWidget({
    super.key,
    required this.child,
    required this.onSearch,
    required this.onNewProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): const SearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): const NewProductIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SearchIntent: CallbackAction<SearchIntent>(onInvoke: (intent) => onSearch()),
          NewProductIntent: CallbackAction<NewProductIntent>(onInvoke: (intent) => onNewProduct()),
        },
        child: child,
      ),
    );
  }
}
