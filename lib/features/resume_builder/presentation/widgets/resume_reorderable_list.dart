import 'package:flutter/material.dart';
import '../../../../app/theme/index.dart';

/// Shared reorderable presentation retaining native drag and semantic actions.
class ResumeReorderableList extends StatelessWidget {
  const ResumeReorderableList({
    super.key,
    required this.header,
    required this.children,
    required this.onReorder,
  });
  final Widget header;
  final List<Widget> children;
  final ReorderCallback onReorder;
  @override
  Widget build(BuildContext context) => ReorderableListView(
    padding: const EdgeInsets.all(AppSpacing.lg),
    header: header,
    onReorder: onReorder,
    proxyDecorator: (child, index, animation) => Material(
      color: AppColors.transparent,
      elevation: AppSpacing.sm,
      borderRadius: AppRadii.card,
      child: child,
    ),
    buildDefaultDragHandles: false,
    children: [
      for (var index = 0; index < children.length; index++)
        Row(
          key: children[index].key,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children[index]),
            ReorderableDragStartListener(
              index: index,
              child: SizedBox.square(
                dimension: AppSpacing.touchTarget,
                child: Icon(
                  Icons.drag_handle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
    ],
  );
}
