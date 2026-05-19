import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/containers/master_containers/supplier_container.dart';
import 'package:hisabio/drawers/master_drawer.dart';
import 'package:hisabio/screens/master_screens/add_new_customer.dart';
import 'package:iconsax/iconsax.dart';

class Customer extends StatelessWidget {
  const Customer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Customer",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      drawer: MasterDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: SearchBar(
                //controller: searchController,
                elevation: WidgetStatePropertyAll(2),
                hintText: "Search customers...",
                leading: Icon(Icons.search_outlined, size: 30),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return SizedBox(height: 8);
                },
                itemCount: 10,
                itemBuilder: (context, index) {
                  return SupplierContainer(
                    elevation: 1,
                    name: "Tarun",
                    gst: "331fgdhjg55",
                    code: "C001977",
                    city: "Mumbai",
                    eyeIconTap: () {},
                    trashIconTap: () {},
                    copyIconTap: () {},
                    editIconTap: () {},
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
            MaterialPageRoute(builder: (context) => AddNewCustomer()),
          );
        },
        backgroundColor: AppColors.primaryPurple,
        child: Icon(Iconsax.add, color: Colors.white, size: 40),
      ),
    );
  }
}
