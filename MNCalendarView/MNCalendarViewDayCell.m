//
//  MNCalendarViewDayCell.m
//  MNCalendarView
//
//  Created by Min Kim on 7/28/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarViewDayCell.h"

NSString *const MNCalendarViewDayCellIdentifier = @"MNCalendarViewDayCellIdentifier";

@interface MNCalendarViewDayCell()

@property(nonatomic,strong,readwrite) NSDate *date;
@property(nonatomic,strong,readwrite) NSDate *month;
@property(nonatomic,assign,readwrite) NSUInteger weekday;

@end

@implementation MNCalendarViewDayCell

- (void)setDate:(NSDate *)date
          month:(NSDate *)month
       calendar:(NSCalendar *)calendar {
  
  self.date     = date;
  self.month    = month;
  self.calendar = calendar;
  
  NSDateComponents *components =
  [self.calendar components:NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                   fromDate:self.date];
  
  NSDateComponents *monthComponents =
  [self.calendar components:NSMonthCalendarUnit
                   fromDate:self.month];
  
  self.weekday = components.weekday;
  self.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)components.day];
    
  self.enabled = monthComponents.month == components.month;
    
    if ([[NSString stringWithFormat:@"%ld", (long)components.day] isEqualToString:@"1"]) {
        if (self.enabled) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMMM"];
            NSString *stringFromDate = [formatter stringFromDate:self.month];
            self.monthNameLabel.text = [NSString stringWithFormat:@"%@", stringFromDate];
        }
    }else{
        self.monthNameLabel.text = @"";
    }
  
  [self setNeedsDisplay];
}

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  
  self.titleLabel.textColor =
  self.enabled ? [UIColor colorWithRed:53.0f/255.0f green:57.0f/255.0f blue:64.0f/255.0f alpha:1.0f] : UIColor.lightGrayColor;
  
  self.backgroundColor =
  self.enabled ? UIColor.whiteColor : [UIColor colorWithRed:241.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGColorRef separatorColor = self.separatorColor.CGColor;
  
  CGSize size = self.bounds.size;
  
  // if (self.weekday != 7) {
  //   CGFloat pixel = 1.f / [UIScreen mainScreen].scale;
  //   MNContextDrawLine(context,
  //                     CGPointMake(size.width - pixel, pixel),
  //                     CGPointMake(size.width - pixel, size.height),
  //                     separatorColor,
  //                     pixel);
  // }
}

- (void)prepareForReuse
{
    [[[self eventKindsView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [super prepareForReuse];
    
}

@end
