//
//  ViewController.h
//  LatLon
//
//  Created by Dav Yaginuma on 5/24/12.
//  Copyright (c) 2012 Sekai No. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property IBOutlet UILabel* coordinatesLabel;
@property IBOutlet UIButton* refreshButton;

- (IBAction) refreshTapped:(id)sender;

@end
