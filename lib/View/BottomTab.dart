import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'Category.dart';
import 'Post/PostCategory.dart';
import 'CreateStore/StoreList.dart';
import 'Home.dart';
import 'MyPosts.dart';
import 'Profile.dart';
import 'SearchList.dart';

class BottomTab extends StatefulWidget {
  @override
  _BottomTabState createState() => _BottomTabState();
}

class _BottomTabState extends State<BottomTab> {
  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  bool _hideNavBar;

//Screens for each nav items.
  List<Widget> _NavScreens() {
    return [
      new HomePage(),
      new StoreLists(),
      new PostCategoryPage(),
      new MyPostPage(),
      new ProfilePage(),
      // PostPage
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.home_outlined,
        ),
        title: ("Home"),
        activeColorPrimary: primaryColor,
        inactiveColorPrimary: secondaryColor,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.store_outlined,
          // color: appcolor,
        ),
        title: ("Store"),
        activeColorPrimary: primaryColor,
        inactiveColorPrimary: secondaryColor,
        // routeAndNavigatorSettings: const RouteAndNavigatorSettings(),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.library_add,
          color: white,
        ),
        title: ("Sell"),
        activeColorPrimary: primaryColor,
        inactiveColorPrimary: secondaryColor,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.local_mall_outlined,
        ),
        title: ("My Ads"),
        activeColorPrimary: primaryColor,
        inactiveColorPrimary: secondaryColor,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.person,
        ),
        title: ("Profile"),
        activeColorPrimary: primaryColor,
        inactiveColorPrimary: secondaryColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PersistentTabView(
        context,
        controller: _controller,
        screens: _NavScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        // hideNavigationBar: _hideNavBar,
        stateManagement: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        hideNavigationBarWhenKeyboardShows: true,
        popActionScreens: PopActionScreensType.all,
        popAllScreensOnTapOfSelectedTab: false,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(0.0),
        ),
        navBarStyle: NavBarStyle.style15,
      ),
    );
  }
}
