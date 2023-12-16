import 'dart:async';

import 'package:assignment/home_screen.dart';
import 'package:assignment/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionSreen extends StatefulWidget {
  const QuestionSreen({super.key});

  @override
  State<QuestionSreen> createState() => _QuestionSreenState();
}

class _QuestionSreenState extends State<QuestionSreen> {
  final TextEditingController _controller = TextEditingController();
  Stream<int>? stream;
  Stream<int> countdown(int seconds) {
    return Stream.periodic(const Duration(seconds: 1), (i) => seconds - i - 1)
        .take(seconds);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWarning();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (c) => const HomeScreen(),
                      ),
                      (s) => false,
                    );
                  },
                  child: Icon(Icons.arrow_back_ios),
                ),
              ),
            ),
            Center(
              child: stream == null
                  ? const SizedBox()
                  : StreamBuilder<int>(
                      stream: stream!,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            "Starting countdown...",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          return _buildTimesUp(context);
                        } else {
                          return _buildOnTime(snapshot);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildOnTime(AsyncSnapshot<int> snapshot) {
    return Column(
      children: [
        Text(
          "Time remaining: ${snapshot.data} seconds",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Container(
          height: 300,
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: TextField(
            maxLines: 7,
            controller: _controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Tell me about yourself',
              hintStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        )
      ],
    );
  }

  Column _buildTimesUp(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        Text(
          "Time's up!",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            _controller.text.isNotEmpty
                ? _controller.text
                : "You wrote nothing",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _controller.text.isNotEmpty ? Colors.grey : Colors.red,
            ),
          ),
        ),
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
              if (_controller.text.isEmpty) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (c) => const QuestionSreen()));
              } else {
                showSnackbar("Submitted", context);
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (c) => const HomeScreen()));
              }
            },
            child: Text(
              _controller.text.isEmpty ? "try again" : "Submit",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ))
      ],
    );
  }

  Future<dynamic> _showWarning() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Alert',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          content: Text(
            'You should answer within 30 seconds',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.deepOrangeAccent;
                    }
                    return const Color.fromARGB(255, 252, 129, 105);
                  },
                )),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  stream = countdown(30);
                  setState(() {});
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
