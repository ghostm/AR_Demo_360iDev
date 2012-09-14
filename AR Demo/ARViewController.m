//
//  ARViewController.m
//  AR Demo
//
//  Created by Matthew Henderson on 8/26/12.
//  Copyright (c) 2012 Matthew Henderson. All rights reserved.
//

#import "ARViewController.h"

@interface ARViewController ()

@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    captureVideoPreviewLayer.bounds=self.videoPreview.bounds;
    captureVideoPreviewLayer.position=CGPointMake(CGRectGetMidX(self.videoPreview.bounds), CGRectGetMidY(self.videoPreview.bounds));
    [self.videoPreview.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    [session addInput:input];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session startRunning];
    });
    self.locationManager = [[CLLocationManager alloc] init];

    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    // setup delegate callbacks
    self.locationManager.delegate = self;
    
    // Start location services to get the true heading.
    self.locationManager.distanceFilter = 1000;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager startUpdatingLocation];

    // heading service configuration
    self.locationManager.headingFilter =0.5;
    if ([CLLocationManager headingAvailable] == NO) {
        // No compass is available. This application cannot function without a compass,
        // so a dialog will be displayed and no magnetic data will be measured.
        self.locationManager = nil;
        UIAlertView *noCompassAlert = [[UIAlertView alloc] initWithTitle:@"No Compass!"
                                                                 message:@"This device does not have the ability to measure magnetic fields."
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                       otherButtonTitles:nil];
        [noCompassAlert show];
    } else {
        // start the compass
        [self.locationManager startUpdatingHeading];
    }
    
    UIAccelerometer*  theAccelerometer = [UIAccelerometer sharedAccelerometer];
    theAccelerometer.updateInterval = 1 / 50.0;
    theAccelerometer.delegate = self;
    
    // Set up motionManager
    motionManager = [[CMMotionManager alloc]  init];
    motionManager.deviceMotionUpdateInterval = 1.0/60.0;
    opQ = [NSOperationQueue currentQueue];
    if(motionManager.isDeviceMotionAvailable) {
        
        // Listen to events from the motionManager
        motionHandler = ^ (CMDeviceMotion *motion, NSError *error) {
            
            CMAttitude *currentAttitude = motion.attitude;
            self.attitudeLabel.text =
            [NSString stringWithFormat:@"Pitch=%.2f Roll=%.2f Yaw=%.2f",
             currentAttitude.pitch, currentAttitude.roll, currentAttitude.yaw];

            CMRotationRate currentRotation = motion.rotationRate;
            self.rotationLabel.text =
            [NSString stringWithFormat:@"Rotation: X=%.1f Y=%.1f Z=%.1f",
             currentRotation.x, currentRotation.y, currentRotation.z];

        };
        [motionManager startDeviceMotionUpdatesToQueue:opQ withHandler:motionHandler];
    }else{
        self.attitudeLabel.hidden = YES;
        self.rotationLabel.hidden = YES;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0){
        return;
    }
    // Use the true heading if it is valid.
    CLLocationDirection currentHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    self.headingLabel.text = [NSString stringWithFormat:@"%.6f", currentHeading];
}

// This delegate method is invoked when the location managed encounters an error condition.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        // This error indicates that the user has denied the application's request to use location services.
        [manager stopUpdatingHeading];
    } else if ([error code] == kCLErrorHeadingFailure) {
        // This error indicates that the heading could not be determined, most likely because of strong magnetic interference.
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	if (newLocation.horizontalAccuracy <= 0) {
        return;
    }
	self.latitudeLabel.text = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.latitude];
	self.longitudeLabel.text = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.longitude];
	self.altitudeLabel.text = [NSString stringWithFormat:@"%.6f", newLocation.altitude];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    self.accelerometerLabel.text = [NSString stringWithFormat:@"Acceleration: X=%.2f Y=%.2f Z=%.2f", acceleration.x, acceleration.y, acceleration.z];
}

@end
