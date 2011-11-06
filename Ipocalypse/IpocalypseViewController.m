//
//  MainViewController.m
//  Yorient
//
//  Created by P. Mark Anderson on 11/10/09.
//  Copyright Spot Metrix, Inc 2009. All rights reserved.
//
#define IpocQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) 
#define IpocURL [NSURL URLWithString: @"http://www.grif.tv/json.php"] 

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

#define IDEAL_LOCATION_ACCURACY 10.0


@interface IpocalypseViewController (Private)
- (void) addBirdseyeView;
@end

@implementation IpocalypseViewController

@synthesize mapView;


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
    
    [self initSound];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self addBirdseyeView];
    
    
    [self.view setFrame:[UIScreen mainScreen].bounds];
    [mapView.sm3dar setFrame:self.view.bounds];
    
    dispatch_async(IpocQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: IpocURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
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
   //     NSString *Name = [[locations valueForKey:@"Name"]objectAtIndex:i];
        
        
        
    //    SM3DARTexturedGeometryView *modelView = [[[SM3DARTexturedGeometryView alloc] initWithOBJ:@"star.obj" textureNamed:nil] autorelease];
 //       SM3DARTexturedGeometryView *model2View = [[[SM3DARTexturedGeometryView alloc] initWithOBJ:@"star.obj" textureNamed:nil] autorelease];
        
 //       SM3DARPointOfInterest *poi = (SM3DARPointOfInterest *)[[mapView.sm3dar addPointAtLatitude:corde.latitude
   //                                                                                     longitude:corde.longitude
    //                                                                                     altitude:0
     //                                                                                       title:Name
     //                                                                                        view:modelView] autorelease];
        
        
  //      SM3DARPointOfInterest *poi2 = (SM3DARPointOfInterest *)[[mapView.sm3dar addPointAtLatitude:corde.latitude + 0.0002
   //                                                                                      longitude:corde.longitude + 0.0002
    //                                                                                      altitude:0
     //                                                                                        title:nil
    //                                                                                          view:model2View] autorelease];
    //    [mapView addAnnotation:poi2];
    //    [mapView addAnnotation:poi];
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

#pragma mark Data loading



- (void) sm3dar:(SM3DARController *)sm3dar didChangeFocusToPOI:(SM3DARPoint *)newPOI fromPOI:(SM3DARPoint *)oldPOI
{
	[self playFocusSound];
}

- (void) sm3dar:(SM3DARController *)sm3dar didChangeSelectionToPOI:(SM3DARPoint *)newPOI fromPOI:(SM3DARPoint *)oldPOI
{
	NSLog(@"POI was selected: %@", [newPOI title]);
}


- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"callout tapped");
}


#pragma mark Sound
- (void) initSound 
{
	CFBundleRef mainBundle = CFBundleGetMainBundle();
	CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR ("focus2"), CFSTR ("aif"), NULL) ;
	AudioServicesCreateSystemSoundID(soundFileURLRef, &focusSound);
}

- (void) playFocusSound 
{
	AudioServicesPlaySystemSound(focusSound);
} 

#pragma mark -

- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation 
{
    if (!acceptableLocationAccuracyAchieved)
    {
        [mapView zoomMapToFit];
    }
    
    birdseyeView.centerLocation = newLocation;
    
    
}

#pragma mark -


- (void) add3dObjectNortheastOfUserLocation 
{
    SM3DARTexturedGeometryView *modelView = [[[SM3DARTexturedGeometryView alloc] initWithOBJ:@"star.obj" textureNamed:nil] autorelease];
    
    CLLocationDegrees latitude = mapView.sm3dar.userLocation.coordinate.latitude + 0.0005;
    CLLocationDegrees longitude = mapView.sm3dar.userLocation.coordinate.longitude + 0.0005;
    
    
    // Add a point with a 3D 
    
    SM3DARPoint *poi = [[mapView.sm3dar addPointAtLatitude:latitude
                                                 longitude:longitude
                                                  altitude:0 
                                                     title:nil 
                                                      view:modelView] autorelease];
    
    [mapView addAnnotation:(SM3DARPointOfInterest*)poi]; 
}


- (IBAction) refreshButtonTapped
{
    
    [birdseyeView setLocations:nil];
    [self.mapView removeAllAnnotations];
    
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


- (SM3DARPointOfInterest *) movePOI:(SM3DARPointOfInterest *)poi toLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)altitude
{    
    
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    SM3DARPointOfInterest *newPOI = [[SM3DARPointOfInterest alloc] initWithLocation:newLocation 
                                                                              title:poi.title 
                                                                           subtitle:poi.subtitle 
                                                                                url:poi.dataURL 
                                                                         properties:poi.properties];
    
    newPOI.view = poi.view;
    newPOI.delegate = poi.delegate;
    newPOI.annotationViewClass = poi.annotationViewClass;
    newPOI.canReceiveFocus = poi.canReceiveFocus;
    newPOI.hasFocus = poi.hasFocus;
    newPOI.identifier = poi.identifier;
    newPOI.gearPosition = poi.gearPosition;
    
    
    id oldAnnotation = [mapView annotationForPoint:poi];
    
    if (oldAnnotation)
    {
        [mapView removeAnnotation:oldAnnotation];
        [mapView addAnnotation:newPOI];
    }
    else
    {
        [mapView.sm3dar removePointOfInterest:poi];
        [mapView.sm3dar addPointOfInterest:newPOI];
    }
    
    [newLocation release];
    [newPOI release];
    
    return newPOI;
}


@end

