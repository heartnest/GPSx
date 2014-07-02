//
//  MPViewController.m
//  GPSx
//
//  Created by HeartNest on 07/06/14.
//  Copyright (c) 2014 asscubo. All rights reserved.
//

#import "MPViewController.h"
#import <MapKit/MapKit.h>
#import "SPAnnotation.h"
#import "CalViewController.h"
#import "Model/Constants.h"

@interface MPViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong,nonatomic) SPAnnotation *friendAnnotation;
@property (strong,nonatomic) CLLocation *cachedUserLocation;//my position
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toCalButt;//calculate button
@property (nonatomic) float dist;
@end

NSString *Global_myid;
NSString *Global_frid;

@implementation MPViewController



#pragma mark - View Contoller Lifecycle -


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.toCalButt.enabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(webServerLoadFriendLocation) userInfo:nil repeats:YES];
}



#pragma mark - MKMapView Delegates -


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    [self adjustMapViewWindow];
}


//event when locaiton is updated (RUN ONLY in foreground)
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    //update cache
    self.cachedUserLocation =  userLocation.location;
    [self calcDistance];
    
    //NSLog(@"updated user location ");
    [self webServerUpdateMyLocation];
    [self adjustMapViewWindow];
}




#pragma mark - Accessories -

-(void)adjustMapViewWindow{
    //zoom to fit size
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    if (!MKMapRectIsEmpty(zoomRect)) {
        [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(80, 80, 80, 80) animated:YES];
    }
}


//calculate and disply the distance
-(void)calcDistance{
    if (self.friendAnnotation != nil) {
        CLLocation *spLocation = [[CLLocation alloc]
                                  initWithLatitude:self.friendAnnotation.coordinate.latitude
                                  longitude:self.friendAnnotation.coordinate.longitude];
        
        CLLocationDistance distance = [self.cachedUserLocation distanceFromLocation:spLocation];
        self.title = [[NSString alloc]initWithFormat:@"distance: %d meters",(int)distance];
        self.dist = distance;
        self.toCalButt.enabled = YES;
    }
}



#pragma mark - Web Server Calls -

//get friend's location
- (void)webServerLoadFriendLocation
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *url = [NSURL URLWithString:[BXSERVER_GETLOCATION stringByAppendingFormat:@"?u=%@",Global_frid]];

        if (DEBUGMODE == 1){
            NSLog(@"str 1 %@", [url absoluteString]);
        }
        
        NSError *error = nil;
        NSData *data = nil;
        @try {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            data = [NSData dataWithContentsOfURL:url options:0 error:&error];
            
        }
        @catch (NSException *exception) {
            NSLog(@"Caught Exception: %@", exception.reason);
        }
        @finally{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        NSArray *array;
        if (data != nil)
            array = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![[[array lastObject] objectForKey:@"lat"] isKindOfClass: [NSNull class]]) {
                
                float lat = [[[array lastObject] objectForKey:@"lat"] floatValue];
                float lng = [[[array lastObject] objectForKey:@"lng"] floatValue];
                float rawtime = [[[array lastObject] objectForKey:@"ts"] floatValue];
                
                if (lat != 0) {
                    
                    NSDate *ldate = [NSDate dateWithTimeIntervalSince1970:rawtime];
                    
                    NSDateFormatter *format = [[NSDateFormatter alloc] init];
                    [format setTimeZone:[NSTimeZone localTimeZone]];
                    [format setDateFormat:@"HH:mm dd/LLL"];
                    NSString *dateString = [format stringFromDate:ldate];
                    
                    CLLocationCoordinate2D coord = {
                        .latitude = lat,
                        .longitude = lng};
                    
                    if (self.friendAnnotation.coordinate.latitude != lat || self.friendAnnotation.coordinate.longitude != lng) {
                        [self.mapView removeAnnotation:self.friendAnnotation];
                        self.friendAnnotation = [[SPAnnotation alloc]
                                                 initWithCoordinate:coord
                                                 andAnnTitle:Global_frid
                                                 andAnnSubTitle:dateString];
                        
                        [self.mapView addAnnotation:self.friendAnnotation];
                        [self calcDistance];
                    }
                }
            }else{
                self.title = @"no friend ...";
            }
            
        });
        
    });
}

//send my location
-(void)webServerUpdateMyLocation{
    
    double timestamp = [self.cachedUserLocation.timestamp timeIntervalSince1970];
    if (self.cachedUserLocation.coordinate.longitude != 0) {
        NSURL *url2 = [NSURL URLWithString:[BXSERVER_LOGLOC stringByAppendingFormat:@"?u=%@&&lng=%f&&lat=%f&&time=%f",Global_myid,self.cachedUserLocation.coordinate.longitude,self.cachedUserLocation.coordinate.latitude,timestamp]];
        
        if (DEBUGMODE) {
            NSLog(@"str 2 %@", [url2 absoluteString]);
        }
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url2 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:nil];
        
    }
}


#pragma mark - Navigational View Controller Delegate -

//go to unit number calculation page
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {

        if ([segue.identifier isEqualToString:@"to calculate"]) {
            if ([segue.destinationViewController respondsToSelector:@selector(setTargetDistance:)])
            {
                CalViewController *cvc = segue.destinationViewController;
                [cvc setTargetDistance:self.dist];
            }
        }
        
    }
}



@end
