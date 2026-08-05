// import 'package:flutter/material.dart';
// import 'package:hisabio/customs/list_tile.dart';
// import 'package:hisabio/screens/reporting_screen/bills.dart';
// import '../screens/reporting_screen/credit.dart';
// import '../screens/reporting_screen/purchase.dart';
//
// class ReportingDrawer extends StatelessWidget {
//   const ReportingDrawer({super.key});
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
//                   MaterialPageRoute(builder: (context) => Bills()),
//                 );
//               },
//               title: "Bills",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//             ),
//             Divider(thickness: 0.5),
//             CustomListTile(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => Credit()),
//                 );
//               },
//               title: "Credit",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//             ),
//             Divider(thickness: 0.5),
//             CustomListTile(
//               title: "Purchase",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//               onTap:(){Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => Purchase()),
//               );}
//             ),
//             Divider(thickness: 0.5),
//             CustomListTile(
//               title: "Retail",
//               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//               // onTap:(){Navigator.push(
//               //   context,
//               //   MaterialPageRoute(builder: (context) => TransportScreen()),
//               // );},
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
