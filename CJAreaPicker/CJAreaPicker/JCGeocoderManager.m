//
//  JCGeocoderManager.m
//  CJAreaPicker
//
//  Created by 曹 景成 on 14-1-22.
//  Copyright (c) 2014年 JasonCao. All rights reserved.
//


#import "JCGeocoderManager.h"

#define kIsSysVersionGreaterThan(kVersionString) ([[[UIDevice currentDevice] systemVersion] compare:(kVersionString)] == NSOrderedDescending)
#define kIsSysVersionGreaterThanOrEqualTo(kVersionString) ([[[UIDevice currentDevice] systemVersion] compare:(kVersionString)] != NSOrderedAscending)
#define kIsSysVersionLessThan(kVersionString) ([[[UIDevice currentDevice] systemVersion] compare:(kVersionString)] == NSOrderedAscending)
#define kIsSysVersionLessThanOrEqualTo(kVersionString) ([[[UIDevice currentDevice] systemVersion] compare:(kVersionString)] != NSOrderedDescending)

#define kStrictSingletonForClass(__CLASS_NAME__) \
static __CLASS_NAME__ *shared##__CLASS_NAME__ = nil;\
+ (__CLASS_NAME__ *)shared##__CLASS_NAME__ {\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
shared##__CLASS_NAME__ = [[super allocWithZone:NULL] init];\
});\
return shared##__CLASS_NAME__;\
}\
+ (id)allocWithZone:(NSZone *)zone {\
return [__CLASS_NAME__ shared##__CLASS_NAME__];\
}\
- (id)copyWithZone:(NSZone *)zone {\
return self;\
}\
- (id)retain {\
return self;\
}\
- (NSUInteger)retainCount {\
return NSUIntegerMax;\
}\
- (oneway void)release {\
}\
- (id)autorelease {\
return self;\
}

@interface JCGeocoderManager ()
#ifdef __IPHONE_5_0
- (void)bestGeocode:(CLLocation *)location;
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 50000
- (void)normalGeocode:(CLLocation *)location;
#endif
- (void)locationServiceDisabled;
- (void)cleanLocationManager;
- (void)cleanGeocoder;
@end

@implementation JCGeocoderManager

@synthesize locationManager = _locationManager;
#ifdef __IPHONE_5_0
@synthesize bestGeocoder = _bestGeocoder;
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 50000
@synthesize normalGeocoder = _normalGeocoder;
#endif
@synthesize delegate = _delegate;

kStrictSingletonForClass(JCGeocoderManager)

- (void)start {
	if ([JCGeocoderManager sharedJCGeocoderManager].locationManager == nil) {
		CLLocationManager *lm = [CLLocationManager new];
		[lm setDelegate:[JCGeocoderManager sharedJCGeocoderManager]];
		[JCGeocoderManager sharedJCGeocoderManager].locationManager = lm;
		[lm release];
	}
#ifdef __IPHONE_4_0
	if (kIsSysVersionGreaterThanOrEqualTo(@"4.0")) {
		if ([CLLocationManager locationServicesEnabled] == NO) {
			[[JCGeocoderManager sharedJCGeocoderManager] locationServiceDisabled];
			return;
		}
	} else {
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 40000
		if (kIsSysVersionLessThan(@"4.0")) {
			if ([JCGeocoderManager sharedJCGeocoderManager].locationManager.locationServicesEnabled == NO) {
				[[JCGeocoderManager sharedJCGeocoderManager] locationServiceDisabled];
				return;
			}
		}
#endif
#ifdef __IPHONE_4_0
	}
#endif
	[[JCGeocoderManager sharedJCGeocoderManager].locationManager startUpdatingLocation];
}

- (void)locationServiceDisabled {
	[[JCGeocoderManager sharedJCGeocoderManager] cleanLocationManager];
	NSError *error = [NSError errorWithDomain:kCLErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"Location Service Disabled" forKey:kJCGeocoderManagerLocationServiceDisabledKey]];
	if ([[JCGeocoderManager sharedJCGeocoderManager].delegate respondsToSelector:@selector(JCGeocoderManager:didFailWithError:)]) {
		[[JCGeocoderManager sharedJCGeocoderManager].delegate JCGeocoderManager:[JCGeocoderManager sharedJCGeocoderManager] didFailWithError:error];
	}
}

#pragma mark - 及时停用定位功能
- (void)cleanLocationManager {
	if ([JCGeocoderManager sharedJCGeocoderManager].locationManager) {
		[[JCGeocoderManager sharedJCGeocoderManager].locationManager stopUpdatingLocation];
		[JCGeocoderManager sharedJCGeocoderManager].locationManager.delegate = nil;
		[JCGeocoderManager sharedJCGeocoderManager].locationManager = nil;
	}
	NSLog(@"已清理LocationManager!");
}

- (void)cleanGeocoder {
#ifdef __IPHONE_5_0
	if ([JCGeocoderManager sharedJCGeocoderManager].bestGeocoder) {
		[[JCGeocoderManager sharedJCGeocoderManager].bestGeocoder cancelGeocode];
		[JCGeocoderManager sharedJCGeocoderManager].bestGeocoder = nil;
	}
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 50000
	if ([JCGeocoderManager sharedJCGeocoderManager].normalGeocoder) {
		[[JCGeocoderManager sharedJCGeocoderManager].normalGeocoder cancel];
		[JCGeocoderManager sharedJCGeocoderManager].normalGeocoder.delegate = nil;
		[JCGeocoderManager sharedJCGeocoderManager].normalGeocoder = nil;
	}
#endif
	NSLog(@"已清理Geocoder!");
}

#ifdef __IPHONE_5_0
- (void)bestGeocode:(CLLocation *)location {
	NSLog(@"%s", __func__);
	if ([JCGeocoderManager sharedJCGeocoderManager].bestGeocoder == nil) {
		CLGeocoder *geocoder = [CLGeocoder new];
		[JCGeocoderManager sharedJCGeocoderManager].bestGeocoder = geocoder;
		[geocoder release];
	}
	[[JCGeocoderManager sharedJCGeocoderManager].bestGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		[[JCGeocoderManager sharedJCGeocoderManager] cleanGeocoder];
		if (placemarks) {
			if ([[JCGeocoderManager sharedJCGeocoderManager].delegate respondsToSelector:@selector(JCGeocoderManager:didFindPlacemark:)]) {
				[[JCGeocoderManager sharedJCGeocoderManager].delegate JCGeocoderManager:[JCGeocoderManager sharedJCGeocoderManager] didFindPlacemark:[placemarks lastObject]];
			}
		} else {
			if ([[JCGeocoderManager sharedJCGeocoderManager].delegate respondsToSelector:@selector(JCGeocoderManager:didFailWithError:)]) {
				[[JCGeocoderManager sharedJCGeocoderManager].delegate JCGeocoderManager:[JCGeocoderManager sharedJCGeocoderManager] didFailWithError:error];
			}
		}
	}];
}
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 50000
- (void)normalGeocode:(CLLocation *)location {
	NSLog(@"%s", __func__);
	CLLocationCoordinate2D newLC2D = [location coordinate];
	if ([JCGeocoderManager sharedJCGeocoderManager].normalGeocoder == nil) {
		MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLC2D];
		geocoder.delegate = [JCGeocoderManager sharedJCGeocoderManager];
		[JCGeocoderManager sharedJCGeocoderManager].normalGeocoder = geocoder;
		[geocoder release];
	}
	[[JCGeocoderManager sharedJCGeocoderManager].normalGeocoder start];
}
#endif

#pragma mark - CLLocationManagerDelegate
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	NSTimeInterval howRecent = [newLocation.timestamp timeIntervalSinceNow];
	if (ABS(howRecent) < 1.0f) {
		[[JCGeocoderManager sharedJCGeocoderManager] cleanLocationManager];
#ifdef __IPHONE_5_0
		if (kIsSysVersionGreaterThanOrEqualTo(@"5.0")) {
			[[JCGeocoderManager sharedJCGeocoderManager] bestGeocode:newLocation];
		} else {
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 50000
			[[JCGeocoderManager sharedJCGeocoderManager] normalGeocode:newLocation];
#endif
#ifdef __IPHONE_5_0
		}
#endif
	}
}
#endif

#ifdef __IPHONE_6_0
- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
	CLLocation *location = [locations lastObject];
	NSTimeInterval howRecent = [location.timestamp timeIntervalSinceNow];
	if (ABS(howRecent) < 1.0f) {
		[[JCGeocoderManager sharedJCGeocoderManager] cleanLocationManager];
		[[JCGeocoderManager sharedJCGeocoderManager] bestGeocode:location];
	}
}
#endif

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	[[JCGeocoderManager sharedJCGeocoderManager] cleanLocationManager];
	if ([[JCGeocoderManager sharedJCGeocoderManager].delegate respondsToSelector:@selector(JCGeocoderManager:didFailWithError:)]) {
		[[JCGeocoderManager sharedJCGeocoderManager].delegate JCGeocoderManager:[JCGeocoderManager sharedJCGeocoderManager] didFailWithError:error];
	}
}

#pragma mark - MKReverseGeocoderDelegate
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 50000
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	[[JCGeocoderManager sharedJCGeocoderManager] cleanGeocoder];
	if ([[JCGeocoderManager sharedJCGeocoderManager].delegate respondsToSelector:@selector(JCGeocoderManager:didFindPlacemark:)]) {
		[[JCGeocoderManager sharedJCGeocoderManager].delegate JCGeocoderManager:[JCGeocoderManager sharedJCGeocoderManager] didFindPlacemark:placemark];
	}
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	[[JCGeocoderManager sharedJCGeocoderManager] cleanGeocoder];
	if ([[JCGeocoderManager sharedJCGeocoderManager].delegate respondsToSelector:@selector(JCGeocoderManager:didFailWithError:)]) {
		[[JCGeocoderManager sharedJCGeocoderManager].delegate JCGeocoderManager:[JCGeocoderManager sharedJCGeocoderManager] didFailWithError:error];
	}
}
#endif
@end
