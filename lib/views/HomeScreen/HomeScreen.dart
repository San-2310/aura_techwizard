import 'package:aura_techwizard/components/app_drawer.dart';
import 'package:aura_techwizard/models/user.dart' as ModelUser;
import 'package:aura_techwizard/resources/user_provider.dart';
import 'package:aura_techwizard/views/JournalScreen4.dart';
import 'package:aura_techwizard/views/games/relaxing_game/Screens/game_screen.dart';
import 'package:aura_techwizard/views/health_wellness_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// Custom Toggle Switch Widget
class CustomToggleSwitch extends StatelessWidget {
  final bool isCalmMode;
  final Function(bool) onToggle;

  const CustomToggleSwitch({
    super.key,
    required this.isCalmMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isCalmMode),
      child: Container(
        width: 70,
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xFFE6E6FA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment:
                  isCalmMode ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Icon(
                    isCalmMode ? Icons.spa : Icons.flash_on,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _isCalmMode = false;

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
      appBar: AppBar(
        actions: [
          CustomToggleSwitch(
            isCalmMode: _isCalmMode,
            onToggle: (value) {
              setState(() {
                _isCalmMode = value;
              });
            },
          ),
          const SizedBox(width: 10),
          _buildHeader(user.photoUrl, user.fullname),
          const SizedBox(width: 10),
        ],
      ),
      drawer: AppDrawer(currentRoute: '/home'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              _buildMoodIcons(user.fullname),
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
      backgroundColor: _isCalmMode
          ? const Color(0xFFF5F5F5)
          : Colors.white, // Change background based on mode
    );
  }

  Widget _buildHeader(String photoUrl, String name) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(photoUrl),
          radius: 20.0,
        ),
      ],
    );
  }

  Widget _buildMoodIcons(String name) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,\n$name!',
                  style: TextStyle(
                    color: _isCalmMode
                        ? const Color(0xFF2E4052)
                        : const Color.fromRGBO(55, 27, 52, 1),
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    color: _isCalmMode
                        ? const Color(0xFF2E4052)
                        : const Color.fromRGBO(55, 27, 52, 1),
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMoodIcon(
              iconPath: 'assets/icons/happy_icon.svg',
              label: 'Happy',
              bgColor: _isCalmMode
                  ? const Color(0xFFB8E3E9)
                  : const Color(0xFFEF5DA8),
            ),
            _buildMoodIcon(
              iconPath: 'assets/icons/calm_icon.svg',
              label: 'Calm',
              bgColor: _isCalmMode
                  ? const Color(0xFFC5E8B8)
                  : const Color(0xFFAEAFF7),
            ),
            _buildMoodIcon(
              iconPath: 'assets/icons/relax_icon.svg',
              label: 'Low',
              bgColor: _isCalmMode
                  ? const Color(0xFFE8D5B8)
                  : const Color(0xFFF09A59),
            ),
            _buildMoodIcon(
              iconPath: 'assets/icons/focus_icon.svg',
              label: 'Stressed',
              bgColor: _isCalmMode
                  ? const Color(0xFFB8C5E8)
                  : const Color(0xFFA0E3E2),
            ),
          ],
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
              width: 32.0,
              height: 32.0,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: TextStyle(
            color:
                _isCalmMode ? const Color(0xFF2E4052) : const Color(0xFF60554D),
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
        color: _isCalmMode ? const Color(0xFFE8D5B8) : const Color(0xFFFBE2CC),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Therapy Sessions',
                style: TextStyle(
                  color: _isCalmMode
                      ? const Color(0xFF2E4052)
                      : const Color(0xFF573926),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "Let's open up to the things that",
                style: TextStyle(
                  color: _isCalmMode
                      ? const Color(0xFF2E4052)
                      : const Color(0xFF60554D),
                  fontSize: 11.0,
                ),
              ),
              Text(
                "matter the most.",
                style: TextStyle(
                  color: _isCalmMode
                      ? const Color(0xFF2E4052)
                      : const Color(0xFF60554D),
                  fontSize: 11.0,
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCalmMode
                      ? const Color(0xFF92A8D1)
                      : const Color(0xFFF09A59),
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
          const SizedBox(width: 10),
          Column(
            children: [
              Image.asset(
                "assets/icons/meetup_icon.png",
                height: 100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivities() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DiaryScreen()));
          },
          child: _buildActivityIcon(
            iconPath: 'assets/icons/journal_icon.svg',
            label: 'Journal',
          ),
        ),
        _buildActivityIcon(
          iconPath: 'assets/icons/music_icon.svg',
          label: 'Music',
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HealthWellnessTrackerScreen()));
          },
          child: _buildActivityIcon(
            iconPath: 'assets/icons/meditation_icon.svg',
            label: 'Meditation',
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => GameScreen()));
          },
          child: _buildActivityIcon(
            iconPath: 'assets/icons/relaxing_games_icon.svg',
            label: 'Games',
          ),
        ),
      ],
    );
  }

  Widget _buildActivityIcon({
    required String iconPath,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27.0),
            color: _isCalmMode
                ? const Color.fromRGBO(230, 230, 250, 0.68)
                : const Color.fromRGBO(255, 225, 241, 0.68),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              iconPath,
              width: 24.0,
              height: 24.0,
              color: _isCalmMode
                  ? const Color(0xFF92A8D1)
                  : const Color(0xFFD30A9A),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: TextStyle(
            color:
                _isCalmMode ? const Color(0xFF2E4052) : const Color(0xFF60554D),
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
        Text(
          "Today's Tasks",
          style: TextStyle(
            color: _isCalmMode ? const Color(0xFF2E4052) : Colors.black,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTaskItem(),
              const SizedBox(width: 12.0),
              _buildTaskItem(),
              const SizedBox(width: 12.0),
              _buildTaskItem(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem() {
    return Container(
      height: 120,
      width: 200,
      decoration: BoxDecoration(
        color: _isCalmMode
            ? const Color.fromRGBO(230, 230, 250, 0.31)
            : const Color.fromRGBO(198, 199, 255, 0.31),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          Icon(
            Icons.check_circle_outline,
            color:
                _isCalmMode ? const Color(0xFF2E4052) : const Color(0xFF60554D),
            size: 24.0,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              'Lorem ipsum',
              style: TextStyle(
                color: _isCalmMode
                    ? const Color(0xFF2E4052)
                    : const Color(0xFF60554D),
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
