//
//  ViewController.m
//  StroopColorGame
//
//  Created by Mayanka  on 7/28/15.
//  Copyright (c) 2015 umkc. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@property (nonatomic, assign) float speed;
@property (nonatomic, retain) NSString *voice;

@property (strong, nonatomic) IBOutlet UILabel *ColorLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self colorWordAssignment];
    [self speakText:@"Hello How are you"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ColorWord Assignment
-(void) colorWordAssignment
{
    _ColorLabel.text=@"RED";
    _ColorLabel.textColor=[UIColor colorWithRed:(0/255.0) green:(102/255.0) blue:(0/255.0) alpha:1] ;
    _ColorLabel.font=[UIFont fontWithName:@"Optima-ExtraBlack" size:50.0];
}

#pragma mark -test to speech function
- (void)speakText:(NSString*)text {
    //_voice = "en-US";
    if (_synthesizer == nil) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
    }
    
    AVSpeechUtterance *utterence = [[AVSpeechUtterance alloc] initWithString:text];
    utterence.rate = _speed;
    
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:_voice];
    [utterence setVoice:voice];
    
    [_synthesizer speakUtterance:utterence];
}

@end
