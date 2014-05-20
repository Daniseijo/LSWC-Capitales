//
//  CapitalesCell.h
//  Capitales
//
//  Created by g102 DIT UPM on 19/05/14.
//  Copyright (c) 2014 g102 DIT UPM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CapitalesCell : UITableViewCell
@property (weak, nonatomic) IBOutlet MKMapView *mapaCapital;
@property (weak, nonatomic) IBOutlet UILabel *nombreLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *salSolLabel;
@property (weak, nonatomic) IBOutlet UILabel *ponSolLabel;
@property (weak, nonatomic) IBOutlet UILabel *nubesLabel;
@end
