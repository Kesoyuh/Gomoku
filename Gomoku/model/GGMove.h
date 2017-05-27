#import <Foundation/Foundation.h>

@interface GGMove : NSObject

typedef NS_ENUM(NSInteger, GGPlayerType)
{
    GGPlayerTypeBlack,
    GGPlayerTypeWhite
};

typedef struct {
    int i;
    int j;
} GGPoint;

@property (nonatomic, readonly) GGPlayerType player;
@property (nonatomic, readonly) GGPoint point;

- (instancetype)initWithPlayer:(GGPlayerType)player point:(GGPoint)point;

@end
