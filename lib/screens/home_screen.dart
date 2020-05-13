import 'package:flutter/material.dart';

import '../screens/profile.dart';
import '../screens/chats.dart';
import '../screens/search.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  _HomeScreenState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).backgroundColor;

    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: color,
        title: const Text(
          'Cat Chat!',
          style: TextStyle(fontSize: 18),
        ),
        bottom: TabBar(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.white,
          indicator: const BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              color: Colors.grey),
          controller: _tabController,
          tabs: <Widget>[
            const Tab(icon: const Icon(Icons.people_outline)),
            const Tab(icon: const Icon(Icons.chat_bubble_outline)),
            const Tab(
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
      ),
      body: buildTabBarScreens(),
    );
  }

  Widget buildTabBarScreens() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[Search(), Chats(), Profile()],
    );
  }
}
