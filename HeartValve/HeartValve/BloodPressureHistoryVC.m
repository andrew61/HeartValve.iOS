//
//  BloodPressureHistoryVC.m
//  MyHealthApp
//
//  Created by Jonathan on 2/28/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "BloodPressureHistoryVC.h"
#import "BloodPressureMeasurement.h"
#import "UserManager.h"
#import "DbManager.h"
#import <TelerikUI/TelerikUI.h>
#import "DateFormatters.h"

@interface BloodPressureHistoryVC ()
{
    NSMutableArray *history;
}

@end

@implementation BloodPressureHistoryVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.view.frame.size.width > self.view.frame.size.height)
    {
        self.tableView.hidden = YES;
        self.chartView.hidden = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.tabBarController.tabBar setHidden:YES];
    }
    else
    {
        self.tableView.hidden = NO;
        self.chartView.hidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.tabBarController.tabBar setHidden:NO];
    }
    
    [[UserManager sharedManager] getBloodPressureMeasurements:^(NSMutableArray *measurements, NSError *error) {
        history = measurements;
        [history addObjectsFromArray:[[DbManager sharedManager] getBloodPressureMeasurements]];
        
        if ([history count] > 0)
        {
            [self loadChart];
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [history count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HistoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    BloodPressureMeasurement *measurement = [history objectAtIndex:indexPath.row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d/%d (%d bpm)", measurement.systolic.intValue, measurement.diastolic.intValue, measurement.pulse.intValue];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:measurement.readingDate];
    
    return cell;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if ([self.tabBarController.selectedViewController isKindOfClass:[BloodPressureHistoryVC class]])
        {
            if (size.width > size.height)
            {
                self.tableView.hidden = YES;
                self.chartView.hidden = NO;
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                [self.navigationController setNavigationBarHidden:YES animated:YES];
                [self.tabBarController.tabBar setHidden:YES];
            }
            else
            {
                self.tableView.hidden = NO;
                self.chartView.hidden = YES;
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                [self.navigationController setNavigationBarHidden:NO animated:YES];
                [self.tabBarController.tabBar setHidden:NO];
            }
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

- (void)loadChart
{
    TKChart *chart = [[TKChart alloc] initWithFrame:CGRectInset(self.chartView.bounds, 5, 5)];
    chart.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.chartView addSubview:chart];
    
    NSMutableArray *systolicData = [NSMutableArray new];
    NSMutableArray *diastolicData = [NSMutableArray new];
    
    for (BloodPressureMeasurement *measurement in [history subarrayWithRange:NSMakeRange(0, MIN(history.count, 10))])
    {
        TKChartDataPoint *systolicDataPoint = [[TKChartDataPoint alloc] initWithX:measurement.bloodPressureId Y:measurement.systolic];
        [systolicData addObject:systolicDataPoint];
        
        TKChartDataPoint *diastolicDataPoint = [[TKChartDataPoint alloc] initWithX:measurement.bloodPressureId Y:measurement.diastolic];
        [diastolicData addObject:diastolicDataPoint];
    }
    
    TKChartLineSeries *systolicSeries = [[TKChartLineSeries alloc] initWithItems:systolicData];
    systolicSeries.title = @"Systolic";
    systolicSeries.style.pointShape = [TKPredefinedShape shapeWithType:TKShapeTypeCircle andSize:CGSizeMake(10, 10)];
    systolicSeries.style.shapeMode = TKChartSeriesStyleShapeModeAlwaysShow;
    [chart addSeries:systolicSeries];
    
    TKChartLineSeries *diastolicSeries = [[TKChartLineSeries alloc] initWithItems:diastolicData];
    diastolicSeries.title = @"Diastolic";
    diastolicSeries.style.pointShape = [TKPredefinedShape shapeWithType:TKShapeTypeCircle andSize:CGSizeMake(10, 10)];
    diastolicSeries.style.shapeMode = TKChartSeriesStyleShapeModeAlwaysShow;
    [chart addSeries:diastolicSeries];
    
    TKChartNumericAxis *yAxis = [[TKChartNumericAxis alloc] initWithMinimum:@20 andMaximum:@200 position:TKChartAxisPositionLeft];
    [chart addAxis:yAxis];
    
    chart.xAxis.style.labelStyle.textHidden = YES;
    chart.legend.hidden = NO;
    chart.legend.style.position = TKChartLegendPositionFloating;
    chart.legend.style.offsetOrigin = TKChartLegendOffsetOriginTopRight;
    chart.allowAnimations = YES;
    chart.userInteractionEnabled = NO;
}

@end
