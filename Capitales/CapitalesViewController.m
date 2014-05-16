//
//  CapitalesViewController.m
//  Capitales
//
//  Created by g102 DIT UPM on 16/05/14.
//  Copyright (c) 2014 g102 DIT UPM. All rights reserved.
//

#import "CapitalesViewController.h"
#import "MapKit/MapKit.h"

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Capital Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.capitales[indexPath.row];
    [self cargaMapa:self.capitales[indexPath.row]];
    return cell;
}

#define OPE_W_URL @"http://api.openweathermap.org/data/2.5/weather"

- (void)cargaMapa:(NSString *)capital {
    self.title = @"Cargando...";
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    dispatch_queue_t queue = dispatch_queue_create("download queue", NULL);
    dispatch_async(queue, ^{
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
                [self parseWeather:data];
            }
        } else {
            self.title = @"Error";
            NSLog(@"Error: %@", [error localizedFailureReason]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

- (void)parseWeather:(NSData *)data {
    NSDictionary *dic;
    NSError *err;
    dic = [NSJSONSerialization JSONObjectWithData:data
                                          options:NSJSONReadingMutableContainers
                                            error:&err];
    if (!dic) {
        NSLog(@"Error parsing JSON: %@", [err localizedDescription]);
        return;
    }
    
    // Log main keys
    for (NSString *key in [dic allKeys]) {
        if ([key isEqualToString:@"name"])
        NSLog(@"KEY = %@ -> %@", key, dic[key]);
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
