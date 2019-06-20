//
//  MainViewController.m
//
//
#import "MainViewController.h"
#import "BPStep2ViewController.h"
#import "BPStep1ViewController.h"


@interface MainViewController ()

@end

@implementation MainViewController
@synthesize indexValue = _indexValue;



- (void)viewDidLoad
{
    
    [self setupDefaults];
    
    
    
}
- (BOOL)shouldAutorotate {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    
}


-(void)viewDidAppear:(BOOL)animated{
}

- (void)setupDefaults
{
    self.viewControllerIDArr = @[@"BPStep2ViewController", @"BPStep1ViewController"];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    
    self.pageViewController.dataSource = self;
    
    UIViewController *secondViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.viewControllerIDArr[1]];
    
    NSArray *viewControllers = @[secondViewController];
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    
    [self.view addSubview:_pageViewController.view];
    
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Page View Controller Data Source

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    
    if ([viewController isKindOfClass:[BPStep2ViewController class]]) {
        
        
        BPStep1ViewController * step1 = [self.storyboard instantiateViewControllerWithIdentifier:@"BPStep1ViewController"];
        
        return  step1;
        
    }
    
    else return nil;
    
}


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    
    if ([viewController isKindOfClass:[BPStep1ViewController class]]) {
        BPStep2ViewController * step2 = [self.storyboard instantiateViewControllerWithIdentifier:@"BPStep2ViewController"];
        return step2;
        
    }
    
    else return nil;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
