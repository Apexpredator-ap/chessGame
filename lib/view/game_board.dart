import 'dart:core';

import 'package:chess_game/components/pieces.dart';
import 'package:chess_game/values/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/dead_piece.dart';
import '../components/square.dart';
import '../helper/helper_methods.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // A 2d list contain each possible move

  late List<List<ChessPiece?>> board;

// currently piece selected on the chess board

  ChessPiece? selectedpiece;

  // row index of the selected piece
  // -1 means no piece is selected

  int selectedRow = -1;

// col index of the selected piece
  // -1 means no piece is selected
  int selectedCol = -1;

// A list of valid moves for the currently selected piece
  // each move is represented as a list with 2 elements: row and col

  List<List<int>> validMoves = [];

// a list of white pieces that has been taken by black
  List<ChessPiece> whitepiecesTaken = [];

// a list of black pieces that has been taken by white
  List<ChessPiece> blackpiecesTaken = [];

  /// A boolean to indicate whose turn is
  bool isWhiteturn = true;

// initial postion of king (keep track of this to make it easier later to see if king is in check)
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    _initializedBoard();
    super.initState();
  }

  /// Intialize board

  void _initializedBoard() {
// initialize board with null
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    ///pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChesspieceType.pawn,
          isWhite: false,
          imagePath: "assets/pawn.png");
    }

    for (int i = 0; i < 8; i++) {
      newBoard[6][i] = ChessPiece(
          type: ChesspieceType.pawn,
          isWhite: true,
          imagePath: "assets/pawn.png");
    }

    ///rook
    newBoard[0][0] = ChessPiece(
        type: ChesspieceType.rook,
        isWhite: false,
        imagePath: "assets/Rook.png");

    newBoard[0][7] = ChessPiece(
        type: ChesspieceType.rook,
        isWhite: false,
        imagePath: "assets/Rook.png");

    newBoard[7][0] = ChessPiece(
        type: ChesspieceType.rook, isWhite: true, imagePath: "assets/Rook.png");

    newBoard[7][7] = ChessPiece(
        type: ChesspieceType.rook, isWhite: true, imagePath: "assets/Rook.png");

    ///kinght
    newBoard[0][1] = ChessPiece(
        type: ChesspieceType.knight,
        isWhite: false,
        imagePath: "assets/knight .png");

    newBoard[0][6] = ChessPiece(
        type: ChesspieceType.knight,
        isWhite: false,
        imagePath: "assets/knight .png");

    newBoard[7][1] = ChessPiece(
        type: ChesspieceType.knight,
        isWhite: true,
        imagePath: "assets/knight .png");

    newBoard[7][6] = ChessPiece(
        type: ChesspieceType.knight,
        isWhite: true,
        imagePath: "assets/knight .png");

    ///bishop
    newBoard[0][2] = ChessPiece(
        type: ChesspieceType.bishop,
        isWhite: false,
        imagePath: "assets/Bishop.png");

    newBoard[0][5] = ChessPiece(
        type: ChesspieceType.bishop,
        isWhite: false,
        imagePath: "assets/Bishop.png");

    newBoard[7][2] = ChessPiece(
        type: ChesspieceType.bishop,
        isWhite: true,
        imagePath: "assets/Bishop.png");

    newBoard[7][5] = ChessPiece(
        type: ChesspieceType.bishop,
        isWhite: true,
        imagePath: "assets/Bishop.png");

    ///queen
    newBoard[0][3] = ChessPiece(
        type: ChesspieceType.queen,
        isWhite: false,
        imagePath: "assets/Queen.png");

    newBoard[7][3] = ChessPiece(
        type: ChesspieceType.queen,
        isWhite: true,
        imagePath: "assets/Queen.png");

    ///kings

    newBoard[0][4] = ChessPiece(
        type: ChesspieceType.king,
        isWhite: false,
        imagePath: "assets/king.png");

    newBoard[7][4] = ChessPiece(
        type: ChesspieceType.king, isWhite: true, imagePath: "assets/king.png");

    board = newBoard;
  }

// user selected a piece

  void pieceSelected(int row, int col) {
    setState(() {
      // No piece has been selected yet, this is the first selection

      if (selectedpiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteturn) {
          selectedpiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }

        // There is a piece already selected  but user can select another one of their pieces
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedpiece!.isWhite) {
        selectedpiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      //if there is a piece selected and user taps on a screen that is valid move,move there

      else if (selectedpiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }
      validMoves = calculatedRealValidmoves(
          selectedRow, selectedCol, selectedpiece, true);
    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }
    // different direction based on their color
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChesspieceType.pawn:

        /// frontil pokam

        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        /// 2 square forward pokam ,first positionil nikkumbo

        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        /// diagonally vettam
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChesspieceType.rook:

        /// horizontal and vertical

        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); ////kollan
              }
              break; //block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChesspieceType.knight:

        /// 8 possible L shapes
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // capture
            }
            continue; //blocked
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      case ChesspieceType.bishop:
        var directions = [
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1] // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //capture
              }
              break; // block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChesspieceType.queen:
        // 8 directions : up , down,left,right, and 4 diagonals

        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], //  left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up  right
          [1, -1], // down left
          [1, 1], // down  right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //capture
              }
              break; // block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChesspieceType.king:
        // All 8 directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], //  left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up  right
          [1, -1], // down left
          [1, 1], // down  right
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); //capture
            }
            continue; // block
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      default:
    }
    return candidateMoves;
  }

  /// Calculate Real valid moves

  List<List<int>> calculatedRealValidmoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidmoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

// after generating all candidate moves,filter out any that would result in a check
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
// this will simulate the future move to see if it's safe
        if (simulatedMoveIssafe(piece!, row, col, endRow, endCol)) {
          realValidmoves.add(move);
        }
      }
    } else {
      realValidmoves = candidateMoves;
    }
    return realValidmoves;
  }

  void movePiece(int newRow, int newCol) {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitepiecesTaken.add(capturedPiece);
      } else {
        blackpiecesTaken.add(capturedPiece);
      }
    }
// check if the piece being moved in a king
    if (selectedpiece!.type == ChesspieceType.king) {
      // update the appropriate king pos
      if (selectedpiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // piece move cheyyukayum venam athe pole ath irunna place clear akkukayum venam
    board[newRow][newCol] = selectedpiece;
    board[selectedRow][selectedCol] = null;

    // see if any king is under attack
    if (isKingInCheck(!isWhiteturn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    ///clear cheyyan
    setState(() {
      selectedpiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // check if it's check mate
    if (isCheckMate(!isWhiteturn)) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                title: Text("CHECK MATE !!!!"),
                actions: [
                  // Play again
                  TextButton(onPressed: resetGame, child: Text("Play Again"))
                ],
              ));

      // Dialog(
      //   elevation: 0,
      //   backgroundColor: Colors.limeAccent,
      //   shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(30.0)),
      //   child: Container(
      //     height: 300,
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //
      //         Text(
      //           "CHECK MATE !!!",
      //           style: TextStyle(fontSize: 20),
      //         ),
      //         ElevatedButton(
      //             onPressed:()=> resetGame(),
      //             child: Text("Play Again"))
      //       ],
      //     ),
      //   ),
      // );
    }
    isWhiteturn = !isWhiteturn;
  }

  bool isKingInCheck(bool isWhiteKing) {
    //get the position of the king

    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;
    // check if any enemy piece can attack the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        //skip empty square and pieces of the same color as the king
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculatedRealValidmoves(i, j, board[i][j], false);
        // check if the kings position is in this piece's valid moves

        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  // Simulated a future move to see if it's safe (doesn't put your own king under attack)
  bool simulatedMoveIssafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    // save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];
    // if the piece is the king ,save it's current position and update to the new one
    List<int>? originalKingPosition;
    if (piece.type == ChesspieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;
      // update the king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // check if our own king is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    // restore board to original state

    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    if (piece.type == ChesspieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }
    // if king is in check = true, means it's not a safe move. safe move = false
    return !kingInCheck;
  }

  bool isCheckMate(bool isWhiteKing) {
    // if the king is not in check ,then it's not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }
// if there is at least one legal move for any of the player's pieces,then it's not checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip empty square and pieces of the other color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculatedRealValidmoves(i, j, board[i][j], true);
        // if this piece has any valid noves,then it's not checkmate

        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

// if none of the above condition are met, there are no legal moves left to make
// it's check mate

    return true;
  }

  ///Reset Game
  void resetGame() {
    Navigator.pop(context);
    _initializedBoard();
    checkStatus = false;
    whitepiecesTaken.clear();
    blackpiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteturn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundcolor,
      body: Column(
        children: [
          /// white pieces taken

          Expanded(
              child: GridView.builder(
                  itemCount: whitepiecesTaken.length,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                        imagepath: whitepiecesTaken[index].imagePath,
                        isWhite: true,
                      ))),

          /// Game Status

          Text(checkStatus ? "CHECK !!!" : "",style:GoogleFonts.almendraSc(fontSize: 20,fontWeight: FontWeight.bold,color:Colors.grey),),


          Expanded(
            flex: 3,
            child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                itemCount: 8 * 8,
                itemBuilder: (context, index) {
                  int row = index ~/ 8;
                  int col = index % 8;
                  // check if this square is selected
                  bool isSelected = selectedRow == row && selectedCol == col;

                  // check if this is a valid move
                  bool isValidMove = false;
                  for (var position in validMoves) {
                    // compare row and column
                    if (position[0] == row && position[1] == col) {
                      isValidMove = true;
                    }
                  }

                  return Square(
                    iswhite: isWhite(index),
                    piece: board[row][col],
                    isSelected: isSelected,
                    onTap: () => pieceSelected(row, col),
                    isValidMove: isValidMove,
                  );
                }),
          ),

          ///Black Pieces Taken
          Expanded(
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: blackpiecesTaken.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                        imagepath: blackpiecesTaken[index].imagePath,
                        isWhite: false,
                      ))),
        ],
      ),

    );

  }
}
