// // // health_wellness_tracker.dart

// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // // Models
// // class Exercise {
// //   final String name;
// //   final String description;
// //   final String videoUrl;
// //   final List<String> ageGroups;
// //   final int durationMinutes;
// //   final String difficulty;

// //   Exercise({
// //     required this.name,
// //     required this.description,
// //     required this.videoUrl,
// //     required this.ageGroups,
// //     required this.durationMinutes,
// //     required this.difficulty,
// //   });
// // }

// // class MeditationSession {
// //   final String title;
// //   final String description;
// //   final String audioUrl;
// //   final int durationMinutes;
// //   final String category;

// //   MeditationSession({
// //     required this.title,
// //     required this.description,
// //     required this.audioUrl,
// //     required this.durationMinutes,
// //     required this.category,
// //   });
// // }

// // class UserProgress {
// //   int currentStreak;
// //   DateTime lastExerciseDate;
// //   List<String> completedExercises;
// //   List<String> completedMeditations;

// //   UserProgress({
// //     this.currentStreak = 0,
// //     required this.lastExerciseDate,
// //     required this.completedExercises,
// //     required this.completedMeditations,
// //   });
// // }

// // // Main Widget
// // class HealthWellnessTracker extends StatefulWidget {
// //   @override
// //   _HealthWellnessTrackerState createState() => _HealthWellnessTrackerState();
// // }

// // class _HealthWellnessTrackerState extends State<HealthWellnessTracker> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   late UserProgress userProgress;
// //   int userAge = 0;
// //   String selectedTab = 'exercise';

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeUserData();
// //   }

// //   Future<void> _initializeUserData() async {
// //     // Get user age from Firebase or local storage
// //     final prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       userAge = prefs.getInt('user_age') ?? 0;
// //     });

// //     // Initialize user progress
// //     var userDoc = await _firestore
// //         .collection('users')
// //         .doc(_auth.currentUser?.uid)
// //         .get();

// //     if (userDoc.exists) {
// //       var data = userDoc.data() as Map<String, dynamic>;
// //       userProgress = UserProgress(
// //         currentStreak: data['currentStreak'] ?? 0,
// //         lastExerciseDate: (data['lastExerciseDate'] as Timestamp).toDate(),
// //         completedExercises: List<String>.from(data['completedExercises']),
// //         completedMeditations: List<String>.from(data['completedMeditations']),
// //       );
// //     } else {
// //       userProgress = UserProgress(
// //         lastExerciseDate: DateTime.now(),
// //         completedExercises: [],
// //         completedMeditations: [],
// //       );
// //     }
// //   }

// //   List<Exercise> _getAgeAppropriateExercises() {
// //     String ageGroup = '';
// //     if (userAge < 18) ageGroup = 'teen';
// //     else if (userAge < 40) ageGroup = 'adult';
// //     else if (userAge < 60) ageGroup = 'middle';
// //     else ageGroup = 'senior';

// //     return [
// //       Exercise(
// //         name: 'Gentle Stretching',
// //         description: 'Basic full-body stretching routine',
// //         videoUrl: 'assets/videos/stretching.mp4',
// //         ageGroups: ['teen', 'adult', 'middle', 'senior'],
// //         durationMinutes: 10,
// //         difficulty: 'Easy',
// //       ),
// //       Exercise(
// //         name: 'Walking',
// //         description: 'Brisk walking routine',
// //         videoUrl: 'assets/videos/walking.mp4',
// //         ageGroups: ['teen', 'adult', 'middle', 'senior'],
// //         durationMinutes: 30,
// //         difficulty: 'Easy',
// //       ),
// //       // Add more exercises based on age groups
// //     ].where((exercise) => exercise.ageGroups.contains(ageGroup)).toList();
// //   }

// //   List<MeditationSession> _getMeditationSessions() {
// //     return [
// //       MeditationSession(
// //         title: 'Breathing Awareness',
// //         description: 'Focus on your breath to calm your mind',
// //         audioUrl: 'assets/audio/breathing.mp3',
// //         durationMinutes: 10,
// //         category: 'Beginner',
// //       ),
// //       MeditationSession(
// //         title: 'Body Scan',
// //         description: 'Progressive relaxation meditation',
// //         audioUrl: 'assets/audio/bodyscan.mp3',
// //         durationMinutes: 15,
// //         category: 'Intermediate',
// //       ),
// //       // Add more meditation sessions
// //     ];
// //   }

// //   Future<void> _updateStreak() async {
// //     final now = DateTime.now();
// //     final difference = now.difference(userProgress.lastExerciseDate).inDays;

// //     if (difference == 1) {
// //       userProgress.currentStreak++;
// //     } else if (difference > 1) {
// //       userProgress.currentStreak = 1;
// //     }

// //     userProgress.lastExerciseDate = now;

// //     await _firestore
// //         .collection('users')
// //         .doc(_auth.currentUser?.uid)
// //         .update({
// //       'currentStreak': userProgress.currentStreak,
// //       'lastExerciseDate': now,
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Health & Wellness'),
// //         actions: [
// //           IconButton(
// //             icon: Icon(Icons.person),
// //             onPressed: () => _showProfileDialog(),
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           _buildStreakCard(),
// //           _buildTabSelector(),
// //           Expanded(
// //             child: selectedTab == 'exercise'
// //                 ? _buildExerciseList()
// //                 : _buildMeditationList(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildStreakCard() {
// //     return Card(
// //       margin: EdgeInsets.all(16),
// //       child: Padding(
// //         padding: EdgeInsets.all(16),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceAround,
// //           children: [
// //             Column(
// //               children: [
// //                 Text(
// //                   '${userProgress.currentStreak}',
// //                   style: Theme.of(context).textTheme.headlineMedium,
// //                 ),
// //                 Text('Day Streak'),
// //               ],
// //             ),
// //             Column(
// //               children: [
// //                 Text(
// //                   '${userProgress.completedExercises.length}',
// //                   style: Theme.of(context).textTheme.headlineMedium,
// //                 ),
// //                 Text('Exercises'),
// //               ],
// //             ),
// //             Column(
// //               children: [
// //                 Text(
// //                   '${userProgress.completedMeditations.length}',
// //                   style: Theme.of(context).textTheme.headlineMedium,
// //                 ),
// //                 Text('Meditations'),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTabSelector() {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: TextButton(
// //             onPressed: () => setState(() => selectedTab = 'exercise'),
// //             child: Text('Exercises'),
// //             style: ButtonStyle(
// //               backgroundColor: MaterialStateProperty.all(
// //                 selectedTab == 'exercise'
// //                     ? Theme.of(context).primaryColor
// //                     : Colors.transparent,
// //               ),
// //             ),
// //           ),
// //         ),
// //         Expanded(
// //           child: TextButton(
// //             onPressed: () => setState(() => selectedTab = 'meditation'),
// //             child: Text('Meditation'),
// //             style: ButtonStyle(
// //               backgroundColor: MaterialStateProperty.all(
// //                 selectedTab == 'meditation'
// //                     ? Theme.of(context).primaryColor
// //                     : Colors.transparent,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildExerciseList() {
// //     final exercises = _getAgeAppropriateExercises();
// //     return ListView.builder(
// //       itemCount: exercises.length,
// //       itemBuilder: (context, index) {
// //         final exercise = exercises[index];
// //         return Card(
// //           margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //           child: ListTile(
// //             title: Text(exercise.name),
// //             subtitle: Text(
// //               '${exercise.durationMinutes} minutes - ${exercise.difficulty}',
// //             ),
// //             trailing: Icon(Icons.play_circle_outline),
// //             onTap: () => _startExercise(exercise),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildMeditationList() {
// //     final meditations = _getMeditationSessions();
// //     return ListView.builder(
// //       itemCount: meditations.length,
// //       itemBuilder: (context, index) {
// //         final meditation = meditations[index];
// //         return Card(
// //           margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //           child: ListTile(
// //             title: Text(meditation.title),
// //             subtitle: Text(
// //               '${meditation.durationMinutes} minutes - ${meditation.category}',
// //             ),
// //             trailing: Icon(Icons.headset),
// //             onTap: () => _startMeditation(meditation),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   void _startExercise(Exercise exercise) {
// //     // Implement exercise session screen
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => ExerciseSession(
// //           exercise: exercise,
// //           onComplete: () {
// //             userProgress.completedExercises.add(exercise.name);
// //             _updateStreak();
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   void _startMeditation(MeditationSession meditation) {
// //     // Implement meditation session screen
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => MeditationSession(
// //           meditation: meditation,
// //           onComplete: () {
// //             userProgress.completedMeditations.add(meditation.title);
// //             _updateStreak();
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   void _showProfileDialog() {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text('Update Profile'),
// //         content: TextField(
// //           keyboardType: TextInputType.number,
// //           decoration: InputDecoration(labelText: 'Age'),
// //           onChanged: (value) {
// //             setState(() {
// //               userAge = int.tryParse(value) ?? userAge;
// //             });
// //           },
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: Text('Cancel'),
// //           ),
// //           TextButton(
// //             onPressed: () async {
// //               final prefs = await SharedPreferences.getInstance();
// //               await prefs.setInt('user_age', userAge);
// //               Navigator.pop(context);
// //             },
// //             child: Text('Save'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // Exercise Session Screen
// // class ExerciseSession extends StatefulWidget {
// //   final Exercise exercise;
// //   final VoidCallback onComplete;

// //   ExerciseSession({required this.exercise, required this.onComplete});

// //   @override
// //   _ExerciseSessionState createState() => _ExerciseSessionState();
// // }

// // class _ExerciseSessionState extends State<ExerciseSession> {
// //   bool isCompleted = false;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text(widget.exercise.name)),
// //       body: Column(
// //         children: [
// //           // Add video player here
// //           Padding(
// //             padding: EdgeInsets.all(16),
// //             child: Text(widget.exercise.description),
// //           ),
// //           ElevatedButton(
// //             onPressed: () {
// //               setState(() => isCompleted = true);
// //               widget.onComplete();
// //               Navigator.pop(context);
// //             },
// //             child: Text('Complete Exercise'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // Meditation Session Screen
// // class MeditationSession extends StatefulWidget {
// //   final MeditationSession meditation;
// //   final VoidCallback onComplete;

// //   MeditationSession({required this.meditation, required this.onComplete});

// //   @override
// //   _MeditationSessionState createState() => _MeditationSessionState();
// // }

// // class _MeditationSessionState extends State<MeditationSession> {
// //   bool isPlaying = false;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text(widget.meditation.title)),
// //       body: Column(
// //         children: [
// //           // Add audio player here
// //           Padding(
// //             padding: EdgeInsets.all(16),
// //             child: Text(widget.meditation.description),
// //           ),
// //           IconButton(
// //             icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
// //             onPressed: () {
// //               setState(() => isPlaying = !isPlaying);
// //               // Implement audio playback
// //             },
// //           ),
// //           ElevatedButton(
// //             onPressed: () {
// //               widget.onComplete();
// //               Navigator.pop(context);
// //             },
// //             child: Text('Complete Session'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// health_wellness_tracker.dart

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // Models
// class Exercise {
//   final String name;
//   final String description;
//   final String videoUrl;
//   final List<String> ageGroups;
//   final int durationMinutes;
//   final String difficulty;

//   Exercise({
//     required this.name,
//     required this.description,
//     required this.videoUrl,
//     required this.ageGroups,
//     required this.durationMinutes,
//     required this.difficulty,
//   });
// }

// class MeditationData {
//   final String title;
//   final String description;
//   final String audioUrl;
//   final int durationMinutes;
//   final String category;

//   MeditationData({
//     required this.title,
//     required this.description,
//     required this.audioUrl,
//     required this.durationMinutes,
//     required this.category,
//   });
// }

// class UserProgress {
//   int currentStreak;
//   DateTime lastExerciseDate;
//   List<String> completedExercises;
//   List<String> completedMeditations;

//   UserProgress({
//     this.currentStreak = 0,
//     required this.lastExerciseDate,
//     required this.completedExercises,
//     required this.completedMeditations,
//   });
// }

// // Main Widget
// class HealthWellnessTrackerScreen extends StatefulWidget {
//   @override
//   _HealthWellnessTrackerScreenState createState() => _HealthWellnessTrackerScreenState();
// }

// class _HealthWellnessTrackerScreenState extends State<HealthWellnessTrackerScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late UserProgress userProgress;
//   int userAge = 0;
//   String selectedTab = 'exercise';

//   @override
//   void initState() {
//     super.initState();
//     _initializeUserData();
//   }

//   Future<void> _initializeUserData() async {
//     // Get user age from Firebase or local storage
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userAge = prefs.getInt('user_age') ?? 0;
//     });

//     // Initialize user progress
//     var userDoc = await _firestore
//         .collection('users')
//         .doc(_auth.currentUser?.uid)
//         .get();

//     if (userDoc.exists) {
//       var data = userDoc.data() as Map<String, dynamic>;
//       userProgress = UserProgress(
//         currentStreak: data['currentStreak'] ?? 0,
//         lastExerciseDate: (data['lastExerciseDate'] as Timestamp).toDate(),
//         completedExercises: List<String>.from(data['completedExercises']),
//         completedMeditations: List<String>.from(data['completedMeditations']),
//       );
//     } else {
//       userProgress = UserProgress(
//         lastExerciseDate: DateTime.now(),
//         completedExercises: [],
//         completedMeditations: [],
//       );
//     }
//   }

//   List<Exercise> _getAgeAppropriateExercises() {
//     String ageGroup = '';
//     if (userAge < 18) ageGroup = 'teen';
//     else if (userAge < 40) ageGroup = 'adult';
//     else if (userAge < 60) ageGroup = 'middle';
//     else ageGroup = 'senior';

//     return [
//       Exercise(
//         name: 'Gentle Stretching',
//         description: 'Basic full-body stretching routine',
//         videoUrl: 'assets/videos/stretching.mp4',
//         ageGroups: ['teen', 'adult', 'middle', 'senior'],
//         durationMinutes: 10,
//         difficulty: 'Easy',
//       ),
//       Exercise(
//         name: 'Walking',
//         description: 'Brisk walking routine',
//         videoUrl: 'assets/videos/walking.mp4',
//         ageGroups: ['teen', 'adult', 'middle', 'senior'],
//         durationMinutes: 30,
//         difficulty: 'Easy',
//       ),
//       // Add more exercises based on age groups
//     ].where((exercise) => exercise.ageGroups.contains(ageGroup)).toList();
//   }

//   List<MeditationData> _getMeditationSessions() {
//     return [
//       MeditationData(
//         title: 'Breathing Awareness',
//         description: 'Focus on your breath to calm your mind',
//         audioUrl: 'assets/audio/breathing.mp3',
//         durationMinutes: 10,
//         category: 'Beginner',
//       ),
//       MeditationData(
//         title: 'Body Scan',
//         description: 'Progressive relaxation meditation',
//         audioUrl: 'assets/audio/bodyscan.mp3',
//         durationMinutes: 15,
//         category: 'Intermediate',
//       ),
//       // Add more meditation sessions
//     ];
//   }

//   Future<void> _updateStreak() async {
//     final now = DateTime.now();
//     final difference = now.difference(userProgress.lastExerciseDate).inDays;

//     if (difference == 1) {
//       userProgress.currentStreak++;
//     } else if (difference > 1) {
//       userProgress.currentStreak = 1;
//     }

//     userProgress.lastExerciseDate = now;

//     await _firestore
//         .collection('users')
//         .doc(_auth.currentUser?.uid)
//         .update({
//       'currentStreak': userProgress.currentStreak,
//       'lastExerciseDate': now,
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Health & Wellness'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.person),
//             onPressed: () => _showProfileDialog(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildStreakCard(),
//           _buildTabSelector(),
//           Expanded(
//             child: selectedTab == 'exercise'
//                 ? _buildExerciseList()
//                 : _buildMeditationList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStreakCard() {
//     return Card(
//       margin: EdgeInsets.all(16),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Column(
//               children: [
//                 Text(
//                   '${userProgress.currentStreak}',
//                   style: Theme.of(context).textTheme.headlineMedium,
//                 ),
//                 Text('Day Streak'),
//               ],
//             ),
//             Column(
//               children: [
//                 Text(
//                   '${userProgress.completedExercises.length}',
//                   style: Theme.of(context).textTheme.headlineMedium,
//                 ),
//                 Text('Exercises'),
//               ],
//             ),
//             Column(
//               children: [
//                 Text(
//                   '${userProgress.completedMeditations.length}',
//                   style: Theme.of(context).textTheme.headlineMedium,
//                 ),
//                 Text('Meditations'),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabSelector() {
//     return Row(
//       children: [
//         Expanded(
//           child: TextButton(
//             onPressed: () => setState(() => selectedTab = 'exercise'),
//             child: Text('Exercises'),
//             style: ButtonStyle(
//               backgroundColor: MaterialStateProperty.all(
//                 selectedTab == 'exercise'
//                     ? Theme.of(context).primaryColor
//                     : Colors.transparent,
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: TextButton(
//             onPressed: () => setState(() => selectedTab = 'meditation'),
//             child: Text('Meditation'),
//             style: ButtonStyle(
//               backgroundColor: MaterialStateProperty.all(
//                 selectedTab == 'meditation'
//                     ? Theme.of(context).primaryColor
//                     : Colors.transparent,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildExerciseList() {
//     final exercises = _getAgeAppropriateExercises();
//     return ListView.builder(
//       itemCount: exercises.length,
//       itemBuilder: (context, index) {
//         final exercise = exercises[index];
//         return Card(
//           margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: ListTile(
//             title: Text(exercise.name),
//             subtitle: Text(
//               '${exercise.durationMinutes} minutes - ${exercise.difficulty}',
//             ),
//             trailing: Icon(Icons.play_circle_outline),
//             onTap: () => _startExercise(exercise),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMeditationList() {
//     final meditations = _getMeditationSessions();
//     return ListView.builder(
//       itemCount: meditations.length,
//       itemBuilder: (context, index) {
//         final meditation = meditations[index];
//         return Card(
//           margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: ListTile(
//             title: Text(meditation.title),
//             subtitle: Text(
//               '${meditation.durationMinutes} minutes - ${meditation.category}',
//             ),
//             trailing: Icon(Icons.headset),
//             onTap: () => _startMeditation(meditation),
//           ),
//         );
//       },
//     );
//   }

//   void _startExercise(Exercise exercise) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ExerciseSessionScreen(
//           exercise: exercise,
//           onComplete: () {
//             userProgress.completedExercises.add(exercise.name);
//             _updateStreak();
//           },
//         ),
//       ),
//     );
//   }

//   void _startMeditation(MeditationData meditation) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MeditationSessionScreen(
//           meditationData: meditation,
//           onComplete: () {
//             userProgress.completedMeditations.add(meditation.title);
//             _updateStreak();
//           },
//         ),
//       ),
//     );
//   }

//   void _showProfileDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Update Profile'),
//         content: TextField(
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(labelText: 'Age'),
//           onChanged: (value) {
//             setState(() {
//               userAge = int.tryParse(value) ?? userAge;
//             });
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               final prefs = await SharedPreferences.getInstance();
//               await prefs.setInt('user_age', userAge);
//               Navigator.pop(context);
//             },
//             child: Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Exercise Session Screen
// class ExerciseSessionScreen extends StatefulWidget {
//   final Exercise exercise;
//   final VoidCallback onComplete;

//   ExerciseSessionScreen({
//     required this.exercise,
//     required this.onComplete,
//   });

//   @override
//   _ExerciseSessionScreenState createState() => _ExerciseSessionScreenState();
// }

// class _ExerciseSessionScreenState extends State<ExerciseSessionScreen> {
//   bool isCompleted = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.exercise.name)),
//       body: Column(
//         children: [
//           // Add video player here
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Text(widget.exercise.description),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() => isCompleted = true);
//               widget.onComplete();
//               Navigator.pop(context);
//             },
//             child: Text('Complete Exercise'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Meditation Session Screen
// class MeditationSessionScreen extends StatefulWidget {
//   final MeditationData meditationData;
//   final VoidCallback onComplete;

//   MeditationSessionScreen({
//     required this.meditationData,
//     required this.onComplete,
//   });

//   @override
//   _MeditationSessionScreenState createState() => _MeditationSessionScreenState();
// }

// class _MeditationSessionScreenState extends State<MeditationSessionScreen> {
//   bool isPlaying = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.meditationData.title)),
//       body: Column(
//         children: [
//           // Add audio player here
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Text(widget.meditationData.description),
//           ),
//           IconButton(
//             icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
//             onPressed: () {
//               setState(() => isPlaying = !isPlaying);
//               // Implement audio playback
//             },
//           ),
//           ElevatedButton(
//             onPressed: () {
//               widget.onComplete();
//               Navigator.pop(context);
//             },
//             child: Text('Complete Session'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

import 'package:appinio_video_player/appinio_video_player.dart';
// Models
import 'package:flutter/material.dart';

class Exercise {
  final String name;
  final String description;
  final String videoUrl;
  final List<String> ageGroups;
  final int durationMinutes;
  final String difficulty;
  final String category;
  final IconData icon; // Added icon property

  Exercise({
    required this.name,
    required this.description,
    required this.videoUrl,
    required this.ageGroups,
    required this.durationMinutes,
    required this.difficulty,
    required this.category,
    required this.icon,
  });
}

class HealthWellnessTrackerScreen extends StatefulWidget {
  const HealthWellnessTrackerScreen({super.key});

  @override
  _HealthWellnessTrackerScreenState createState() =>
      _HealthWellnessTrackerScreenState();
}

class _HealthWellnessTrackerScreenState
    extends State<HealthWellnessTrackerScreen> {
  String selectedAgeGroup = 'all';
  String selectedDifficulty = 'all';
  String selectedCategory = 'all';

  final List<Exercise> exercises = [
    Exercise(
      name: 'Morning Yoga',
      description: 'Start your day with gentle yoga poses',
      videoUrl: 'assets/videos/stretching.mp4',
      ageGroups: ['teen', 'adult', 'middle'],
      durationMinutes: 15,
      difficulty: 'Easy',
      category: 'Yoga',
      icon: Icons.self_improvement,
    ),
    Exercise(
      name: 'Cardio Workout',
      description: 'High-energy cardio session',
      videoUrl: 'assets/videos/walking.mp4',
      ageGroups: ['teen', 'adult'],
      durationMinutes: 20,
      difficulty: 'Hard',
      category: 'Cardio',
      icon: Icons.directions_run,
    ),
    Exercise(
      name: 'Senior Stretching',
      description: 'Gentle stretching for seniors',
      videoUrl: 'assets/videos/stretching.mp4',
      ageGroups: ['senior'],
      durationMinutes: 10,
      difficulty: 'Easy',
      category: 'Stretching',
      icon: Icons.accessibility_new,
    ),
  ];

  List<Exercise> getFilteredExercises() {
    return exercises.where((exercise) {
      bool ageMatch = selectedAgeGroup == 'all' ||
          exercise.ageGroups.contains(selectedAgeGroup);
      bool difficultyMatch = selectedDifficulty == 'all' ||
          exercise.difficulty == selectedDifficulty;
      bool categoryMatch =
          selectedCategory == 'all' || exercise.category == selectedCategory;
      return ageMatch && difficultyMatch && categoryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color(0xFFFCEFF4), // Light pink background from the image
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 191, 121, 234), // Purple from the image
        title: Text('Exercise Library', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _buildExerciseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFilterDropdown(
            value: selectedAgeGroup,
            label: 'Age Group',
            icon: Icons.people,
            items: [
              DropdownMenuItem(value: 'all', child: Text('All Ages')),
              DropdownMenuItem(value: 'teen', child: Text('Teen')),
              DropdownMenuItem(value: 'adult', child: Text('Adult')),
              DropdownMenuItem(value: 'middle', child: Text('Middle Age')),
              DropdownMenuItem(value: 'senior', child: Text('Senior')),
            ],
            onChanged: (value) => setState(() => selectedAgeGroup = value!),
          ),
          SizedBox(height: 12),
          _buildFilterDropdown(
            value: selectedDifficulty,
            label: 'Difficulty',
            icon: Icons.fitness_center,
            items: [
              DropdownMenuItem(value: 'all', child: Text('All Difficulties')),
              DropdownMenuItem(value: 'Easy', child: Text('Easy')),
              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
              DropdownMenuItem(value: 'Hard', child: Text('Hard')),
            ],
            onChanged: (value) => setState(() => selectedDifficulty = value!),
          ),
          SizedBox(height: 12),
          _buildFilterDropdown(
            value: selectedCategory,
            label: 'Category',
            icon: Icons.category,
            items: [
              DropdownMenuItem(value: 'all', child: Text('All Categories')),
              DropdownMenuItem(value: 'Yoga', child: Text('Yoga')),
              DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
              DropdownMenuItem(value: 'Stretching', child: Text('Stretching')),
            ],
            onChanged: (value) => setState(() => selectedCategory = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFEEE5FF), // Light purple from the image
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          icon: Icon(icon, color: Color(0xFF452C55)),
          labelStyle: TextStyle(color: Color(0xFF452C55)),
        ),
        items: items,
        onChanged: onChanged,
        dropdownColor: Color(0xFFEEE5FF),
      ),
    );
  }

  Widget _buildExerciseList() {
    final filteredExercises = getFilteredExercises();
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = filteredExercises[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFFF9966), // Orange from the image
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                exercise.icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            title: Text(
              exercise.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF452C55),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  '${exercise.durationMinutes} minutes - ${exercise.difficulty}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  exercise.category,
                  style: TextStyle(
                    color: Color(0xFFFF9966),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: Color(0xFFEEE5FF),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.play_arrow,
                color: Color(0xFF452C55),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseVideoScreen(exercise: exercise),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ExerciseVideoScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseVideoScreen({super.key, required this.exercise});

  @override
  _ExerciseVideoScreenState createState() => _ExerciseVideoScreenState();
}

class _ExerciseVideoScreenState extends State<ExerciseVideoScreen> {
  late CustomVideoPlayerController _customVideoPlayerController;
  late VideoPlayerController _videoPlayerController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() async {
    try {
      _videoPlayerController =
          VideoPlayerController.asset(widget.exercise.videoUrl)
            ..initialize().then((_) {
              setState(() {
                _isLoading = false;
              });
            });

      _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: _videoPlayerController,
        customVideoPlayerSettings: const CustomVideoPlayerSettings(
          showSeekButtons: true,
          showPlayButton: true,
          playButton: Icon(Icons.play_arrow),
          pauseButton: Icon(Icons.pause),
          enterFullscreenButton: Icon(Icons.fullscreen),
          exitFullscreenButton: Icon(Icons.fullscreen_exit),
        ),
      );
    } catch (e) {
      print('Error initializing video player: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildVideoPlayer(),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                widget.exercise.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return CustomVideoPlayer(
      customVideoPlayerController: _customVideoPlayerController,
    );
  }
}




// class ExerciseVideoScreen extends StatefulWidget {
//   final Exercise exercise;

//   ExerciseVideoScreen({required this.exercise});

//   @override
//   _ExerciseVideoScreenState createState() => _ExerciseVideoScreenState();
// }

// class _ExerciseVideoScreenState extends State<ExerciseVideoScreen> {
//   late CustomVideoPlayerController _customVideoPlayerController;
//   late CachedVideoPlayerController _videoPlayerController;
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoPlayer();
//   }

//   Future<void> _initializeVideoPlayer() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       _videoPlayerController = CachedVideoPlayerController.asset(
//         widget.exercise.videoUrl,
//       );
      
//       await _videoPlayerController.initialize();

//       if (mounted) {
//         _customVideoPlayerController = CustomVideoPlayerController(
//           context: context,
//           videoPlayerController: _videoPlayerController,
//           customVideoPlayerSettings: const CustomVideoPlayerSettings(
//             showSeekButtons: true,
//             showPlayButton: true,
//             playButton: Icon(Icons.play_arrow),
//             pauseButton: Icon(Icons.pause),
//             enterFullscreenButton: Icon(Icons.fullscreen),
//             exitFullscreenButton: Icon(Icons.fullscreen_exit),
//           ),
//         );

//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error initializing video player: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _error = 'An error occurred while loading the video. Please check if the video file exists in assets.';
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _customVideoPlayerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.exercise.name),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             AspectRatio(
//               aspectRatio: 16 / 9,
//               child: _buildVideoPlayer(),
//             ),
//             Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.exercise.description,
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                   if (_error != null) ...[
//                     SizedBox(height: 16),
//                     Text(
//                       _error!,
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: _initializeVideoPlayer,
//                       child: Text('Retry'),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildVideoPlayer() {
//     if (_isLoading) {
//       return Container(
//         color: Colors.black12,
//         child: const Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     if (_error != null) {
//       return Container(
//         color: Colors.black12,
//         child: Center(
//           child: Icon(
//             Icons.error_outline,
//             size: 48,
//             color: Colors.red,
//           ),
//         ),
//       );
//     }

//     return CustomVideoPlayer(
//       customVideoPlayerController: _customVideoPlayerController,
//     );
//   }
// }












// class ExerciseVideoScreen extends StatefulWidget {
//   final Exercise exercise;

//   ExerciseVideoScreen({required this.exercise});

//   @override
//   _ExerciseVideoScreenState createState() => _ExerciseVideoScreenState();
// }

// class _ExerciseVideoScreenState extends State<ExerciseVideoScreen> {
//   VideoPlayerController? _controller;
//   bool _isInitialized = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoPlayer();
//   }

//   Future<void> _initializeVideoPlayer() async {
//     try {
//       final controller = VideoPlayerController.network(
//         widget.exercise.videoUrl,
//         videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
//       );
      
//       _controller = controller;
      
//       // Add listeners before initialization
//       controller.addListener(() {
//         if (mounted) setState(() {});
//       });

//       // Initialize the controller
//       await controller.initialize();
      
//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Error loading video. Please check your internet connection and try again.';
//         });
//       }
//       print('Video player error: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.exercise.name),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             AspectRatio(
//               aspectRatio: 16 / 9,
//               child: _buildVideoPlayer(),
//             ),
//             Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.exercise.description,
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                   SizedBox(height: 16),
//                   if (_isInitialized && _errorMessage == null && _controller != null)
//                     _buildVideoControls(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildVideoPlayer() {
//     if (_errorMessage != null) {
//       return Container(
//         color: Colors.black12,
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.error_outline, size: 48, color: Colors.red),
//                 SizedBox(height: 16),
//                 Text(
//                   _errorMessage!,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.red),
//                 ),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _errorMessage = null;
//                       _isInitialized = false;
//                     });
//                     _initializeVideoPlayer();
//                   },
//                   child: Text('Retry'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     if (!_isInitialized || _controller == null) {
//       return Container(
//         color: Colors.black12,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text('Loading video...'),
//             ],
//           ),
//         ),
//       );
//     }

//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         VideoPlayer(_controller!),
//         _VideoOverlay(controller: _controller!),
//       ],
//     );
//   }

//   Widget _buildVideoControls() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: Icon(
//             _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
//           ),
//           onPressed: () {
//             setState(() {
//               _controller!.value.isPlaying
//                   ? _controller!.pause()
//                   : _controller!.play();
//             });
//           },
//         ),
//         IconButton(
//           icon: Icon(Icons.replay),
//           onPressed: () {
//             _controller!.seekTo(Duration.zero);
//             _controller!.play();
//           },
//         ),
//       ],
//     );
//   }
// }

// class _VideoOverlay extends StatelessWidget {
//   final VideoPlayerController controller;

//   const _VideoOverlay({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (controller.value.isPlaying) {
//           controller.pause();
//         } else {
//           controller.play();
//         }
//       },
//       child: ValueListenableBuilder(
//         valueListenable: controller,
//         builder: (context, VideoPlayerValue value, child) {
//           return AnimatedOpacity(
//             opacity: value.isPlaying ? 0.0 : 1.0,
//             duration: Duration(milliseconds: 300),
//             child: Container(
//               color: Colors.black26,
//               child: Icon(
//                 value.isPlaying ? Icons.pause : Icons.play_arrow,
//                 size: 60,
//                 color: Colors.white,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


// class ExerciseVideoScreen extends StatefulWidget {
//   final Exercise exercise;

//   ExerciseVideoScreen({required this.exercise});

//   @override
//   _ExerciseVideoScreenState createState() => _ExerciseVideoScreenState();
// }

// class _ExerciseVideoScreenState extends State<ExerciseVideoScreen> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     // Simply initialize network video controller since we're using URLs
//     _initializeVideoPlayer();
//   }

//   Future<void> _initializeVideoPlayer() async {
//     try {
//       _controller = VideoPlayerController.network(widget.exercise.videoUrl);
//       await _controller.initialize();
//       setState(() {
//         _isInitialized = true;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error loading video: ${e.toString()}';
//       });
//       print('Video player error: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.exercise.name),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           AspectRatio(
//             aspectRatio: 16 / 9,
//             child: _buildVideoPlayer(),
//           ),
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.exercise.description,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//                 SizedBox(height: 16),
//                 if (_isInitialized && _errorMessage == null)
//                   _buildVideoControls(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVideoPlayer() {
//     if (_errorMessage != null) {
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.error_outline, size: 48, color: Colors.red),
//               SizedBox(height: 100),
//               Text(
//                 _errorMessage!,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.red),
//               ),
//               SizedBox(height: 100),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _errorMessage = null;
//                     _isInitialized = false;
//                   });
//                   _initializeVideoPlayer();
//                 },
//                 child: Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (!_isInitialized) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading video...'),
//           ],
//         ),
//       );
//     }

//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         VideoPlayer(_controller),
//         _VideoOverlay(controller: _controller),
//       ],
//     );
//   }

//   Widget _buildVideoControls() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: Icon(
//             _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//           ),
//           onPressed: () {
//             setState(() {
//               _controller.value.isPlaying
//                   ? _controller.pause()
//                   : _controller.play();
//             });
//           },
//         ),
//         IconButton(
//           icon: Icon(Icons.replay),
//           onPressed: () {
//             _controller.seekTo(Duration.zero);
//             _controller.play();
//           },
//         ),
//       ],
//     );
//   }
// }

// class _VideoOverlay extends StatelessWidget {
//   final VideoPlayerController controller;

//   const _VideoOverlay({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (controller.value.isPlaying) {
//           controller.pause();
//         } else {
//           controller.play();
//         }
//       },
//       child: ValueListenableBuilder(
//         valueListenable: controller,
//         builder: (context, VideoPlayerValue value, child) {
//           return AnimatedOpacity(
//             opacity: value.isPlaying ? 0.0 : 1.0,
//             duration: Duration(milliseconds: 300),
//             child: Container(
//               color: Colors.black26,
//               child: Icon(
//                 value.isPlaying ? Icons.pause : Icons.play_arrow,
//                 size: 60,
//                 color: Colors.white,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }









// class ExerciseVideoScreen extends StatefulWidget {
//   final Exercise exercise;

//   ExerciseVideoScreen({required this.exercise});

//   @override
//   _ExerciseVideoScreenState createState() => _ExerciseVideoScreenState();
// }

// class _ExerciseVideoScreenState extends State<ExerciseVideoScreen> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.asset(widget.exercise.videoUrl)
//       ..initialize().then((_) {
//         setState(() {
//           _isInitialized = true;
//         });
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.exercise.name),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           AspectRatio(
//             aspectRatio: 16 / 9,
//             child: _isInitialized
//                 ? VideoPlayer(_controller)
//                 : Center(child: CircularProgressIndicator()),
//           ),
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.exercise.description,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//                 SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         _controller.value.isPlaying
//                             ? Icons.pause
//                             : Icons.play_arrow,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _controller.value.isPlaying
//                               ? _controller.pause()
//                               : _controller.play();
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Update the Exercise class to specify video source type
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class Exercise {
//   final String name;
//   final String description;
//   final String videoUrl;
//   final bool isAssetVideo; // Add this field to distinguish between asset and network videos
//   final List<String> ageGroups;
//   final int durationMinutes;
//   final String difficulty;
//   final String category;

//   Exercise({
//     required this.name,
//     required this.description,
//     required this.videoUrl,
//     this.isAssetVideo = false, // Default to network videos
//     required this.ageGroups,
//     required this.durationMinutes,
//     required this.difficulty,
//     required this.category,
//   });
// }

// // Update your exercise list with proper video URLs
// final List<Exercise> exercises = [
//   Exercise(
//     name: 'Morning Yoga',
//     description: 'Start your day with gentle yoga poses',
//     // Use a sample video URL - replace with your actual video URL
//     videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
//     isAssetVideo: false,
//     ageGroups: ['teen', 'adult', 'middle'],
//     durationMinutes: 15,
//     difficulty: 'Easy',
//     category: 'Yoga',
//   ),
//   Exercise(
//     name: 'Cardio Workout',
//     description: 'High-energy cardio session',
//     videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
//     isAssetVideo: false,
//     ageGroups: ['teen', 'adult'],
//     durationMinutes: 20,
//     difficulty: 'Hard',
//     category: 'Cardio',
//   ),
//   // Add more exercises...
// ];

// // Update the ExerciseVideoScreen with proper error handling
// class HealthWellnessTrackerScreen extends StatefulWidget {
//   final Exercise exercise;

//   HealthWellnessTrackerScreen({required this.exercise});

//   @override
//   _HealthWellnessTrackerScreenState createState() => _HealthWellnessTrackerScreenState();
// }

// class _HealthWellnessTrackerScreenState extends State<HealthWellnessTrackerScreen> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoPlayer();
//   }

//   Future<void> _initializeVideoPlayer() async {
//     try {
//       if (widget.exercise.isAssetVideo) {
//         _controller = VideoPlayerController.asset(widget.exercise.videoUrl);
//       } else {
//         _controller = VideoPlayerController.network(widget.exercise.videoUrl);
//       }

//       await _controller.initialize();
//       setState(() {
//         _isInitialized = true;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error loading video: ${e.toString()}';
//       });
//       print('Video player error: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.exercise.name),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           AspectRatio(
//             aspectRatio: 16 / 9,
//             child: _buildVideoPlayer(),
//           ),
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.exercise.description,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//                 SizedBox(height: 16),
//                 if (_isInitialized && _errorMessage == null)
//                   _buildVideoControls(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVideoPlayer() {
//     if (_errorMessage != null) {
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.error_outline, size: 48, color: Colors.red),
//               SizedBox(height: 16),
//               Text(
//                 _errorMessage!,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.red),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _errorMessage = null;
//                     _isInitialized = false;
//                   });
//                   _initializeVideoPlayer();
//                 },
//                 child: Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (!_isInitialized) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading video...'),
//           ],
//         ),
//       );
//     }

//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         VideoPlayer(_controller),
//         _VideoOverlay(controller: _controller),
//       ],
//     );
//   }

//   Widget _buildVideoControls() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: Icon(
//             _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//           ),
//           onPressed: () {
//             setState(() {
//               _controller.value.isPlaying
//                   ? _controller.pause()
//                   : _controller.play();
//             });
//           },
//         ),
//         IconButton(
//           icon: Icon(Icons.replay),
//           onPressed: () {
//             _controller.seekTo(Duration.zero);
//             _controller.play();
//           },
//         ),
//       ],
//     );
//   }
// }

// // Add a video overlay for better user experience
// class _VideoOverlay extends StatelessWidget {
//   final VideoPlayerController controller;

//   const _VideoOverlay({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (controller.value.isPlaying) {
//           controller.pause();
//         } else {
//           controller.play();
//         }
//       },
//       child: ValueListenableBuilder(
//         valueListenable: controller,
//         builder: (context, VideoPlayerValue value, child) {
//           return AnimatedOpacity(
//             opacity: value.isPlaying ? 0.0 : 1.0,
//             duration: Duration(milliseconds: 300),
//             child: Container(
//               color: Colors.black26,
//               child: Icon(
//                 value.isPlaying ? Icons.pause : Icons.play_arrow,
//                 size: 60,
//                 color: Colors.white,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


