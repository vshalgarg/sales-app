import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/bottom_navigation_bar.dart';
import 'package:hisabio/customs/containers/master_containers/supplier_container.dart';
import 'package:hisabio/drawers/master_drawer.dart';
import 'package:hisabio/provider/get_supplier_provider.dart';
import 'package:hisabio/screens/master_screens/add_new_supplier.dart';

//import 'package:http/http.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class Supplier extends StatefulWidget {
  const Supplier({super.key});

  @override
  State<Supplier> createState() => _SupplierState();
}

class _SupplierState extends State<Supplier> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SupplierProvider>().fetchSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Supplier",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
      drawer: MasterDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              height: 40,
              width: double.infinity,
              child: SearchBar(
                elevation: WidgetStatePropertyAll(2),
                hintText: "Search suppliers...",
                leading: Icon(Icons.search_outlined, size: 30),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
              ),
            ),
            SizedBox(height: 25),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? Center(child: Text(provider.error!))
                  : ListView.separated(
                      itemCount: provider.data?.content?.length ?? 0,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 8);
                      },
                      itemBuilder: (context, index) {
                        final item = provider.data!.content![index];
                        return SupplierContainer(
                          elevation: 1,
                          name: item.supplierName,
                          gst: item.supplierGstNo,
                          code: item.code,
                          city: item.city,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewSupplier()),
          );
        },
        backgroundColor: AppColors.primaryPurple,
        child: Icon(Iconsax.add, color: Colors.white, size: 40),
      ),
    );
  }
}
