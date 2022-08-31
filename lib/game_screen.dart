import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hangman/utils.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  AudioCache audioCache = AudioCache(prefix: "sounds/");
  String word = wordlist[Random().nextInt(wordlist.length)];
  List guessedalphabet = [];
  int points = 0;
  int status = 0;
  bool soundOn = true;
  List images = [
    "images/0.png",
    "images/1.png",
    "images/2.png",
    "images/3.png",
    "images/4.png",
    "images/5.png",
    "images/6.png",
  ];

  playsound(String sound) async {
    if (soundOn) {
      await audioCache.play(sound);
    }
  }

  opendialog(String title) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: 180,
            decoration: BoxDecoration(color: Colors.orange),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: retroStyle(25, Colors.white, FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Your Points: $points",
                  style: retroStyle(20, Colors.white, FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width / 2,
                  child: TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        status = 0;
                        guessedalphabet.clear();
                        points = 0;
                        word = wordlist[Random().nextInt(wordlist.length)];
                      });
                      playsound("restart.mp3");
                    },
                    child: Center(
                      child: Text(
                        "Play Again",
                        style: retroStyle(20, Colors.black, FontWeight.normal),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String handletext() {
    String displayword = "";
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      if (guessedalphabet.contains(char)) {
        displayword += char + " ";
      } else {
        displayword += "? ";
      }
    }
    return displayword;
  }

  checkletter(String alphabet) {
    if (word.contains(alphabet)) {
      setState(() {
        guessedalphabet.add(alphabet);
        points += 5;
      });
      playsound("correct.mp3");
    } else if (status != 6) {
      setState(() {
        status += 1;
        points -= 5;
      });
      playsound("wrong.mp3");
    } else {
      opendialog("You Lost !");
      playsound("lost.mp3");
    }
    bool isWon = true;
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      if (!guessedalphabet.contains(char)) {
        setState(() {
          isWon = false;
        });
        break;
      }
    }
    if (isWon) {
      opendialog("You Won !");
      playsound("won.mp3");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "Hangman",
          style: retroStyle(
            30,
            Colors.orange,
            FontWeight.normal,
          ),
        ),
        actions: [
          IconButton(
            iconSize: 30,
            icon:
                Icon(soundOn ? Icons.volume_up_sharp : Icons.volume_off_sharp),
            color: Colors.white,
            onPressed: () {
              setState(() {
                soundOn = !soundOn;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width / 3.5,
                height: 30,
                decoration: BoxDecoration(color: Colors.white),
                child: Center(
                  child: Text(
                    "$points Points",
                    style: retroStyle(
                      15,
                      Colors.black,
                      FontWeight.normal,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Image(
                image: AssetImage(images[status]),
                width: 155,
                height: 155,
                fit: BoxFit.cover,
                color: Colors.white,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "${7 - status} lives left",
                style: retroStyle(18, Colors.grey, FontWeight.normal),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                handletext(),
                style: retroStyle(25, Colors.white, FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(left: 10),
                childAspectRatio: 1.5,
                children: letters.map((alphabet) {
                  return InkWell(
                    onTap: () => checkletter(alphabet),
                    child: Center(
                      child: Text(
                        alphabet,
                        style: retroStyle(20, Colors.white, FontWeight.normal),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
