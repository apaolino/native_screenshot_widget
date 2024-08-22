#import "NativeScreenshotWidgetPlugin.h"

@implementation NativeScreenshotWidgetPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    NativeScreenshotWidgetPlugin* instance = [[NativeScreenshotWidgetPlugin alloc] init];
    ScreenshotHostApiSetup(registrar.messenger, instance);
}


- (void)takeScreenshotWithCompletion:(nonnull void (^)(FlutterStandardTypedData * _Nullable, FlutterError * _Nullable))completion {
    @try {
        NSApplication *app = [NSApplication sharedApplication];
        NSWindow *window = [app mainWindow];
        NSView *view = [window contentView];
        
        NSRect bounds = [view bounds];
        NSBitmapImageRep *bitmapRep = [view bitmapImageRepForCachingDisplayInRect:bounds];
        [view cacheDisplayInRect:bounds toBitmapImageRep:bitmapRep];
        
        NSImage *image = [[NSImage alloc] initWithSize:bounds.size];
        [image addRepresentation:bitmapRep];
        
        NSData *imageData = [image TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        NSDictionary *properties = @{NSImageCompressionFactor: @1.0};
        NSData *jpegData = [imageRep representationUsingType:NSBitmapImageFileTypeJPEG properties:properties];
        
        FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:jpegData];
        completion(data, nil);
    } @catch (NSException *exception) {
        // takeSnapshot error
        FlutterError *flutterError = [FlutterError errorWithCode:@"TakeScreenshotError"
                                                        message:@"Failed takeScreenshot."
                                                        details:exception.description];
        NSLog(@"%@", exception);
        completion(nil, flutterError);
    } @finally {
        // Any cleanup code if needed
    }
}

@end
