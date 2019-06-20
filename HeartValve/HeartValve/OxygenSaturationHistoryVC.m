//
//  OxygenSaturationHistoryVC.m
//  HeartValve
//
//  Created by Jonathan on 10/11/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "OxygenSaturationHistoryVC.h"
#import "OxygenSaturation.h"
#import "UserManager.h"
#import "DbManager.h"
#import <TelerikUI/TelerikUI.h>
#import "DateFormatters.h"

@interface OxygenSaturationHistoryVC ()
{
    NSMutableArray *history;
}

@end

@implementation OxygenSaturationHistoryVC

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
    
    [[UserManager sharedManager] getOxygenSaturation:^(NSMutableArray *measurements, NSError *error) {
        history = measurements;
        [history addObjectsFromArray:[[DbManager sharedManager] getOxygenSaturation]];
        
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
    
    OxygenSaturation *measurement = [history objectAtIndex:indexPath.row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%.f%% (%d bpm)", measurement.spO2.doubleValue, measurement.heartRate.intValue];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:measurement.readingDate];
    
    return cell;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if ([self.tabBarController.selectedViewController isKindOfClass:[OxygenSaturationHistoryVC class]])
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
    
    NSMutableArray *spO2Data = [NSMutableArray new];
    NSMutableArray *heartRateData = [NSMutableArray new];
    
    for (OxygenSaturation *measurement in [history subarrayWithRange:NSMakeRange(0, MIN(history.count, 10))])
    {
        TKChartDataPoint *spO2DataPoint = [[TKChartDataPoint alloc] initWithX:measurement.oxygenSaturationId Y:measurement.spO2];
        TKChartDataPoint *heartRateDataPoint = [[TKChartDataPoint alloc] initWithX:measurement.oxygenSaturationId Y:measurement.heartRate];
        
        [spO2Data addObject:spO2DataPoint];
        [heartRateData addObject:heartRateDataPoint];
    }
    
    TKChartLineSeries *spO2Series = [[TKChartLineSeries alloc] initWithItems:spO2Data];
    spO2Series.title = @"SpO2";
    spO2Series.style.pointShape = [TKPredefinedShape shapeWithType:TKShapeTypeCircle andSize:CGSizeMake(10, 10)];
    spO2Series.style.shapeMode = TKChartSeriesStyleShapeModeAlwaysShow;
    [chart addSeries:spO2Series];
    
    TKChartPaletteItem *spO2Item = [chart paletteItemForSeries:spO2Series atIndex:spO2Series.index];
    
    TKChartLineSeries *heartRateSeries = [[TKChartLineSeries alloc] initWithItems:heartRateData];
    heartRateSeries.title = @"Pulse";
    heartRateSeries.style.pointShape = [TKPredefinedShape shapeWithType:TKShapeTypeCircle andSize:CGSizeMake(10, 10)];
    heartRateSeries.style.shapeMode = TKChartSeriesStyleShapeModeAlwaysShow;
    [chart addSeries:heartRateSeries];
    
    TKChartPaletteItem *heartRateItem = [chart paletteItemForSeries:heartRateSeries atIndex:heartRateSeries.index];
    
    NSNumber *minSpO2 = [history valueForKeyPath:@"@min.spO2"];
    NSNumber *maxSpO2 = [history valueForKeyPath:@"@max.spO2"];
    
    minSpO2 = [NSNumber numberWithInt:100.0 * ceil((minSpO2.doubleValue / 100.0) - 1)];
    maxSpO2 = [NSNumber numberWithInt:100.0 * floor((maxSpO2.doubleValue / 100.0) + 1)];
    
    TKChartNumericAxis *spO2Axis = [[TKChartNumericAxis alloc] initWithMinimum:minSpO2 andMaximum:maxSpO2 position:TKChartAxisPositionLeft];
    spO2Axis.title = @"SpO2";
    spO2Axis.style.titleStyle.rotationAngle = M_PI_2 * 3.0;
    spO2Axis.style.titleStyle.textColor = [spO2Item.stroke color];
    spO2Axis.style.lineStroke = [TKStroke strokeWithColor:[spO2Item.stroke color]];
    spO2Axis.style.labelStyle.textColor = [spO2Item.stroke color];
    [chart addAxis:spO2Axis];
    
    NSNumber *minHeartRate = [history valueForKeyPath:@"@min.heartRate"];
    NSNumber *maxHeartRate = [history valueForKeyPath:@"@max.heartRate"];
    
    minHeartRate = [NSNumber numberWithInt:100.0 * ceil((minHeartRate.doubleValue / 100.0) - 1)];
    maxHeartRate = [NSNumber numberWithInt:100.0 * floor((maxHeartRate.doubleValue / 100.0) + 1)];
    
    TKChartNumericAxis *heartRateAxis = [[TKChartNumericAxis alloc] initWithMinimum:minHeartRate andMaximum:maxHeartRate position:TKChartAxisPositionRight];
    heartRateAxis.title = @"Pulse";
    heartRateAxis.style.titleStyle.rotationAngle = M_PI_2;
    heartRateAxis.style.titleStyle.textColor = [heartRateItem.stroke color];
    heartRateAxis.style.lineStroke = [TKStroke strokeWithColor:[heartRateItem.stroke color]];
    heartRateAxis.style.labelStyle.textColor = [heartRateItem.stroke color];
    [chart addAxis:heartRateAxis];
    
    chart.xAxis.style.labelStyle.textHidden = YES;
    chart.legend.hidden = YES;
    chart.legend.style.position = TKChartLegendPositionFloating;
    chart.legend.style.offsetOrigin = TKChartLegendOffsetOriginTopRight;
    chart.allowAnimations = YES;
    chart.userInteractionEnabled = NO;
}

@end
