//
//  ViewController.m
//  LatLon
//
//  Created by Dav Yaginuma on 5/24/12.
//  Copyright (c) 2012 Sekai No. All rights reserved.
//

#import "ViewController.h"
#import "CoreLocation/CLLocationManagerDelegate.h"
#import <MapKit/MapKit.h>

@interface ViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager* locationManager;
@end

@implementation ViewController

@synthesize locationManager=_locationManager, refreshButton, coordinatesLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction) refreshTapped:(id)sender {
  [self.locationManager startUpdatingLocation];
  [self performSelector:@selector(timerStopUpdatingLocation) withObject:@"Timed Out" afterDelay:30.0];
}

#pragma mark -

- (CLLocationManager *) locationManager {
	if (_locationManager == nil) {
		_locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
	}
	return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  NSLog(@"Location determined to be: %@", newLocation);
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timerStopUpdatingLocation) object:@"Timed Out"];
  
	// test the age of the location measurement to determine if the measurement is cached
	// in most cases you will not want to rely on cached measurements
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
  if (locationAge > 120.0) {
    NSLog(@"Location received is too old: %f", locationAge);
    return;
  }
  
	// test that the horizontal accuracy does not indicate an invalid measurement
	if (newLocation.horizontalAccuracy < 0) return;
	
  NSString* coordinateString = [NSString stringWithFormat:@"%f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
  self.coordinatesLabel.text = coordinateString;
  
  UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
  if (pasteboard) {
    NSLog(@"Storing coordinate in pasteboard %@", pasteboard);
    pasteboard.string = coordinateString;
  }
  
  [self stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  NSLog(@"Location Manager did fail with error: %@", [error localizedDescription]);
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timerStopUpdatingLocation) object:@"Timed Out"];
  switch([error code]) {
    case kCLErrorLocationUnknown:
      // The location "unknown" error simply means the manager is currently unable to get the location.
      // We can ignore this error for the scenario of getting a single location fix, because we already have a 
      // timeout that will stop the location manager to save power.
      break;
    case kCLErrorDenied:
      // Looks like the user has denied location access for the app
      self.coordinatesLabel.text = @"Error: Location access denied";
      [self stopUpdatingLocation];
      break;
    case kCLErrorNetwork: {
      self.coordinatesLabel.text = @"Error: check network";
    }
    default:
      [self stopUpdatingLocation];
      break;
  }
}

- (void) timerStopUpdatingLocation {
  [self stopUpdatingLocation];
}

- (void) stopUpdatingLocation {
	[self.locationManager stopUpdatingLocation];
	self.locationManager.delegate = nil;
}

@end
