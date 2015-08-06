//
//  ViewController.m
//  StroopColorGame
//
//  Created by Mayanka  on 7/28/15.
//  Copyright (c) 2015 umkc. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

typedef enum{
    RED,BLUE,GREEN,BROWN,PURPLE
} colorNames;
@interface ViewController ()
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@property (nonatomic, assign) float speed;
@property (nonatomic, retain) NSString *voice;
@property (strong, nonatomic) IBOutlet UILabel *ColorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *visualCue;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property NSString *response,*labelColor;
@end

int score=0,times=0,number=0,flagForVoiceInput=0;
BOOL flagTest=false;

NSArray *questions=@[@"I am going to give you a name and address. After I have said it, I want you to repeat it. Remember this name and address because I am going to ask you to tell it to me again in a few minutes: John Brown, 42 West Street, Kensington.",@"What is the date? (exact only)",@"What was the name and address I asked you to remember"];
const unsigned char SpeechKitApplicationKey[] = {0xf6, 0xb6, 0xbc, 0xb0, 0x40, 0x1a, 0x2c, 0x8f, 0x65, 0xab, 0xb2, 0x95, 0xfd, 0x59, 0xe6, 0x83, 0x31, 0xa8, 0x20, 0xf9, 0x2d, 0xcc, 0xb6, 0xd4, 0xd6, 0xca, 0xce, 0x66, 0x29, 0xe3, 0x57, 0x1f ,0x99, 0x13, 0xcf, 0xda, 0x2d, 0xfc, 0x69, 0x92, 0xa7, 0x1b, 0x28, 0xa5, 0x74, 0x0e, 0x28, 0xa5, 0xb6, 0x48, 0x9e, 0xe4, 0x14, 0x54, 0xb8, 0xea, 0x1e, 0x87, 0x51, 0x47, 0x6a, 0xa8, 0x66, 0x03};

using namespace std;
using namespace cv;

@implementation ViewController
@synthesize recordButton,voiceSearch;

//static BOOL _debug = NO;
- (void)viewDidLoad {
    // Do any additional setup after loading the view, typically from a nib.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"smile" ofType:@"xml"];
    _cascade = (CvHaarClassifierCascade*)cvLoad([path cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, NULL);
    _storage = cvCreateMemStorage(0);
    _nextButton.enabled=false;
    [super viewDidLoad];
    [SpeechKit setupWithID:@"NMDPTRIAL_mckw9_mail_umkc_edu20150731142522"
                      host:@"sandbox.nmdp.nuancemobility.net"
                      port:443
                    useSSL:NO
                  delegate:self];
    
    // Set earcons to play
    SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_listening.wav"];
    //    SKEarcon* earconStop	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
    //    SKEarcon* earconCancel	= [SKEarcon earconWithName:@"earcon_cancel.wav"];
    
    [SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
    //    [SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
    //    [SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];
    
    // self.Romo = [RMCharacter Romo];
    //[RMCore setDelegate:self];
    _ColorLabel.text=@"WELCOME TO STROOP COLOR TEST";
    [self speakText:@"Hi!! "];
    //    while (_synthesizer.speaking) {
    //Would you like to play a game?
    //    }
    //    //[self tappedOnRecord:NULL];
    
    
    //[self speakText:@"Hello How are you"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    // Add Romo's face to self.view whenever the view will appear
    // [self.Romo addToSuperview:self->romoView];
}


#pragma mark - Question Generator
-(void) questionGenerator:(BOOL) labelAssignment
{
    [self speakText:questions[0]];
    [self speakText:questions[2]];
    [self tappedOnRecord:NULL];
    
}

#pragma mark - Text to speech function
- (BOOL)speakText:(NSString*)text {
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
    
    return true;
}


#pragma mark - RMCoreDelegate Methods
- (void)robotDidConnect:(RMCoreRobot *)robot
{
    // Currently the only kind of robot is Romo3, so this is just future-proofing
    if ([robot isKindOfClass:[RMCoreRobotRomo3 class]]) {
        self.Romo3 = (RMCoreRobotRomo3 *)robot;
        
        // Change Romo's LED to be solid at 80% power
        [self.Romo3.LEDs setSolidWithBrightness:0.8];
        
        // When we plug Romo in, he get's excited!
        self.Romo.expression = RMCharacterExpressionExcited;
    }
}

- (void)robotDidDisconnect:(RMCoreRobot *)robot
{
    if (robot == self.Romo3) {
        self.Romo3 = nil;
        
        // When we unpluged Romo , he get's sad!
        self.Romo.expression = RMCharacterExpressionSad;
    }
}

#pragma mark - didcaptureImage


- (void)didCaptureIplImage:(IplImage *)iplImage
{
    IplImage *imgRGB = cvCreateImage(cvGetSize(iplImage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplImage, imgRGB, CV_BGR2RGB);
    
    IplImage *imgSmall = cvCreateImage(cvSize(imgRGB->width/2, imgRGB->height/2), IPL_DEPTH_8U, 3);
    cvPyrDown(imgRGB, imgSmall, CV_GAUSSIAN_5x5);
    
    CvSeq *smiles = cvHaarDetectObjects(imgSmall, _cascade, _storage, 1.1f, 3, CV_HAAR_DO_CANNY_PRUNING);
    
    for (int i = 0; i < smiles->total; i++)
    {
        CvRect cvrect = *(CvRect*)cvGetSeqElem(smiles, 0);
        
        Mat matImgSmall = Mat(imgSmall);
        
        rectangle(matImgSmall, cvrect, Scalar(255, 0, 0));
    }
    
    if (smiles->total > 0)
    {
        //[self showSmileWithImage:imgSmall];
        //[self speakText:@"You smiled"];
    }
    else
    {
        cvReleaseImage(&imgSmall);
    }
    
    [self didFinishProcessingImage:imgRGB];
}

#pragma mark - Voice recogniser functions
- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    NSLog(@"Got results.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    
    long numOfResults = [results.results count];
    
    transactionState = TS_IDLE;
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    //
    if (numOfResults > 0)
    {
        // searchBox.text = [results firstResult];
        _response=[results firstResult];
        NSLog(@"Response is [%@]",_response);
        
        if(flagForVoiceInput==0)
        {
            if([_response.uppercaseString isEqualToString:@"YES"])
            {
                [self questionGenerator:true];
                _nextButton.enabled=true;
            }
            else
                [self goodBye];
            flagForVoiceInput++;
        }
        else if(flagForVoiceInput==1)
        {
            NSLog(@"Response is [%@]",_response);
            
            
            // if( [self speakText:@"Thank you for the response. Lets move on to next label"])
            
            [self checkResults:_response];
        }
    }
    if (numOfResults > 1)
    {
        //        alternativesDisplay.text = [[results.results subarrayWithRange:NSMakeRange(1, numOfResults-1)] componentsJoinedByString:@"\n"];
    }
    if (results.suggestion) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Suggestion"
                                                        message:results.suggestion
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        // [alert release];
        
    }
    
    //  [voiceSearch release];
    // voiceSearch = nil;
}
- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    NSLog(@"Got error.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    
    transactionState = TS_IDLE;
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    // [alert release];
    
    if (suggestion) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Suggestion"
                                                        message:suggestion
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        //  [alert release];
        
    }
    
    //  [voiceSearch release];
    voiceSearch = nil;
}
- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording started.");
    
    transactionState = TS_RECORDING;
    [recordButton setTitle:@"Recording..." forState:UIControlStateNormal];
    // [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.05];
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording finished.");
    
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVUMeter) object:nil];
    //
    transactionState = TS_PROCESSING;
    [recordButton setTitle:@"Processing..." forState:UIControlStateNormal];
}

#pragma mark - Record Button

- (IBAction)tappedOnRecord:(id)sender {
    if(!_synthesizer.speaking)
    {
        if (transactionState == TS_RECORDING) {
            [voiceSearch stopRecording];
        }
        else if (transactionState == TS_IDLE) {
            SKEndOfSpeechDetection detectionType;
            NSString* recoType;
            NSString* langType;
            
            transactionState = TS_INITIAL;
            
            //      alternativesDisplay.text = @"";
            
            /* 'Dictation' is selected */
            detectionType = SKLongEndOfSpeechDetection; /* Dictations tend to be long utterances that may include short pauses. */
            recoType = SKDictationRecognizerType; /* Optimize recognition performance for dictation or message text. */
            langType = @"en_US";
            /* Nuance can also create a custom recognition type optimized for your application if neither search nor dictation are appropriate. */
            
            NSLog(@"Recognizing type:'%@' Language Code: '%@' using end-of-speech detection:%d.", recoType, langType, detectionType);
            
            // if (voiceSearch) [voiceSearch release];
            
            voiceSearch = [[SKRecognizer alloc] initWithType:recoType
                                                   detection:detectionType
                                                    language:langType
                                                    delegate:self];
        }
    }
}

#pragma mark - Check results
-(void) checkResults:(NSString*)response
{
    times++;
    
    if ([response.uppercaseString containsString:@"JOHN"]) {
        score++;
    }
    if([response.uppercaseString containsString:@"BROWN"]){
        score++;
    }
    if([response.uppercaseString containsString:@"WEST ST."]){
        score++;
    }
    if ([response.uppercaseString containsString:@"42"] ) {
        score++;
    }
    if([response.uppercaseString containsString:@"KENSINGTON"])
    {
        score++;
    }
    if(times==1)
    {
        NSString *msg=[NSString stringWithFormat:@"You scored %d out of %d questions",score,times];
        NSLog(@"You scored %d out of %d questions",score,times);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Score"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self goodBye];
    }
    else
        [self questionGenerator:false];
    
}
#pragma mark - Good Bye
-(void) goodBye
{
    _ColorLabel.text=@"GOOD BYE";
    recordButton.enabled=false;
}

#pragma mark - Next Button
- (IBAction)tappedOnNext:(id)sender {
    if(!flagTest)
    {
        if(number<4)
            [self questionGenerator:true];
        else
        {
            [self speakText:@"Now lets test for visual recall ability, Try recollect the label corresponding to the image displayed.. Click on Start Button When your ready"];
            [_nextButton setTitle:@"Start" forState:UIControlStateNormal];
            flagTest=true;
        }
    }
    else
    {
        [self questionGenerator:false];
        [self tappedOnRecord:NULL];
        [_nextButton setTitle:@"Next" forState:UIControlStateNormal];

    }
}

@end
