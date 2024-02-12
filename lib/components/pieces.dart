enum ChesspieceType { pawn, rook, knight, bishop, queen, king }

class ChessPiece {
  final ChesspieceType type;
  final bool isWhite;
  final String imagePath;

  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.imagePath,
  });
}
