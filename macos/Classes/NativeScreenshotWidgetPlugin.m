#import "NativeScreenshotWidgetPlugin.h"

// This implementation is specific to macOS.
// For iOS, a separate implementation using UIKit would be required.
// See iOS implementation suggestions in the documentation.

@implementation NativeScreenshotWidgetPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    NativeScreenshotWidgetPlugin* instance = [[NativeScreenshotWidgetPlugin alloc] init];
    ScreenshotHostApiSetup(registrar.messenger, instance);
}


- (void)takeScreenshotWithCompletion:(nonnull void (^)(FlutterStandardTypedData * _Nullable, FlutterError * _Nullable))completion {
    @try {
        NSApplication *app = [NSApplication sharedApplication];
        NSWindow *window = [app mainWindow];
        
        // Check if window is available
        if (!window || !window.isVisible) {
            // App is not in foreground or window is not available
            // Find the app window by its bundle identifier
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            
            // Get all windows
            CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
            NSArray *windows = CFBridgingRelease(windowList);
            
            // Find our app's window
            CGWindowID targetWindowID = kCGNullWindowID;
            CGRect windowBounds = CGRectZero;
            
            for (NSDictionary *windowInfo in windows) {
                NSString *windowOwner = windowInfo[(id)kCGWindowOwnerName];
                NSString *windowName = windowInfo[(id)kCGWindowName];
                
                // Try to match by app name or bundle identifier
                if ([windowOwner containsString:@"Flutter"] || 
                    [windowOwner isEqualToString:[[NSProcessInfo processInfo] processName]] ||
                    [windowName containsString:bundleIdentifier]) {
                    targetWindowID = [windowInfo[(id)kCGWindowNumber] unsignedIntValue];
                    
                    // Get window bounds
                    CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)windowInfo[(id)kCGWindowBounds], &windowBounds);
                    break;
                }
            }
            
            if (targetWindowID != kCGNullWindowID) {
                // Capture the specific window
                CGImageRef cgImage = CGWindowListCreateImage(windowBounds, 
                                                           kCGWindowListOptionIncludingWindow, 
                                                           targetWindowID, 
                                                           kCGWindowImageBoundsIgnoreFraming);
                
                if (cgImage) {
                    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
                    
                    // Convert to JPEG directly
                    NSDictionary *properties = @{NSImageCompressionFactor: @0.9};
                    NSData *jpegData = [bitmapRep representationUsingType:NSBitmapImageFileTypeJPEG properties:properties];
                    
                    CGImageRelease(cgImage);
                    
                    if (jpegData) {
                        FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:jpegData];
                        completion(data, nil);
                        return;
                    } else {
                        @throw [NSException exceptionWithName:@"ImageConversionError" reason:@"Failed to convert image to JPEG" userInfo:nil];
                    }
                } else {
                    @throw [NSException exceptionWithName:@"ScreenCaptureError" reason:@"Failed to capture specific window" userInfo:nil];
                }
            } else {
                // Fallback to capturing the entire screen if we can't find the specific window
                CGImageRef cgImage = CGWindowListCreateImage(CGRectNull, 
                                                           kCGWindowListOptionOnScreenOnly, 
                                                           kCGNullWindowID, 
                                                           kCGWindowImageDefault);
                
                if (cgImage) {
                    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
                    
                    // Convert to JPEG directly
                    NSDictionary *properties = @{NSImageCompressionFactor: @0.9};
                    NSData *jpegData = [bitmapRep representationUsingType:NSBitmapImageFileTypeJPEG properties:properties];
                    
                    CGImageRelease(cgImage);
                    
                    if (jpegData) {
                        FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:jpegData];
                        completion(data, nil);
                        return;
                    } else {
                        @throw [NSException exceptionWithName:@"ImageConversionError" reason:@"Failed to convert image to JPEG" userInfo:nil];
                    }
                } else {
                    @throw [NSException exceptionWithName:@"ScreenCaptureError" reason:@"Failed to capture screen" userInfo:nil];
                }
            }
        } else {
            // Normal flow when app is in foreground
            NSView *view = [window contentView];
            
            NSRect bounds = [view bounds];
            NSBitmapImageRep *bitmapRep = [view bitmapImageRepForCachingDisplayInRect:bounds];
            [view cacheDisplayInRect:bounds toBitmapImageRep:bitmapRep];
            
            NSImage *image = [[NSImage alloc] initWithSize:bounds.size];
            [image addRepresentation:bitmapRep];
            
            // Convert directly to JPEG without going through TIFF
            NSDictionary *properties = @{NSImageCompressionFactor: @0.9};
            NSData *jpegData = [bitmapRep representationUsingType:NSBitmapImageFileTypeJPEG properties:properties];
            
            if (jpegData) {
                FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:jpegData];
                completion(data, nil);
            } else {
                @throw [NSException exceptionWithName:@"ImageConversionError" reason:@"Failed to convert image to JPEG" userInfo:nil];
            }
        }
    } @catch (NSException *exception) {
        // Improved error reporting
        NSString *errorMessage = [NSString stringWithFormat:@"Failed to take screenshot: %@", exception.reason];
        FlutterError *flutterError = [FlutterError errorWithCode:@"TakeScreenshotError"
                                                        message:errorMessage
                                                        details:exception.description];
        NSLog(@"Screenshot error: %@", exception);
        completion(nil, flutterError);
    } @finally {
        // Any cleanup code if needed
    }
}

@end
