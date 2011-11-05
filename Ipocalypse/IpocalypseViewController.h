//
//  IpocalypseViewController.h
//  Ipocalypse
//
//  Created by Grif on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "SM3DAR.h" 
#import "AudioToolbox/AudioServices.h"
#import <MapKit/MapKit.h>
#import "BirdseyeView.h"

@interface IpocalypseViewController : UIViewController <MKMapViewDelegate, SM3DARDelegate, CLLocationManagerDelegate> 
{
	SystemSoundID focusSound;
    BOOL sm3darInitialized;
    
    IBOutlet SM3DARMapView *mapView;
    
    BirdseyeView *birdseyeView;
    
    CLLocationAccuracy desiredLocationAccuracy;
    NSInteger desiredLocationAccuracyAttempts;
    BOOL acceptableLocationAccuracyAchieved;
}

@property (nonatomic, retain) IBOutlet SM3DARMapView *mapView;

- (void)initSound;
- (void)playFocusSound;
- (IBAction) refreshButtonTapped;

@end
