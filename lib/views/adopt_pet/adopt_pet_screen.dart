// import 'package:flutter/material.dart';
// import 'package:manipal_app/components/app_drawer.dart';
// import 'package:manipal_app/screens/adopt_pets/chatbot_screen.dart';

// class PetAdoptScreen extends StatelessWidget {
//   const PetAdoptScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Adopt Pet"),
//       ),
//       drawer: AppDrawer(currentRoute: '/adopt_pet'),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           child:Column(children: [
//             // ElevatedButton(onPressed: (){
//             //   Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatbotScreen()));
//             // }, child: Text('Chatbot'))
//           ],)
//         ),
//       ),
//     );
//   }
// }

import 'package:aura_techwizard/views/adopt_pet/chatbot_screen.dart';
import 'package:flutter/material.dart';

class PetAdoptionScreen extends StatefulWidget {
  const PetAdoptionScreen({super.key});

  @override
  _PetAdoptionScreenState createState() => _PetAdoptionScreenState();
}

class _PetAdoptionScreenState extends State<PetAdoptionScreen> {
  String selectedCategory = 'All';

  final Map<String, List<Map<String, String>>> pets = {
    'All': [
      {'name': 'Buddy', 'image': 'assets/images/community.png'},
      {'name': 'Max', 'image': 'assets/images/community.png'},
      {'name': 'Whiskers', 'image': 'assets/images/community.png'},
      {'name': 'Felix', 'image': 'assets/images/community.png'},
      {'name': 'Polly', 'image': 'assets/images/community.png'},
    ],
    'Dogs': [
      {'name': 'Buddy', 'image': 'assets/images/community.png'},
      {'name': 'Max', 'image': 'assets/images/community.png'},
    ],
    'Cats': [
      {'name': 'Whiskers', 'image': 'assets/images/community.png'},
      {'name': 'Felix', 'image': 'assets/images/community.png'},
    ],
    'Birds': [
      {'name': 'Polly', 'image': 'assets/images/community.png'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> selectedPets = pets[selectedCategory] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () {

        //   },
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Community Join Section
              Container(
                padding: const EdgeInsets.all(20),
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF2F2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Join Our Animal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Lovers Community',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 50),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(19),
                              ),
                              backgroundColor: Colors.transparent,
                            ).copyWith(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              elevation: WidgetStateProperty.all(0),
                            ),
                            child: const Text(
                              'Continue',
                            ),
                          ).buildGradient(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Image.asset(
                      'assets/images/community.png',
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Category Selection
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CategoryButton(
                      label: 'All',
                      isSelected: selectedCategory == 'All',
                      onTap: () {
                        setState(() {
                          selectedCategory = 'All';
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CategoryButton(
                      label: 'Dogs',
                      isSelected: selectedCategory == 'Dogs',
                      onTap: () {
                        setState(() {
                          selectedCategory = 'Dogs';
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CategoryButton(
                      label: 'Cats',
                      isSelected: selectedCategory == 'Cats',
                      onTap: () {
                        setState(() {
                          selectedCategory = 'Cats';
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CategoryButton(
                      label: 'Birds',
                      isSelected: selectedCategory == 'Birds',
                      onTap: () {
                        setState(() {
                          selectedCategory = 'Birds';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Pets List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Pets',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllPetsPage(
                            category: selectedCategory,
                            pets: selectedPets,
                          ),
                        ),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Display Pets in Horizontal Scroll
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: selectedPets.take(4).map((pet) {
                    return PetCard(
                      name: pet['name']!,
                      imagePath: pet['image']!,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Which Pet Should I Adopt?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF2F2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      ImageIcon(
                        AssetImage("assets/images/weather.png"),
                        size: 80.0, // You can specify the size of the icon
                        color: Colors
                            .black, // Optional: you can specify a color for the icon
                      ),
                      const Text('Ask Our Weatherbot'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatbotScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                          backgroundColor: Colors.transparent,
                        ).copyWith(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.transparent),
                          elevation: WidgetStateProperty.all(0),
                        ),
                        child: const Text(
                          'Chat',
                          style: TextStyle(color: Colors.black),
                        ),
                      ).buildGradient(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PetCard extends StatelessWidget {
  final String name;
  final String imagePath;

  const PetCard({
    super.key,
    required this.name,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Image.asset(imagePath, height: 100, fit: BoxFit.cover),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        height: 50,
        width: 80,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE4E4) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class AllPetsPage extends StatelessWidget {
  final String category;
  final List<Map<String, String>> pets;

  const AllPetsPage({
    super.key,
    required this.category,
    required this.pets,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All $category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: pets.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Image.asset(pets[index]['image']!, width: 50),
              title: Text(pets[index]['name']!),
            );
          },
        ),
      ),
    );
  }
}

extension GradientElevatedButton on ElevatedButton {
  Widget buildGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9CDBA6), // Start color
            Color(0xFFDEF9C4), // End color
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(19), // Rounded corners
      ),
      child: this,
    );
  }
}
