//
//  BirdseyeView.m
//  Birdseye
//
//  Created by P. Mark Anderson on 3/18/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import "BirdseyeView.h"
#import <MapKit/MapKit.h>

#define BEV_DEG2RAD(x) (M_PI * (x) / 180.0)


@implementation BirdseyeView

@synthesize rangeInDegrees;
@synthesize fovInDegrees;
@synthesize locations;
@synthesize centerLocation;

- (void)dealloc 
{
    self.locations = nil;
    self.centerLocation = nil;
    
    [super dealloc];
}

- (id) initWithLocations:(NSArray *)_locations around:(CLLocation *)_centerLocation radiusInPixels:(CGFloat)_radiusInPixels
{
    CGFloat frameSize = _radiusInPixels * 2.0;
    self = [super initWithFrame:CGRectMake(0, 0, frameSize, frameSize)];

    if (self) 
    {
        self.locations = _locations;
        self.centerLocation = _centerLocation;
        
        dotSize = 4.0;  //11.0;
        radiusInPixels = _radiusInPixels;
        fovInDegrees = 50.0;
        maxRangeInDegrees = 1.0;  //1.15;
        minRangeInDegrees = 0.0075;  //0.01;

        //rangeInDegrees = ((maxRangeInDegrees - minRangeInDegrees) / 2.0) + minRangeInDegrees;
        rangeInDegrees = minRangeInDegrees;
        
        self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
        self.alpha = 1.0;
		self.clearsContextBeforeDrawing = YES;   
    }
    
    return self;
}

//
// Returns true if point was out of range and
// changes given point's distance to be
// the view's radius.
//
- (BOOL) makePointInRange:(CGPoint*)point
{
    CGPoint tmpPoint = *point;

    
    // Find distance of point from center.

    CGFloat xlen = tmpPoint.x - radiusInPixels;
    CGFloat ylen = tmpPoint.y - radiusInPixels;
    
    CGFloat distance = sqrtf(xlen * xlen + ylen * ylen);

    CGFloat padding = dotSize / 2.0;    
    
    if (distance < (radiusInPixels - padding))
    {
        return NO;
    }
    

    // Point is beyond radius.  Move it along its line to the boundary.
    
    CGFloat angle = atan2f(ylen, xlen);
    tmpPoint.x = cosf(angle) * (radiusInPixels - padding) + radiusInPixels;
    tmpPoint.y = sinf(angle) * (radiusInPixels - padding) + radiusInPixels;
    
    // TODO: Figure out why points don't line up perfectly with boundary circle.
        
    *point = tmpPoint;
    
    return YES;
}

- (void)drawRect:(CGRect)rect 
{
	CGContextRef context = UIGraphicsGetCurrentContext();

    // Circumscription.

    CGFloat outlineWidth = 1.0;
    CGFloat colorValue = 0.33;
    CGRect circleFrame = CGRectMake(outlineWidth/2, 
                                    outlineWidth/2, 
                                    2*radiusInPixels-outlineWidth, 
                                    2*radiusInPixels-outlineWidth);

    CGContextSetRGBStrokeColor(context, colorValue, colorValue, colorValue, 0.66);
    CGContextSetLineWidth(context, outlineWidth);
    CGContextStrokeEllipseInRect(context, circleFrame);

    CGContextSetRGBFillColor(context, colorValue, colorValue, colorValue, 0.33);
    CGContextFillEllipseInRect(context, circleFrame);
    

    // Draw each dot.
    
    CGRect dotFrame;
    BOOL outOfRange = NO;
    CGFloat x, y;
    
    if (locations)
    {
        for (CLLocation *loc in locations)
        {
            if (![loc respondsToSelector:@selector(coordinate)])
            {
                continue;
            }
            
            CLLocationCoordinate2D coord = loc.coordinate;
            
            // TODO: test at prime meridian.
            
            CLLocationDegrees xDelta = centerLocation.coordinate.longitude - coord.longitude;
            CLLocationDegrees yDelta = centerLocation.coordinate.latitude - coord.latitude;
            
            CGFloat xUnit = -xDelta / rangeInDegrees;
            CGFloat yUnit = yDelta / rangeInDegrees;
            
            x = radiusInPixels + (radiusInPixels * xUnit);
            y = radiusInPixels + (radiusInPixels * yUnit);
            
            
            // Is the point out of range?
            
            CGPoint point = CGPointMake(x, y);
            outOfRange = [self makePointInRange:&point];
            
            //NSLog(@"Adding dot at %.1f, %.1f", point.x, point.y);
            
            CGFloat scaledDotSize;
            
            CGFloat rangeScale = (maxRangeInDegrees - minRangeInDegrees) / (rangeInDegrees - minRangeInDegrees);
            scaledDotSize = dotSize / (5.0 / rangeScale);        
            
            if (outOfRange)
            {
                //    scaledDotSize = dotSize / 3.0;
                //            CGContextSetRGBFillColor(context, 1.0, 0, 0, 0.33);  // red		
                CGContextSetRGBFillColor(context, 1.0, 1.0, 0, 0.33);  
            }
            else
            {
                
                //            CGContextSetRGBFillColor(context, 0.0, 0.55, 0.75, 0.8);  // light blue
                CGContextSetRGBFillColor(context, 1.0, 0.55, 0.75, 0.8);  
            }
            
            if (scaledDotSize < 4.0)
                scaledDotSize = 4.0;
            else if (scaledDotSize > dotSize)
                scaledDotSize = dotSize;
            
            dotFrame = CGRectMake(point.x-(scaledDotSize/2.0), 
                                  point.y-(scaledDotSize/2.0), 
                                  scaledDotSize, 
                                  scaledDotSize);
            
            
            
            // Draw the dot.
            
            CGContextFillEllipseInRect(context, dotFrame);
            
            
            // Draw an outline around the dot.
            
            CGContextSetLineWidth(context, (scaledDotSize/3.0));
            CGContextSetRGBStrokeColor(context, 1.0, 1.0, 0.7, 0.25);
            CGContextStrokeEllipseInRect(context, dotFrame);
            
        }
    }
	
    // Draw user's position in the center.
    
    CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);	
	CGFloat centerPointSize = 5.0;
    CGContextFillRect(context, CGRectMake(radiusInPixels - centerPointSize/2, 
                                          radiusInPixels - centerPointSize/2, 
                                          centerPointSize, 
                                          centerPointSize));
    

    // Draw north pointer.
    
    y = 2;
    CGContextMoveToPoint(context, radiusInPixels, y);
    CGContextAddLineToPoint(context, radiusInPixels-centerPointSize, centerPointSize+y);
    CGContextAddLineToPoint(context, radiusInPixels+centerPointSize, centerPointSize+y);
    
    CGContextFillPath(context);
    
/*
    // Draw FOV.
    
    CGContextMoveToPoint(context, radiusInPixels, radiusInPixels);
    
    CGFloat a = fovInDegrees / 2.0;
    
	CGContextAddArc(context, 
                    radiusInPixels, 
                    radiusInPixels, 
                    radiusInPixels, 
                    BEV_DEG2RAD(-90.0 - a), 
                    BEV_DEG2RAD(-90.0 + a), 
                    0);
	
    CGContextSetRGBFillColor(context, 0.3, 0.3, 0.33, 0.33);	
	CGContextFillPath(context);
*/    
    
}

- (void) moveToScreenPoint:(CGPoint)point
{
    CGRect newFrame = self.frame;
    newFrame.origin.x = point.x - radiusInPixels;
    newFrame.origin.y = point.y - radiusInPixels;
    self.frame = newFrame;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat mid = ((maxRangeInDegrees - minRangeInDegrees) / 15) + minRangeInDegrees;
    
    if (rangeInDegrees == minRangeInDegrees)
        rangeInDegrees = mid;
    else if (rangeInDegrees == mid)
        rangeInDegrees = maxRangeInDegrees;
    else
        rangeInDegrees = minRangeInDegrees;
    
    [self setNeedsDisplay];
}

/*
 - (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event   
{
    UITouch *touch = [touches anyObject];
    
    if ([touch view] != self)
        return;
    
    CGPoint point = [touch locationInView:self];
    
    CGFloat xmax = (2.0 * radiusInPixels);
    
    CGFloat xtouch = point.x;
    if (xtouch < 0.0)
        xtouch = 0.0;
    else if (xtouch > xmax)
        xtouch = xmax;
    
    CGFloat scale = xtouch / xmax;
    
    rangeInDegrees = minRangeInDegrees + ((maxRangeInDegrees - minRangeInDegrees) * scale);
    
    [self setNeedsDisplay];
}
*/

- (void) setCenterLocation:(CLLocation *)newLocation
{
    if (newLocation != centerLocation)
    {
        [centerLocation release];
        centerLocation = [newLocation retain];
    }
    
    [self setNeedsDisplay];
}

- (NSArray *) sanitizeLocations:(NSArray *)newLocations
{
    if (!newLocations)
        return [NSArray array];
    
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[newLocations count]];
    
    for (id loc in newLocations)
    {
        if ([loc isKindOfClass:[CLLocation class]])
        {
            [tmp addObject:loc];
        }
        else if ([loc conformsToProtocol:@protocol(MKAnnotation)])
        {
            id<MKAnnotation> ann = (id<MKAnnotation>)loc;
            CLLocation *l = [[CLLocation alloc] initWithLatitude:ann.coordinate.latitude
                                                       longitude:ann.coordinate.longitude];
            [tmp addObject:l];
            [l release];
        }
    }
    
    return tmp;    
}

- (void) setLocations:(NSArray *)newLocations
{
    if (newLocations != locations)
    {
        [locations release];
        
        locations = [[self sanitizeLocations:newLocations] retain];
    }
    
    [self setNeedsDisplay];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading 
{
    headingInDegrees = newHeading.trueHeading;
    
    if (headingInDegrees < 0.0)
    {
        headingInDegrees = newHeading.magneticHeading;
    }    
}

@end

