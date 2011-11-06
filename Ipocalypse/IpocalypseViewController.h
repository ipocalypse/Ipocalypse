//
// IpocalypseViewController.h
// Ipocalypse
//
// Created by Grif Priest on 9/9/11.
// Copyright 2011 __MyCompanyName__. All rights reserved.
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
    CLLocationManager *locationManager;
    IBOutlet SM3DARMapView *mapView;
    
    BirdseyeView *birdseyeView;
    
    CLLocationAccuracy desiredLocationAccuracy;
    NSInteger desiredLocationAccuracyAttempts;
    BOOL acceptableLocationAccuracyAchieved;
}

@property (nonatomic, retain) IBOutlet SM3DARMapView *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
- (IBAction) refreshButtonTapped;

@end
