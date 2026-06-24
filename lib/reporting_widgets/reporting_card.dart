import 'package:flutter/material.dart';

class ReportingCard extends StatelessWidget {
  final List<MapEntry<String, String>> fields;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReportingCard({
    super.key,
    required this.fields,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Top Right Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onView != null)
                  IconButton(
                    onPressed: onView,
                    icon: const Icon(
                      Icons.visibility,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),

                const SizedBox(width: 8),

                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),

                const SizedBox(width: 8),

                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),

            const SizedBox(height: 6),

            // Fields
            ...fields.map(
                  (field) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            field.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: Text(
                            field.value,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}