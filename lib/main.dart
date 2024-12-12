import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const DicePageStateful(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color.fromARGB(255, 110, 93, 87),
          onPrimary: Colors.white,
          secondary: Color.fromARGB(255, 110, 93, 87),
          onSecondary: Color.fromARGB(255, 110, 93, 87),
          surface: Colors.brown,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 110, 93, 87),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 52, 31, 24),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        dialogBackgroundColor: const Color.fromARGB(255, 110, 93, 87),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }
}

class Player {
  String name; // 플레이어 이름
  List<int> scores; // 플레이어 점수 리스트
  List<bool> isScored; // 플레이어 점수 확정 여부
  bool isActive; // 플레이어 턴 계산

  Player({
    required this.name,
    required this.scores,
    required this.isScored,
    required this.isActive,
  });
}

class DicePageStateful extends StatefulWidget {
  const DicePageStateful({super.key});

  @override
  _DicePageStatefulState createState() => _DicePageStatefulState();
}

class _DicePageStatefulState extends State<DicePageStateful> {
  List<int> dice = [1, 2, 3, 4, 5]; // 주사위 리스트
  List<bool> isDice = [false, false, false, false, false]; // 주사위 킵 여부
  int playerCount = 1; // 플레이어 인원 수
  bool showPlayerDialog = true; // 인원 수 설정 팝업 여부
  List<Player> players = []; // 플레이어 리스트 ( 최대 4명 )

  int currentRound = 1; // 현재 라운드 ( 총 12 라운드 )
  int currentPlayer = 0; // 현재 턴 진행 중인 플레이어

  int rollCount = 3; // 주사위 굴리기 횟수
  bool isRolling = true; // 점수 입력, 주사위 킵 여부 등 관리 위한 변수

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (showPlayerDialog) {
        _showPlayerSelectDialog();
      }
    });
  }

  // 인원 수 설정 팝업
  void _showPlayerSelectDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color.fromARGB(255, 110, 93, 87),
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Center(
            child: Text(
              'Choose Player Number',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              int numPlayers = index + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      playerCount = numPlayers;
                    });
                    Navigator.pop(context);
                    _showNameInputDialog(numPlayers);
                  },
                  child: Text("$numPlayers"),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // 플레이어 이름 설정 팝업
  void _showNameInputDialog(int playerCount) {
    List<TextEditingController> controllers = List.generate(
      playerCount,
      (_) => TextEditingController(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color.fromARGB(255, 110, 93, 87),
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Center(
            child: Text(
              'Enter Player Names',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(playerCount, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    controller: controllers[index],
                    decoration: InputDecoration(
                      labelText: 'Player ${index + 1} Name',
                      filled: true,
                      fillColor: Colors.brown,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      floatingLabelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.brown,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  for (int i = 0; i < controllers.length; i++) {
                    String playerName = controllers[i].text.trim();
                    if (playerName.isEmpty) {
                      playerName = "Player ${i + 1}";
                    }
                    players.add(
                      Player(
                        name: playerName,
                        scores: List.filled(15, 0),
                        isScored: List.generate(15,
                            (i) => i == 6 || i == 7 || i == 14 ? true : false),
                        isActive: false,
                      ),
                    );
                  }
                  showPlayerDialog = false;
                  Navigator.pop(context);
                });
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // 게임 결과 팝업
  void _showResultDialog() {
    List<Player> sortedPlayers = List.from(players);
    sortedPlayers.sort((a, b) => b.scores[14].compareTo(a.scores[14]));

    String getRankLine(int rankIndex, String rankLabel) {
      if (sortedPlayers.length > rankIndex) {
        return "$rankLabel : ${sortedPlayers[rankIndex].name} (${sortedPlayers[rankIndex].scores[14]}points)";
      } else {
        return "$rankLabel : -";
      }
    }

    String winnerLine = getRankLine(0, "Winner");
    String secondLine = getRankLine(1, "2nd");
    String thirdLine = getRankLine(2, "3rd");
    String fourthLine = getRankLine(3, "4th");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 110, 93, 87),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Center(
            child: Text(
              'CONGRATUATION !',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 300,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      winnerLine,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      secondLine,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      thirdLine,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      fourthLine,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
              ),
              child: const Text("Play Again"),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
              ),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // 게임 리셋 함수
  void _resetGame() {
    setState(() {
      currentRound = 1;
      currentPlayer = 0;
      isRolling = true;
      rollCount = 3;
      dice = [1, 2, 3, 4, 5];
      isDice = [false, false, false, false, false];
      for (var p in players) {
        p.scores = List.filled(15, 0);
        p.isScored = List.generate(
            15, (i) => i == 6 || i == 7 || i == 14 ? true : false);
      }
    });
  }

  // 주사위 킵 On/Off 함수
  void toggleDiceKeep(int diceIndex) {
    setState(() {
      isDice[diceIndex] = !isDice[diceIndex];
    });
  }

  // 주사위 킵 리셋 함수
  void resetDiceKeep() {
    setState(() {
      isDice = [false, false, false, false, false];
    });
  }

  // 주사위 굴리기 함수
  void rollDice() async {
    if (rollCount > 0) {
      setState(() {
        rollCount -= 1;
        isRolling = true;
      });
      // 간단히 굴리는 모션 구현
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          for (int j = 0; j < 5; j++) {
            if (!isDice[j]) {
              dice[j] = Random().nextInt(6) + 1;
            }
          }
        });
      }
      setState(() {
        isRolling = false;
      });
    }
  }

  // ones ~ sixes 점수 계산 함수
  int calNums(int num) {
    int total = 0;
    List<int> diceNum = List.from(dice);

    for (int value in diceNum) {
      if (value == num) {
        total += value;
      }
    }
    return total;
  }

  // ones ~ sixes 까지의 합 계산 함수
  int totalCal(Player player) {
    return player.scores.sublist(0, 6).reduce((a, b) => a + b);
  }

  // total 결과 값에 따른 보너스 점수 계산 함수
  int bonusCal(Player player) {
    return totalCal(player) >= 63 ? 35 : 0;
  }

  // choice 점수 계산 함수
  int choice() {
    int total = 0;
    List<int> diceNum = List.from(dice);

    for (int value in diceNum) {
      total += value;
    }
    return total;
  }

  // four of a kind 점수 계산 함수
  int fourOfaKind() {
    int total = 0;
    List<int> diceNum = List.from(dice);

    Map<int, int> countMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (int value in diceNum) {
      if (countMap.containsKey(value)) {
        countMap[value] = countMap[value]! + 1;
      }
    }

    for (int key in countMap.keys) {
      if (countMap[key]! >= 4) {
        total = key * 4;
        break;
      }
    }
    return total;
  }

  // fullhouse 점수 계산 함수
  int fullHouse() {
    int total = 0;
    List<int> diceNum = List.from(dice);

    Map<int, int> countMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (int value in diceNum) {
      if (countMap.containsKey(value)) {
        countMap[value] = countMap[value]! + 1;
      }
    }

    int? threeKind;
    int? twoKind;

    countMap.forEach((key, value) {
      if (value == 3) {
        threeKind = key;
      } else if (value == 2) {
        twoKind = key;
      }
    });

    if (threeKind != null && twoKind != null) {
      total = threeKind! * 3 + twoKind! * 2;
    }

    return total;
  }

  // S straight 계산 함수
  int smallStraight() {
    List<int> diceNum = List.from(dice);
    diceNum.sort();
    List<List<int>> smallStraights = [
      [1, 2, 3, 4],
      [2, 3, 4, 5],
      [3, 4, 5, 6]
    ];

    for (List<int> straight in smallStraights) {
      if (straight.every((num) => diceNum.contains(num))) {
        return 15;
      }
    }
    return 0;
  }

  // L straight 계산 함수
  int largeStraight() {
    List<int> diceNum = List.from(dice);
    diceNum.sort();
    List<List<int>> largeStraights = [
      [1, 2, 3, 4, 5],
      [2, 3, 4, 5, 6]
    ];

    for (List<int> straight in largeStraights) {
      if (straight.every((num) => diceNum.contains(num))) {
        return 30;
      }
    }
    return 0;
  }

  // Yacht 계산 함수
  int yacht() {
    List<int> diceNum = List.from(dice);

    if (diceNum.toSet().length == 1) {
      return 50;
    }
    return 0;
  }

  // 전체 총합 grand total 계산 함수
  int grandCal(Player player) {
    return player.scores.reduce((a, b) => a + b) -
        player.scores[6] -
        player.scores[14];
  }

  @override
  Widget build(BuildContext context) {
    // 플레이어 및 점수판 타이틀 리스트
    final List<String> scoreTitle = [
      "Player",
      "Ones",
      "Twos",
      "Threes",
      "Fours",
      "Fives",
      "Sixes",
      "Total",
      "Bonus",
      "Choice",
      "Four of a Kind",
      "Fullhouse",
      "Small Straight",
      "Large Straight",
      "Yacht",
      "Grand Total",
    ];

    // 타이틀 리스트 및 이미지 위젯 빌더
    Widget buildScoreTitleList() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(scoreTitle.length, (index) {
          return Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    right: BorderSide(color: Colors.brown, width: 1.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Image.asset('assets/${scoreTitle[index]}.png'),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 120,
                      child: Center(
                        child: Text(
                          scoreTitle[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      );
    }

    // Player.scores 리스트 별 점수 계산 함수 매칭
    int calculateScoreForIndex(int index) {
      switch (index) {
        case 0:
          return calNums(1);
        case 1:
          return calNums(2);
        case 2:
          return calNums(3);
        case 3:
          return calNums(4);
        case 4:
          return calNums(5);
        case 5:
          return calNums(6);
        case 6:
          return 0;
        case 7:
          return 0;
        case 8:
          return choice();
        case 9:
          return fourOfaKind();
        case 10:
          return fullHouse();
        case 11:
          return smallStraight();
        case 12:
          return largeStraight();
        case 13:
          return yacht();
        case 14:
          return 0;
        default:
          return 0;
      }
    }

    // 플레이어별 점수 입력판 위젯 빌더
    Widget buildPlayerScoreList() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: players.map((player) {
          bool isCurrentPlayer =
              (players.indexOf(player) == currentPlayer % playerCount);
          return Container(
            decoration: BoxDecoration(
              border: isCurrentPlayer
                  ? Border.all(color: Colors.black87, width: 5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 164,
                        height: 30,
                        child: Center(
                          child: Text(
                            player.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: List.generate(player.scores.length, (index) {
                    int calculatedScore = calculateScoreForIndex(index);
                    final displayedScore = player.isScored[index]
                        ? player.scores[index]
                        : calculatedScore;
                    final backgroundColor =
                        player.isScored[index] ? Colors.black54 : Colors.white;
                    final textColor =
                        player.isScored[index] ? Colors.white : Colors.black;
                    final fontSize = player.isScored[index] ? 20.0 : 16.0;

                    bool isNonClickableIndex =
                        (index == 6 || index == 7 || index == 14);

                    return Row(
                      children: [
                        GestureDetector(
                          onTap: (!isRolling &&
                                  !player.isScored[index] &&
                                  !isNonClickableIndex &&
                                  isCurrentPlayer)
                              ? () {
                                  setState(() {
                                    player.scores[index] = calculatedScore;
                                    player.isScored[index] = true;
                                    isRolling = true;
                                    rollCount = 3;
                                    currentPlayer += 1;
                                    player.scores[6] = totalCal(player);
                                    player.scores[7] = bonusCal(player);
                                    player.scores[14] = grandCal(player);
                                    resetDiceKeep();
                                    if (currentPlayer % playerCount == 0) {
                                      currentRound += 1;
                                    }
                                    if (currentRound > 12) {
                                      _showResultDialog();
                                    }
                                  });
                                }
                              : null,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: 164,
                              height: 30,
                              child: Center(
                                child: Text(
                                  displayedScore.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // 플레이어 점수판
            Expanded(
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyLarge!,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildScoreTitleList(),
                    buildPlayerScoreList(),
                  ],
                ),
              ),
            ),

            const VerticalDivider(
              color: Colors.white,
              width: 50.0,
              indent: 20,
              endIndent: 20,
            ),

            // 주사위 표시판
            Expanded(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            // 주사위 1 2 3
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: isRolling
                                        ? null
                                        : () => toggleDiceKeep(0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                              'assets/dice${dice[0]}.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          if (isDice[0])
                                            const Positioned(
                                              top: 5,
                                              right: 5,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.lightGreen,
                                                size: 50,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: isRolling
                                        ? null
                                        : () => toggleDiceKeep(1),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                              'assets/dice${dice[1]}.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          if (isDice[1])
                                            const Positioned(
                                              top: 5,
                                              right: 5,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.lightGreen,
                                                size: 50,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: isRolling
                                        ? null
                                        : () => toggleDiceKeep(2),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                              'assets/dice${dice[2]}.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          if (isDice[2])
                                            const Positioned(
                                              top: 5,
                                              right: 5,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.lightGreen,
                                                size: 50,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // 주사위 4 5 , 굴리기 버튼
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: isRolling
                                        ? null
                                        : () => toggleDiceKeep(3),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                              'assets/dice${dice[3]}.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          if (isDice[3])
                                            const Positioned(
                                              top: 5,
                                              right: 5,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.lightGreen,
                                                size: 50,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: isRolling
                                        ? null
                                        : () => toggleDiceKeep(4),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                              'assets/dice${dice[4]}.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          if (isDice[4])
                                            const Positioned(
                                              top: 5,
                                              right: 5,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.lightGreen,
                                                size: 50,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: GestureDetector(
                                      onTap: rollDice,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Image.asset(
                                                      'assets/rollingIcon.png'),
                                                  const Text(
                                                    'ROLL',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 40,
                                                      shadows: [
                                                        Shadow(
                                                          offset:
                                                              Offset(-2, -2),
                                                          blurRadius: 0.0,
                                                          color: Colors.black,
                                                        ),
                                                        Shadow(
                                                          offset: Offset(2, 2),
                                                          blurRadius: 0.0,
                                                          color: Colors.black,
                                                        ),
                                                        Shadow(
                                                          offset: Offset(-2, 2),
                                                          blurRadius: 0.0,
                                                          color: Colors.black,
                                                        ),
                                                        Shadow(
                                                          offset: Offset(2, -2),
                                                          blurRadius: 0.0,
                                                          color: Colors.black,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ])),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  // 남은 굴리기 횟수
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remaining Rolls : $rollCount',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(
                              rollCount,
                              (index) => Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/rollingIcon.png',
                                  width: 128,
                                  height: 128,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
