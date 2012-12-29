//
//  SensorMonitor.m
//  BlurBuster
//
//  Created by ishimaru on 2012/10/31.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import "SensorMonitor.h"

@implementation SensorMonitor

-(id)init{
    self = [super init];
    if(self != nil){
        session = [[AVCaptureSession alloc] init];
    }
    return self;
}

- (void)prepareCMDeviceMotion{
	// Do any additional setup after loading the view, typically from a nib.
    
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    [session addInput:input];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    [session startRunning];
    
    //Check iOS Version
    _systemVersion = [[[UIDevice currentDevice]systemVersion]floatValue];
    NSLog(@"iOS version: %f", _systemVersion);
    
    self.manager = [[CMMotionManager alloc]init];
    
    beginningOfEpoch = [[NSDate alloc]initWithTimeIntervalSince1970:0.0];
    timestampOffsetInitialized = false;
}

-(void)startCMDeviceMotion:(int)frequency{
    
    //Check sensor
    if(self.manager.deviceMotionAvailable){
        
        //frequency
        self.manager.deviceMotionUpdateInterval = 1.0f/frequency;
        
        //Handler
        CMDeviceMotionHandler handler = ^(CMDeviceMotion *motion, NSError *error){
            
            if (!timestampOffsetInitialized) {
                timestampOffsetFrom1970 = [self getTimestamp] - motion.timestamp;
                timestampOffsetInitialized = true;
            }
            
            NSTimeInterval timestamp = motion.timestamp + timestampOffsetFrom1970;
            
            [self.delegate sensorValueChanged:motion timestamp:timestamp];
            
        };
        
        //Start device motion
        if(5.0 < _systemVersion){
            [self.manager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical toQueue:[NSOperationQueue currentQueue] withHandler:handler];
        }else{
            [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
        }
    }
}

-(void)dealloc{
    [[UIAccelerometer sharedAccelerometer]setDelegate:nil];
}


- (void)stopSensor{
    
    //Stop sensor
    if(4.0 < _systemVersion){
        if(self.manager.deviceMotionActive){
            [self.manager stopDeviceMotionUpdates];
        }
    }
}

//appends a string to a file (given the filename in the path)
- (BOOL) appendFile:(NSString *)path withString:(NSString*)string;
{
    BOOL result = YES;
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if ( !fh ) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    if ( !fh ) return NO;
    @try {
        [fh seekToEndOfFile];
        [fh writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
    @catch (NSException * e) {
        result = NO;
    }
    [fh closeFile];
    return result;
}



-(void) capture:(NSTimeInterval)timestamp{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections){
        for (AVCaptureInputPort *port in [connection inputPorts]){
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ){
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	[videoConnection setVideoOrientation:curDeviceOrientation];
    
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments){
             // Do something with the attachments.             
             NSLog(@"attachements: %@", exifAttachments);
         }
         else
             NSLog(@"no attachments");
         
         NSLog(@"%@",imageSampleBuffer);
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         NSLog(@"%@",image);
         [self.delegate finishedTakePicture:image timestamp:timestamp];
     }];
    
}

-(NSTimeInterval)getTimestamp {
	NSTimeInterval timestamp = -[beginningOfEpoch timeIntervalSinceNow];
	return timestamp;
}


@end