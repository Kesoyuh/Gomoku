#import "GGBoard.h"

static int const BOARD_SIZE = 15;

@interface GGBoard ()
{
    GGPieceType _board[BOARD_SIZE][BOARD_SIZE];
}

@end

@implementation GGBoard

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initBoard];
    }
    
    return self;
}

- (void)initBoard {
    for (int i = 0; i < BOARD_SIZE; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            _board[i][j] = GGPieceTypeBlank;
        }
    }
}

- (BOOL)canMoveAtPoint:(GGPoint)point {
    return _board[point.i][point.j] == GGPieceTypeBlank;
}

- (void)makeMove:(GGMove *)move {
    GGPoint point = move.point;
    if ([self canMoveAtPoint:point]) {
        if (move.player == GGPlayerTypeBlack) {
            _board[point.i][point.j] = GGPieceTypeBlack;
        } else {
            _board[point.i][point.j] = GGPieceTypeWhite;
        }
    }
}

- (void)undoMove:(GGMove *)move {
    GGPoint point = move.point;
    _board[point.i][point.j] = GGPieceTypeBlank;
}

- (BOOL)checkWinAtPoint:(GGPoint)point {
    int count = 1;
    int i = point.i;
    int j = point.j;
    
    // Horizontal
    for (j++; j < BOARD_SIZE; j++) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    j = point.j;
    for (j--; j >= 0; j--) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Vertical
    i = point.i;
    j = point.j;
    for (i++; i < BOARD_SIZE; i++) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    i = point.i;
    for (i--; i >= 0; i--) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Oblique up
    i = point.i + 1;
    j = point.j + 1;
    for (; i < BOARD_SIZE && j < BOARD_SIZE; i++, j++) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    i = point.i - 1;
    j = point.j - 1;
    for (; i >= 0 && j >= 0; i--, j--) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Oblique down
    i = point.i + 1;
    j = point.j - 1;
    for (; i < BOARD_SIZE && j >= 0; i++, j--) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    i = point.i - 1;
    j = point.j + 1;
    for (; i >= 0 && j < BOARD_SIZE; i--, j++) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        return NO;
    }
}

@end
