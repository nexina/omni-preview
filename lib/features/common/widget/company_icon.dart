import 'package:flutter/material.dart';

class CompanyIcon extends StatelessWidget {
  const CompanyIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),

          child: Image.asset("assets/icons/nexina_white.png", height: 20),
        ),
        const Text(
          "/",
          style: TextStyle(
            fontSize: 15.0,
            color: Color.fromARGB(255, 180, 180, 180),
            fontFamily: "Inria Sans",
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: const Text(
            "O M N I",
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.white,
              fontFamily: "Inria Sans",
            ),
          ),
        ),
      ],
    );
  }
}
