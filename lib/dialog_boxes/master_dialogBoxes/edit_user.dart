
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../customs/containers/role_dropdown.dart';
import '../../provider/master_provider/permission_provider.dart';
import '../../provider/master_provider/role_provider.dart';
import '../../provider/master_provider/user_provider.dart';

class EditUserDialog extends StatefulWidget {
  final int userId;
  final String username;

  const EditUserDialog({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  String? _selectedRole;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final roleProvider = context.read<RoleProvider>();
      final userProvider = context.read<UserProvider>();

      await roleProvider.fetchRoles(showLoader: false);

      final userRoles = await userProvider.fetchUserRoles(
        widget.userId,
        showLoader: false,
      );

      if (userRoles == null) {
        throw Exception(
          userProvider.errorMessage ?? 'Unable to load user roles',
        );
      }

      final availableRoles = roleProvider.roles
          .map((role) => role.roleName.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      String? selectedRole;

      if (userRoles.isNotEmpty) {
        final assignedRole = userRoles.first.trim();

        selectedRole = availableRoles.cast<String?>().firstWhere(
              (role) =>
          role!.toLowerCase() == assignedRole.toLowerCase(),
          orElse: () => null,
        );

        // Preserve the assigned role even if it isn't in the available list.
        selectedRole ??= assignedRole;
      }

      if (!mounted) return;

      setState(() {
        _selectedRole = selectedRole;
        _loading = false;
      });

      debugPrint('Available roles: $availableRoles');
      debugPrint('Assigned roles: $userRoles');
      debugPrint('Selected role: $_selectedRole');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedRole == null || _selectedRole!.trim().isEmpty) {
      setState(() {
        _error = 'Please select a role';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final provider = context.read<UserProvider>();

    final success = await provider.updateUserRoles(
      userId: widget.userId,
      roleNames: [_selectedRole!],
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _saving = false;
        _error = provider.errorMessage ?? 'Failed to update user';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roles = context.watch<RoleProvider>().roles;

    // Convert RoleModel list into role names for RoleDropdown.
    final List<String> roleNames = roles
        .map((role) => role.roleName)
        .where((name) => name.trim().isNotEmpty)
        .toList();

    final screenWidth = MediaQuery.of(context).size.width;

    final dialogWidth = screenWidth < 600
        ? screenWidth * 0.86
        : 420.0;
    final canUpdate =
    context.watch<PermissionProvider>().canUpdate('USER');

    if (!canUpdate) {
      return const AlertDialog(
        content: Text('You do not have permission to update users.'),
      );
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        width: dialogWidth,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 35),
              padding: const EdgeInsets.fromLTRB(18, 52, 18, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _loading
                  ? const SizedBox(
                height: 230,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit User',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF263F85),
                    ),
                  ),

                  const SizedBox(height: 22),

                 // _buildLabel('Username *'),

                  const SizedBox(height: 7),

                  TextFormField(
                    initialValue: widget.username,
                    readOnly: true,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: _fieldDecoration(
                      icon: Icons.person_outline,
                      labelText: 'Username ',
                    ),
                  ),

                   const SizedBox(height: 18),

                  // Custom RoleDropdown with all roles from API.
                  AbsorbPointer(
                    absorbing: _saving,
                    child: RoleDropdown(
                      value: _selectedRole,
                      roles: roleNames,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                          _error = null;
                        });
                      },
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF263F91),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                              height: 19,
                              width: 19,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Save Changes',
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _saving
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF263F85),
                              side: const BorderSide(
                                color: Color(0xFF263F85),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Circular icon overlapping the dialog.
            Container(
              height: 82,
              width: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EFFF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 5,
                ),
              ),
              child: const Icon(
                Icons.manage_accounts_outlined,
                size: 36,
                color: Color(0xFF263F85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required IconData icon,
    required String labelText,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF263F85),
        size: 27,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.black54,
          width: 1.3,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.black54,
          width: 1.3,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF263F85),
          width: 1.6,
        ),
      ),
    );
  }
}
