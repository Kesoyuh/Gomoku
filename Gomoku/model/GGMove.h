#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GGPlayerType) {
    GGPlayerTypeBlack,
    GGPlayerTypeWhite
};

typedef struct {
    int i;
    int j;
} GGPoint;

@interface GGMove : NSObject

@property (nonatomic, readonly) GGPlayerType playerType;
@property (nonatomic, readonly) GGPoint point;

- (instancetype)initWithPlayer:(GGPlayerType)playerType point:(GGPoint)point;

@end
