// import 'package:flutter/material.dart';
// import 'package:hisabio/customs/list_tile.dart';
// import 'package:hisabio/screens/master_screens/customer.dart';
// import 'package:hisabio/screens/master_screens/supplier.dart';
//
// import '../screens/master_screens/staff.dart';
// import '../screens/master_screens/transport.dart';
// import '../screens/master_screens/users.dart';
//
// class MasterDrawer extends StatelessWidget {
//   const MasterDrawer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: ListView(
//           children: [
//             SizedBox(height: 50),
//             CustomListTile(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => SupplierScreen()),
//                 );
//               },
//               title: "Suppliers",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//             ),
//             Divider(thickness: 0.5),
//             CustomListTile(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => CustomerScreen()),
//                 );
//               },
//               title: "Customers",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//             ),
//             Divider(thickness: 0.5),
//             CustomListTile(
//               title: "Staff",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//               onTap:(){Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => StaffScreen()),
//               );}
//             ),
//             Divider(thickness: 0.5),
//             CustomListTile(
//               onTap:(){Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => TransportScreen()),
//               );},
//               title: "Transport",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//             ),
//             Divider(thickness: 0.5),
//             CustomListTile(
//               onTap:(){Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => UsersScreen()),
//               );},
//               title: "Users",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
