//
//  ViewController.m
//  02WM-猜图2
//
//  Created by hwm on 15/8/18.
//  Copyright (c) 2015年 xiaomage. All rights reserved.
//

#import "ViewController.h"
#import "WMQuestion.h"
@interface ViewController ()

- (IBAction)tip;
- (IBAction)help;
- (IBAction)bigImage;
- (IBAction)nextQuestion;
- (IBAction)iconClick;

@property (weak, nonatomic) IBOutlet UIButton *scoreBtn;
/** 答案的view*/
@property (weak, nonatomic) IBOutlet UIView *answerView;

@property (weak, nonatomic) IBOutlet UIView *optionView;

/**  序号 */
@property (weak, nonatomic) IBOutlet UILabel *noLable;
/**  标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
/**  头像(图标) */
@property (weak, nonatomic) IBOutlet UIButton *iconBtn;

@property (weak, nonatomic) IBOutlet UIButton*nextQuestionBtn;

/**  遮盖 */
@property (nonatomic, weak) UIButton *cover;
/**   所有的题目 */
@property (nonatomic, strong) NSArray *question;
/**  当前题目的序号 */
@property  (nonatomic, assign) int index;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _index = -1;
    [self nextQuestion];// 使一开始就是1/10的位置
    
}

// 控制状态栏的状态
- (UIStatusBarStyle)preferredStatusBarStyle {
    // 白色
    return UIStatusBarStyleLightContent;
}

// 懒加载
- (NSArray *)question {
    
    if (_question == nil) {
        // 1.获取字典数组
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"questions" ofType:@"plist"];
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];
        
        NSMutableArray *array = [NSMutableArray array]; //
        for (NSDictionary *dict in dictArray) {
            WMQuestion *questions = [WMQuestion questionWithDict:dict];
            [array addObject:questions];
        }
        _question = array;
    }
    return _question;
}

#pragma mark - 下一题
/**  下一题 */
- (IBAction)nextQuestion {
    // 1.增加索引
    self.index ++;
    
    // 2.取出模型
    WMQuestion *questions = self.question[self.index];
    
    // 3.设置控件的数据
    [self settingData:questions];
        
/** 九宫格 */
    // 4.添加正确选项
    [self addAnswerBtn:questions];
    
    /** 妈妈吖! 又是一个九宫格 */
        // 5.添加待选项
    [self addOptionBtn:questions];
}

#pragma mark - 设置数据
- (void)settingData: (WMQuestion *)questions {
    //   3.1.设置序号
    self.noLable.text = [NSString stringWithFormat:@"%d/%lu", self.index + 1, self.question.count];
    
    //   3.2.设置标题
    self.titleLable.text = questions.title;
    
    //   3.3.设置图标
    [self.iconBtn setImage:[UIImage imageNamed:questions.icon] forState:UIControlStateNormal];
    
    //   3.4.设置下一题按钮状态
    self.nextQuestionBtn.enabled = (_index != self.question.count - 1);

}

- (void)addOptionBtn:(WMQuestion *)questions {
    //  5.1.删除以前的所有按钮
    [self.optionView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        //  5.2.添加待选按钮
    NSUInteger count = questions.options.count;
    for (int i = 0; i < count; i++) {
        // 5.2.1.创建待选按钮
        UIButton *optionSub = [[UIButton alloc] init];
        
        // 5.2.2.设置背景
        [optionSub setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
        [optionSub setBackgroundImage:[UIImage imageNamed:@"btn_heighlighted"] forState:UIControlStateHighlighted];
        
        // 5.2.3.设置大小位置
        int totalCoclumns = 7;// 总列数
        CGFloat viewW = self.optionView.frame.size.width;
        CGFloat marginX = 10;
        CGFloat marginY = 15;
        CGFloat optionW = 36;
        CGFloat optionH = 36;
        CGFloat leftMargin = (viewW - totalCoclumns * optionW - marginX * (totalCoclumns - 1)) * 0.5;
        int  row = i / totalCoclumns;
        int  col = i % totalCoclumns; // 取模运算不能用于double(也就是CGFloat)类型
        CGFloat optionX = leftMargin + col * (optionW + marginX);
        CGFloat optionY = row * (optionH + marginY);
        optionSub.frame = CGRectMake(optionX, optionY, optionW, optionH);
        
        // 5.2.4.设置文字
        [optionSub setTitle:questions.options[i] forState:UIControlStateNormal];
        // 设置文字的颜色
        [optionSub setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        // 5,2.5.添加按钮
        [self.optionView addSubview:optionSub];
        
        // 5.2.6.监听点击
        [optionSub addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    

}

/**  监听待选项的点击 */
- (void)optionClick:(UIButton *)optionBtn { // 谁被点击了, 就把谁传进来
    
    // 1.让被点击的待选按钮消失
    optionBtn.hidden = YES;
    
    // 2.显示文字到正确答案上
    for (UIButton *answerBtn in self.answerView.subviews) {
        NSString *answerTitle = [answerBtn titleForState:UIControlStateNormal];
        
        // 判断答案是否有文字
        if (answerTitle.length == 0) { // 没有文字
            // 设置答案按钮的文字为被点击的文字
            NSString *optionTitle = [optionBtn titleForState:UIControlStateNormal];
            
            [answerBtn setTitle:optionTitle forState:UIControlStateNormal];
            break;
        }
    }
    // 3.判断文字是否填满了
    BOOL full = YES;
    NSMutableString *temAnswerTitle = [NSMutableString string];
    for (UIButton *answerBtn in self.answerView.subviews) {
        NSString *answerTitle = [answerBtn titleForState:UIControlStateNormal];
        if (answerTitle.length == 0) {
            full = NO;
        }
        // 拼接按钮文字
        if (answerTitle) {
            [temAnswerTitle appendString:answerTitle];
        }
    }
    
    // 4.答案满了
    
    if (full) {
        WMQuestion *question = self.question[self.index];
        
        if ([temAnswerTitle isEqualToString:question.answer]) {
            
            for (UIButton *answerBtn in self.answerView.subviews) { // 答对了文字显示蓝色
                [answerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            }
            // 加分
            [self addScore:1520];
            
            // 0.3秒后自动跳入下一行
            [self performSelector:@selector(nextQuestion) withObject:nil afterDelay:0.3];
            
        }else {
            for (UIButton *answerBtn in self.answerView.subviews) {
                [answerBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark - 加分
- (void)addScore:(int) deltaScore {
    int score = [self.scoreBtn titleForState:UIControlStateNormal].intValue; // 转换为 int 类型
    score += deltaScore;
    [self.scoreBtn setTitle:[NSString stringWithFormat:@"%d", score] forState:UIControlStateNormal];

}

- (void)addAnswerBtn: (WMQuestion *)questions {
    //  4.1.删除之前的所有按钮
    [self.answerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //  4.2.添加新的答案按钮
    NSUInteger length = questions.answer.length;//计算答案的长度
    for (int i = 0; i < length; i++) {
        // 4.2.1.创建按钮
        UIButton *answerBtn = [[UIButton alloc] init];
        // 设置字体颜色
        [answerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        // 4.2.2设置背景图片
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"btn_answer_heighlighted"] forState:UIControlStateHighlighted];
        
        // 4.2.3设置大小位置
        CGFloat viewW = self.answerView.frame.size.width;
        CGFloat margin = 13;
        CGFloat answerW = 40;
        CGFloat answerH = 40;
        CGFloat leftMargin = (viewW - length * answerW - length * (margin - 1) ) * 0.5;
        CGFloat answerX = leftMargin + i * (answerW + margin);
        CGFloat answerY = 0;
        answerBtn.frame = CGRectMake(answerX, answerY, answerW, answerH);
        
        // 4.2.4添加
        [self.answerView addSubview:answerBtn];
        
        // 4.2.5设置监听
        [answerBtn addTarget:self action:@selector(answerClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

/**  监听答案按钮的点击 */
- (void)answerClick: (UIButton *)answerBtn { // 谁被点击, 就把谁传进来
    
    // 答案按钮的文字
    NSString *answerTitle = [answerBtn titleForState:UIControlStateNormal];
    
    // 1.让答案按钮文字对应的待选按钮文字显示出来
    for (UIButton *optionBtn in self.optionView.subviews) {
        //
        NSString *optionTitle = [optionBtn titleForState:UIControlStateNormal];
        
        if ([optionTitle isEqualToString:answerTitle] && (optionBtn.hidden == YES)) {
            optionBtn.hidden = NO;// hidden = no代表不隐藏, = yes代表隐藏
            break;
        }
    }
    
    // 2.让被点击的答案按钮文字消失
    [answerBtn setTitle:nil forState:UIControlStateNormal];
    
    // 3.让所有的答案按钮为黑色
    for (UIButton *answerBtn in self.answerView.subviews) {
        [answerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
}

/**  提示 */
- (IBAction)tip {
    // 1.点击所有的答案按钮
    for (UIButton *answerBtn in self.answerView.subviews) {
        [self answerClick:answerBtn];
    }
    // 2.取出答案
    //  2.1.取出对应的模型
    WMQuestion *question = self.question[self.index];
    //  2.2.取出第一个答案
    NSString *firstAnswer = [question.answer substringToIndex:1 ];
    for (UIButton *optionBtn in self.optionView.subviews) {
    if ([optionBtn.currentTitle isEqualToString:firstAnswer]) {
        [self optionClick:optionBtn];
        break;
    }
  }
    // 减分
    [self addScore:-1500];
}

/**  帮助 */
- (IBAction)help {
}

/**  大图 */
- (IBAction)bigImage {
    // 1.添加阴影
    UIButton *cover = [[UIButton alloc] init];
    cover.alpha = 0.0f;
    cover.backgroundColor = [UIColor blackColor];
    cover.frame = self.view.bounds;
    [self.view addSubview:cover];
    
//  我恨你啊.....
    self.cover = cover; // 记得 赋值 给引用(属性)(成员变量)
    
    //   1.1.当点击遮盖的时候, 会调用smallImage方法
    [cover addTarget:self action:@selector(smallImage) forControlEvents:UIControlEventTouchUpInside];
    
    // 2.更换阴影和头像的位置
    [self.view bringSubviewToFront:self.iconBtn];
    
    // 3.执行动画  \抛弃头尾式
    [UIView animateWithDuration:0.5f animations:^{
        // 3.1.阴影慢慢显示出来
        cover.alpha = 0.5f;
        
        // 3.2.头像慢慢变大, 慢慢移到屏幕的正中间
        CGFloat iconW = self.view.frame.size.width;
        CGFloat iconH = iconW;
        CGFloat iconX = 0;
        CGFloat iconY = (self.view.frame.size.height - iconH) * 0.5;
        self.iconBtn.frame = CGRectMake(iconX, iconY, iconW, iconH);
    }];
  
}


/**  图像 */
- (IBAction)iconClick {
    if (_cover == nil) {
        [self  bigImage];
    }else {
        [self smallImage];
    }
}

/**  小图 */
- (void)smallImage {
    [UIView animateWithDuration:0.5f animations:^{
        // 1.87 118 180
        CGFloat iconW = 180;
        CGFloat iconH = iconW;
        CGFloat iconX = 97;
        CGFloat iconY = 118;
        self.iconBtn.frame = CGRectMake(iconX, iconY, iconW, iconH);
        
        // 2.
        self.cover.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        // 3.移除遮盖
        [self.cover removeFromSuperview];
        self.cover = nil;
    }];
}
@end





