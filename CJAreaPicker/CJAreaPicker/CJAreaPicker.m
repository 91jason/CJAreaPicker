//
//  CJAreaPicker.m
//  CJAreaPicker
//
//  Created by 曹 景成 on 14-1-22.
//  Copyright (c) 2014年 JasonCao. All rights reserved.
//

#import "CJAreaPicker.h"
#import "JCGeocoderManager.H"

@interface CJAreaPicker ()<JCGeocoderManagerDelegate>

@end

@implementation CJAreaPicker

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
    
    if (self.type == CJPlaceTypeState) {
        
        self.title = @"选择地区";
        
        _places = [NSMutableArray array];
        _places = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area.plist" ofType:nil]];
        [self.tableView reloadData];
        
        JCGeocoderManager *manager = [JCGeocoderManager sharedJCGeocoderManager];
        manager.delegate = self;
        [[JCGeocoderManager sharedJCGeocoderManager] start];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAnimated:)];
        self.navigationItem.leftBarButtonItem = backButton;
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- Action

/**
 *	@brief	选定地区事件
 *
 *	@param 	sender 	    事件传递值
 */
- (void)comfirmAction:(id)sender {
    
    NSString *place;
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    switch (self.type) {
        case CJPlaceTypeState:
            
            if (indexPath.section == 1) {
                place =  _places[indexPath.row][@"state"];
            }else{
                place = _userlocation;
            }
            
            break;
        case CJPlaceTypeCity:
            
            place = [NSString stringWithFormat:@"%@ %@",_placeName,_places[indexPath.row][@"city"]];
            
            break;
        case CJPlaceTypeArea:
            place = [NSString stringWithFormat:@"%@ %@",_placeName,_places[indexPath.row]];
            break;
        default:
            break;
    }
    
    
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(areaPicker:didSelectAddress:)]) {
        
        [_delegate areaPicker:self didSelectAddress:place];
        
    }
}

#pragma mark -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.type == CJPlaceTypeState) {
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && self.type == CJPlaceTypeState) {
        return 1;
    }else{
       return _places.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifer = @"UITableViewCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    
    switch (self.type) {
        case CJPlaceTypeState:
            if (indexPath.section == 0) {
                
                cell.textLabel.text = _userlocation.length > 0 ? [NSString stringWithFormat:@"%@",_userlocation] : @"正在定位...";
            }else{
                cell.textLabel.text = _places[indexPath.row][@"state"];
            }
            break;
        case CJPlaceTypeCity:
            cell.textLabel.text = _places[indexPath.row][@"city"];
            break;
        case CJPlaceTypeArea:
            cell.textLabel.text = _places[indexPath.row];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.type == CJPlaceTypeState) {
        switch (section) {
            case 0:
                return @"当前地区";
                break;
            case 1:
                return @"全国";
                break;
                
            default:
                return Nil;
                break;
        }
    }else{
        return nil;
    }
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CJAreaPicker *nextPicker = [[CJAreaPicker alloc]initWithStyle:UITableViewStylePlain];
    nextPicker.delegate = self.delegate;
    
    switch (self.type) {
        case CJPlaceTypeState:
            if (indexPath.section == 0) {
                
            }else{
                nextPicker.places    =  _places[indexPath.row][@"cities"];
                nextPicker.type = CJPlaceTypeCity;
                nextPicker.title =  _places[indexPath.row][@"state"];
                nextPicker.placeName = nextPicker.title;
            }
            
            
            break;
        case CJPlaceTypeCity:
            
            nextPicker.places   = _places[indexPath.row][@"areas"];
            nextPicker.type = CJPlaceTypeArea;
            nextPicker.title =  _places[indexPath.row][@"city"];
            nextPicker.placeName = [NSString stringWithFormat:@"%@ %@",_placeName,nextPicker.title];
            
            break;
        case CJPlaceTypeArea:
            
            break;
        default:
            break;
    }
    
    if (nextPicker.places.count>0) {
        [self.navigationController pushViewController:nextPicker animated:YES];
    }else{
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(comfirmAction:)];
        
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return (_userlocation.length<1 && self.type ==CJPlaceTypeState &&indexPath.section == 0) ? nil : indexPath;
}

#pragma mark -- JCGeocoderManagerDelegate

- (void)JCGeocoderManager:(JCGeocoderManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"%@", [NSString stringWithFormat:@"无法确定您所在的城市:%@", [error localizedDescription]]);
}

- (void)JCGeocoderManager:(JCGeocoderManager *)manager didFindPlacemark:(MKPlacemark *)placemark {
    
    NSDictionary *addressDictionary = placemark.addressDictionary;
    
    _userlocation = [NSString stringWithFormat:@"%@ %@ %@",[addressDictionary objectForKey:(id)kABPersonAddressStateKey],[addressDictionary objectForKey:(id)kABPersonAddressCityKey],[addressDictionary objectForKey:@"SubLocality"]];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
