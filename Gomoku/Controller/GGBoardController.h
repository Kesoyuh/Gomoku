#import <UIKit/UIKit.h>
#import "GGBoardView.h"
#import "GGPlayer.h"

@class GCDAsyncSocket;

typedef NS_ENUM(NSInteger, GGMode)
{
    GGModeSingle,
    GGModeDouble,
    GGModeLAN
};

@interface GGBoardController : UIViewController <GGBoardViewDelegate>

@property (weak, nonatomic) IBOutlet GGBoardView *boardView;
@property (assign, nonatomic) enum GGMode gameMode;

@end
