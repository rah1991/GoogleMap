//
//  ViewController.m
//  GoogleDirectionAPISample
//
//  Created by Rahul Mathur on 14/03/16.
//  Copyright © 2016 Rahul Mathur. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [GMSServices provideAPIKey:@"AIzaSyAYoljT0p3GG_j3xN0VbBgglXvZjpNHR_k"];
    mutArrDest = [[NSMutableArray alloc]init];
    mutArrSource = [[NSMutableArray alloc]init];
    [tblDest setHidden:YES];
    [tblSource setHidden:YES];

    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)btnGetPathAction:(id)sender {
    [tblSource setHidden:YES];
    [tblDest setHidden:YES];
    [self drawPath];
}
-(void)drawPath{
    NSString *aStrURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&key=AIzaSyAYoljT0p3GG_j3xN0VbBgglXvZjpNHR_k",txtSource.text ,txtDestination.text];
    NSURL *aUrl = [NSURL URLWithString:    [aStrURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *aData = [NSData dataWithContentsOfURL:aUrl];
//    NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:aData options:NSJSONReadingMutableLeaves error:nil]);
    if([[[NSJSONSerialization JSONObjectWithData:aData options:NSJSONReadingMutableLeaves error:nil] objectForKey:@"routes"] count]>0   ){
        NSArray *responseArray = [[[[[[NSJSONSerialization JSONObjectWithData:aData options:NSJSONReadingMutableLeaves error:nil] objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"steps"];
        [mapView removeOverlay:aPL];
        for (MKOverlayView *overlaysad in mapView.overlays) {
            [mapView removeOverlay:overlaysad];
        }
        
        NSMutableArray *aMutArrCoordinates = [NSMutableArray new];
        
        for (int i =0; i<responseArray.count; i++) {
            aPL = nil;
            aPL = [self polylineWithEncodedString:responseArray[i][@"polyline"][@"points"]];
            [mapView addOverlay:aPL];
            float latitude = [[[[responseArray objectAtIndex:i] objectForKey:@"start_location"] objectForKey:@"lat"] floatValue];
            float longitude = [[[[responseArray objectAtIndex:i] objectForKey:@"start_location"] objectForKey:@"lng"] floatValue];
            CLLocation *aLocation  = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
            [aMutArrCoordinates addObject:aLocation];
        }
        
        float sourceLat = [[[[responseArray firstObject] objectForKey:@"start_location"] objectForKey:@"lat"] floatValue];
        float sourceLng = [[[[responseArray firstObject] objectForKey:@"start_location"] objectForKey:@"lng"] floatValue];
        
        
        float destLat = [[[[responseArray lastObject] objectForKey:@"end_location"] objectForKey:@"lat"] floatValue];
        float destLng = [[[[responseArray lastObject] objectForKey:@"end_location"] objectForKey:@"lng"] floatValue];
        
        
//        CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:sourceLat longitude:sourceLng];
//        CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:destLat longitude:destLng];
//        CLLocationDistance d = [pointALocation distanceFromLocation:pointBLocation];
//
//        MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(sourceLat, sourceLng), 2*d, 2*d);
//        [mapView setRegion:r animated:YES];
        
        
        
        float maxLat = -200;
        float maxLong = -200;
        float minLat = MAXFLOAT;
        float minLong = MAXFLOAT;
        
        for (int i=0 ; i<[aMutArrCoordinates count] ; i++) {
            CLLocationCoordinate2D location = (CLLocationCoordinate2D)[[aMutArrCoordinates objectAtIndex:i]coordinate ];
            
            if (location.latitude < minLat) {
                minLat = location.latitude;
            }
            
            if (location.longitude < minLong) {
                minLong = location.longitude;
            }
            
            if (location.latitude > maxLat) {
                maxLat = location.latitude;
            }
            
            if (location.longitude > maxLong) {
                maxLong = location.longitude;
            }
        }
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat + minLat) * 0.5, (maxLong + minLong) * 0.5);
       
        CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:sourceLat longitude:sourceLng];
        CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:destLat longitude:destLng];
        CLLocationDistance d = [pointALocation distanceFromLocation:pointBLocation];
        
        MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(center, 2*d, 2*d);
        [mapView setRegion:r animated:YES];

//        [mapView regionThatFits:r];
//        CLLocationCoordinate2D noLocation;
//        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500,           500);
//        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
//        [mapView setRegion:adjustedRegion animated:YES];
//        mapView.showsUserLocation = YES;
        
    }
   
}

- (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString {
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
    free(coords);
    
    return polyline;
}
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:aPL];
    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 1;
    return routeLineRenderer;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == tblSource) {
        return mutArrSource.count;
    }else{
        return mutArrDest.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == tblSource) {
        UITableViewCell* aCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        GMSAutocompletePrediction *aPrediction = [mutArrSource objectAtIndex:indexPath.row];
        aCell.textLabel.text = aPrediction.attributedFullText.string;
        [aCell.textLabel setFont:[UIFont systemFontOfSize:10]];
        [aCell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [aCell.textLabel setAdjustsFontSizeToFitWidth:YES];
        return aCell;
    }else{
        UITableViewCell* aCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        GMSAutocompletePrediction *aPrediction = [mutArrDest objectAtIndex:indexPath.row];
        aCell.textLabel.text = aPrediction.attributedFullText.string;
        [aCell.textLabel setFont:[UIFont systemFontOfSize:10]];
        [aCell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [aCell.textLabel setAdjustsFontSizeToFitWidth:YES];
        return aCell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==tblSource) {
        GMSAutocompletePrediction *aPrediction = [mutArrSource objectAtIndex:indexPath.row];
        strSource = aPrediction.attributedFullText.string;
        txtSource.text = strSource;
    }else{
        GMSAutocompletePrediction *aPrediction = [mutArrDest objectAtIndex:indexPath.row];
        strDest = aPrediction.attributedFullText.string;
        txtDestination.text = strDest;
    }
    [tblSource setHidden:YES];
    [tblDest setHidden:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField==txtSource) {
        if (mutArrSource.count>0) {
            [tblSource setHidden:NO];
        }
        [tblDest setHidden:YES];

    }else{
        if (mutArrDest.count>0) {
            [tblDest setHidden:NO];
        }
        [tblSource setHidden:YES];

    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    GMSPlacesClient *aPLaceClent = [[GMSPlacesClient alloc]init];
    [aPLaceClent autocompleteQuery:textField.text bounds:nil filter:nil callback:^(NSArray<GMSAutocompletePrediction *> * _Nullable results, NSError * _Nullable error) {
        if (results) {
            if ([txtSource isFirstResponder]) {
                [mutArrSource removeAllObjects];
                [mutArrSource addObjectsFromArray:results];
                [tblSource setHidden:NO];
                [tblSource reloadData];
                
            }else{
                [mutArrDest     removeAllObjects];
                [mutArrDest addObjectsFromArray:results];
                [tblDest setHidden:NO];
                [tblDest reloadData];
            }
//            for (int i =0; i<results.count; i++) {
//                GMSAutocompletePrediction *aPrediction = results[i];
//                
//                NSLog(@"%@",aPrediction.attributedPrimaryText.string);
//            }
            
        }
    }];
    return YES;
    
    
    
}
@end
