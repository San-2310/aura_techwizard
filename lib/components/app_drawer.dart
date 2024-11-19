import 'package:aura_techwizard/models/user.dart';
import 'package:aura_techwizard/resources/user_provider.dart';
import 'package:aura_techwizard/views/HomeScreen/HomeScreen.dart';
import 'package:aura_techwizard/views/adopt_pet/adopt_pet_screen.dart';
import 'package:aura_techwizard/views/analyse_report.dart';
import 'package:aura_techwizard/views/analysis_screens/analysis_screen.dart';
import 'package:aura_techwizard/views/diet_plan_screen.dart';
import 'package:aura_techwizard/views/therapist_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromRGBO(174, 175, 247, 1), // Soft pink
                // Color.fromRGBO(253, 221, 236, 1), // Light peach
                Color(0xFFC5DEE3), // Pale blue
              ],
            )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Aura",
                  style: TextStyle(
                      fontSize: 50,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context, 'Home', Icons.home, HomeScreen(), '/home'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(context, 'Adopt Pet', Icons.pets,
                PetAdoptionScreen(), '/adopt_pet'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(context, 'Lab Report Analysis',
                Icons.receipt, SummarizerScreen(), '/summarizer'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(context, 'Diet Plan Generator',
                Icons.restaurant, DietPlanScreen(), '/diet_plan'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(context, 'Usage Analyser', Icons.auto_graph,
                CombinedAnalysisScreen(), '/combined_analysis'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                'Therapist Near Me',
                Icons.medical_services_outlined,
                TherapistScreen(
                  userUid: user!.uid,
                ),
                '/therapist'),
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(BuildContext context, String title, IconData icon,
      Widget destination, String route) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      selected: currentRoute == route,
      selectedTileColor: Color.fromRGBO(253, 221, 236, 1),
      onTap: () {
        if (currentRoute != route) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destination));
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}
