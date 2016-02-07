//
//  NSObject_MPMusicPlayingController_Methods.h
//  Treble
//
//  Created by Andy Liang on 2016-02-05.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MPMediaQuery.h>
#import <MediaPlayer/MPVolumeView.h>

@interface MPMusicPlayerController (Private)

-(int)numberOfItems;
-(MPMediaQuery*)queueAsQuery;

@end