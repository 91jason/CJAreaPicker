//
//  CJAreaPicker.h
//  CJAreaPicker
//
//  Created by 曹 景成 on 14-1-22.
//  Copyright (c) 2014年 JasonCao. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *	@brief	地区类型
 */
typedef enum {
    CJPlaceTypeState = 0, /**< 省份类型 */
    CJPlaceTypeCity = 1,  /**< 市类型 */
    CJPlaceTypeArea = 2   /**< 区类型 */
}CJPlaceType;

@class CJAreaPicker;

/**
 *	@brief	地区选择器协议
 */
@protocol CJAreaPickerDelegate <NSObject>

@required

/**
 *	@brief	当地区选择器选中地区后
 *
 *	@param 	picker 	    选择器
 *  @param  address     选中的地址
 */
- (void)areaPicker:(CJAreaPicker *)picker didSelectAddress:(NSString *)address;

@end

/**
 *	@brief	地区选择器，基类为UITableViewController。数据从are.plist里取,到末级有选择提示。
 */

@interface CJAreaPicker : UITableViewController

/**
 *	@brief	地区类型(省/市/区)
 */
@property (nonatomic) CJPlaceType type;
/**
 *	@brief	Model放(省/市/区)数组
 */
@property (nonatomic, strong) NSArray *places;
/**
 *	@brief	当前已经选择的地区信息
 */
@property (nonatomic, strong) NSString *placeName;
/**
 *	@brief	当前用户所在的地区
 */
@property (nonatomic, strong) NSString *userlocation;
/**
 *	@brief	地区选择器协议委托
 */
@property (nonatomic, unsafe_unretained) IBOutlet id<CJAreaPickerDelegate>delegate;

@end
