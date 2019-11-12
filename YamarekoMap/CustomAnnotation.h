//
//  CustomAnnotation.h
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/10/25.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    IBOutlet NSString *annotationTitle;
    IBOutlet NSString *annotationSubtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithLocationCoordinate:(CLLocationCoordinate2D) _coordinate
                           title:(NSString *)_annotationTitle subtitle:(NSString *)_annotationannSubtitle;
@property (nonatomic, assign)NSInteger tag;
@property (nonatomic, strong)NSString* buf;
- (NSString *)title;
- (NSString *)subtitle;

@end
