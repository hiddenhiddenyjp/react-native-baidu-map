//
//  FFCustomAnnotationView.m
//  feifanyouwo
//
//  Created by 韩志峰 on 2017/7/17.
//  Copyright © 2017年 zhuang chaoxiao. All rights reserved.
//

#import "FFCustomAnnotationView.h"
#import "FFLoactionAnotation.h"



#define kCalloutWidth       200.0
#define kCalloutHeight      30.0


@interface FFCustomAnnotationView ()
@property (nonatomic, strong) UITapGestureRecognizer  *tapGesture;

@end


@implementation FFCustomAnnotationView

- (instancetype)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(customAnntionViewDidClick)];
        self.bounds = CGRectMake(0, 0, 200, 34);
        [self addChildViews];
        self.userInteractionEnabled = YES;
    }
    return self;
}
- (void)addChildViews{
//    [self addGestureRecognizer:self.tapGesture];
    /*
    [self addSubview:self.callOutView];
    [self.callOutView addSubview:self.titleLabel];
     */
    
    [self addSubview:self.imageView];
    [self.imageView addSubview:self.titleLabel];
    
    self.clipsToBounds = 0;
    self.imageView.clipsToBounds = 0;
}
/*
 self.callOutView = [[CallOutView alloc] initWithFrame:CGRectMake(10, 10, 200, 34)];
 */
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.userInteractionEnabled = YES;
    }
    return _titleLabel;
}
- (CallOutView *)callOutView{
    if (!_callOutView) {
        _callOutView = [[CallOutView alloc] init];
        _callOutView.userInteractionEnabled = YES;
        _callOutView.backgroundColor = [UIColor clearColor];
    }
    return _callOutView;
}
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"blue" ofType:@"png"];
        _imageView.image = [UIImage imageNamed:@"blue"];//[UIImage imageWithContentsOfFile:path];
    }
    return _imageView;
}
- (void)customAnntionViewDidClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customViewDidSelected:annotationView:)]) {
        [self.delegate customViewDidSelected:self.annotation annotationView:self];
    }
}
- (void)updateCustomAnnotationView:(FFLoactionAnotation *)annotation{
    self.annotation = annotation;
    self.titleLabel.text = annotation.title;
    self.callOutView.click = annotation.selected ? YES : NO;
    [self.titleLabel sizeToFit];
    
    CGFloat h = self.titleLabel.bounds.size.height + 3 + 7;
    if (h < 34) {
        h = 34;
    }
    self.bounds = CGRectMake(0, 0, self.titleLabel.bounds.size.width + 6, h);
    /*
    self.callOutView.frame = CGRectMake(0, 0, width + 20, 34);
    self.titleLabel.frame = CGRectMake(3, -2, width + 20, 34);
    [self setNeedsDisplay];
    */
    if (annotation.selected) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"red" ofType:@"png"];
        self.imageView.image = [UIImage imageNamed:@"red"];//[UIImage imageWithContentsOfFile:path];
    }else{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"blue" ofType:@"png"];
        self.imageView.image = [UIImage imageNamed:@"blue"];//[UIImage imageWithContentsOfFile:path];
    }
    
    self.imageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    CGSize size = self.titleLabel.bounds.size;
    self.titleLabel.frame = CGRectMake(3, 3, size.width, size.height);
}

- (void)upDateWithSelectState:(BOOL)isSelect{
    if (isSelect) {
        self.imageView.image = [UIImage imageNamed:@"red"];
    }else{
        self.imageView.image = [UIImage imageNamed:@"blue"];
    }
}
@end