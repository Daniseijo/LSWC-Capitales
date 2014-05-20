//
//  CapitalesViewController.m
//  Capitales
//
//  Created by g102 DIT UPM on 16/05/14.
//  Copyright (c) 2014 g102 DIT UPM. All rights reserved.
//

#import "CapitalesViewController.h"
#import "CapitalesCell.h"
#import "MapKit/MapKit.h"

#define OPE_W_URL @"http://api.openweathermap.org/data/2.5/weather"

@interface CapitalesViewController ()
@property (nonatomic, strong) NSArray *capitales;
@end

@implementation CapitalesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Carga lista de capitales
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cities" ofType:@"plist"];
    self.capitales = [NSArray arrayWithContentsOfFile:path];
    
    self.title = @"Capitales";
    self.navigationController.navigationBar.barTintColor = self.tableView.backgroundColor;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.capitales.count;
}

- (CapitalesCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CapitalesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Capital Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.nombreLabel.adjustsFontSizeToFitWidth = YES;
    cell.nubesLabel.adjustsFontSizeToFitWidth = YES;
    cell.nombreLabel.text = self.capitales[indexPath.row];
    MKCoordinateRegion reg;
    [cell.mapaCapital setRegion:reg];
    [self cargaCelda:cell atIndex:indexPath];
    return cell;
}

- (void)cargaCelda:(CapitalesCell *)cell atIndex:(NSIndexPath *)indexPath {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t queue = dispatch_queue_create("download queue", NULL);
    dispatch_async(queue, ^{
        NSDictionary *dic;
        NSString *capital = self.capitales[indexPath.row];
        NSString *s = [NSString stringWithFormat:@"%@?q=%@&units=metric&lang=sp", OPE_W_URL, capital];
        NSString *escapedURL = [s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:escapedURL];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        NSHTTPURLResponse *responseHTTP = nil;
        NSError *error =nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:req
                                             returningResponse:&responseHTTP
                                                         error:&error];
        if (data) {
            NSInteger statusCode = [responseHTTP statusCode];
            //NSLog(@"Código = %d", statusCode);
            if (statusCode != 200) {
                self.title = @"Error";
            } else {
                //parsear
                NSError *err;
                dic = [NSJSONSerialization JSONObjectWithData:data
                                                      options:NSJSONReadingMutableContainers
                                                        error:&err];
                if (!dic) {
                    NSLog(@"Error parsing JSON: %@", [err localizedDescription]);
                    return;
                }
            }
        } else {
            self.title = @"Error";
            NSLog(@"Error: %@", [error localizedFailureReason]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self parseDictionary:dic inCell:cell];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

- (void)parseDictionary:(NSDictionary *)dic inCell:(CapitalesCell *)cell {
    NSString *nubes = dic[@"weather"][0][@"description"];
    cell.nubesLabel.text = [nubes capitalizedString];
    
    NSNumber *nTemp = dic[@"main"][@"temp"];
    cell.tempLabel.text = [NSString stringWithFormat:@"%d ºC", nTemp.intValue];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSNumber *nDate = dic[@"sys"][@"sunrise"];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:nDate.doubleValue];
    cell.salSolLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
    
    nDate = dic[@"sys"][@"sunset"];
    date = [[NSDate alloc] initWithTimeIntervalSince1970:nDate.doubleValue];
    cell.ponSolLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
    
    NSNumber *nLatitude = dic[@"coord"][@"lat"];
    NSNumber *nLongitude = dic[@"coord"][@"lon"];
    MKCoordinateRegion reg;
    reg.center.latitude = nLatitude.floatValue;
    reg.center.longitude = nLongitude.floatValue;
    reg.span.latitudeDelta = 0.5;
    reg.span.longitudeDelta = 0.5;
    [cell.mapaCapital setRegion:reg animated: NO];
    cell.mapaCapital.mapType = MKMapTypeHybrid;
    cell.mapaCapital.userInteractionEnabled = NO;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
