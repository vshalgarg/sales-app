import 'package:flutter/material.dart';
import 'package:hisabio/customs/containers/master_containers/users_container.dart';
import 'package:hisabio/drawers/master_drawer.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../customs/bottom_navigation_bar.dart';
import '../../provider/get_user_provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final userSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<GetUsersProvider>().getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<GetUsersProvider>();
    if (userProvider.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (userProvider.error != null) {
      return Scaffold(body: Center(child: Text(userProvider.error!)));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Users",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      drawer: MasterDrawer(),
      bottomNavigationBar: CustomBottomNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SearchBar(
                controller: userSearchController,
                elevation: WidgetStatePropertyAll(2),
                hintText: "Search User...",
                leading: Icon(Icons.search_outlined, size: 30),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return SizedBox(height: 8);
                },
                  itemCount: userProvider.users!.users!.length,
                itemBuilder: (context, index) {
                  final user = userProvider.users!.users![index];
                  return UserContainer(
                    name: user.username ?? "",
                    trashIconTap: () {},
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
         // Navigator.push(
          //  context,
           // MaterialPageRoute(builder: (context) => AddNewTransport()),
        //  );
        },
        backgroundColor: AppColors.primaryPurple,
        child: Icon(Iconsax.add, color: Colors.white, size: 40),
      ),
    );
  }
}
