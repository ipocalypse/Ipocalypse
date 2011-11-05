//
//  BirdseyeView.h
//  Birdseye
//
//  Created by P. Mark Anderson on 3/18/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface BirdseyeView : UIView 
{
    NSArray *locations;
    CLLocation *centerLocation;
    CLLocationDegrees rangeInDegrees;
    CGFloat dotSize;
    CGFloat radiusInPixels;
    CGFloat fovInDegrees;
    CGFloat maxRangeInDegrees;
    CGFloat minRangeInDegrees;
    CLLocationDirection headingInDegrees;
}

@property (nonatomic, assign) CLLocationDegrees rangeInDegrees;
@property (nonatomic, assign) CGFloat fovInDegrees;
@property (nonatomic, retain) CLLocation *centerLocation;
@property (nonatomic, retain) NSArray *locations;

- (id) initWithLocations:(NSArray *)locations around:(CLLocation *)centerLocation radiusInPixels:(CGFloat)radiusInPixels;


@end
