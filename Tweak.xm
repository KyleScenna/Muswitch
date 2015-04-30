#import <UIKit/UIKit.h>
#import "MediaRemote.h"

@interface SBAppSwitcherPeopleScrollView : UIScrollView
-(void)removeContent;
@end

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (_Bool)play;
- (_Bool)isPlaying;
- (_Bool)pause;
- (_Bool)isPaused;
- (_Bool)isFirstTrack;
- (_Bool)changeTrack:(int)arg1;
- (id)nowPlayingTitle;
+ (_Bool)applicationCanBeConsideredNowPlaying:(id)arg1;
@end

static SBAppSwitcherPeopleScrollView *peopleScrollView1 = nil;
static UIView *view = nil;
static UIImageView *imageView = nil;
static UIScrollView *peopleScrollView = nil;
static UIView *peopleScrollViewHolder = nil;
static NSMutableString *nowPlayingTitle = [[NSMutableString alloc] init];
static NSMutableString *nowPlayingArtist = [[NSMutableString alloc]init];
static NSMutableString *nowPlayingAlbum = [[NSMutableString alloc]init];
static UIImage *image = nil;
static UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
static UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
static UIButton *fastforwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
static UIButton *rewindButton = [UIButton buttonWithType:UIButtonTypeCustom];
static UILabel *songNameLabel = [[UILabel alloc] init];
static UILabel *artistNameLabel = [[UILabel alloc] init];
static UILabel *artistNameLabelPage = [[UILabel alloc] init];
static UILabel *albumNameLabel = [[UILabel alloc] init];

#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)

@interface CopyMusicListner: NSObject {
}
@end

@implementation CopyMusicListner

+(void)trackDidChange {
    
    
    
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        
        NSDictionary *dict=(__bridge NSDictionary *)(information);
        
        if(dict != NULL && [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle]!= NULL ){
            NSString *nowPlayingTitle_tmp = [[NSString alloc] initWithString:[dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle]];
            if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle] == NULL) {
                [songNameLabel removeFromSuperview];
                [albumNameLabel removeFromSuperview];
                [artistNameLabel removeFromSuperview];
                [artistNameLabelPage removeFromSuperview];
                [imageView removeFromSuperview];
            }
            if(![nowPlayingTitle isEqual:nowPlayingTitle_tmp])
            {
                if(nowPlayingTitle_tmp != NULL){
                    [nowPlayingTitle setString:nowPlayingTitle_tmp];
                    songNameLabel.text = nowPlayingTitle;
                    [songNameLabel removeFromSuperview];
                    [peopleScrollView addSubview:songNameLabel];
                }
            }
            
            if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]!= NULL) {
                image = [UIImage imageWithData:[dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]];
                [imageView removeFromSuperview];
                imageView.image = image;
                [view addSubview:imageView];
            }
            
            if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist]!= NULL) {
                [nowPlayingArtist setString:[dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist]];
                artistNameLabel.text = nowPlayingArtist;
                artistNameLabelPage.text = nowPlayingArtist;
                [artistNameLabelPage removeFromSuperview];
                [artistNameLabel removeFromSuperview];
                [view addSubview:artistNameLabel];
                [peopleScrollView addSubview:artistNameLabelPage];
            }
            if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum]!= NULL) {
                [nowPlayingAlbum setString:[dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum]];
                albumNameLabel.text = nowPlayingAlbum;
                [albumNameLabel removeFromSuperview];
                [view addSubview:albumNameLabel];
            }
            
        }
    });
}
                                   
+ (void)load {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackDidChange) name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
                                       
}
                                   
@end


%group iOS8
%hook SBAppSwitcherPeopleScrollView

- (id)_labelImageParametersForLabelString:(id)arg1 {
    %orig;
    arg1 = nil;
    return nil;
}

%end

%hook SBAppSwitcherPeopleViewController

-(void)switcherWillBePresented:(BOOL)presented {

    %orig;
    
    
    peopleScrollView1 = MSHookIvar<SBAppSwitcherPeopleScrollView*>(self, "_peopleScrollView");
    peopleScrollView1.scrollEnabled = NO;
    CGRect rectSize = peopleScrollView1.frame;
    peopleScrollView = [[UIScrollView alloc] initWithFrame:CGRect(rectSize)];
    [peopleScrollView setContentSize:CGSizeMake(peopleScrollView.bounds.size.width * 2, peopleScrollView.bounds.size.height)];
    [peopleScrollView setPagingEnabled:YES];
    [peopleScrollView setScrollEnabled:YES];
    [peopleScrollView setClipsToBounds:YES];
    peopleScrollView.showsHorizontalScrollIndicator = NO;
    [peopleScrollView1 addSubview:peopleScrollView];

    int imgFrameSize = view.frame.size.width / 4;
    
    CGRect aFrame = peopleScrollView.bounds;
    aFrame.origin.x += peopleScrollView.bounds.size.width;
    view = [[UIView alloc] initWithFrame:aFrame];
    [peopleScrollView addSubview:view];
    
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width / 2 - imgFrameSize / 2, 5, imgFrameSize, imgFrameSize)];
    if (IS_IPHONE_4) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width / 2 - imgFrameSize / 2 + 5, 0, imgFrameSize - 5, imgFrameSize - 5)];
    }
    [view addSubview:imageView];
    [imageView removeFromSuperview];
    
    imageView.image = image;
    [view addSubview:imageView];
    
    
    
    songNameLabel.textAlignment = NSTextAlignmentCenter;
    songNameLabel.textColor = [UIColor whiteColor];
    
    artistNameLabel.textAlignment = NSTextAlignmentCenter;
    artistNameLabel.textColor = [UIColor whiteColor];
    
    artistNameLabelPage.textAlignment = NSTextAlignmentCenter;
    artistNameLabelPage.textColor = [UIColor whiteColor];
    
    albumNameLabel.textAlignment = NSTextAlignmentCenter;
    albumNameLabel.textColor = [UIColor whiteColor];
    
    songNameLabel.text = nowPlayingTitle;
    [peopleScrollView addSubview:songNameLabel];
    
    
    
    artistNameLabel.text = nowPlayingArtist;
    [view addSubview:artistNameLabel];
    
    artistNameLabelPage.text = nowPlayingArtist;
    [peopleScrollView addSubview:artistNameLabelPage];
    
    albumNameLabel.text = nowPlayingAlbum;
    [view addSubview:albumNameLabel];
    

  
    
    // Make a play button and add it to subview.
    
    UIImage *playButtonImage = [[UIImage alloc]initWithContentsOfFile:@"/Library/Application Support/Muswitch/playbutton.png"];
    playButton.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 75 / 2, peopleScrollView.frame.size.height / 3 - 4, 75, 75);
    [playButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [playButton setImage:playButtonImage forState:UIControlStateNormal];
    playButton.contentMode = UIViewContentModeScaleToFill;
    
    
    // Make a pause button and add to subview.
    
    UIImage *pauseButtonImage = [[UIImage alloc]initWithContentsOfFile:@"/Library/Application Support/Muswitch/pausebutton.png"];
    pauseButton.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 75 / 2, peopleScrollView.frame.size.height / 3 - 4, 75, 75);
    [pauseButton addTarget:self action:@selector(pauseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [pauseButton setImage:pauseButtonImage forState:UIControlStateNormal];
    pauseButton.contentMode = UIViewContentModeScaleToFill;
    
    // Make a fast forward button
    UIImage *fastforwardButtonImage = [[UIImage alloc]initWithContentsOfFile:@"/Library/Application Support/Muswitch/fastforwardbutton.png"];
    fastforwardButton.frame = CGRectMake(playButton.frame.origin.x + 65, peopleScrollView.frame.size.height / 3 - 4, 75, 75);
    [fastforwardButton addTarget:self action:@selector(fastBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [fastforwardButton setImage:fastforwardButtonImage forState:UIControlStateNormal];
    fastforwardButton.contentMode = UIViewContentModeScaleToFill;
    
    // Make a rewind button
    
    UIImage *rewindButtonImage = [[UIImage alloc]initWithContentsOfFile:@"/Library/Application Support/Muswitch/rewindbutton.png"];
    rewindButton.frame = CGRectMake(playButton.frame.origin.x - 65, peopleScrollView.frame.size.height / 3 - 4, 75, 75);
    [rewindButton addTarget:self action:@selector(rewindBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rewindButton setImage:rewindButtonImage forState:UIControlStateNormal];
    rewindButton.contentMode = UIViewContentModeScaleToFill;
    
    
    songNameLabel.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 150, playButton.frame.origin.y - 10, 300, 25);
    artistNameLabel.frame = CGRectMake(view.frame.size.width / 2 - 147, imageView.frame.origin.y + imgFrameSize, 300, 25);
    artistNameLabelPage.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 150, playButton.frame.origin.y + 60, 300, 25);
    albumNameLabel.frame = CGRectMake(view.frame.size.width / 2 - 147, artistNameLabel.frame.origin.y + 20, 300, 25);
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    UIInterfaceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) == YES) {
        
        playButton.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 218.5, 0, 75, 75);
        pauseButton.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 218.5, 0, 75, 75);
        if (IS_IPHONE_4) {
            playButton.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 218.5 + 40, 0, 75, 75);
            pauseButton.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 218.5 + 40, 0, 75, 75);
        }
        fastforwardButton.frame = CGRectMake(playButton.frame.origin.x + 65, 0, 75, 75);
        rewindButton.frame = CGRectMake(playButton.frame.origin.x - 65, 0, 75, 75);
        
        songNameLabel.frame = CGRectMake(fastforwardButton.frame.origin.x + 75, 25, 300, 25);
        artistNameLabelPage.frame = CGRectMake(songNameLabel.frame.origin.x, songNameLabel.frame.origin.y + 25, 300, 25);
    
        
        imageView.frame = CGRectMake(0, 0, 90, 90);
        if (IS_IPHONE_4){
            imageView.frame = CGRectMake(0, 0, 80, 80);
        }
        artistNameLabel.frame = CGRectMake(view.frame.size.width / 2 - artistNameLabel.frame.size.width / 2, view.frame.size.height / 3, 300, 25);
        albumNameLabel.frame = CGRectMake(artistNameLabel.frame.origin.x, artistNameLabel.frame.origin.y + 25, 300, 25);
        
        
        if ([[%c(SBMediaController)sharedInstance] isPlaying]) {
            [peopleScrollView addSubview:pauseButton];
        }
        
        else {
            [peopleScrollView addSubview:playButton];
        }
        
        [peopleScrollView addSubview:fastforwardButton];
        [peopleScrollView addSubview:rewindButton];
        
        [view addSubview:imageView];
        [view addSubview:artistNameLabel];
        [view addSubview:albumNameLabel];
}
    
    

    if ([[%c(SBMediaController)sharedInstance] isPlaying]) {
        [peopleScrollView addSubview:pauseButton];
    }
    
    else {
        [peopleScrollView addSubview:playButton];
    }
    
    [peopleScrollView addSubview:fastforwardButton];
    [peopleScrollView addSubview:rewindButton];
    
}


- (long long)peopleScrollView:(id)arg1 numberOfItemsInSection:(long long)arg2 {
    arg2 = 0;
    %orig;
    return 0;
}


%new
-(void)btnClicked:(id)arg1
{
    [[%c(SBMediaController)sharedInstance] play];
    [playButton removeFromSuperview];
    [peopleScrollView addSubview:pauseButton];
    if (nowPlayingTitle == NULL) {
        [[%c(SBMediaController)sharedInstance] isFirstTrack];
    }

}

%new
-(void)pauseBtnClicked:(id)arg1
{
        [((SBMediaController *)[%c(SBMediaController) sharedInstance]) pause];
        [pauseButton removeFromSuperview];
        [peopleScrollView addSubview:playButton];
}

%new
-(void)fastBtnClicked:(id)arg1 {
    [[%c(SBMediaController) sharedInstance] changeTrack:1];
}

%new
-(void)rewindBtnClicked:(id)arg1 {
    [[%c(SBMediaController) sharedInstance] changeTrack:-1];
}
%new
-(void)orientationChanged:(id)arg1 {

    }
   
%end
%end

%group iOS7
%hook SBAppSliderController

- (void)switcherWasPresented:(_Bool)arg1 {
    peopleScrollViewHolder = MSHookIvar<SBAppSwitcherPeopleScrollView*>(self, "_pageView");
    peopleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height / 4)];
    [peopleScrollView setContentSize:CGSizeMake(peopleScrollView.bounds.size.width * 2, peopleScrollView.bounds.size.height)];
    [peopleScrollView setPagingEnabled:YES];
    [peopleScrollView setScrollEnabled:YES];
    [peopleScrollView setClipsToBounds:YES];
    peopleScrollView.showsHorizontalScrollIndicator = NO;
    [peopleScrollViewHolder addSubview:peopleScrollView];
    int imgFrameSize = view.frame.size.width / 4;
    
    CGRect aFrame = peopleScrollView.bounds;
    aFrame.origin.x += peopleScrollView.bounds.size.width;
    view = [[UIView alloc] initWithFrame:aFrame];
    [peopleScrollView addSubview:view];
    
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width / 2 - imgFrameSize / 2, 5, imgFrameSize, imgFrameSize)];
    if (IS_IPHONE_4) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width / 2 - imgFrameSize / 2 + 5, 0, imgFrameSize - 5, imgFrameSize - 5)];
    }
    [view addSubview:imageView];
    
    imageView.image = image;
    [view addSubview:imageView];
    
    
    
    songNameLabel.textAlignment = NSTextAlignmentCenter;
    songNameLabel.textColor = [UIColor whiteColor];
    
    artistNameLabel.textAlignment = NSTextAlignmentCenter;
    artistNameLabel.textColor = [UIColor whiteColor];
    
    artistNameLabelPage.textAlignment = NSTextAlignmentCenter;
    artistNameLabelPage.textColor = [UIColor whiteColor];
    
    albumNameLabel.textAlignment = NSTextAlignmentCenter;
    albumNameLabel.textColor = [UIColor whiteColor];
    
    songNameLabel.text = nowPlayingTitle;
    [peopleScrollView addSubview:songNameLabel];
    
    artistNameLabel.text = nowPlayingArtist;
    [view addSubview:artistNameLabel];
    
    artistNameLabelPage.text = nowPlayingArtist;
    [peopleScrollView addSubview:artistNameLabelPage];
    
    albumNameLabel.text = nowPlayingAlbum;
    [view addSubview:albumNameLabel];
    
    
    
    
    // Make a play button and add it to subview.
    
    UIImage *playButtonImage = [[UIImage alloc]initWithContentsOfFile:@"/Library/Application Support/Muswitch/playbutton.png"];
    playButton.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 75 / 2, peopleScrollView.frame.size.height / 3 - 4, 75, 75);
    [playButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [playButton setImage:playButtonImage forState:UIControlStateNormal];
    playButton.contentMode = UIViewContentModeScaleToFill;
    
    
    // Make a pause button and add to subview.
    
    UIImage *pauseButtonImage = [[UIImage alloc]initWithContentsOfFile:@"/Library/Application Support/Muswitch/pausebutton.png"];
    pauseButton.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 75 / 2, peopleScrollView.frame.size.height / 3 - 4, 75, 75);
    [pauseButton addTarget:self action:@selector(pauseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [pauseButton setImage:pauseButtonImage forState:UIControlStateNormal];
    pauseButton.contentMode = UIViewContentModeScaleToFill;
    
    // Make a fast forward button
    UIImage *fastforwardButtonImage = [[UIImage alloc]initWithContentsOfFile:@"/Library/Application Support/Muswitch/fastforwardbutton.png"];
    fastforwardButton.frame = CGRectMake(playButton.frame.origin.x + 65, peopleScrollView.frame.size.height / 3 - 4, 75, 75);
    [fastforwardButton addTarget:self action:@selector(fastBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [fastforwardButton setImage:fastforwardButtonImage forState:UIControlStateNormal];
    fastforwardButton.contentMode = UIViewContentModeScaleToFill;
    
    // Make a rewind button
    
    UIImage *rewindButtonImage = [[UIImage alloc]initWithContentsOfFile:@"/Library/Application Support/Muswitch/rewindbutton.png"];
    rewindButton.frame = CGRectMake(playButton.frame.origin.x - 65, peopleScrollView.frame.size.height / 3 - 4, 75, 75);
    [rewindButton addTarget:self action:@selector(rewindBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rewindButton setImage:rewindButtonImage forState:UIControlStateNormal];
    rewindButton.contentMode = UIViewContentModeScaleToFill;
    
    
    songNameLabel.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 150, playButton.frame.origin.y - 10, 300, 25);
    artistNameLabel.frame = CGRectMake(view.frame.size.width / 2 - 147, imageView.frame.origin.y + imgFrameSize, 300, 25);
    artistNameLabelPage.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 150, playButton.frame.origin.y + 60, 300, 25);
    albumNameLabel.frame = CGRectMake(view.frame.size.width / 2 - 147, artistNameLabel.frame.origin.y + 20, 300, 25);
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    UIInterfaceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) == YES) {
        
        playButton.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 218.5, 0, 75, 75);
        pauseButton.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 218.5, 0, 75, 75);
        if (IS_IPHONE_4) {
            playButton.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 218.5 + 40, 0, 75, 75);
            pauseButton.frame = CGRectMake(peopleScrollView.frame.size.width / 2 - 218.5 + 40, 0, 75, 75);
        }
        fastforwardButton.frame = CGRectMake(playButton.frame.origin.x + 65, 0, 75, 75);
        rewindButton.frame = CGRectMake(playButton.frame.origin.x - 65, 0, 75, 75);
        
        songNameLabel.frame = CGRectMake(fastforwardButton.frame.origin.x + 75, 25, 300, 25);
        artistNameLabelPage.frame = CGRectMake(songNameLabel.frame.origin.x, songNameLabel.frame.origin.y + 25, 300, 25);
        
        imageView.frame = CGRectMake(0, 0, 90, 90);
        if (IS_IPHONE_4){
            imageView.frame = CGRectMake(0, 0, 80, 80);
        }
        artistNameLabel.frame = CGRectMake(view.frame.size.width / 2 - artistNameLabel.frame.size.width / 2, view.frame.size.height / 3, 300, 25);
        albumNameLabel.frame = CGRectMake(artistNameLabel.frame.origin.x, artistNameLabel.frame.origin.y + 25, 300, 25);
        
        
        if ([[%c(SBMediaController)sharedInstance] isPlaying]) {
            [peopleScrollView addSubview:pauseButton];
        }
        
        else {
            [peopleScrollView addSubview:playButton];
        }
        
        [peopleScrollView addSubview:fastforwardButton];
        [peopleScrollView addSubview:rewindButton];
        
        [view addSubview:imageView];
        [view addSubview:artistNameLabel];
        [view addSubview:albumNameLabel];
    }
    
    
    
    if ([[%c(SBMediaController)sharedInstance] isPlaying]) {
        [peopleScrollView addSubview:pauseButton];
    }
    
    else {
        [peopleScrollView addSubview:playButton];
    }
    
    [peopleScrollView addSubview:fastforwardButton];
    [peopleScrollView addSubview:rewindButton];
    
}
%new
-(void)btnClicked:(id)arg1
{
    [[%c(SBMediaController)sharedInstance] play];
    [playButton removeFromSuperview];
    [peopleScrollView addSubview:pauseButton];
    if (nowPlayingTitle == NULL) {
        [[%c(SBMediaController)sharedInstance] isFirstTrack];
    }
    
}

%new
-(void)pauseBtnClicked:(id)arg1
{
    [((SBMediaController *)[%c(SBMediaController) sharedInstance]) pause];
    [pauseButton removeFromSuperview];
    [peopleScrollView addSubview:playButton];
}

%new
-(void)fastBtnClicked:(id)arg1 {
    [[%c(SBMediaController) sharedInstance] changeTrack:1];
}

%new
-(void)rewindBtnClicked:(id)arg1 {
    [[%c(SBMediaController) sharedInstance] changeTrack:-1];
}
%new
-(void)orientationChanged:(id)arg1 {
    
}

%end
%end

%ctor {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        %init (iOS8);
    } else {
        %init (iOS7);
    }
}










