import 'package:chess_game/components/pieces.dart';
import 'package:flutter/material.dart';

import '../helper/helper_methods.dart';
import '../values/colors.dart';

class Square extends StatelessWidget {
  final bool iswhite;
  final ChessPiece? piece;
  final bool isSelected;
  final void Function()? onTap;
  final bool isValidMove;

  const Square(
      {super.key,
      required this.iswhite,
      required this.piece,
      required this.isSelected,
      required this.onTap,
      required this.isValidMove});

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.blue;
    } else if (isValidMove) {
      squareColor = Colors.blue[600];
    } else {
      squareColor = iswhite ? foregroundcolor : backgroundcolor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
          color: squareColor,
          // color kuranj kuranj varan
          margin: EdgeInsets.all(isValidMove ? 8 : 0),
          child: piece != null
              ? Image.asset(
                  piece!.imagePath,
                  color: piece!.isWhite ? Colors.white : Colors.black,
                )
              : null),
    );
  }
}
