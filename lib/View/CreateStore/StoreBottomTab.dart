import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/View/CreateStore/Bank.dart';
import 'package:glocal_bizz/View/CreateStore/KYC.dart';

import 'MyStoreDetail.dart';
import 'OrderHistory.dart';
import 'PaymentHistory.dart';

class StoreBottomTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: color2,
              indicatorWeight: 1.1,
              labelColor: color2,
              unselectedLabelColor: white,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.home,
                  ),
                  child: Text("Store"),
                  iconMargin: EdgeInsets.only(bottom: 0),
                ),
                Tab(
                  icon: Icon(Icons.library_books),
                  child: Text("Orders"),
                  iconMargin: EdgeInsets.only(bottom: 0),
                ),
                Tab(
                  icon: Icon(Icons.account_balance_wallet),
                  child: Text("Payments"),
                  iconMargin: EdgeInsets.only(bottom: 0),
                ),
                Tab(
                  icon: Icon(Icons.poll),
                  child: Text("KYC"),
                  iconMargin: EdgeInsets.only(bottom: 0),
                ),
                Tab(
                  icon: Icon(Icons.account_balance),
                  child: Text("Bank"),
                  iconMargin: EdgeInsets.only(bottom: 0),
                ),
              ],
            ),
            title: Text('My Store Details'),
            centerTitle: true,
          ),
          body: TabBarView(
            children: [
              new MyStoreDetails(),
              new OrderHistory(),
              new PaymentHistory(),
              new KYCPage(),
              new BankPage(),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:glocal_bizz/Controller/constand.dart';
// import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

// import 'MyStoreDetail.dart';
// import 'OrderHistory.dart';
// import 'PaymentHistory.dart';

// class StoreBottomTab extends StatefulWidget {
//   @override
//   _StoreBottomTabState createState() => _StoreBottomTabState();
// }

// class _StoreBottomTabState extends State<StoreBottomTab> {
//   PersistentTabController _controller =
//       PersistentTabController(initialIndex: 0);

//   bool _hideNavBar;

// //Screens for each nav items.
//   List<Widget> _NavScreens() {
//     return [
//       new MyStoreDetails(),
//       new OrderHistory(),
//       new PaymentHistory(),
//     ];
//   }

//   List<PersistentBottomNavBarItem> _navBarsItems() {
//     return [
//       PersistentBottomNavBarItem(
//         icon: Icon(
//           Icons.home,
//         ),
//         title: ("Store"),
//         textStyle: TextStyle(color: white),
//         activeColorSecondary: Colors.white,
//         activeColorPrimary: primaryColor,
//         inactiveColorPrimary: color2,
//       ),
//       PersistentBottomNavBarItem(
//         icon: Icon(
//           Icons.library_books,
//           // color: appcolor,
//         ),
//         title: ("Order History"),
//         textStyle: TextStyle(color: Colors.amber),
//         activeColorPrimary: primaryColor,
//         activeColorSecondary: Colors.white,
//         inactiveColorPrimary: color2,
//         // routeAndNavigatorSettings: const RouteAndNavigatorSettings(),
//       ),
//       PersistentBottomNavBarItem(
//         icon: Icon(
//           Icons.account_balance_wallet,
//           // color: white,
//         ),
//         title: ("Payments"),
//         textStyle: TextStyle(color: white),
//         activeColorSecondary: Colors.white,
//         activeColorPrimary: primaryColor,
//         inactiveColorPrimary: color2,
//       ),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: PersistentTabView(
//         context,
//         controller: _controller,
//         screens: _NavScreens(),
//         items: _navBarsItems(),
//         confineInSafeArea: true,
//         // hideNavigationBar: _hideNavBar,
//         stateManagement: true,
//         backgroundColor: Colors.white,
//         handleAndroidBackButtonPress: false,
//         resizeToAvoidBottomInset: true,
//         hideNavigationBarWhenKeyboardShows: true,
//         popActionScreens: PopActionScreensType.all,
//         popAllScreensOnTapOfSelectedTab: false,
//         decoration: NavBarDecoration(
//           borderRadius: BorderRadius.circular(0.0),
//         ),
//         navBarStyle: NavBarStyle.style7,
//       ),
//     );
//   }
// }
