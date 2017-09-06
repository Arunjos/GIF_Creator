//
//  ViewController.m
//  CreateGifImages
//
//  Created by user on 22/02/16.
//  Copyright © 2016 Qburst. All rights reserved.
//

#import "ViewController.h"

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

//Class Declaration of NumberPair
@interface NumberPair : NSObject
@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@end

//Class Implementation of NumberPair
@implementation NumberPair
@synthesize x, y;
@end

//Class Declaration of ImageResolution
@interface ImageResolution : NSObject
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) float resolutionScale;
@end

//Class Implementation of ImageResolution
@implementation ImageResolution
@synthesize width, height, resolutionScale;
@end

//Main Class Declaration
@interface ViewController ()

@end


//Main Class Implementation
@implementation ViewController

//Global Variable Declaration
NSMutableArray* xyValuePairs;
ImageResolution* imageResolution;
NSMutableArray* listOfImages;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Sample Data add to input array
    xyValuePairs = [[NSMutableArray alloc] init];
    NumberPair *newPair = [[NumberPair alloc] init];
    newPair.x = 20;
    newPair.y = 25;
    [xyValuePairs addObject:newPair];
    
    newPair = [[NumberPair alloc] init];
    newPair.x = 20;
    newPair.y = 50;
    [xyValuePairs addObject:newPair];
    
    newPair = [[NumberPair alloc] init];
    newPair.x = 21;
    newPair.y = 50;
    [xyValuePairs addObject:newPair];
    
    /* NOTES REGARDING RESOLUTION OF IMAGE */
    
        /* NOTE1:- The resolution of the image will be the product of image size and resolutionScale
            For Example:- if width = 100,height = 150,resolutionScale = 10
            Then resolution will be 1000 X 1500 (100*10 = 1000, 150*10 = 1500)
         */
    
        /* NOTE2:- If the resolutionScale is Zero then it will automatically choose a resolution whatever is right for the current device
         */
    
    /* RESOLUTION NOTES ENDED :-) */
    
    //Setting sample data for dimensions and resolution of image
    imageResolution = [[ImageResolution alloc] init];
    imageResolution.width = 100;
    imageResolution.height = 100;
    imageResolution.resolutionScale = 25;
    
    //Calling the getimage function with pixelsarray as parameter
    UIImage* resultImage = [self getImageForPixelArray:xyValuePairs];
    [self.imageView setImage:resultImage];
    
    //Sample Data add to listOfImages array
    listOfImages = [[NSMutableArray alloc] init];
    [listOfImages addObject:[UIImage imageNamed:@"image0.png"]];
    [listOfImages addObject:[UIImage imageNamed:@"image1.png"]];
    [listOfImages addObject:[UIImage imageNamed:@"image2.png"]];
    
    //Calling Gif Image creating function with listOfImages as parameter
    NSString* resultGifImagePath = [self exportAnimatedGif:listOfImages]; //You can load your image from resultGifImagePath and able to do whatever you want
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:resultGifImagePath]]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIImage* )getImageForPixelArray:(NSMutableArray*)pixelArray {
    if(pixelArray.count != 0) {
        
        
        // begin a graphics context of sufficient size
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageResolution.width,imageResolution.height), NO, imageResolution.resolutionScale);
        
        // get the context for CoreGraphics
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        // set stroking color and draw circle
        [[UIColor blackColor] setStroke];
        
        //Draw the pixels
        for (NumberPair* coordinatespair in pixelArray){
    
             CGContextFillRect(ctx, CGRectMake(coordinatespair.x, coordinatespair.y,1,1));
           
        }
        // make image out of bitmap context
        UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // free the context
        UIGraphicsEndImageContext();
        

        return retImage;
        
    }else{
        
        NSLog(@"The pixelArray is empty");
        return nil;
    }
    
}

- (NSString*)exportAnimatedGif:(NSMutableArray*)listOfImages
{
    
    float totalImageFrames = [listOfImages count];
    float timeOfChangingFrames = 1; // In Seconds
    NSString* nameOfOutputGifImage = @"animated1.gif";
    
    //NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"animated.gif"];
    NSString *path = [NSTemporaryDirectory() stringByAppendingString:[@"/" stringByAppendingString:nameOfOutputGifImage]];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path],
                                                                        kUTTypeGIF,
                                                                        totalImageFrames,
                                                                        NULL);
    
    NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:timeOfChangingFrames] forKey:(NSString *)kCGImagePropertyGIFDelayTime]
                                                                forKey:(NSString *)kCGImagePropertyGIFDictionary];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount]
                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];
    
    for (UIImage* image in listOfImages) {
        CGImageDestinationAddImage(destination, image.CGImage, (CFDictionaryRef)frameProperties);
    }
    
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    NSLog(@"animated GIF file created at %@", path);
    
    return path;
}

@end
