import 'package:flutter/material.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Record',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Voice Recording Button
            Column(
              children: [
                Text(
                  _isRecording ? 'Listening...' : 'Tap to record',
                  style: TextStyle(
                    color: _isRecording ? Colors.green : Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isRecording = !_isRecording;
                    });
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.green : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.green : Colors.white)
                              .withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 60,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
