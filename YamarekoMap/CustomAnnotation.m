//
//  CustomAnnotation.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/10/25.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation
@synthesize coordinate;

- (NSString *)title {
    return annotationTitle;
}

- (NSString *)subtitle {
    return annotationSubtitle;
}

- (id)initWithLocationCoordinate:(CLLocationCoordinate2D) _coordinate
                           title:(NSString *)_annotationTitle subtitle:(NSString *)_annotationSubtitle {
    coordinate = _coordinate;
    self->annotationTitle = _annotationTitle;
    self->annotationSubtitle = _annotationSubtitle;
    return self;
}

@end
