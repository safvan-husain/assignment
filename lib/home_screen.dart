import 'package:assignment/auth_provider.dart';
import 'package:assignment/question_screen.dart';
import 'package:assignment/user_model.dart';
import 'package:assignment/widgets/circle_progress_with_icon.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserModel? user = Provider.of<AuthProvider>(context).user;
  int _currentIndex = 1;
  var navBarItems = {
    "Certificate": Icons.badge_outlined,
    "Profile": Icons.contact_page,
    "Chat": Icons.chat_bubble,
    "Score": Icons.dew_point,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 1
          ? _buildProfileScreen(context)
          : Center(
              child: Text(navBarItems.entries.elementAt(_currentIndex).key),
            ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        currentIndex: _currentIndex,
        unselectedItemColor: Colors.grey,
        items: navBarItems.entries
            .toList()
            .asMap()
            .map(
              (index, e) => MapEntry(
                index,
                BottomNavigationBarItem(
                    icon: index == _currentIndex
                        ? CircleAvatar(
                            backgroundColor:
                                const Color.fromARGB(255, 247, 181, 150),
                            child: Icon(
                              e.value,
                              color: Colors.deepOrangeAccent,
                            ),
                          )
                        : Icon(e.value),
                    label: ""),
              ),
            )
            .values
            .toList(),
      ),
    );
  }

  SafeArea _buildProfileScreen(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 40,
          ),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Icon(Icons.settings),
                ),
              ),
              CircleAvatar(
                radius: 50,
                backgroundImage: user == null
                    ? Image.asset("assets/avatar.jpeg").image
                    : user!.avatar == null
                        ? Image.asset("assets/avatar.jpeg").image
                        : Image.network(user!.avatar!).image,
              ),
              const SizedBox(height: 20),
              Text(
                user == null ? "name" : user!.name,
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              Text(
                user == null ? "email" : user!.id,
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.deepOrangeAccent;
                    }
                    return const Color.fromARGB(255, 252, 129, 105);
                  },
                )),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (c) => const QuestionSreen(),
                    ),
                    (s) => false,
                  );
                },
                child: Text(
                  "Win Certificate",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: ["coins", "shieald", "trophy", "level"]
                      .map((e) => Expanded(
                            child: Card(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 5),
                                    const CircleAvatar(),
                                    Text(
                                      e,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      "0",
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Streak",
                              style: GoogleFonts.poppins(
                                color: Colors.deepOrangeAccent,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "0 day reached",
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                        const CircleProgressWithIcon(
                          progress: 0.8,
                          icon: Icons.fire_hydrant,
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
