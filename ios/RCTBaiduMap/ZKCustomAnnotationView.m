//
//  ZKCustomAnnotationView.m
//  RCTBaiduMap
//
//  Created by 杨继鹏 on 2017/10/23.
//  Copyright © 2017年 lovebing.org. All rights reserved.
//

#import "ZKCustomAnnotationView.h"
#import "ZKLoactionAnotation.h"

@interface ZKCustomAnnotationView()

@end

@implementation ZKCustomAnnotationView

- (instancetype)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        
        if ([annotation isKindOfClass:[ZKLoactionAnotation class]]) {
            ZKLoactionAnotation *zkAnn = (ZKLoactionAnotation *)annotation;
            
            UIImageView *leftImage = [[UIImageView alloc] init];
            leftImage.image = [UIImage imageNamed:@"main_marker"];
            [self addSubview:leftImage];
            
            UILabel *label = [[UILabel alloc] init];
            label.text = zkAnn.title;
            label.textColor = [UIColor darkGrayColor];
            [label sizeToFit];
            CGSize labelSize = label.bounds.size;
            
            
            UIView *rightView = [self creatRightViewWithHeight:labelSize.height + 14];
            leftImage.frame = CGRectMake(0, 0, label.bounds.size.width + 12, rightView.bounds.size.height + 7);
            [self addSubview:rightView];
            
            CGFloat h = rightView.bounds.size.height;
            if (h < leftImage.bounds.size.height) {
                h = leftImage.bounds.size.height;
            }
            self.bounds = CGRectMake(0, 0, leftImage.bounds.size.width + rightView.bounds.size.width, h);
            
            label.frame = CGRectMake(7, 5, labelSize.width, labelSize.height);
            [self addSubview:label];
            
            CGSize s = rightView.frame.size;
            leftImage.frame = self.bounds;
            rightView.frame = CGRectMake(self.bounds.size.width - s.width - 1, 0, s.width, s.height);
            
            leftImage.image = [self fixImage:[UIImage imageNamed:@"main_marker"] oriImageSize:CGSizeMake(77, 21) targetSize:leftImage.bounds.size];
            //[[UIImage imageNamed:@"main_marker"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 17, 10) resizingMode:UIImageResizingModeStretch];
            
        }
        
    }
    return self;
}

- (UIView *)creatRightViewWithHeight:(CGFloat)height{
    UIImageView *bg = [[UIImageView alloc] init];
    bg.image = [UIImage imageNamed:@"location_right"];
    
    UIImageView *arrow = [[UIImageView alloc] init];
    arrow.image = [UIImage imageNamed:@"cus_arrow"];
    [bg addSubview:arrow];
    
    UILabel *daoH = [[UILabel alloc] init];
    daoH.text = @"导航";
    daoH.textColor = [UIColor whiteColor];
    [daoH sizeToFit];
    CGSize size = daoH.bounds.size;
    [bg addSubview:daoH];
    
    arrow.frame = CGRectMake(7, (height - 13)/2, 12, 13);
    daoH.frame = CGRectMake(CGRectGetMaxX(arrow.frame) + 5, 0, size.width, height);
    daoH.textAlignment = NSTextAlignmentCenter;
    
    bg.bounds = CGRectMake(0, 0, daoH.bounds.size.width + arrow.bounds.size.width + 12 + 7, height);
    
    return bg;
}

- (UIImage *)fixImage:(UIImage *)image oriImageSize:(CGSize)oriSize targetSize:(CGSize)targetSize{
    UIImage *temp = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 10, oriSize.width - 6) resizingMode:UIImageResizingModeStretch];
    
    CGFloat tempWidth = targetSize.width/2+oriSize.width/2;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tempWidth, targetSize.height), NO, 1);
    [temp drawInRect:CGRectMake(0, 0, tempWidth, targetSize.height)];
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [newImg resizableImageWithCapInsets:UIEdgeInsetsMake(5, tempWidth - 6, 10, 5) resizingMode:UIImageResizingModeStretch];
}


@end
