#import "RNMlKit.h"

#import <React/RCTBridge.h>

#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseMLVision/FirebaseMLVision.h>
#import <React/RCTImageLoader.h>

@implementation RNMlKit

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

static NSString *const detectionNoResultsMessage = @"Something went wrong";


- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

RCT_REMAP_METHOD(deviceTextRecognition, deviceTextRecognition:(NSString *)imagePath resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (!imagePath) {
        resolve(@NO);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FIRVision *vision = [FIRVision vision];
        FIRVisionTextRecognizer *textRecognizer = [vision onDeviceTextRecognizer];
        
        //NSDictionary *d = [[NSDictionary alloc] init];
        //if Base64
        UIImage *image = [self decodeBase64ToImage:imagePath];
        if (!image) {
            //If URI
            image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        }
        //UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        //NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];
        //UIImage *image = [UIImage imageWithData:imageData];
        
        if (!image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve(@NO);
            });
            return;
        }
        
        FIRVisionImage *handler = [[FIRVisionImage alloc] initWithImage:image];
        
        [textRecognizer processImage:handler completion:^(FIRVisionText *_Nullable result, NSError *_Nullable error) {
            if (error != nil || result == nil) {
                NSString *errorString = error ? error.localizedDescription : detectionNoResultsMessage;
                NSDictionary *pData = @{
                                        @"error": [NSMutableString stringWithFormat:@"On-Device text detection failed with error: %@", errorString],
                                        };
                // Running on background thread, don't call UIKit
                dispatch_async(dispatch_get_main_queue(), ^{
                    resolve(pData);
                });
                return;
            }
            
            //  CGRect boundingBox;
            //  CGSize size;
            //CGPoint origin;
            NSMutableArray *output = [NSMutableArray array];
            
            for (FIRVisionTextBlock *block in result.blocks) {
                NSMutableDictionary *blockDict = [NSMutableDictionary dictionary];
                NSMutableDictionary *bounding = [NSMutableDictionary dictionary];
                
                NSMutableDictionary *origin = [NSMutableDictionary dictionary];
                NSMutableDictionary *originRight = [NSMutableDictionary dictionary];
                NSMutableDictionary *center = [NSMutableDictionary dictionary];
                
                NSMutableDictionary *size = [NSMutableDictionary dictionary];
                blockDict[@"blockText"] = block.text;
                
                NSMutableArray *langsArray = [NSMutableArray array];
                for (FIRVisionTextRecognizedLanguage *lang in block.recognizedLanguages) {
                    if(lang.languageCode)
                        [langsArray addObject:lang.languageCode];
                }
                blockDict[@"recognized_lang"] = langsArray;
                
                
                
                // NSArray<NSValue *> *blockCornerPoints = block.cornerPoints;
                CGRect blockFrame = block.frame;
                origin[@"x"] = @(blockFrame.origin.x);
                origin[@"y"] = @(blockFrame.origin.y);
                
                originRight[@"x"] = @(blockFrame.origin.x+blockFrame.size.width);
                originRight[@"y"] = @(blockFrame.origin.y);
                center[@"x"] = @(blockFrame.origin.x +(blockFrame.size.width/2));
                center[@"y"] = @(blockFrame.origin.y+ (blockFrame.size.height/2));
                size[@"width"]= @(blockFrame.size.width);
                size[@"height"]= @(blockFrame.size.height);
                
                
                bounding[@"origin"] = origin;
                bounding[@"origin_right"] = originRight;
                bounding[@"center"] = center;
                bounding[@"size"] = size;
                
                //NSMutableDictionary *blockDict2 = block.;
                
                blockDict[@"bounding"] = bounding;
                //[output addObject:blocks];
                NSMutableArray *linesArray = [NSMutableArray array];
                for (FIRVisionTextLine *line in block.lines) {
                    NSMutableDictionary *lineDict = [NSMutableDictionary dictionary];
                    
                    NSMutableDictionary *bounding = [NSMutableDictionary dictionary];
                    NSMutableDictionary *origin = [NSMutableDictionary dictionary];
                    NSMutableDictionary *originRight = [NSMutableDictionary dictionary];
                    NSMutableDictionary *center = [NSMutableDictionary dictionary];
                    
                    NSMutableDictionary *size = [NSMutableDictionary dictionary];
                    
                    lineDict[@"lineText"] = line.text;
                    
                    NSMutableArray *langsArray = [NSMutableArray array];
                    for (FIRVisionTextRecognizedLanguage *lang in line.recognizedLanguages) {
                        if(lang.languageCode)
                            [langsArray addObject:lang.languageCode];
                    }
                    lineDict[@"recognized_lang"] = langsArray;
                    
                    CGRect lineFrame = line.frame;
                    origin[@"x"] = @(lineFrame.origin.x);
                    origin[@"y"] = @(lineFrame.origin.y);
                    originRight[@"x"] = @(blockFrame.origin.x+blockFrame.size.width);
                    originRight[@"y"] = @(blockFrame.origin.y);
                    center[@"x"] = @(blockFrame.origin.x +(blockFrame.size.width/2));
                    center[@"y"] = @(blockFrame.origin.y+ (blockFrame.size.height/2));
                    size[@"width"]= @(lineFrame.size.width);
                    size[@"height"]= @(lineFrame.size.height);
                    
                    
                    bounding[@"origin"] = origin;
                    bounding[@"origin_right"] = originRight;
                    bounding[@"center"] = center;
                    bounding[@"size"] = size;
                    
                    //NSMutableDictionary *blockDict2 = block.;
                    
                    lineDict[@"bounding"] = bounding;
                    
                    ///[output addObject:lines];
                    NSMutableArray *elementsArray = [NSMutableArray array];
                    for (FIRVisionTextElement *element in line.elements) {
                        NSMutableDictionary *elementDict = [NSMutableDictionary dictionary];
                        
                        NSMutableDictionary *bounding = [NSMutableDictionary dictionary];
                        NSMutableDictionary *origin = [NSMutableDictionary dictionary];
                        NSMutableDictionary *originRight = [NSMutableDictionary dictionary];
                        NSMutableDictionary *center = [NSMutableDictionary dictionary];
                        NSMutableDictionary *size = [NSMutableDictionary dictionary];
                        
                        
                        elementDict[@"elementText"] = element.text;
                        
                        NSMutableArray *langsArray = [NSMutableArray array];
                        for (FIRVisionTextRecognizedLanguage *lang in element.recognizedLanguages) {
                            if(lang.languageCode)
                                [langsArray addObject:lang.languageCode];
                        }
                        elementDict[@"recognized_lang"] = langsArray;
                        
                        CGRect elementFrame = element.frame;
                        origin[@"x"] = @(elementFrame.origin.x);
                        origin[@"y"] = @(elementFrame.origin.y);
                        originRight[@"x"] = @(blockFrame.origin.x+blockFrame.size.width);
                        originRight[@"y"] = @(blockFrame.origin.y);
                        center[@"x"] = @(blockFrame.origin.x +(blockFrame.size.width/2));
                        center[@"y"] = @(blockFrame.origin.y+ (blockFrame.size.height/2));
                        size[@"width"]= @(elementFrame.size.width);
                        size[@"height"]= @(elementFrame.size.height);
                        
                        
                        bounding[@"origin"] = origin;
                        bounding[@"origin_right"] = originRight;
                        bounding[@"center"] = center;
                        bounding[@"size"] = size;
                        
                        //NSMutableDictionary *blockDict2 = block.;
                        
                        elementDict[@"bounding"] = bounding;
                        
                        [elementsArray addObject:elementDict];
                        
                    }
                    lineDict[@"elements"] = elementsArray;
                    [output addObject:lineDict];
                }
               // blockDict[@"lines"] = linesArray;
               // [output addObject:blockDict];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve(output);
            });
        }];
    });
}
@end

