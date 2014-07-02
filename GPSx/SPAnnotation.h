//
//  SPAnnotation.h
//  GPSx
//
//  Created by HeartNest on 06/06/14.
//  Copyright (c) 2014 asscubo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SPAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *annTitle, *annSubTitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *annTitle, *annSubTitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate andAnnTitle:(NSString *)theannTitle andAnnSubTitle:(NSString *)theannSubTitle;

@end