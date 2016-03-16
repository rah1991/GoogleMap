//
//  ViewController.h
//  GoogleDirectionAPISample
//
//  Created by Rahul Mathur on 14/03/16.
//  Copyright © 2016 Rahul Mathur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
@interface ViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITextField *txtSource;
    
    __weak IBOutlet UITextField *txtDestination;
    __weak IBOutlet MKMapView *mapView;
    
    
    CLLocationManager *aManager;
    MKPolylineView *lineView;
    MKPolyline *aPL;
    
    GMSPlacesClient *placeClient;
    __weak IBOutlet UITableView *tblSource;
    __weak IBOutlet UITableView *tblDest;

    
    NSMutableArray *mutArrSource;
    NSMutableArray *mutArrDest;
    
    NSString *strSource;
    NSString *strDest;
}
- (IBAction)btnGetPathAction:(id)sender;

@end

