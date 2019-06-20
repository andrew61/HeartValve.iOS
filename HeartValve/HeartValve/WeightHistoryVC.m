//
//  WeightHistoryVC.m
//  MyHealthApp
//
//  Created by Jonathan on 2/29/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "WeightHistoryVC.h"
#import "WeightMeasurement.h"
#import "UserManager.h"
#import "DbManager.h"
#import <TelerikUI/TelerikUI.h>
#import "DateFormatters.h"

@interface WeightHistoryVC ()
{
    NSMutableArray *history;
}

@end

@implementation WeightHistoryVC

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
    
    [[UserManager sharedManager] getWeightMeasurements:^(NSMutableArray *measurements, NSError *error) {
        history = measurements;
        [history addObjectsFromArray:[[DbManager sharedManager] getWeightMeasurements]];
        
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
    
    WeightMeasurement *measurement = [history objectAtIndex:indexPath.row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%.f", measurement.weight.floatValue];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:measurement.readingDate];
    
    return cell;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if ([self.tabBarController.selectedViewController isKindOfClass:[WeightHistoryVC class]])
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
    
    NSMutableArray *data = [NSMutableArray new];
    
    for (WeightMeasurement *measurement in [history subarrayWithRange:NSMakeRange(0, MIN(history.count, 10))])
    {
        TKChartDataPoint *dataPoint = [[TKChartDataPoint alloc] initWithX:measurement.weightId Y:[NSNumber numberWithInt:measurement.weight.intValue]];
        [data addObject:dataPoint];
    }
    
    TKChartAreaSeries *series = [[TKChartAreaSeries alloc] initWithItems:data];
    series.title = @"Weight";
    series.style.pointShape = [TKPredefinedShape shapeWithType:TKShapeTypeCircle andSize:CGSizeMake(10, 10)];
    series.style.shapeMode = TKChartSeriesStyleShapeModeAlwaysShow;
    [chart addSeries:series];
    
    NSNumber *minWeight = [history valueForKeyPath:@"@min.weight"];
    NSNumber *maxWeight = [history valueForKeyPath:@"@max.weight"];
    
    minWeight = [NSNumber numberWithInt:100.0 * ceil((minWeight.doubleValue / 100.0) - 1)];
    maxWeight = [NSNumber numberWithInt:100.0 * floor((maxWeight.doubleValue / 100.0) + 1)];
    
    TKChartNumericAxis *weightAxis = [[TKChartNumericAxis alloc] initWithMinimum:minWeight andMaximum:maxWeight position:TKChartAxisPositionLeft];
    [chart addAxis:weightAxis];
    
    chart.xAxis.style.labelStyle.textHidden = YES;
    chart.legend.hidden = YES;
    chart.legend.style.position = TKChartLegendPositionFloating;
    chart.legend.style.offsetOrigin = TKChartLegendOffsetOriginTopRight;
    chart.allowAnimations = YES;
    chart.userInteractionEnabled = NO;
}

@end