//
//  ViewController.m
//  HNAirSpot
//
//  Created by __无邪_ on 16/6/15.
//  Copyright © 2016年 __无邪_. All rights reserved.
//

#import "ViewController.h"
// 语音识别控件
#import "iflyMSC/IFlyDataUploader.h"
#import "iflyMSC/IFlyContact.h"
#import "iflyMSC/IFlyUserWords.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
#import "iflyMSC/IFlySpeechConstant.h"

#import "ISRDataHelper.h"


@interface ViewController ()<IFlySpeechRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startListening;
@property (weak, nonatomic) IBOutlet UILabel *labRecognizerResult;
@property (nonatomic,strong) IFlySpeechRecognizer * iflyRecognizer;
@property (nonatomic,strong) IFlyDataUploader * uploader;
@property (nonatomic,strong) NSMutableString * finalRecognizerResult;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self uploadUserWords];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action

- (IBAction)startListenAction:(id)sender {
    
    BOOL result = [self.iflyRecognizer startListening];
    
    if (result) {
        [self.startListening setTitle:@"listenning..." forState:UIControlStateNormal];
        NSLog(@"start listenning...");
    }else{
        [self.startListening setTitle:@"开始识别" forState:UIControlStateNormal];
        [self.iflyRecognizer stopListening];
        NSLog(@"stop listenning");
    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    //终止识别
    [_iflyRecognizer cancel];
    [_iflyRecognizer setDelegate:nil];
    _iflyRecognizer = nil;
    
    [super viewWillDisappear:animated];
}


#pragma mark - Private
//上传联系人
- (void)uploadContact{
    //获取联系人集合
    IFlyContact *iFlyContact = [[IFlyContact alloc] init];
    NSString *contactList = [iFlyContact contact];
    //设置参数
    [self.uploader setParameter:@"uup" forKey:@"subject"];
    [self.uploader setParameter:@"contact" forKey:@"dtt"];
    //启动上传
    [self.uploader uploadDataWithCompletionHandler:^(NSString * grammerID, IFlySpeechError *error)
    {
        //接受返回的grammerID和error
//        NSLog(@"----上传联系人完成%@ %@ %@",grammerID,error.errorDesc,@(error.errorCode));
        [self onUploadFinished:grammerID error:error];
        
    }name:@"contact" data: contactList];  

}
//上传用户词表
- (void)uploadUserWords{
    //生成用户词表对象
    //用户词表
#define USERWORDS   @"{\"userword\":[{\"name\":\"iflytek\",\"words\":[\"\",\"1912酒吧街\",\"清蒸鲈鱼\",\"挪威三文鱼\",\"黄埔军校\",\"横沙牌坊\",\"科大讯飞\"]}]}"
    IFlyUserWords *iFlyUserWords = [[IFlyUserWords alloc] initWithJson:USERWORDS ];
#define NAME @"userwords"
    //设置参数
    [self.uploader setParameter:@"iat" forKey:@"sub"];
    [self.uploader setParameter:@"userword" forKey:@"dtt"];
    //上传词表
    [self.uploader uploadDataWithCompletionHandler:^(NSString * grammerID, IFlySpeechError *error)
    {
        //接受返回的grammerID和error
        [self onUploadFinished:grammerID error:error];
        [self uploadContact];
        
    } name:NAME data:[iFlyUserWords toString]];
}
- (void) onUploadFinished:(NSString *)grammerID error:(IFlySpeechError *)error{
    NSLog(@"%d",[error errorCode]);
    
    if (![error errorCode]) {
        NSLog(@"----上传完成%@",grammerID);
    }
    else {
        NSLog(@"----上传失败%@ %@ %@",grammerID,error.errorDesc,@(error.errorCode));
    }
    
}
- (NSString *)systemLanguage{
    NSString *language = [NSLocale preferredLanguages][0];
    return language;
}



#pragma mark - SpeechRecognizer

- (void) onError:(IFlySpeechError *) errorCode{
    NSLog(@"Error : %@ , %d",errorCode.errorDesc,errorCode.errorCode);
    [self.iflyRecognizer stopListening];
}
- (void) onBeginOfSpeech{
    
}
- (void) onEndOfSpeech{
    [self.iflyRecognizer stopListening];
}
- (void) onCancel{
    [self.iflyRecognizer stopListening];
}
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [results objectAtIndex:0];
    for (NSString *key in dic){
        [result appendFormat:@"%@",key];//合并结果
    }
    
    NSLog(@"\n\n\n\n*******Temporary Result (%d): %@\n\n\n\n",isLast,result);
    
    NSString *resultStr = [[ISRDataHelper shareInstance] getResultFromJson:result];
    
    if ([resultStr isValuable]) {
        [self.finalRecognizerResult appendString:resultStr];
    }
    
    if (isLast) {
        NSLog(@"Finally Result ----- : %@",self.finalRecognizerResult);
        [self.startListening setTitle:@"开始识别" forState:UIControlStateNormal];
        [self.labRecognizerResult setText:self.finalRecognizerResult];
    }else{
        
    }
    
}
#pragma mark - Configure

- (IFlySpeechRecognizer *)iflyRecognizer{
    if (!_iflyRecognizer) {
        _iflyRecognizer = [[IFlySpeechRecognizer alloc] init];
        _iflyRecognizer.delegate = self;
        //应用领域。
        [_iflyRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        
        //设置结果数据格式，可设置为json，xml，plain，默认为json。
        [_iflyRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //前端点检测；静音超时时间，即用户多长时间不说话则当做超时处理； 单位：ms
        //[self.iflyRecognizer setParameter:@"1000" forKey:[IFlySpeechConstant VAD_BOS]];
        
        //后断点检测；后端点静音检测时间，即用户停止说话多长时间内即认为不再输入
        [_iflyRecognizer setParameter:@"1000" forKey:[IFlySpeechConstant VAD_EOS]];
        
        NSLog(@"%@",[self systemLanguage]);
        NSString *language = [self systemLanguage];
        
        if ([language containsString:@"zh"]) {
            //语言 支持：zh_cn，zh_tw，en_us<br>
            [_iflyRecognizer setParameter:@"zh_cn" forKey:[IFlySpeechConstant LANGUAGE]];
        }else{
            [_iflyRecognizer setParameter:@"en_us" forKey:[IFlySpeechConstant LANGUAGE]];
        }
    }
    return _iflyRecognizer;
}
- (IFlyDataUploader *)uploader{
    if (!_uploader) {
        _uploader = [[IFlyDataUploader alloc] init];
    }
    return _uploader;
}
- (NSMutableString *)finalRecognizerResult{
    if (!_finalRecognizerResult) {
        _finalRecognizerResult = [[NSMutableString alloc] init];
    }
    return _finalRecognizerResult;
}
/*
 *******Result (0): {"sn":1,"ls":false,"bg":0,"ed":0,"ws":[{"bg":0,"cw":[{"sc":0.00,"w":"回来"}]}]}
 *******Result (1): {"sn":2,"ls":true,"bg":0,"ed":0,"ws":[{"bg":0,"cw":[{"sc":0.00,"w":"。"}]}]}
 
 
 {"sn":1,"ls":true,"bg":0,"ed":0,"ws":[{"bg":0,"cw":[{"w":"白日","sc":0}]},{"bg":0,"cw":[{"w":"依山","sc":0}]},{"bg":0,"cw":[{"w":"尽","sc":0}]},{"bg":0,"cw":[{"w":"黄河入海流","sc":0}]},{"bg":0,"cw":[{"w":"。","sc":0}]}]}
 
 */














@end
