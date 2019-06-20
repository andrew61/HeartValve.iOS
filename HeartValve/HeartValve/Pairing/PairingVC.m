//
//  PairingVC.m
//  HeartValve
//
//  Created by Jameson B on 10/31/17.
//  Copyright © 2017 MUSC. All rights reserved.
//

#import "PairingVC.h"

@interface PairingVC ()

@end

@implementation PairingVC
{
    NSArray *tableData;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *pulseOxiSerialNumber =[[NSUserDefaults standardUserDefaults]
                                     stringForKey:@"pulseOxiSerialNumber"];
    NSLog(@"serialNumber: %@",pulseOxiSerialNumber);
    tableData = [NSArray arrayWithObjects:@"AND Weight Scale", @"AND BP Monitor", @"Pulse Oximeter",@"Back To Login", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return @"Pairing Devices";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellResue" forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    cell.textLabel.font = [cell.textLabel.font fontWithSize:24];
    if(indexPath.row == 3){
        cell.imageView.image = [UIImage imageNamed:@"back"];
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WeightScalePairingVC"];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if(indexPath.row == 1){
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BPMonitorPairingVC"];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if(indexPath.row == 2){
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PulseOximeterPairingVC"];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if(indexPath.row == 3){
//        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
//        [self presentViewController:vc animated:YES completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];

    }

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
