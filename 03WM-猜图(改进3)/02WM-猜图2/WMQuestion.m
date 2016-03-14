//
//  WMQuestion.m
//  02WM-猜图2
//
//  Created by hwm on 15/8/18.
//  Copyright (c) 2015年 xiaomage. All rights reserved.
//

#import "WMQuestion.h"

@implementation WMQuestion

// 自定义构造方法
- (instancetype)initWithDict: (NSDictionary *)dict {
    if (self = [super init]) {
        self.title = dict[@"title"];
        self.icon = dict[@"icon"];
        self.answer = dict[@"answer"];
        self.options = dict[@"options"];
    }
    return self;
}

// 类工厂
+ (instancetype)questionWithDict: (NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}




@end
