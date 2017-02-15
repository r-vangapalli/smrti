#import "ASTrackListViewController.h"

#import <ReactiveObjC.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NSDate+as.h"
#import "ASTrack.h"
#import "ASTrackPropertiesViewController.h"
#import "ASTrackProperties.h"

@interface ASTrackListViewController () <MPMediaPickerControllerDelegate, ASTrackPropertiesViewControllerDelegate>

@property(nonatomic, strong) NSMutableArray<ASTrack *> *trackList;
@property(nonatomic, weak) ASTrack *currentEditTrack;

@end

@implementation ASTrackListViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _trackList = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    [RACObserve(self, trackList) subscribeNext:^(NSMutableArray * trackList) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    [self loadTracks];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTrack:(id)track {
    // dummy method to fool xcode and avoid warnings!
}

- (IBAction)addProject {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    NSMutableArray *fromKVC = [self mutableArrayValueForKey:@"trackList"];
    ASTrack *track = [[ASTrack alloc] initWithMediaItem:mediaItemCollection.items[0]];
    [fromKVC addObject:track];
    self.currentEditTrack = track;

    @weakify(self);
    [mediaPicker dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        [self performSegueWithIdentifier:@"toTrackProperties" sender:self];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trackList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"projectCell" forIndexPath:indexPath];

    ASTrack *track  = [self.trackList objectAtIndex:indexPath.item];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", track.name, [NSDate formatTimeInterval:track.mediaItem.playbackDuration]];
    cell.imageView.image = [track.mediaItem.artwork imageWithSize:cell.imageView.bounds.size];

    return cell;
}

 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *fromKVC = [self mutableArrayValueForKey:@"trackList"];
        [fromKVC removeObjectAtIndex:indexPath.item];
        [self saveTracks];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Table view delegate
/*
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 // TODO
 }
 */

 #pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *to = segue.destinationViewController;
    if ([@"toTrackDetails" isEqualToString:segue.identifier]) {
        if ([to respondsToSelector:@selector(setTrack:)])
        {
            NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
            [to performSelector:@selector(setTrack:) withObject:[self.trackList objectAtIndex:selectedIndexPath.item]];
        }
    } else if ([@"toTrackProperties" isEqualToString:segue.identifier]) {
        ASTrackPropertiesViewController *vc = (ASTrackPropertiesViewController *)to;
        vc.mediaItem = self.currentEditTrack.mediaItem;
        vc.delegate = self;
    }
}

#pragma mark - ASTrackPropertiesViewControllerDelegate

- (void)trackPropertiesViewController:(ASTrackPropertiesViewController *)trackPropertiesViewController willCloseWithProperties:(ASTrackProperties *)properties {
    if (self.currentEditTrack) {
        [self.currentEditTrack configWithProperties:properties];
    }
}

-(void)appWillResignActive:(NSNotification*)notification
{
    [self saveTracks];
}

-(void)saveTracks {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.trackList];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"trackList"];
    [defaults synchronize];

}

- (void)loadTracks {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"trackList"];
    NSArray *temp = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    self.trackList = [NSMutableArray arrayWithArray:temp];
    [self.tableView reloadData];
}

@end
