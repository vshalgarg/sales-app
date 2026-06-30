import 'package:flutter/material.dart';

class ReportingCard extends StatelessWidget {
  final List<MapEntry<String, String>> fields;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  const ReportingCard({
    super.key,
    required this.fields,
    this.onEdit,
    this.onAdd,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              // Top Right Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionButton(
                    icon: Icons.add_circle_outline,
                    color: Colors.green,
                    onTap: onAdd ?? () {},
                  ),
                  const SizedBox(width: 6),

                  _actionButton(
                    icon: Icons.edit_outlined,
                    color: Colors.orange,
                    onTap: onEdit ?? () {},
                  ),
                  const SizedBox(width: 6),

                  _actionButton(
                    icon: Icons.delete_outline,
                    color: Colors.red,
                    onTap: onDelete ?? () {},
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Fields
              ...fields.map(
                    (field) => Padding(
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
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
