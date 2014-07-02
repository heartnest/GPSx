//
//  SPAnnotation.m
//  GPSx
//
//  Created by HeartNest on 06/06/14.
//  Copyright (c) 2014 asscubo. All rights reserved.
//

#import "SPAnnotation.h"

@implementation SPAnnotation

@synthesize coordinate;
@synthesize annTitle, annSubTitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate andAnnTitle:(NSString *)theMarkTitle andAnnSubTitle:(NSString *)theMarkSubTitle {
	coordinate = theCoordinate;
    annTitle = theMarkTitle;
    annSubTitle = theMarkSubTitle;
	return self;
}

- (NSString *)title {
    return annTitle;
}

- (NSString *)subtitle {
    return annSubTitle;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    self.coordinate = newCoordinate;
}

@end
