//
//  DKTagCloudView.m
//  DKTagCloudViewDemo
//
//  Created by ZhangAo on 14-11-18.
//  Copyright (c) 2014年 zhangao. All rights reserved.
//

#import "DKTagCloudView.h"

@interface DKTagCloudView ()

@property (nonatomic, strong) NSMutableArray *labels;

@end

@implementation DKTagCloudView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userInteractionEnabled = YES;
    self.minFontSize = 14;
    self.maxFontSize = 60;
    self.randomColors = @[
                          [UIColor blackColor],
                          [UIColor cyanColor],
                          [UIColor purpleColor],
                          [UIColor orangeColor],
                          [UIColor redColor],
                          [UIColor yellowColor],
                          [UIColor lightGrayColor],
                          [UIColor grayColor],
                          [UIColor greenColor]
                          ];
}

- (UIColor *)randomColor {
    return self.randomColors[arc4random() % self.randomColors.count];
}

- (UIFont *)randomFont:(NSUInteger)numberOfTries {
	NSUInteger maxFontSize = (MAX(0, self.maxFontSize - numberOfTries * 2));
	NSUInteger randomSize = maxFontSize == 0 ? 0 : arc4random() % maxFontSize;
    return [UIFont systemFontOfSize:randomSize + self.minFontSize];
}

- (CGRect)randomFrameForLabel:(UILabel *)label {
    [label sizeToFit];
    CGFloat maxWidth = MAX(1, self.bounds.size.width - label.bounds.size.width);
    CGFloat maxHeight = MAX(1, self.bounds.size.height - label.bounds.size.height);
    
    return CGRectMake(arc4random() % (NSInteger)maxWidth, arc4random() % (NSInteger)maxHeight,
                      CGRectGetWidth(label.bounds), CGRectGetHeight(label.bounds));
}

- (BOOL)frameIntersects:(CGRect)frame {
    for (UILabel *label in self.labels) {
        if (CGRectIntersectsRect(frame, label.frame)) {
            return YES;
        }
    }
    return NO;
}

- (NSMutableArray *)labels {
    if (_labels == nil) {
        _labels = [NSMutableArray new];
    }
    return _labels;
}

- (void)generate {
	[self _generateWithTries:0];
}

- (void)_generateWithTries:(NSUInteger)numberOfGenerationPasses {
    [self.labels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.labels removeAllObjects];
    
    int i = 0;
    for (NSString *title in self.titls) {
        assert([title isKindOfClass:[NSString class]]);
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = i++;
        label.text = title;
        label.textColor = [self randomColor];
        
		NSUInteger numberOfTriesForLabel = 0;
		BOOL foundMatchingFrame;
        do {
			label.font = [self randomFont:numberOfTriesForLabel];
            label.frame = [self randomFrameForLabel:label];
			++numberOfTriesForLabel;
			
			if (numberOfTriesForLabel > 50) {
				
				if (numberOfGenerationPasses > 10) {
					NSLog(@"Could not find suitable cloud. Aborting");
					return;
				}
				
				NSLog(@"Could not find suitable cloud. Trying again");
				[self _generateWithTries:numberOfGenerationPasses + 1];
				return;
			}
			
			CGRect labelFrame = label.frame;
			BOOL frameIntersectsOtherLabel = [self frameIntersects:labelFrame];
			BOOL frameFitsInView = CGRectContainsRect(self.bounds, labelFrame);
			foundMatchingFrame = (frameIntersectsOtherLabel == NO && frameFitsInView);
        } while (foundMatchingFrame == NO);
        
        [self.labels addObject:label];
        [self addSubview:label];
        
        UITapGestureRecognizer *tagGestue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [label addGestureRecognizer:tagGestue];
        label.userInteractionEnabled = YES;
    }
}

- (void)handleGesture:(UIGestureRecognizer*)gestureRecognizer {
    UILabel *label = (UILabel *)gestureRecognizer.view;
    if (self.tagClickBlock) {
        self.tagClickBlock(label.text,label.tag);
    }
}

@end
