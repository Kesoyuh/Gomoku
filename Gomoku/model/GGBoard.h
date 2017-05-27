#import <Foundation/Foundation.h>
#import "GGMove.h"

@interface GGBoard : NSObject

typedef NS_ENUM(NSInteger, GGPieceType)
{
    GGPieceTypeBlank,
    GGPieceTypeBlack,
    GGPieceTypeWhite
};

- (instancetype)init;
- (void)initBoard;
- (BOOL)canMoveAtPoint:(GGPoint)point;
- (void)makeMove:(GGMove *)move;
- (void)undoMove:(GGMove *)move;
- (BOOL)checkWinAtPoint:(GGPoint)point;

@end
