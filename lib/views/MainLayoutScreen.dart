import 'package:aura_techwizard/views/HomeScreen/HomeScreen.dart';
import 'package:aura_techwizard/views/community_screen/community_screen.dart';
import 'package:aura_techwizard/views/community_screen/feed_screen.dart';
import 'package:flutter/material.dart';

class MainLayoutScreen extends StatefulWidget {
  @override
  _MainLayoutScreenState createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;

  // List of pages for each BottomNavigationBar item
  final List<Widget> _pages = [
    HomeScreen(),
    FeedScreen(),
    // SettingsScreen(),
    // ProfileScreen(),
  ];

  // Function to handle item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the current page
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromRGBO(55, 27, 52, 1),
        unselectedItemColor: const Color.fromRGBO(205, 208, 227, 1),
        currentIndex: _selectedIndex, // Current selected index
        onTap: _onItemTapped, // Update index on item tap
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

