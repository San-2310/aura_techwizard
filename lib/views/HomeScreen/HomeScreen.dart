import 'package:aura_techwizard/models/user.dart' as ModelUser;
import 'package:aura_techwizard/resources/user_provider.dart';
import 'package:aura_techwizard/views/community_screen/community_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  // final List<Widget> _pages = [
  //   HomeScreen(),
  //   CommunityScreen(),
  // ];

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final ModelUser.User? user = Provider.of<UserProvider>(context).getUser;

    if (_isLoading || user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user!.photoUrl,user!.fullname),
              const SizedBox(height: 20.0),
              _buildMoodIcons(),
              const SizedBox(height: 20.0),
              _buildTherapySessions(),
              const SizedBox(height: 20.0),
              _buildActivities(),
              const SizedBox(height: 20.0),
              _buildTasks(),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   //backgroundColor: Colors.black87,
      //   selectedItemColor: const Color.fromRGBO(55, 27, 52, 1),
      //   unselectedItemColor: const Color.fromRGBO(205, 208, 227, 1),
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.group),
      //       label: 'Community',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildHeader(String photoUrl, String name) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ImageIcon(
              AssetImage("assets/icons/menu.png"),
              size: 24.0,
            ),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(photoUrl),
                  radius: 20.0,
                ),
              ],
            ),
            //SizedBox(width: 10.0),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $name!',
                  style: TextStyle(
                    color: Color.fromRGBO(55, 27, 52, 1),
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    color: Color.fromRGBO(55, 27, 52, 1),
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildHeader(ModelUser.User? user) {
  Widget _buildMoodIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMoodIcon(
          iconPath: 'assets/icons/happy_icon.svg',
          label: 'Happy',
          bgColor: const Color(0xFFEF5DA8),
        ),
        _buildMoodIcon(
          iconPath: 'assets/icons/calm_icon.svg',
          label: 'Calm',
          bgColor: const Color(0xFFAEAFF7),
        ),
        _buildMoodIcon(
          iconPath: 'assets/icons/relax_icon.svg',
          label: 'Relax',
          bgColor: const Color(0xFFF09A59),
        ),
        _buildMoodIcon(
          iconPath: 'assets/icons/focus_icon.svg',
          label: 'Focus',
          bgColor: const Color(0xFFA0E3E2),
        ),
      ],
    );
  }

  Widget _buildMoodIcon({
    required String iconPath,
    required String label,
    required Color bgColor,
  }) {
    return Column(
      children: [
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: bgColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              iconPath,
              //color: iconColor,
              width: 32.0,
              height: 32.0,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF60554D),
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTherapySessions() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE2CC),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Therapy Sessions',
                style: TextStyle(
                  color: Color(0xFF573926),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                "Let's open up to the things that",
                style: TextStyle(
                  color: Color(0xFF60554D),
                  fontSize: 11.0,
                ),
              ),
              //
              const Text(
                "matter the most.",
                style: TextStyle(
                  color: Color(0xFF60554D),
                  fontSize: 11.0,
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF09A59),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('Book Now'),
                    const SizedBox(width: 8.0),
                    SvgPicture.asset("assets/icons/book_icon.svg"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            children: [
              Container(
                child: Image.asset(
                  "assets/icons/meetup_icon.png",
                  height: 100,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActivities() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActivityIcon(
          iconPath: 'assets/icons/journal_icon.svg',
          label: 'Journal',
          //iconColor: const Color(0xFFFBE2CC),
        ),
        _buildActivityIcon(
          iconPath: 'assets/icons/music_icon.svg',
          label: 'Music',
          //iconColor: const Color(0xFFFFE1F1),
        ),
        _buildActivityIcon(
          iconPath: 'assets/icons/meditation_icon.svg',
          label: 'Meditation',
          //bgColor: const Color(0xFFD30A9A),
        ),
        _buildActivityIcon(
          iconPath: 'assets/icons/relaxing_games_icon.svg',
          label: ' Games',
          //bgColor: const Color(0xFFC6C7FF),
        ),
      ],
    );
  }

  Widget _buildActivityIcon({
    required String iconPath,
    required String label,
    //required Color bgColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27.0),
            color: const Color.fromRGBO(255, 225, 241, 0.68),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              iconPath,
              width: 24.0,
              height: 24.0,
              color: const Color(0xFFD30A9A),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF60554D),
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Tasks",
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        // SingleChildScrollView(
        //   scrollDirection: Axis.horizontal,
        //   child: Row(
        //     children: [
        //       _buildTaskItem(),
        //       const SizedBox(width: 12.0),
        //       _buildTaskItem(),
        //     ],
        //   ),
        // ),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTaskItem(),
              const SizedBox(width: 12.0),
              _buildTaskItem(),
              const SizedBox(width: 12.0),
              _buildTaskItem(),
              // Add more items if needed
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTaskItem() {
    return Container(
      height: 120,
      width: 200,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(198, 199, 255, 0.31),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16.0),
          Icon(
            Icons.check_circle_outline,
            color: Color(0xFF60554D),
            size: 24.0,
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Text(
              'Lorem ipsum',
              style: TextStyle(
                color: Color(0xFF60554D),
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
