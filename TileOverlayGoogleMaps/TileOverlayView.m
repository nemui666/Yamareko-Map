//     File: TileOverlayView.m
// Abstract: 
//     MKOverlayView subclass to display a raster tiled map overlay.
//   
//  Version: 1.0
// 
// Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
// Inc. ("Apple") in consideration of your agreement to the following
// terms, and your use, installation, modification or redistribution of
// this Apple software constitutes acceptance of these terms.  If you do
// not agree with these terms, please do not use, install, modify or
// redistribute this Apple software.
// 
// In consideration of your agreement to abide by the following terms, and
// subject to these terms, Apple grants you a personal, non-exclusive
// license, under Apple's copyrights in this original Apple software (the
// "Apple Software"), to use, reproduce, modify and redistribute the Apple
// Software, with or without modifications, in source and/or binary forms;
// provided that if you redistribute the Apple Software in its entirety and
// without modifications, you must retain this notice and the following
// text and disclaimers in all such redistributions of the Apple Software.
// Neither the name, trademarks, service marks or logos of Apple Inc. may
// be used to endorse or promote products derived from the Apple Software
// without specific prior written permission from Apple.  Except as
// expressly stated in this notice, no other rights or licenses, express or
// implied, are granted by Apple herein, including but not limited to any
// patent rights that may be infringed by your derivative works or by other
// works in which the Apple Software may be incorporated.
// 
// The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
// MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
// THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
// OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
// 
// IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
// MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
// AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
// STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// 
// Copyright (C) 2010 Apple Inc. All Rights Reserved.
//

#import "TileOverlayView.h"
#import "TileOverlay.h"

@implementation TileOverlayView

@synthesize tileAlpha;

- (id)initWithOverlay:(id <MKOverlay>)overlay
{
    if (self = [super initWithOverlay:overlay]) {
        tileAlpha = 1.0; // 0.75 // base map alpha
        _manualRecoding = NO;
        // ディレクトリパス取得
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        cacheDirPath = [array objectAtIndex:0];
    }
    return self;
}

- (BOOL)canDrawMapRect:(MKMapRect)mapRect
             zoomScale:(MKZoomScale)zoomScale
{
    // Return YES only if there are some tiles in this mapRect and at this zoomScale.
    
    TileOverlay *tileOverlay = (TileOverlay *)self.overlay;
    NSArray *tilesInRect = [tileOverlay tilesInMapRect:mapRect zoomScale:zoomScale];
    
    return [tilesInRect count] > 0;    
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{
    TileOverlay *tileOverlay = (TileOverlay *)self.overlay;
    NSArray *tilesInRect = [tileOverlay tilesInMapRect:mapRect zoomScale:zoomScale];
    CGContextSetAlpha(context, tileAlpha);
    
    for (ImageTile *tile in tilesInRect) {
        // For each image tile, draw it in its corresponding MKMapRect frame
        CGRect rect = [self rectForMapRect:tile.frame];
        
        // ローカルから取得
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *directory = [paths objectAtIndex:0];
        NSString *filePath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"yamareko_map/cache/%@.png",tile.imagePath]];
       
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
        //NSLog(@"IMG: %@", tile.imagePath);
        
        if (image == nil && _manualRecoding) {
            // 国土地理
            NSString *strUrl = [[NSString alloc] initWithFormat:@"http://cyberjapandata.gsi.go.jp/xyz/std/%@.png", tile.imagePath];
            //NSString *strUrl = [[NSString alloc] initWithFormat:@"http://nemui.m48.coreserver.jp/web/yamarekomap/getImageMap/%@.png", tile.imagePath];
            
            //NSLog(@"Loading tile from URL %@", path);
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
            image = [[UIImage alloc] initWithData:imgData];
            
            // ディレクトリ作成
            NSArray* path = [strUrl pathComponents];
            NSString *newCacheDirPath = [cacheDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"yamareko_map/cache/%@/%@",path[4],path[5]]];
            
            // 次にFileManagerを用いて、ディレクトリの作成を行います。
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error2 = nil;
            BOOL created = [fileManager createDirectoryAtPath:newCacheDirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error2];
            // 作成に失敗した場合は、原因をログに出します。
            if (!created) {
                NSLog(@"failed to create directory. reason is %@ - %@", error2, error2.userInfo);
            }
            
            // 保存する先のパス
            NSString *savedPath = [newCacheDirPath stringByAppendingPathComponent:path[6]];
            
            // 保存処理を行う。
            fileManager = [NSFileManager defaultManager];
            NSError* error = nil;
            BOOL success = [fileManager createFileAtPath:savedPath contents:imgData attributes:nil];
            if (!success) {
                NSLog(@"failed to save image. reason is %@ - %@", error, error.userInfo);
            }
        }
        if (image != nil) {
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
            CGContextScaleCTM(context, 1/zoomScale, 1/zoomScale);
            CGContextTranslateCTM(context, 0, image.size.height);
            CGContextScaleCTM(context, 1, -1);
            CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
            CGContextRestoreGState(context);
        }
    }
}

@end