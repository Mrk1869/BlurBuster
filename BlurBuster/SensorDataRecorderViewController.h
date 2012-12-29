//
//  SensorDataRecorderViewController.h
//  BlurBuster
//
//  Created by ishimaru on 2012/10/31.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SensorMonitor.h"
#import "FileWriter.h"

@interface SensorDataRecorderViewController : UIViewController<SensorMonitorDelegate>{
    
    __weak IBOutlet UILabel *accelX;
    __weak IBOutlet UILabel *accelY;
    __weak IBOutlet UILabel *accelZ;
    __weak IBOutlet UILabel *gyroX;
    __weak IBOutlet UILabel *gyroY;
    __weak IBOutlet UILabel *gyroZ;
    __weak IBOutlet UILabel *attitudeRoll;
    __weak IBOutlet UILabel *attitudePitch;
    __weak IBOutlet UILabel *attitudeYaw;
    __weak IBOutlet UIButton *startButton;
    __weak IBOutlet UILabel *magnetX;
    __weak IBOutlet UILabel *magnetY;
    __weak IBOutlet UILabel *magnetZ;
    __weak IBOutlet UILabel *numberOfPicturesLabel;
    
    SensorMonitor *sensorMonitor;
    FileWriter *fileWriter;

}

- (IBAction)startButtonPushed:(id)sender;

@end

