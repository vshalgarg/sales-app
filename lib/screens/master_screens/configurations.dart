import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/master_provider/config_provider.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  bool isRetailEnabled = false;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final configProvider = context.read<ConfigProvider>();

      try {
        await configProvider.fetchConfiguration();
        if (!mounted) return;

        setState(() {
          isRetailEnabled = configProvider.retailEnabled;
          isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        ScaffoldSnackBar.show(
          context,
          e.toString(),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConfigProvider>();

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Configurations",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enable Retail Module",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          Text(
                            "Allows users to access Retail Entry and Retail reports.",
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: isRetailEnabled,
                      onChanged: isLoading
                          ? null
                          : (value) {
                        setState(() {
                          isRetailEnabled = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context
                      .read<ConfigProvider>()
                      .saveConfiguration(isRetailEnabled);

                  if (!context.mounted) return;

                  ScaffoldSnackBar.show(
                    context,
                    "Configuration updated successfully",
                  );

                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldSnackBar.show(
                    context,
                    e.toString(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              child: Text(
                "Save Changes",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
