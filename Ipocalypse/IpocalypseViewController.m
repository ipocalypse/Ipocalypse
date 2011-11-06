//
// IpocalypseViewController.m
// Ipocalypse
//
// Created by Grif Priest on 9/9/11.
// Copyright 2011 __MyCompanyName__. All rights reserved.
//
#define IpocQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) 
#define IpocURL [NSURL URLWithString: @"http://www.grif.tv/json.php"] 
#define IDEAL_LOCATION_ACCURACY 10.0

#import <MapKit/MapKit.h>
#import "IpocalypseViewController.h"
#import "Constants.h"

@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
-(NSData*)toJSON;
@end

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;    
}
@end


@interface IpocalypseViewController (Private)
- (void) addBirdseyeView;
@end

@implementation IpocalypseViewController

@synthesize mapView;
@synthesize locationManager;

- (void)dealloc 
{    
    [mapView release];
    mapView = nil;
    
    [birdseyeView release];
    
	[super dealloc];
}

- (void) viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
    
    
    [mapView.sm3dar startCamera];
}

- (void) viewDidLoad 
{
	[super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self addBirdseyeView];
    
    
    [self.view setFrame:[UIScreen mainScreen].bounds];
    [mapView.sm3dar setFrame:self.view.bounds];
    
    dispatch_async(IpocQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: IpocURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    
    [NSThread detachNewThreadSelector:@selector(UploadUserLocation:) toTarget:self withObject:nil];
    
}
-(void) UploadUserLocation:(id)anObject {
    
    
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    
    for (int i=0; i<1000000; i++){
        
        // Upload UID, LAT, and LONG to server
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startUpdatingLocation];
        
        CLLocation *location = [locationManager location];
        CLLocationCoordinate2D coordinate = [location coordinate];
        
        
        NSString *Latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
        NSString *Longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
        NSString *Uid = [[UIDevice currentDevice] uniqueIdentifier];
        NSString *post = [NSString stringWithFormat:@"http://www.grif.tv/add2.php?Uid=%@&Latitude=%@&Longitude=%@", Uid, Latitude, Longitude];
        [NSData dataWithContentsOfURL:[NSURL URLWithString:post]];
        [NSThread sleepForTimeInterval:5.0];
    }
    [NSThread exit];
    
    //we need to do this to prevent memory leaks
    
    [autoreleasepool release];
    
}
- (void)fetchedData:(NSData *)responseData {
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData 
                                                         options:kNilOptions 
                                                           error:&error];
    NSArray* locations = [json objectForKey:@"location"]; 
    
    NSLog(@"location: %@", locations); 
    
    CLLocationCoordinate2D corde;
    //Place User locations on Map and in 3DAR with UID
    
    for (int i=0; i<[locations count]; i++){
        corde.latitude = [[[locations objectAtIndex:i] valueForKey:@"Latitude"]floatValue];
        corde.longitude = [[[locations objectAtIndex:i] valueForKey:@"Longitude"]floatValue];
        NSString *Name = [[locations valueForKey:@"Name"]objectAtIndex:i];
        
  
        
        CLLocation *Location = [[CLLocation alloc] initWithLatitude:corde.latitude longitude:corde.longitude];
        
        SM3DARPointOfInterest *poi = [[SM3DARPointOfInterest alloc] initWithLocation:Location 
                                                                                  title:Name
                                                                               subtitle:nil
                                                                                    url:nil
                                                                             properties:nil];
        
 //       SM3DARTexturedGeometryView *modelView = [[[SM3DARTexturedGeometryView alloc] initWithOBJ:@"star.obj" textureNamed:nil] autorelease];
 //       SM3DARTexturedGeometryView *model2View = [[[SM3DARTexturedGeometryView alloc] initWithOBJ:@"star.obj" textureNamed:nil] autorelease];
        
  //      SM3DARPointOfInterest *poi = (SM3DARPointOfInterest *)[[mapView.sm3dar addPointAtLatitude:corde.latitude
  //                                                                                      longitude:corde.longitude
  //                                                                                       altitude:0
  //                                                                                          title:Name
  //                                                                                           view:modelView] autorelease];
        
        
  //      SM3DARPointOfInterest *poi2 = (SM3DARPointOfInterest *)[[mapView.sm3dar addPointAtLatitude:corde.latitude + 0.0002
   //                                                                                      longitude:corde.longitude + 0.0002
    //                                                                                      altitude:0
     //                                                                                        title:nil
    //                                                                                          view:model2View] autorelease];
    //    [mapView addAnnotation:poi2];
        [mapView addAnnotation:poi];
    }
    
}

- (void)didReceiveMemoryWarning 
{
    NSLog(@"\n\ndidReceiveMemoryWarning\n\n");
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
    NSLog(@"viewDidUnload");
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (IBAction) refreshButtonTapped
{
    
    [birdseyeView setLocations:nil];
    [self.mapView removeAllAnnotations];
    dispatch_async(IpocQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: IpocURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    
}

- (void) addBirdseyeView
{
    CGFloat birdseyeViewRadius = 70.0;
    
    birdseyeView = [[BirdseyeView alloc] initWithLocations:nil
                                                    around:mapView.sm3dar.userLocation 
                                            radiusInPixels:birdseyeViewRadius];
    
    birdseyeView.center = CGPointMake(self.view.frame.size.width - (birdseyeViewRadius) - 10, 
                                      10 + (birdseyeViewRadius));
    
    [self.view addSubview:birdseyeView];
    
    mapView.sm3dar.compassView = birdseyeView;    
}

@end

