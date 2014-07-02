//
//  Constants.h
//  GPSx
//
//  Created by HeartNest on 07/06/14.
//  Copyright (c) 2014 asscubo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Constants <NSObject>

// Attention: the web service links are private and the availability is not GRANTED.
// Develpers are invited to use personal web services.
#define BXSERVER_GETLOCATION @"http://www.boxue.it/LTSocialLab/getlocation.php"
#define BXSERVER_LOGLOC @"http://www.boxue.it/LTSocialLab/updatelocation.php"

// UserDefaults keys
#define SETTING_MYID @"setting_myid"
#define SETTING_FRID @"setting_friendsid"

// Debugging
#define DEBUGMODE 0

// Global parameters
extern NSString *Global_myid;
extern NSString *Global_frid;

@end