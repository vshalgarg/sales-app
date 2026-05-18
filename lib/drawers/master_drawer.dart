import 'package:flutter/material.dart';
import 'package:hisabio/customs/list_tile.dart';
import 'package:hisabio/screens/master_screens/customer.dart';
import 'package:hisabio/screens/master_screens/supplier.dart';

class MasterDrawer extends StatelessWidget {
  const MasterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            SizedBox(height: 50),
            CustomListTile(
              onTap: (){Navigator.push(context, MaterialPageRoute(builder:(context)=>Supplier()));},
              title: "Suppliers",
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            Divider(thickness: 0.5),
            CustomListTile(
              onTap: (){Navigator.push(context, MaterialPageRoute(builder:(context)=>Customer()));},
              title: "Customers",
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            Divider(thickness: 0.5),
            CustomListTile(
              title: "Staff",
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            Divider(thickness: 0.5),
            CustomListTile(
              title: "Transport",
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            Divider(thickness: 0.5),
            CustomListTile(
              title: "Users",
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
