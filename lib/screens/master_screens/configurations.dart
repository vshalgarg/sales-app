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
bool isChecked=false;
  @override
  void initState() {
  super.initState();

  Future.microtask(() {
  context.read<ConfigProvider>().fetchConfiguration();
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
                      value: provider.retailEnabled,
                      onChanged: (value) {
                        context.read<ConfigProvider>().setRetailEnabled(value!);
                      },
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height:20),
            ElevatedButton(
              onPressed: () async {try {
                await context.read<ConfigProvider>().saveConfiguration(
                  provider.retailEnabled,
                );
                if(!context.mounted) return;

                ScaffoldSnackBar.show(
                  context,
                  "Configuration updated successfully",
                );

                Navigator.pop(context);
              } catch (e) {
                ScaffoldSnackBar.show(
                  context,
                  e.toString(),
                );
              }},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              child: Text("Save Changes",style: TextStyle(color:Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
