import 'package:flutter/material.dart';
import 'dart:math';

class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});
}

class FlashcardHome extends StatefulWidget {
  const FlashcardHome({super.key});
  @override
  State<FlashcardHome> createState() => _FlashcardHomeState();
}

class _FlashcardHomeState extends State<FlashcardHome>
    with SingleTickerProviderStateMixin {
  bool showAnswer = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  List<Flashcard> flashcards = [
    Flashcard(question: 'What is Flutter?', answer: 'A UI toolkit by Google.'),
    Flashcard(question: 'What language does Flutter use?', answer: 'Dart.'),
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(_controller);
  }

  void _flipCard() {
    if (showAnswer) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  void _nextCard() {
    if (currentIndex < flashcards.length - 1) {
      setState(() {
        currentIndex++;
        if (showAnswer) {
          _controller.reverse();
          showAnswer = false;
        }
      });
    }
  }

  void _previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        if (showAnswer) {
          _controller.reverse();
          showAnswer = false;
        }
      });
    }
  }

  void _showAddEditDialog(int? index) {
    final questionController = TextEditingController(
      text: index != null ? flashcards[index].question : '',
    );
    final answerController = TextEditingController(
      text: index != null ? flashcards[index].answer : '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(flashcards.isEmpty ? 'Add Flashcard' : 'Edit Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Answer'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              final newCard = Flashcard(
                question: questionController.text,
                answer: answerController.text,
              );
              setState(() {
                if (index != null) {
                  flashcards[index] = newCard;
                } else {
                  flashcards.add(newCard);
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _deleteCard(int index) {
    setState(() {
      flashcards.removeAt(index);
      if (flashcards.isEmpty) {
        currentIndex = 0;
        showAnswer = false;
        _controller.reset();
      } else {
        if (currentIndex >= flashcards.length) {
          currentIndex = flashcards.length - 1;
        }
        showAnswer = false;
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCard(bool isBack) {
    if (flashcards.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= flashcards.length) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 35.0),
        padding: const EdgeInsets.all(35.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD740), Color(0xFFFFA000)],
          ),
        ),
        child: const Center(
          child: Text(
            "No flashcards available.\nTap + to add one.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    final question = flashcards[currentIndex].question;
    final answer = flashcards[currentIndex].answer;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 35.0),
      padding: const EdgeInsets.all(35.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD740), Color(0xFFFFA000)],
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              isBack ? answer : question,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _flipCard,
              label: Text(showAnswer ? 'Hide Answer' : 'Show Answer'),
              icon: const Icon(Icons.flip),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(18.0),
                backgroundColor: Colors.lightGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showAddEditDialog(currentIndex),
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _deleteCard(currentIndex),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flash Card")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: GestureDetector(
              onTap: flashcards.isEmpty ? null : _flipCard,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final isFront = _animation.value < (pi / 2);
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_animation.value),
                    child: isFront
                        ? _buildCard(false)
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _buildCard(true),
                          ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Previous-Next Button
          flashcards.isEmpty
              ? const SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: (flashcards.isEmpty || currentIndex == 0)
                          ? null
                          : _previousCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (flashcards.isEmpty || currentIndex == 0)
                            ? Colors.grey
                            : Colors.orange,
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          (flashcards.isEmpty ||
                              currentIndex == flashcards.length - 1)
                          ? null
                          : _nextCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (flashcards.isEmpty ||
                                currentIndex == flashcards.length - 1)
                            ? Colors.grey
                            : Colors.orange,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        tooltip: 'Add Quiz',
        icon: const Icon(Icons.add),
        label: Text('Add Quiz'),
        onPressed: () => _showAddEditDialog(null),
      ),
    );
  }
}
