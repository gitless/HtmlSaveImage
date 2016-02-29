//
//  UnpreventableUILongPressGestureRecognizer.m
//  ImageSaveDemo
//
//  Created by v on 16/2/26.
//  Copyright © 2016年 v. All rights reserved.
//

#import "UnpreventableUILongPressGestureRecognizer.h"

@implementation UnpreventableUILongPressGestureRecognizer

//UIGestureRecognizerDelegate有两个没公开的函数，只要重载了就会被调用。即所有的UIGestureRecognizer子类.delegate = someInstance; 经过set以后，只要这个delegate实例里有这两个函数，就会被调用进入。经过验证，这两个api是可以通过apple审查上app store的。

//只需要实现这一个私有函数即可.
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return NO;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer canPreventGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//   
//    return YES;
//}
@end
