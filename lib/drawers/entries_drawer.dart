// import 'package:flutter/material.dart';
// import 'package:hisabio/customs/list_tile.dart';
//
// import '../screens/entry_screen/credit_entry.dart';
// import '../screens/entry_screen/entries_bill_entry.dart';
// import '../screens/entry_screen/purchase_entry.dart';
// import '../screens/entry_screen/retail_entry.dart';
//
// class EntryDrawer extends StatelessWidget {
//   const EntryDrawer({super.key});
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
//                   MaterialPageRoute(builder: (context) => EntriesBillEntry()),
//                 );
//               },
//               title: "Bill Entry",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//             ),
//             Divider(thickness: 0.5),
//             CustomListTile(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => CreditEntry()),
//                 );
//               },
//               title: "Credit Entry",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//             ),
//             Divider(thickness: 0.5),
//             CustomListTile(
//               title: "Purchase Entry",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PurchaseEntryScreen(),
//                   ),
//                 );
//               },
//             ),
//             Divider(thickness: 0.5),
//             CustomListTile(
//               title: "Retail Entry",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => RetailEntryScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
