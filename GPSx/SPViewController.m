//
//  SPViewController.m
//  Spoter
//
//  Created by HeartNest on 03/06/14.
//  Copyright (c) 2014 asscubo. All rights reserved.
//

#import "SPViewController.h"
#import <CoreLocation/CoreLocation.h>

#import "Model/Constants.h"

@interface SPViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelLng;
@property (weak, nonatomic) IBOutlet UILabel *labelLat;
@property (weak, nonatomic) IBOutlet UILabel *labelAlt;
@property (weak, nonatomic) IBOutlet UILabel *labelSpeed;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelCourse;
@property (weak, nonatomic) IBOutlet UILabel *labelVAccuracy;
@property (weak, nonatomic) IBOutlet UILabel *labelHAccuracy;
@property (weak, nonatomic) NSTimer *myClock;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *cachedLoc;

@property bool shouldGPS;//if we are using GPS
@end

NSString *Global_myid = @"alice";//Default roles
NSString *Global_frid = @"bob";

@implementation SPViewController

static NSString *cellID = @"cellid";

#pragma mark  - view controller life cycle - 

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self configGPSAccuracy];
        [self configRoles];
    } else {
        self.labelLng.text =  @"Location services are not enabled";
        
    }
    
    //radio that detects role change from setting
    [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification*note){
                                                      [self configRoles];
                                                  }];
}


#pragma mark  - GPS switcher -


- (IBAction)toggleGPS:(UIBarButtonItem *)sender {
    if (self.shouldGPS) {
        [sender setTitle:@"Start"];
        self.shouldGPS = NO;
        [self.locationManager stopUpdatingLocation];
        if ([self.myClock isValid]) {
            [self.myClock invalidate];
        }
    }
    else {
        [sender setTitle:@"Stop"];
        self.shouldGPS = YES;
        [self.locationManager startUpdatingLocation];
        
        //uncomment if you wanna update periodically
        //[self startClock];
    }
}


#pragma mark  - accessories -


-(void)startClock{
    if (![self.myClock isValid]) {
        self.myClock= [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(webServerUpdateMyLoc) userInfo:nil repeats:YES];
    }
}


#pragma mark  - Web server call -


-(void)webServerUpdateMyLoc{
    float lng = self.cachedLoc.coordinate.longitude;
    float lat = self.cachedLoc.coordinate.latitude;
    double timestamp = [self.cachedLoc.timestamp timeIntervalSince1970];
    
    //send feed to server
    if (lng != 0 && lat != 0) {
        NSURL *url = [NSURL URLWithString:[BXSERVER_LOGLOC stringByAppendingFormat:@"?u=%@&&lng=%f&&lat=%f&&time=%f",Global_myid,lng,lat,timestamp]];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:nil];
    }
    
}


#pragma mark  - configurations -


-(void)configGPSAccuracy{
    
    unsigned accuracyVal;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id accuracyObj = [userDefaults objectForKey:@"setting_gpsprecision"];
    if (accuracyObj == nil) {
        accuracyVal = -1;
    }else
        accuracyVal = [accuracyObj intValue];
    
    switch (accuracyVal) {
        case 0:
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            break;
        case 1:
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            break;
        case 2:
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            break;
        case 3:
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            break;
        case 4:
            self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
            break;
        default:
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            break;
    }
}

-(void)configRoles{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *myid = [userDefaults objectForKey:@"setting_myid"];
    if (myid != nil) {
        Global_myid = myid;
    }
    NSString *frid = [userDefaults objectForKey:@"setting_friendID"];
    if (frid != nil) {
        Global_frid = frid;
    }
    self.title = Global_myid;
}


#pragma mark  - lcation manager delegates -

//when location is updated
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

    CLLocation *location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        //if event is recent
        self.cachedLoc = location;
        
        self.labelLat.text = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        self.labelLng.text = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        self.labelAlt.text = [NSString stringWithFormat:@"%f", location.altitude];
        self.labelTime.text = [[NSString alloc] initWithFormat:@"%@", location.timestamp ];
        self.labelHAccuracy.text = [[NSString alloc] initWithFormat:@"%f", location.horizontalAccuracy];
        self.labelVAccuracy.text = [[NSString alloc] initWithFormat:@"%f",location.verticalAccuracy];
        
        self.labelSpeed.text = [[NSString alloc] initWithFormat:@"%f meters",location.speed];
        self.labelCourse.text = [[NSString alloc] initWithFormat:@"%f", location.course];
        
        //send my location to web server
        [self webServerUpdateMyLoc];
    }
}

//error handler
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    self.labelLat.text = [error localizedDescription];
}


@end
