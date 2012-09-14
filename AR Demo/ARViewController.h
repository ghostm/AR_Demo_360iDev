//
//  ARViewController.h
//  AR Demo
//
//  Created by Matthew Henderson on 8/26/12.
//  Copyright (c) 2012 Matthew Henderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

@interface ARViewController : UIViewController<CLLocationManagerDelegate, UIAccelerometerDelegate>{
    CMDeviceMotionHandler motionHandler;
    CMMotionManager     *motionManager;
    NSOperationQueue    *opQ;
}
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic) CLLocationDirection currentHeading;

@property (nonatomic, weak) IBOutlet UIView* videoPreview;
@property (nonatomic, weak) IBOutlet UILabel* latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel* longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel* altitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel* headingLabel;
@property (nonatomic, weak) IBOutlet UILabel* accelerometerLabel;
@property (nonatomic, weak) IBOutlet UILabel* rotationLabel;
@property (nonatomic, weak) IBOutlet UILabel* attitudeLabel;

@end
