//
//  WMQuestion.h
//  02WM-猜图2
//
//  Created by hwm on 15/8/18.
//  Copyright (c) 2015年 xiaomage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMQuestion : NSObject
/** 标题 */
@property (nonatomic, strong) NSString *title;
/** 图像 */
@property (nonatomic, strong) NSString *icon;
/** 答案 */
@property (nonatomic, strong) NSString *answer;
/** 待选项 */
@property (nonatomic, strong) NSArray *options;

// 自定义构造方法
- (instancetype)initWithDict: (NSDictionary *)dict;
// 类工厂
+ (instancetype)questionWithDict: (NSDictionary *)dict;

@end
