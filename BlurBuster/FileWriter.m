//
//  FileWriter.m
//  BlurBuster
//
//  Created by ishimaru on 2012/11/01.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import "FileWriter.h"

NSString* const kAccelerometerFileAppendix = @"Accel";
NSString* const kGyroscopeFileAppendix = @"Gyro";
NSString* const kTimestampAppendix = @"Timestamp";

NSDictionary *exifDictionary;

double lowPath_accelX;
double lowPath_accelY;
double lowPath_accelZ;
double lowPath_gyroX;
double lowPath_gyroY;
double lowPath_gyroZ;
double lowPath_gyroRoll;
double lowPath_gyroPitch;
double lowPath_gyroYaw;
double filteringFactor;

@implementation FileWriter

@synthesize currentFilePrefix, currentRecordingDirectory, currentRecordingDirectoryForPicture;
@synthesize accelerometerFileName;
@synthesize gyroFileName;
@synthesize timestampFileName;

-(id)init{
    self = [super init];
    if(self != nil){
        fileManager = [[NSFileManager alloc]init];
        isRecording = false;
        filteringFactor = 0.1;
    }
    return self;
}

-(void)dealloc{
    [self stopRecording];
}

-(void)startRecording{
    
    if(!isRecording){

        NSDate *now = [NSDate date];
        self.currentFilePrefix = [[now description] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths lastObject];
        self.currentRecordingDirectory = [documentDirectory stringByAppendingPathComponent:self.currentFilePrefix];
        [fileManager createDirectoryAtPath:self.currentRecordingDirectory withIntermediateDirectories:NO attributes:nil error:NULL];
        self.currentRecordingDirectoryForPicture = [[documentDirectory stringByAppendingPathComponent:self.currentFilePrefix] stringByAppendingPathComponent:@"picture"];
        [fileManager createDirectoryAtPath:self.currentRecordingDirectoryForPicture withIntermediateDirectories:NO attributes:nil error:NULL];
        
        //reset currentFilePrefix
        currentFilePrefix = @"";
        
        //init files
        [self initAccelerometerFile:self.currentFilePrefix];
        [self initGyroFile:self.currentFilePrefix];
        [self initTimestampFile:self.currentFilePrefix];
        
        isRecording = true;
    }
}

-(void)stopRecording{
    
    if(isRecording){
        
        //close all open files
        fclose(accelerometerFile);
        fclose(gyroFile);
        fclose(timestampFile);
        
        isRecording = false;
    }
}

-(NSString *)setupTextFile:(FILE **)file withBaseFileName:(NSString *)baseFileName appendix:(NSString *)appendix dataDescription:(NSString *)description subtitle:(NSString *)subtitle columnDescriptions:(NSArray *)columnDescriptions{
    
    NSString *fileName = [[baseFileName stringByAppendingString:appendix] stringByAppendingPathExtension:@"csv"];
    NSString *completeFilePath = [currentRecordingDirectory stringByAppendingPathComponent:fileName];

    //create the file for the record
    *file = fopen([completeFilePath UTF8String], "a");
    
    for (int i = 0; i < [columnDescriptions count]; i++) {
        if([columnDescriptions count] == (i+1)){
            fprintf(*file, "%s\n",[[columnDescriptions objectAtIndex:i] UTF8String]);
        }else{
            fprintf(*file, "%s,",[[columnDescriptions objectAtIndex:i] UTF8String]);
        }
    }
    
    return completeFilePath;
}

- (void)initAccelerometerFile:(NSString*)name {
    self.accelerometerFileName = [self setupTextFile:&accelerometerFile
                                    withBaseFileName:name 
                                            appendix:kAccelerometerFileAppendix
                                     dataDescription:@"Accelerometer data"
                                            subtitle:[NSString stringWithFormat:@"%% Sampling frequency: 50 Hz\n"]
                                  columnDescriptions:[NSArray arrayWithObjects:
                                                      @"Seconds.milliseconds since 1970",
                                                      @"Acceleration value in x-direction",
                                                      @"Acceleration value in y-direction",
                                                      @"Acceleration value in z-direction",
                                                      nil]
                                  ];
}


- (void)initGyroFile:(NSString*)name {
    
    self.gyroFileName = [self setupTextFile:&gyroFile
                           withBaseFileName:name
                                   appendix:kGyroscopeFileAppendix
                            dataDescription:@"Gyrometer data"
                                   subtitle:nil
                         columnDescriptions:[NSArray arrayWithObjects:
                                             @"Seconds.milliseconds since 1970",
                                             @"Gyro X",
                                             @"Gyro Y",
                                             @"Gyro Z",
                                             @"Roll of the device",
                                             @"Pitch of the device",
                                             @"Yaw of the device",
                                             nil]
                         ];
}

-(void)initTimestampFile:(NSString*)name{
    self.timestampFileName = [self setupTextFile:&timestampFile
                                withBaseFileName:name appendix:kTimestampAppendix
                                 dataDescription:@"Timestamp data"
                                        subtitle:nil
                              columnDescriptions:[NSArray arrayWithObject:
                                                  @"Seconds.milliseconds since 1970"]
                              ];
}

-(void)recordSensorValue:(CMDeviceMotion *)motionTN timestamp:(NSTimeInterval)timestampTN{
    
    if(isRecording){
        
//        lowPath_accelX = (motionTN.userAcceleration.x * filteringFactor) + (lowPath_accelX * (1.0 - filteringFactor));
//        lowPath_accelY = (motionTN.userAcceleration.x * filteringFactor) + (lowPath_accelY * (1.0 - filteringFactor));
//        lowPath_accelZ = (motionTN.userAcceleration.x * filteringFactor) + (lowPath_accelZ * (1.0 - filteringFactor));
//        
//        lowPath_gyroX = (motionTN.rotationRate.x * filteringFactor) + (lowPath_gyroX * (1.0 - filteringFactor));
//        lowPath_gyroY = (motionTN.rotationRate.y * filteringFactor) + (lowPath_gyroY * (1.0 - filteringFactor));
//        lowPath_gyroZ = (motionTN.rotationRate.z * filteringFactor) + (lowPath_gyroZ * (1.0 - filteringFactor));
//        
//        lowPath_gyroRoll = (motionTN.attitude.roll * filteringFactor) + (lowPath_gyroRoll * (1.0 - filteringFactor));
//        lowPath_gyroPitch = (motionTN.attitude.pitch * filteringFactor) + (lowPath_gyroPitch * (1.0 - filteringFactor));
//        lowPath_gyroYaw = (motionTN.attitude.yaw * filteringFactor) + (lowPath_gyroYaw * (1.0 - filteringFactor));
        
//        lowPath_accelX = motionTN.userAcceleration.x - lowPath_accelX;
//        lowPath_accelY = motionTN.userAcceleration.x - lowPath_accelY;
//        lowPath_accelZ = motionTN.userAcceleration.x - lowPath_accelZ;
//        lowPath_gyroX = motionTN.rotationRate.x - lowPath_gyroX;
//        lowPath_gyroY = motionTN.rotationRate.y - lowPath_gyroY;
//        lowPath_gyroZ = motionTN.rotationRate.z - lowPath_gyroZ;
//        lowPath_gyroRoll = motionTN.attitude.roll - lowPath_gyroRoll;
//        lowPath_gyroPitch = motionTN.attitude.pitch - lowPath_gyroPitch;
//        lowPath_gyroYaw = motionTN.attitude.yaw - lowPath_gyroYaw;


        fprintf(accelerometerFile,
                "%10.5f,%f,%f,%f\n",
                timestampTN,
                lowPath_accelX,
                lowPath_accelY,
                lowPath_accelZ
                );
        
        fprintf(gyroFile,
                "%10.5f,%f,%f,%f,%f,%f,%f\n",
                timestampTN,
                lowPath_gyroX,
                lowPath_gyroY,
                lowPath_gyroZ,
                lowPath_gyroRoll,
                lowPath_gyroPitch,
                lowPath_gyroYaw
                );
        
        fprintf(accelerometerFile,
            "%10.5f,%f,%f,%f\n",
            timestampTN,
            motionTN.userAcceleration.x,
            motionTN.userAcceleration.y,
            motionTN.userAcceleration.z
        );
        
        fprintf(gyroFile,
                "%10.5f,%f,%f,%f,%f,%f,%f\n",
                timestampTN,
                motionTN.rotationRate.x,
                motionTN.rotationRate.y,
                motionTN.rotationRate.z,
                motionTN.attitude.roll,
                motionTN.attitude.pitch,
                motionTN.attitude.yaw
                );
    }
}

-(void)recordPicture:(UIImage*)image timestamp:(NSTimeInterval)timestamp exifAttachments:(CFDictionaryRef)exifAttachments{
    
    exifDictionary = (__bridge NSDictionary *)exifAttachments;
    if(isRecording){
        fprintf(timestampFile,
                "%10.5f,%s,%d\n",
                timestamp,
                [[NSString stringWithFormat:@"%@",[exifDictionary objectForKey:@"ExposureTime"]] cString],
                0);
        NSString *pictureFilePath = [NSString stringWithFormat:@"%@/%10.5f.jpg",self.currentRecordingDirectoryForPicture,timestamp];
        [UIImageJPEGRepresentation(image,0.5f) writeToFile:pictureFilePath atomically:YES];
        NSLog(@"%@",pictureFilePath);
    }
}
@end
