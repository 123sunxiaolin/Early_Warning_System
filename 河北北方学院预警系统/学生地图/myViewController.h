//
//  myViewController.h
//  map
//
//  Created by zhaicongcong on 4/17/14.
//  Copyright (c) 2014 zhaicongcong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "firstViewController.h"

#import "VPPMapHelperDelegate.h"
#import "VPPMapHelper.h"
@interface myViewController : UIViewController<CLLocationManagerDelegate,AVAudioRecorderDelegate,VPPMapHelperDelegate>
{
    CLLocationManager *locationManager;
     NSArray *arrimg;
    CLLocationCoordinate2D coordinate;
}



@end
