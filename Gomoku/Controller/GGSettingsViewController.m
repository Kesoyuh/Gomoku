#import "GGSettingsViewController.h"
#import "GGMenuController.h"

@interface GGSettingsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentDifficulty;
@property (weak, nonatomic) IBOutlet UISwitch *switchSound;
@property (weak, nonatomic) IBOutlet UISwitch *switchMusic;

@end

@implementation GGSettingsViewController

- (void)viewDidLoad {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [_segmentDifficulty setSelectedSegmentIndex:[defaults integerForKey:@"difficulty"]];
    [_switchSound setOn:[defaults integerForKey:@"sound"]];
    [_switchMusic setOn:[defaults integerForKey:@"music"]];
    
    [super viewDidLoad];
}

- (IBAction)segementDifficulty_ValueChanged:(UISegmentedControl *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sender.selectedSegmentIndex forKey:@"difficulty"];
    [defaults synchronize];
}

- (IBAction)switchMusic_ValueChanged:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:@(sender.on).integerValue forKey:@"music"];
    [defaults synchronize];
    
    GGMenuController *menuController = (GGMenuController *)self.presentingViewController;
    
    if (sender.on) {
        [menuController.musicPlayer play];
    } else {
        [menuController.musicPlayer pause];
        menuController.musicPlayer.currentTime = 0;
    }
}


- (IBAction)switchSound_ValueChanged:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:@(sender.on).integerValue forKey:@"sound"];
    [defaults synchronize];
    
    GGMenuController *menuController = (GGMenuController *)self.presentingViewController;
    
    if (sender.on) {
        menuController.moveSoundPlayer.volume = 1;
    } else {
        menuController.moveSoundPlayer.volume = 0;
    }
}

- (IBAction)btnBack_TouchUp:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
