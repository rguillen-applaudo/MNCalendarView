//
//  MNCalendarView.m
//  MNCalendarView
//
//  Created by Min Kim on 7/23/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarView.h"
#import "MNCalendarViewLayout.h"
#import "MNCalendarViewDayCell.h"
#import "MNCalendarViewWeekdayCell.h"
// #import "MNCalendarHeaderView.h"
#import "MNFastDateEnumeration.h"
#import "NSDate+MNAdditions.h"

@interface MNCalendarView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic,strong,readwrite) UICollectionView *collectionView;
@property(nonatomic,strong,readwrite) UICollectionViewFlowLayout *layout;

@property(nonatomic,strong,readwrite) NSArray *monthDates;
@property(nonatomic,strong,readwrite) NSArray *weekdaySymbols;
@property(nonatomic,assign,readwrite) NSUInteger daysInWeek;

@property(nonatomic,strong,readwrite) NSDateFormatter *monthFormatter;

- (NSDate *)firstVisibleDateOfMonth:(NSDate *)date;
- (NSDate *)lastVisibleDateOfMonth:(NSDate *)date;

- (BOOL)dateEnabled:(NSDate *)date;
- (BOOL)canSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)applyConstraints;

@end

@implementation MNCalendarView

- (void)commonInit {
  self.calendar   = NSCalendar.currentCalendar;
  self.fromDate   = [NSDate.date mn_beginningOfDay:self.calendar];
  self.toDate     = [self.fromDate dateByAddingTimeInterval:MN_YEAR * 4];
  self.daysInWeek = 7;
  
  // self.headerViewClass  = MNCalendarHeaderView.class;
  self.weekdayCellClass = MNCalendarViewWeekdayCell.class;
  self.dayCellClass     = MNCalendarViewDayCell.class;
  
  _separatorColor = [UIColor colorWithRed:.85f green:.85f blue:.85f alpha:1.f];
  
  [self addSubview:self.collectionView];
  [self applyConstraints];
  [self reloadData];
}

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self commonInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder: aDecoder];
  if ( self ) {
    [self commonInit];
  }
  
  return self;
}

- (UICollectionView *)collectionView {
  if (nil == _collectionView) {
    MNCalendarViewLayout *layout = [[MNCalendarViewLayout alloc] init];

    _collectionView =
      [[UICollectionView alloc] initWithFrame:CGRectZero
                         collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor colorWithRed:.96f green:.96f blue:.96f alpha:1.f];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
      _collectionView.pagingEnabled = YES;
    
    [self registerUICollectionViewClasses];
  }
  return _collectionView;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
  _separatorColor = separatorColor;
}

- (void)setCalendar:(NSCalendar *)calendar {
  _calendar = calendar;
  
  self.monthFormatter = [[NSDateFormatter alloc] init];
  self.monthFormatter.calendar = calendar;
  [self.monthFormatter setDateFormat:@"MMMM yyyy"];
}

- (void)setSelectedDate:(NSDate *)selectedDate {
  _selectedDate = [selectedDate mn_beginningOfDay:self.calendar];
}

- (void)reloadData {
  NSMutableArray *monthDates = @[].mutableCopy;
  MNFastDateEnumeration *enumeration =
    [[MNFastDateEnumeration alloc] initWithFromDate:[self.fromDate mn_firstDateOfMonth:self.calendar]
                                             toDate:[self.toDate mn_firstDateOfMonth:self.calendar]
                                           calendar:self.calendar
                                               unit:NSMonthCalendarUnit];
  for (NSDate *date in enumeration) {
    [monthDates addObject:date];
  }
  self.monthDates = monthDates;
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.calendar = self.calendar;
  
  self.weekdaySymbols = formatter.shortWeekdaySymbols;
  
  [self.collectionView reloadData];
}

- (void)registerUICollectionViewClasses {
  [_collectionView registerClass:self.dayCellClass
      forCellWithReuseIdentifier:MNCalendarViewDayCellIdentifier];
  
  [_collectionView registerClass:self.weekdayCellClass
      forCellWithReuseIdentifier:MNCalendarViewWeekdayCellIdentifier];
  
  // [_collectionView registerClass:self.headerViewClass
  //     forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
  //            withReuseIdentifier:MNCalendarHeaderViewIdentifier];
}

- (NSDate *)firstVisibleDateOfMonth:(NSDate *)date {
  date = [date mn_firstDateOfMonth:self.calendar];
  
  NSDateComponents *components =
    [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                fromDate:date];
  
  return
    [[date mn_dateWithDay:-((components.weekday - 1) % self.daysInWeek) calendar:self.calendar] dateByAddingTimeInterval:MN_DAY];
}

- (NSDate *)lastVisibleDateOfMonth:(NSDate *)date {
  date = [date mn_lastDateOfMonth:self.calendar];
  
  NSDateComponents *components =
    [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                     fromDate:date];
  
  return
    [date mn_dateWithDay:components.day + (self.daysInWeek - 1) - ((components.weekday - 1) % self.daysInWeek)
                calendar:self.calendar];
}

- (void)applyConstraints {
  NSDictionary *views = @{@"collectionView" : self.collectionView};
  [self addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
                                           options:0
                                           metrics:nil
                                             views:views]];
  
  [self addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
                                           options:0
                                           metrics:nil
                                             views:views]
   ];
}

- (BOOL)dateEnabled:(NSDate *)date {
  if (self.delegate && [self.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)]) {
    return [self.delegate calendarView:self shouldSelectDate:date];
  }
  return YES;
}

- (BOOL)canSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  MNCalendarViewCell *cell = (MNCalendarViewCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];

  BOOL enabled = cell.enabled;

  if ([cell isKindOfClass:MNCalendarViewDayCell.class] && enabled) {
    MNCalendarViewDayCell *dayCell = (MNCalendarViewDayCell *)cell;

    enabled = [self dateEnabled:dayCell.date];
  }

  return enabled;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return self.monthDates.count;
}

// - (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
//            viewForSupplementaryElementOfKind:(NSString *)kind
//                                  atIndexPath:(NSIndexPath *)indexPath {
//   MNCalendarHeaderView *headerView =
//     [collectionView dequeueReusableSupplementaryViewOfKind:kind
//                                        withReuseIdentifier:MNCalendarHeaderViewIdentifier
//                                               forIndexPath:indexPath];

//   headerView.backgroundColor = self.collectionView.backgroundColor;
//   headerView.titleLabel.text = [self.monthFormatter stringFromDate:self.monthDates[indexPath.section]];

//   return headerView;
// }

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  NSDate *monthDate = self.monthDates[section];
  
  NSDateComponents *components =
    [self.calendar components:NSDayCalendarUnit
                     fromDate:[self firstVisibleDateOfMonth:monthDate]
                       toDate:[self lastVisibleDateOfMonth:monthDate]
                      options:0];
    // NSLog(@" %ld + %ld", self.daysInWeek, components.day);
  return self.daysInWeek + components.day + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

  if (indexPath.item < self.daysInWeek) {
    MNCalendarViewWeekdayCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:MNCalendarViewWeekdayCellIdentifier
                                                forIndexPath:indexPath];
    
    cell.backgroundColor = self.collectionView.backgroundColor;
//    cell.titleLabel.text = self.weekdaySymbols[indexPath.item];
     cell.titleLabel.text = @"";
    cell.separatorColor = self.separatorColor;
    return cell;
  }
  MNCalendarViewDayCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:MNCalendarViewDayCellIdentifier
                                              forIndexPath:indexPath];
  cell.separatorColor = self.separatorColor;
  
  NSDate *monthDate = self.monthDates[indexPath.section];
  NSDate *firstDateInMonth = [self firstVisibleDateOfMonth:monthDate];

  NSUInteger day = indexPath.item - self.daysInWeek;
  
  NSDateComponents *components =
    [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                     fromDate:firstDateInMonth];
  components.day += day;
  
  NSDate *date = [self.calendar dateFromComponents:components];
  [cell setDate:date
          month:monthDate
       calendar:self.calendar];
  
  if (cell.enabled) {
    [cell setEnabled:[self dateEnabled:date]];
  }

  if (self.selectedDate && cell.enabled) {
    [cell setSelected:[date isEqualToDate:self.selectedDate]];
  }
    
    [self cell:cell checkForEventsAtIndexPath:indexPath];
  
  return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self canSelectItemAtIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self canSelectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     // NSLog(@"CALENDAR DID SELECT ROW 1");
  MNCalendarViewCell *cell = (MNCalendarViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];

  if ([cell isKindOfClass:MNCalendarViewDayCell.class] && cell.enabled) {
    MNCalendarViewDayCell *dayCell = (MNCalendarViewDayCell *)cell;
    
    self.selectedDate = dayCell.date;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        // NSLog(@"CALENDAR DID SELECT ROW 2");
      [self.delegate calendarView:self didSelectDate:dayCell.date];
       // NSLog(@"CALENDAR DID SELECT ROW 3");
    }
    
    [self.collectionView reloadData];
  }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  CGFloat width      = self.bounds.size.width;
  CGFloat itemWidth  = roundf(width / self.daysInWeek);
  CGFloat itemHeight = indexPath.item < self.daysInWeek ? 0.f : 45.0f;
  
  NSUInteger weekday = indexPath.item % self.daysInWeek;
  
  if (weekday == self.daysInWeek - 1) {
    itemWidth = width - (itemWidth * (self.daysInWeek - 1));
  }
  
  return CGSizeMake(itemWidth, itemHeight);
}

- (void)cell:(MNCalendarViewDayCell *)cell checkForEventsAtIndexPath:(NSIndexPath *)indexPath{
    // TODO: get eventKinds from _eventKindsArray for date
    // Example:
    // _calendarKindsArray = [[NSMutableArray alloc] initWithArray:@[@{@"date" : @"10"}]];
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", @"10"];
    // NSArray *filteredArray = [_calendarKindsArray filteredArrayUsingPredicate:predicate];
    // id firstFoundObject = filteredArray.firstObject;
    // NSLog(@"Result: %@", firstFoundObject);
    // Example
    
    NSDictionary *eventKinds = @{
                                 @"date" : [cell date],
                                 @"has_practice" : @"1",
                                 @"has_meet" : @"1",
                                 @"has_meeting" : @"1"
                                 };
    BOOL hasPractice = [[eventKinds valueForKey:@"has_practice"] boolValue];
    BOOL hasMeet = [[eventKinds valueForKey:@"has_meet"] boolValue];
    BOOL hasMeeting = [[eventKinds valueForKey:@"has_meeting"] boolValue];
    
    
    [[[cell eventKindsView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *eventsKindArray = [[NSMutableArray alloc] initWithCapacity:2];
    if (hasPractice) {
        [eventsKindArray addObject:@{@"kind" : @"practice", @"color" : [UIColor blackColor]}];
    }
    if (hasMeet) {
        [eventsKindArray addObject:@{@"kind" : @"meet", @"color" : [UIColor grayColor]}];
    }
    if (hasMeeting) {
        [eventsKindArray addObject:@{@"kind" : @"meeting", @"color" : [UIColor lightGrayColor]}];
    }
    
    if (eventsKindArray.count > 0) {
        int item = 0;
        for (NSDictionary *eventKindItem in eventsKindArray) {
            if (eventsKindArray.count == 1) {
                if (item == 0) {
                    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(11, 0, 8, 8)];
                    [itemView setBackgroundColor:[eventKindItem valueForKey:@"color"]];
                    itemView.layer.cornerRadius = 4;
                    [[cell eventKindsView] addSubview:itemView];
                }
            }
            else if (eventsKindArray.count == 2){
                if (item == 0) {
                    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(3.5, 0, 8, 8)];
                    [itemView setBackgroundColor:[eventKindItem valueForKey:@"color"]];
                    itemView.layer.cornerRadius = 4;
                    [[cell eventKindsView] addSubview:itemView];
                }
                else if (item == 1){
                    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(18.5, 0, 8, 8)];
                    [itemView setBackgroundColor:[eventKindItem valueForKey:@"color"]];
                    itemView.layer.cornerRadius = 4;
                    [[cell eventKindsView] addSubview:itemView];
                }
            }
            else if (eventsKindArray.count ==3){
                if (item == 0) {
                    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 8, 8)];
                    [itemView setBackgroundColor:[eventKindItem valueForKey:@"color"]];
                    itemView.layer.cornerRadius = 4;
                    [[cell eventKindsView] addSubview:itemView];
                }
                else if (item == 1){
                    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(11, 0, 8, 8)];
                    [itemView setBackgroundColor:[eventKindItem valueForKey:@"color"]];
                    itemView.layer.cornerRadius = 4;
                    [[cell eventKindsView] addSubview:itemView];
                }
                else if (item == 2){
                    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(21, 0, 8, 8)];
                    [itemView setBackgroundColor:[eventKindItem valueForKey:@"color"]];
                    itemView.layer.cornerRadius = 4;
                    [[cell eventKindsView] addSubview:itemView];
                }
            }
            item += 1;
        }
    }
}

//-(BOOL)checkIfDate:(NSDate *)date hasEventKind:(NSString *)eventKind{
//    // TODO: check if date has event kind
//    // TODO: get event kinds from _calendarKindsArray for date
//    // TODO: get booleans from calendarKinds for date
//    // TODO: cache booleans for date
//    NSLog(@"check %@ event for %@", eventKind, date);
//    // TODO: return boolean for
//    return [self getYesOrNo];
//}
//
-(BOOL)getYesOrNo
{
    int tmp = (arc4random() % 30)+1;
    if(tmp % 5 == 0)
        return YES;
    return NO;
}

#pragma mark -
#pragma mark Scroll View delegate


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageHeight = _collectionView.frame.size.height;
    float currentPage = _collectionView.contentOffset.y / pageHeight;

    if (0.0f != fmodf(currentPage, 1.0f))
    {
//        pageControl.currentPage = currentPage + 1;
        currentPage += 1;
    }
    else
    {
//        pageControl.currentPage = currentPage;
    }

    NSLog(@"Changed Page Number : %f", currentPage);
    [self calendarChangedToPage:currentPage];
}

#pragma mark -
#pragma mark Scroll View delegate


-(void)calendarChangedToPage:(float)page{
  NSMutableArray *datesArray = [[NSMutableArray alloc] initWithCapacity:0];
  [_collectionView layoutIfNeeded];
    for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
        if ([cell isKindOfClass:MNCalendarViewDayCell.class]) {
            NSLog(@"DATE %@", [(MNCalendarViewDayCell *)cell date]);
            [datesArray addObject:[(MNCalendarViewDayCell *)cell date]];
        }
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject: descriptor];
    NSArray *sortedDatesArray = [datesArray sortedArrayUsingDescriptors:descriptors];
    
    NSLog(@"\n firts date %@ \n last date %@", [sortedDatesArray firstObject], [sortedDatesArray lastObject]);
    
    [_delegate calendarView:self shouldCheckEventKindsFromStartDate:[sortedDatesArray firstObject] toEndDate:[sortedDatesArray lastObject] inPage:page];
}

//

-(void)setCalendarKinds:(NSArray *)calendarKinds ForPage:(float)page{
    [_calendarKindsArray addObject:calendarKinds];
  [[self collectionView] reloadData];
}

-(BOOL)calendarKindsArrayHasArrayFor:(float)page{
  // TODO - RG - Check Main Array for page
    NSArray *targetPage = [_calendarKindsArray objectAtIndex:page-1];
    if (!targetPage){
        return NO;
    }
    
    return YES;
}

@end
