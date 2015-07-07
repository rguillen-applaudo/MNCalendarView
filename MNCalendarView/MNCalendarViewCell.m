//
//  MNCalendarViewCell.m
//  MNCalendarView
//
//  Created by Min Kim on 7/26/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarViewCell.h"

void MNContextDrawLine(CGContextRef c, CGPoint start, CGPoint end, CGColorRef color, CGFloat lineWidth) {
  CGContextSetAllowsAntialiasing(c, false);
  CGContextSetStrokeColorWithColor(c, color);
  CGContextSetLineWidth(c, lineWidth);
  CGContextMoveToPoint(c, start.x, start.y - (lineWidth/2.f));
  CGContextAddLineToPoint(c, end.x, end.y - (lineWidth/2.f));
  CGContextStrokePath(c);
  CGContextSetAllowsAntialiasing(c, true);
}

NSString *const MNCalendarViewCellIdentifier = @"MNCalendarViewCellIdentifier";

@interface MNCalendarViewCell()

@property(nonatomic,strong,readwrite) UILabel *titleLabel;

@end

@implementation MNCalendarViewCell

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = UIColor.whiteColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.titleLabel.font = [UIFont systemFontOfSize:14.f];
    self.titleLabel.textColor = [UIColor darkTextColor];
    self.titleLabel.highlightedTextColor = [UIColor lightGrayColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.userInteractionEnabled = NO;
    self.titleLabel.backgroundColor = [UIColor clearColor];
      
      self.monthNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 10.f)];
      self.monthNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
      self.monthNameLabel.font = [UIFont systemFontOfSize:8.f];
      self.monthNameLabel.textColor = [UIColor grayColor];
      self.monthNameLabel.highlightedTextColor = [UIColor lightGrayColor];
      self.monthNameLabel.textAlignment = NSTextAlignmentCenter;
      self.monthNameLabel.userInteractionEnabled = NO;
      self.monthNameLabel.backgroundColor = [UIColor clearColor];

      self.eventKindsView = [[UIView alloc] initWithFrame:CGRectMake(0, 36, 30, 8)];
      self.eventKindsView.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.titleLabel];
      [self.contentView addSubview:self.monthNameLabel];
      [self.contentView addSubview:self.eventKindsView];
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
      self.selectedBackgroundView.layer.cornerRadius = (25/2);
      self.selectedBackgroundView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
      self.selectedBackgroundView.layer.borderWidth = 1.0f;
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  self.contentView.frame = self.bounds;
  self.selectedBackgroundView.frame = CGRectMake(0, 0, 25, 25);
    self.selectedBackgroundView.center = self.contentView.center;
    self.eventKindsView.frame = CGRectMake((self.bounds.size.width / 2) - 15, 36, 30, 8);
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGColorRef separatorColor = self.separatorColor.CGColor;
  
  CGFloat pixel = 1.f / [UIScreen mainScreen].scale;
  MNContextDrawLine(context,
                    CGPointMake(0.f, self.bounds.size.height),
                    CGPointMake(self.bounds.size.width, self.bounds.size.height),
                    separatorColor,
                    pixel);
}

@end
