//
//  ISRDataHelper.h
//  HNAirSpot
//
//  Created by __无邪_ on 16/6/15.
//  Copyright © 2016年 __无邪_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Categories.h"

// 云端返回数据解析类
@protocol ISRDataHelper<NSObject>

//解析听写json格式的数据
- (NSString *) getResultFromJson:(NSString*)params;

//解析命令词返回的结果
- (NSString*) getResultFormAsr:(NSString*)params;

//解析语法识别返回的结果
-(NSString *) getResultFromASRJson:(NSString*)params;

@end

@interface ISRDataHelper : NSObject<ISRDataHelper>

+ (id) shareInstance;

@end