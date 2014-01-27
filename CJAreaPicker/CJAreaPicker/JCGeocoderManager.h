//
//  JCGeocoderManager.h
//  CJAreaPicker
//
//  Created by 曹 景成 on 14-1-22.
//  Copyright (c) 2014年 JasonCao. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Availability.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#ifdef kJCGeocoderManagerLocationServiceDisabledKey
#undef kJCGeocoderManagerLocationServiceDisabledKey
#endif
#define kJCGeocoderManagerLocationServiceDisabledKey @"kJCGeocoderManagerLocationServiceDisabledKey"

@class JCGeocoderManager;

@protocol JCGeocoderManagerDelegate <NSObject>

@optional
/**
 *	@brief	获取位置成功后
 *
 *	@param 	manager 	    manager自身
 *
 *	@param 	placemark 	    位置信息
 */
- (void)JCGeocoderManager:(JCGeocoderManager *)manager didFindPlacemark:(MKPlacemark *)placemark;
/**
 *	@brief	获取位置失败后
 *
 *	@param 	manager 	    manager自身
 *
 *	@param 	error 	        错误信息
 */
- (void)JCGeocoderManager:(JCGeocoderManager *)manager didFailWithError:(NSError *)error;

@end

@interface JCGeocoderManager : NSObject <CLLocationManagerDelegate
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 50000
, MKReverseGeocoderDelegate
#endif
> {
	CLLocationManager *_locationManager;
#ifdef __IPHONE_5_0
	CLGeocoder *_bestGeocoder;
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 50000
	MKReverseGeocoder *_normalGeocoder;
#endif
	id<JCGeocoderManagerDelegate> _delegate;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
#ifdef __IPHONE_5_0
@property (nonatomic, retain) CLGeocoder *bestGeocoder;
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 50000
@property (nonatomic, retain) MKReverseGeocoder *normalGeocoder;
#endif
@property (nonatomic, assign) id<JCGeocoderManagerDelegate> delegate;

+ (JCGeocoderManager *)sharedJCGeocoderManager;
- (void)start;
@end
