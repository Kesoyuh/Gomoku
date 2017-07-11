#import "GGMove.h"

static int const GRID_SIZE = 15;

typedef NS_ENUM(NSInteger, GGPieceType)
{
    GGPieceTypeBlank,
    GGPieceTypeBlack,
    GGPieceTypeWhite
};

@interface GGBoard : NSObject
{
    @protected
    GGPieceType _grid[GRID_SIZE][GRID_SIZE];
}

- (instancetype)init;
- (void)initBoard;
- (BOOL)isEmpty;
- (BOOL)canMoveAtPoint:(GGPoint)point;
- (void)makeMove:(GGMove *)move;
- (void)undoMove:(GGMove *)move;
- (BOOL)checkWinAtPoint:(GGPoint)point;

- (GGMove *)findBestMove;

@end
