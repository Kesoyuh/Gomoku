#import <Foundation/Foundation.h>
#import "GGMove.h"

typedef NS_ENUM(NSInteger, GGPieceType)
{
    GGPieceTypeBlank,
    GGPieceTypeBlack,
    GGPieceTypeWhite
};

@interface GGBoard : NSObject

- (instancetype)init;
- (void)initBoard;
- (BOOL)canMoveAtPoint:(GGPoint)point;
- (void)makeMove:(GGMove *)move;
- (void)undoMove:(GGMove *)move;
- (BOOL)checkWinAtPoint:(GGPoint)point;
- (GGPoint)findBestPointWithPlayer:(GGPlayerType)playerType;

@end
