//
//  ViewController.h
//  StroopColorGame
//
//  Created by Mayanka  on 7/28/15.
//  Copyright (c) 2015 umkc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/objdetect/objdetect.hpp>
#import <RMCore/RMCore.h>
#import <RMCharacter/RMCharacter.h>
#include <opencv2/highgui/highgui.hpp>
#import "opencv2/opencv.hpp"
#import "AbstractOCVViewController.h"
#import <SpeechKit/SpeechKit.h>

@interface ViewController :AbstractOCVViewController <RMCoreDelegate,AVSpeechSynthesizerDelegate, SpeechKitDelegate, SKRecognizerDelegate>
{
   // IBOutlet UIView *romoView;
    CvHaarClassifierCascade *_cascade;
    CvMemStorage *_storage;
    double _min, _max;
    //SKRecognizer* voiceSearch;
       enum {
        TS_IDLE,
        TS_INITIAL,
        TS_RECORDING,
        TS_PROCESSING,
    } transactionState;
}
@property (strong,readwrite) SKRecognizer* voiceSearch;
@property (strong, nonatomic) IBOutlet UIImageView *signImageView;
@property (strong, readwrite) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) RMCoreRobotRomo3 *Romo3;
@property (nonatomic, strong) RMCharacter *Romo;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@end

