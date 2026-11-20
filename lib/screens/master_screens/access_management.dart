import 'package:flutter/material.dart';
import 'package:hisabio/constants/app_spacing.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/provider/master_provider/role_provider.dart';
import 'package:hisabio/provider/master_provider/permission_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../constants/custom_icons.dart';
import '../../model_classes/role/role_model.dart';
import '../../pagination/user_pagination_widget.dart';


class AccessManagementScreen extends StatefulWidget {
  const AccessManagementScreen({super.key});

  @override
  State<AccessManagementScreen> createState() =>
      _AccessManagementScreenState();
}

class _AccessManagementScreenState
    extends State<AccessManagementScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted &&
          context.read<PermissionProvider>().hasPermission(
              'ACCESS_MANAGEMENT_CURD')) {
        context.read<RoleProvider>().fetchRoles();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;

  List<RoleModel> _filterRoles(List<RoleModel> roles) {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return roles;

    return roles.where((role) {
      return role.roleName.toLowerCase().contains(query) ||
          (role.roleDesc ?? '').toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);

    final canManageAccess = context.watch<PermissionProvider>()
        .hasPermission('ACCESS_MANAGEMENT_CURD');

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,

      appBar: mobile
          ? null
          : CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: 'Access Management',
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),

      body: Consumer<RoleProvider>(
        builder: (context, provider, child) {
          if (!canManageAccess) {
            return const Center(
              child: Text(
                'You do not have permission to access Access Management.',
              ),
            );
          }

          if (provider.isLoading && provider.roles.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null && provider.roles.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: provider.fetchRoles,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredRoles = _filterRoles(provider.roles);

          if (mobile) {
            return _buildMobileScreen(
              provider,
              filteredRoles,
            );
          }

          // Existing desktop layout
          if (provider.roles.isEmpty) {
            return const Center(
              child: Text('No roles found'),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchRoles,
            child: ListView.separated(
              padding: AppSpacing.screen,
              itemCount: provider.roles.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.cardSeparator),
              itemBuilder: (context, index) {
                return _buildDesktopRoleCard(
                  provider.roles[index],
                );
              },
            ),
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: canManageAccess
          ? FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: AppColors.primaryPurple,
        elevation: 6,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleFormScreen(),
            ),
          );
        },
        child: const Icon(
          Iconsax.add,
          color: Colors.white,
          size: 40,
        ),
      )
          : null,
    );
  }

  // MOBILE SCREEN

  Widget _buildMobileScreen(
      RoleProvider provider,
      List<RoleModel> roles,
      ) {
    return Container(
      color: AppColors.bodyFillColor,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _buildMobileHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: _buildSearchBar(),
            ),
            Expanded(
              child: LocalPaginationWidget<RoleModel>(
                items: roles,
                pageSize: 10,
                refresh: provider.fetchRoles,
                itemBuilder: (context, role) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                      vertical: AppSpacing.cardSeparator / 2,
                    ),
                    child: _buildMobileRoleCard(role),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER

  Widget _buildMobileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple app bar: back arrow + screen title. No Hisabio logo.
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 27,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 44,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Access Management',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Header illustration and supporting text sit below the app bar.
          SizedBox(
            height: 126,
            child: Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8, bottom: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Manage roles and their permissions across the application.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildSecurityIllustration(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityIllustration() {
    return SizedBox(
      width: 126,
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 116, height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primaryPurple.withOpacity(0.20),
                AppColors.primaryPurple.withOpacity(0.02),
              ]),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 94,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPurple.withOpacity(0.55),
                    AppColors.primaryPurple.withOpacity(0.82),
                    AppColors.primaryPurple,
                  ],
                ).createShader(bounds),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 102,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 39,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0, bottom: 17,
            child: Container(
              width: 48, height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.groups_rounded,
                  color: AppColors.primaryPurple, size: 29),
            ),
          ),
          Positioned(
            left: 5, top: 17,
            child: Container(
              width: 9, height: 9,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.35), shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SEARCH

  Widget _buildSearchBar() {
    return Container(
      height: 59,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search role...',
          hintStyle: TextStyle(
            color: AppColors.primaryPurple.withOpacity(0.55),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primaryPurple,
            size: 27,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
            icon: const Icon(Icons.close),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // ROLE CARD

  Widget _buildMobileRoleCard(RoleModel role) {
    final description = role.roleDesc?.trim() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoleDetailsScreen(roleId: role.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.13),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 9,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryPurple.withOpacity(0.55),
                        AppColors.primaryPurple,
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 17, 13, 17),
                    child: Row(
                      children: [
                        _buildRoleIcon(role.roleName),
                        const SizedBox(width: 12),
                        Container(width: 1.4, height: 82,
                            color: AppColors.primaryPurple.withOpacity(0.18)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                role.roleName.toUpperCase(),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800,
                                  color: AppColors.primaryPurple, letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                description.isEmpty
                                    ? 'Manage access and permissions.'
                                    : description,
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5, height: 1.3,
                                  color: AppColors.primaryPurple.withOpacity(0.82),
                                ),
                              ),
                              const SizedBox(height: 9),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 7),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primaryPurple.withOpacity(0.10), AppColors.primaryPurple.withOpacity(0.14)],
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.layers_rounded, size: 16,
                                        color: AppColors.primaryPurple),
                                    SizedBox(width: 6),
                                    Flexible(
                                      child: Text('View permissions',
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RoleFormScreen(role: role),
                              ),
                            );
                          },
                          child: const Icon(Iconsax.edit,
                              color: AppColors.editGreen, size: 27),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ROLE ICONS

  Widget _buildRoleIcon(String roleName) {
    final name = roleName.toLowerCase();

    IconData icon;
    if (name.contains('admin')) {
      icon = Icons.workspace_premium_rounded;
    } else if (name.contains('agent')) {
      icon = Icons.groups_rounded;
    } else if (name.contains('manager')) {
      icon = Icons.person_rounded;
    } else if (name.contains('support')) {
      icon = Icons.headset_mic_rounded;
    } else if (name.contains('transport')) {
      icon = Icons.local_shipping_rounded;
    } else if (name.contains('staff')) {
      icon = Icons.badge_rounded;
    } else if (name.contains('supplier')) {
      icon = Icons.inventory_2_rounded;
    } else {
      icon = Icons.shield_rounded;
    }

    return Container(
      width: 65, height: 65,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.primaryPurple.withOpacity(0.10), AppColors.primaryPurple.withOpacity(0.16)],
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Icon(icon, size: 38, color: AppColors.primaryPurple),
    );
  }

  // DESKTOP ROLE CARD - EXISTING FUNCTIONALITY

  Widget _buildDesktopRoleCard(RoleModel role) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoleDetailsScreen(
              roleId: role.id,
            ),
          ),
        );
      },
      child: Card(
        elevation: 1.5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.orangeColor,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 3,
                      ),
                      child: Text(
                        role.roleName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      (role.roleDesc == null ||
                          role.roleDesc!.trim().isEmpty)
                          ? '-'
                          : role.roleDesc!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoleFormScreen(role: role),
                    ),
                  );
                },
                child: customIcon(
                  icon: Iconsax.edit,
                  iconColor: AppColors.editGreen,
                  bgColor: AppColors.editGreenLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class RoleFormScreen extends StatefulWidget {
  final RoleModel? role;

  const RoleFormScreen({super.key, this.role});

  @override
  State<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roleNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _availableSearchController = TextEditingController();
  final _assignedSearchController = TextEditingController();

  final Set<int> _assignedIds = {};
  final Set<int> _selectedAvailableIds = {};
  final Set<int> _selectedAssignedIds = {};
  bool _showAssignedPermissions = false;

  int? _parentRoleId;

  bool _initialLoading = true;
  bool _saving = false;
  String? _loadError;

  bool get _isEditing => widget.role != null;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    if (!context.read<PermissionProvider>().hasPermission('ACCESS_MANAGEMENT_CURD')) {
      _loadError = 'You do not have permission to manage roles.';
      _initialLoading = false;
      return;
    }

    final provider = context.read<RoleProvider>();

    try {
      debugPrint('========== ROLE FORM DEBUG ==========');

      debugPrint('Fetching roles...');
      final rolesResult = await provider.fetchRoles();
      debugPrint('Roles loaded: ${provider.roles.length}');

      debugPrint('Fetching all permissions...');
      final permissionsResult = await provider.fetchPermissions();

      debugPrint('Permissions API result: $permissionsResult');
      debugPrint('Permissions count: ${provider.permissions.length}');

      for (final permission in provider.permissions) {
        debugPrint(
          'Permission ID: ${permission.id}, '
              'Name: ${permission.name}, '
              'Description: ${permission.description}',
        );
      }

      if (_isEditing) {
        debugPrint('Fetching role details for ID: ${widget.role!.id}');

        final success =
        await provider.fetchRoleDetails(widget.role!.id);

        debugPrint('Role details loaded: $success');

        if (!success) {
          throw Exception('Unable to load role details');
        }

        final details = provider.roleDetails;

        if (details == null) {
          throw Exception('Role details not found');
        }

        _roleNameController.text = details.roleName;
        _descriptionController.text = details.roleDesc ?? '';

        _assignedIds.addAll(
          details.permissions.map((permission) => permission.id),
        );
      }
    } catch (e) {
      _loadError = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _initialLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    _descriptionController.dispose();
    _availableSearchController.dispose();
    _assignedSearchController.dispose();
    super.dispose();
  }

  List<RolePermission> _sortPermissions(List<RolePermission> permissions) {
    const actionOrder = <String, int>{
      'CREATE': 0,
      'VIEW': 1,
      'UPDATE': 2,
      'DELETE': 3,
    };

    String actionOf(String name) {
      final upperName = name.toUpperCase().trim();
      for (final action in actionOrder.keys) {
        if (upperName.endsWith('_$action')) return action;
      }
      return '';
    }

    String moduleOf(String name) {
      final upperName = name.toUpperCase().trim();
      final action = actionOf(upperName);
      if (action.isEmpty) return upperName;
      return upperName.substring(0, upperName.length - action.length - 1);
    }

    final sorted = List<RolePermission>.from(permissions);
    sorted.sort((a, b) {
      final moduleCompare = moduleOf(a.name).compareTo(moduleOf(b.name));
      if (moduleCompare != 0) return moduleCompare;

      final actionA = actionOf(a.name);
      final actionB = actionOf(b.name);
      final orderA = actionOrder[actionA] ?? 99;
      final orderB = actionOrder[actionB] ?? 99;
      if (orderA != orderB) return orderA.compareTo(orderB);
      return a.name.toUpperCase().compareTo(b.name.toUpperCase());
    });
    return sorted;
  }

  List<RolePermission> _filteredPermissions(
      List<RolePermission> permissions,
      String search,
      ) {
    final sortedPermissions = _sortPermissions(permissions);
    if (search.trim().isEmpty) return sortedPermissions;

    final query = search.toLowerCase().trim();

    return sortedPermissions.where((permission) {
      return permission.name.toLowerCase().contains(query) ||
          (permission.description ?? '').toLowerCase().contains(query);
    }).toList();
  }

  Set<int> _getFinalPermissionIds() {
    final permissionIds = Set<int>.from(_assignedIds);
    permissionIds.addAll(_selectedAvailableIds);
    permissionIds.removeAll(_selectedAssignedIds);
    return permissionIds;
  }

  Future<void> _saveRole() async {
    if (!context.read<PermissionProvider>().hasPermission('ACCESS_MANAGEMENT_CURD')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to manage roles.')),
      );
      return;
    }
    final permissionIds = _getFinalPermissionIds();
    if (permissionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assign at least one permission.'),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<RoleProvider>();

    setState(() {
      _saving = true;
    });

    bool success = false;

    try {
      final name = _roleNameController.text.trim();
      final description = _descriptionController.text.trim();

      if (_isEditing) {
        success = await provider.updateRole(
          roleId: widget.role!.id,
          roleName: name,
          roleDesc: description,
          permissionIds: permissionIds.toList(),
          parentRoleId: _parentRoleId,
        );
      } else {
        success = await provider.createRole(
          roleName: name,
          roleDesc: description,
          permissionIds: permissionIds.toList(),
          parentRoleId: _parentRoleId,
        );
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Role updated successfully'
                  : 'Role created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.error ?? 'Unable to save role',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoleProvider>();
    final canManageAccess = context.watch<PermissionProvider>()
        .hasPermission('ACCESS_MANAGEMENT_CURD');

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,

      // No Hisabio header here.
      appBar: AppBar(
        backgroundColor: AppColors.bodyFillColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Role' : 'Create Role',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: !canManageAccess
          ? const Center(child: Text('You do not have permission to manage roles.'))
          : _initialLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _loadError!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _initialLoading = true;
                    _loadError = null;
                  });
                  _loadFormData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      )
          : Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRoleInformation(provider),
                    const SizedBox(height: 20),
                    _buildPermissionsSection(provider),
                  ],
                ),
              ),
            ),

            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleInformation(RoleProvider provider) {
    final parentRoles = provider.roles.where((role) {
      return !_isEditing || role.id != widget.role!.id;
    }).toList();

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Role Information',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),

          _buildLabel('Role Name *'),
          const SizedBox(height: 7),
          TextFormField(
            controller: _roleNameController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              'Enter role name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter role name';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildLabel('Description'),
          const SizedBox(height: 7),
          TextFormField(
            controller: _descriptionController,
            maxLines: 1,
            decoration: _inputDecoration(
              'Enter role description',
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPermissionsSection(RoleProvider provider) {
    final availablePermissions = provider.permissions
        .where((permission) => !_assignedIds.contains(permission.id))
        .toList();
    final assignedPermissions = provider.permissions
        .where((permission) => _assignedIds.contains(permission.id))
        .toList();

    final showingPermissions = _showAssignedPermissions
        ? assignedPermissions
        : availablePermissions;
    final visiblePermissions = _filteredPermissions(
      showingPermissions,
      _showAssignedPermissions
          ? _assignedSearchController.text
          : _availableSearchController.text,
    );
    final selectedIds = _showAssignedPermissions
        ? _selectedAssignedIds
        : _selectedAvailableIds;
    final searchController = _showAssignedPermissions
        ? _assignedSearchController
        : _availableSearchController;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Permissions',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurpleLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_getFinalPermissionIds().length} assigned',
                  style: const TextStyle(
                    color: AppColors.primaryPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildPermissionTab(
                    title: 'Available',
                    count: availablePermissions.length,
                    selected: !_showAssignedPermissions,
                    onTap: () => setState(() {
                      _showAssignedPermissions = false;
                    }),
                  ),
                ),
                Expanded(
                  child: _buildPermissionTab(
                    title: 'Assigned',
                    count: assignedPermissions.length,
                    selected: _showAssignedPermissions,
                    onTap: () => setState(() {
                      _showAssignedPermissions = true;
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildPermissionPanel(
            title: _showAssignedPermissions
                ? 'Assigned Permissions'
                : 'Available Permissions',
            permissions: visiblePermissions,
            totalCount: showingPermissions.length,
            selectedIds: selectedIds,
            searchController: searchController,
            emptyMessage: _showAssignedPermissions
                ? 'No permissions assigned yet'
                : 'No available permissions',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: assignedPermissions.isEmpty
                      ? null
                      : () {
                    setState(() {
                      _assignedIds.clear();
                      _selectedAssignedIds.clear();
                      _selectedAvailableIds.clear();
                    });
                  },
                  icon: const Icon(Icons.keyboard_double_arrow_left),
                  label: const Text('Remove All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryPurple,
                    side: const BorderSide(color: AppColors.primaryPurple),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: availablePermissions.isEmpty
                      ? null
                      : () {
                    setState(() {
                      _assignedIds.addAll(
                        provider.permissions.map((permission) => permission.id),
                      );
                      _selectedAvailableIds.clear();
                      _selectedAssignedIds.clear();
                    });
                  },
                  icon: const Icon(Icons.keyboard_double_arrow_right),
                  label: const Text('Assign All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryPurple,
                    side: const BorderSide(color: AppColors.primaryPurple),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTab({
    required String title,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: selected
              ? Border.all(color: AppColors.primaryPurple.withOpacity(0.35))
              : null,
          boxShadow: selected
              ? [
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.08),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.primaryPurple : Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryPurpleLight
                    : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? AppColors.primaryPurple : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionPanel({
    required String title,
    required List<RolePermission> permissions,
    required int totalCount,
    required Set<int> selectedIds,
    required TextEditingController searchController,
    required String emptyMessage,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurpleLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$totalCount',
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: title.startsWith('Assigned')
                      ? 'Search assigned permissions'
                      : 'Search available permissions',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 230,
            child: permissions.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    title.startsWith('Assigned')
                        ? Icons.verified_user_outlined
                        : Icons.lock_outline_rounded,
                    size: 42,
                    color: AppColors.primaryPurple.withOpacity(0.55),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: permissions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppColors.primaryPurple.withOpacity(0.10),
                indent: 42,
              ),
              itemBuilder: (context, index) {
                final permission = permissions[index];
                final selected = selectedIds.contains(permission.id);
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    setState(() {
                      if (selected) {
                        selectedIds.remove(permission.id);
                      } else {
                        selectedIds.add(permission.id);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 26,
                          child: Checkbox(
                            value: selected,
                            activeColor: AppColors.primaryPurple,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedIds.add(permission.id);
                                } else {
                                  selectedIds.remove(permission.id);
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                permission.name,
                                softWrap: true,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              if (permission.description != null &&
                                  permission.description!.trim().isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  permission.description!,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    height: 1.3,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildTransferIcon({
  //   required IconData icon,
  //   required String tooltip,
  //   required bool enabled,
  //   required VoidCallback onPressed,
  // }) {
  //   return Tooltip(
  //     message: tooltip,
  //     child: SizedBox(
  //       width: 48,
  //       height: 48,
  //       child: Material(
  //         color: enabled ? AppColors.primaryBlue : AppColors.primaryPurpleLight,
  //         borderRadius: BorderRadius.circular(12),
  //         child: InkWell(
  //           borderRadius: BorderRadius.circular(12),
  //           onTap: enabled ? onPressed : null,
  //           child: Icon(
  //             icon,
  //             color: enabled ? Colors.white : AppColors.primaryPurple,
  //             size: 27,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving
                    ? null
                    : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(47),
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: (_saving || _getFinalPermissionIds().isEmpty)
                    ? null
                    : _saveRole,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(47),
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(_isEditing ? 'Update Role' : 'Create Role'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black38,
        fontSize: 13,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primaryPurple,
          width: 1.4,
        ),
      ),
    );
  }
}

class RoleDetailsScreen extends StatefulWidget {
  final int roleId;

  const RoleDetailsScreen({
    super.key,
    required this.roleId,
  });

  @override
  State<RoleDetailsScreen> createState() => _RoleDetailsScreenState();
}

class _RoleDetailsScreenState extends State<RoleDetailsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted && context.read<PermissionProvider>().hasPermission('ACCESS_MANAGEMENT_CURD')) {
        context.read<RoleProvider>().fetchRoleDetails(widget.roleId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canManageAccess = context.watch<PermissionProvider>()
        .hasPermission('ACCESS_MANAGEMENT_CURD');

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,

      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: 'Role Details',
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w600,
        ),
      ),

      body: Consumer<RoleProvider>(
        builder: (context, provider, child) {
          if (!canManageAccess) {
            return const Center(
              child: Text('You do not have permission to view role details.'),
            );
          }

          if (provider.detailsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final details = provider.roleDetails;

          if (details == null) {
            return const Center(
              child: Text('Unable to load role details'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 1.5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Role Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildField(
                      'Role Name',
                      details.roleName,
                    ),

                    const SizedBox(height: 18),

                    _buildField(
                      'Description',
                      details.roleDesc ?? '',
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Permissions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: details.permissions.isEmpty
                          ? const Text('No permissions assigned')
                          : Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: details.permissions.map((permission) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              permission.name,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 7),

        TextFormField(
          initialValue: value,
          readOnly: true,
          maxLines: label == 'Description' ? 2 : 1,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
