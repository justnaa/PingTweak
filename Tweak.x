#import "ping.h"
#import <AudioToolbox/AudioServices.h>
BOOL enabled;

%group ping
    %hook NCNotificationShortLookView
    - (void)layoutSubviews {
        NSString *appName = self.title;

        %orig;
        // Setting background colour
        NSArray<__kindof UIView *> *subs = self.subviews;
        UIView *transparent = subs[0];
        [transparent setHidden:YES];
        self.layer.cornerRadius = radius;
        int onTop = 1;
        self.tag = 12;

        // Getting primary colour of app if enabled

        // Thank you so much @bengiannis
        UIColor *color = [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:1.00];
        if (titleChange) {
            UIImage *image = nil;
            for (PLPlatterHeaderContentView *subview in self.subviews) {
                if ([subview isKindOfClass:[%c(PLPlatterHeaderContentView) class]]) {
                    if ([subview icons].count > 0) {
                        image = [[subview icons] firstObject];
                        break;
                    }
                }
            }

            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            unsigned char rgba[4];
            CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

            CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
            CGColorSpaceRelease(colorSpace);
            CGContextRelease(context);

            if(rgba[3] > 0) {
                CGFloat alpha = ((CGFloat)rgba[3])/255.0;
                CGFloat multiplier = alpha/255.0;
                color = [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                        green:((CGFloat)rgba[1])*multiplier
                        blue:((CGFloat)rgba[2])*multiplier
                        alpha:1];
            }
            else {
                color = [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                    green:((CGFloat)rgba[1])/255.0
                    blue:((CGFloat)rgba[2])/255.0
                    alpha:1];
            }
        }

        // Getting user defined per app notification colour
        int thisred = [[settings objectForKey:[NSString stringWithFormat:@"redAmount%@", appName]] ?: @266 intValue];
        int thisgreen = [[settings objectForKey:[NSString stringWithFormat:@"greenAmount%@", appName]] ?: @266 intValue];
        int thisblue = [[settings objectForKey:[NSString stringWithFormat:@"blueAmount%@", appName]] ?: @266 intValue];
        // then checking if they're null (equal or above 266)
        if (thisred <= 255 && thisgreen <= 255 && thisblue <= 255) {
            red = thisred;
            green = thisgreen;
            blue = thisblue;
            color = [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:1.00];

        }

        // Setting notification colour
        for (UIView *sub in subs) {
            if (onTop == 2) {
                // Seeing if user has enabled transparent top
                // If so making it transparent
                if (noTop) {
                    sub.opaque = NO;
                } else if (noBottom) {
                        // Setting upper radius
                        UIBezierPath *maskPath;
                        maskPath = [UIBezierPath bezierPathWithRoundedRect:sub.bounds
                                                         byRoundingCorners:(UIRectCornerBottomRight | UIRectCornerBottomLeft | UIRectCornerTopRight |UIRectCornerTopLeft)
                                                               cornerRadii:CGSizeMake(radius, radius)];
                        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                        maskLayer.frame = sub.bounds;
                        maskLayer.path = maskPath.CGPath;
                        sub.layer.mask = maskLayer;
                        sub.backgroundColor = color;
                    } else {
                        // Setting upper radius
                        UIBezierPath *maskPath;
                        maskPath = [UIBezierPath bezierPathWithRoundedRect:sub.bounds
                                                         byRoundingCorners:(UIRectCornerTopRight | UIRectCornerTopLeft)
                                                               cornerRadii:CGSizeMake(radius, radius)];
                        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                        maskLayer.frame = sub.bounds;
                        maskLayer.path = maskPath.CGPath;
                        sub.layer.mask = maskLayer;
                        sub.backgroundColor = color;
                }
            } else {
                // Setting bottom radius
                UIBezierPath *maskPath;

                // Setting default
                maskPath = [UIBezierPath bezierPathWithRoundedRect:sub.bounds
                                                 byRoundingCorners:(UIRectCornerBottomRight | UIRectCornerBottomLeft)
                                                       cornerRadii:CGSizeMake(radius, radius)];
                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                maskLayer.frame = sub.bounds;
                maskLayer.path = maskPath.CGPath;
                sub.layer.mask = maskLayer;
                sub.backgroundColor = color;
                // Seeing if user has enabled transparent top
                // If so make the top and bottom transparent
                if (noTop) {

                    maskPath = [UIBezierPath bezierPathWithRoundedRect:sub.bounds
                                                     byRoundingCorners:(UIRectCornerBottomRight | UIRectCornerBottomLeft | UIRectCornerTopRight |UIRectCornerTopLeft)
                                                           cornerRadii:CGSizeMake(radius, radius)];
                    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                    maskLayer.frame = sub.bounds;
                    maskLayer.path = maskPath.CGPath;
                    sub.layer.mask = maskLayer;
                    sub.backgroundColor = color;
                }
                // Seeing if bottom is disabled if so making it transparent
                if (noBottom) {
                    // This line is needed for some reason. If it's not there it doesn't become transparent.
                    sub.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
                    sub.opaque = NO;
                }
            }
            onTop = onTop + 1;
        }
        red = [[settings objectForKey:@"redAmount"] ?: @39 intValue];
        green = [[settings objectForKey:@"greenAmount"] ?: @52 intValue];
        blue = [[settings objectForKey:@"blueAmount"] ?: @65 intValue];
    }
    %end


    // Changing the notifications text
    %hook NCNotificationListHeaderTitleView
        - (void)layoutSubviews {
            %orig;
            // Checking if it's an app name
            UIView *parent = self.superview.superview.superview.superview.superview.superview;
            NSString *description = parent.description;
            NSString *newTitle = [settings valueForKey:self.title];
            if ([description containsString:@"<CSMainPageView"]) {
                self.title = title;
            } else {
                // Then checking if the user has defined a custom title, if they have set the title to that.
                if (newTitle == nil) {
                } else {
                    // Setting text with out Ellipsis
                    UILabel *t = self.subviews[0].subviews[0];
                    t.text = newTitle;
                    t.minimumScaleFactor = 8./t.font.pointSize;
                    t.adjustsFontSizeToFitWidth = YES;
                }
            }
        }
    %end

    // Removing shadow in popup

    %hook NCNotificationViewController
        - (void)viewDidLoad {
            %orig;
            self.hasShadow = false;
        }
    %end

    // Changing action cell colour

    %hook NCNotificationListCellActionButton
        - (void)layoutSubviews {
            UIView *actionButton = self.subviews[0];

            // Getting user defined colour
            int r = [[settings objectForKey:@"actionRedAmount"] ?: @266 intValue];
            int g = [[settings objectForKey:@"actionGreenAmount"] ?: @266 intValue];
            int b = [[settings objectForKey:@"actionBlueAmount"] ?: @266 intValue];
            // Check if its default
            if (r <= 255 && g <= 255 && b <= 255) {
                actionButton.backgroundColor = [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.00];
            }
            // Need to do it first or it flickers in
            %orig;
        }
    %end
%end

%ctor {
    // Getting preferences and seeing if tweak is enabled
    // And setting defaults
    settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/me.justnaaa.Pingpref.plist"] ?: [@{} mutableCopy];
    BOOL enabled = [[settings objectForKey:@"enableTweak"] ?: @(YES) boolValue];
    titleChange = [[settings objectForKey:@"enableTitleChange"] ?: @(YES) boolValue];
    radius = [[settings objectForKey:@"notificationRadius"] ?: @10 intValue];
    red = [[settings objectForKey:@"redAmount"] ?: @39 intValue];
    green = [[settings objectForKey:@"greenAmount"] ?: @52 intValue];
    blue = [[settings objectForKey:@"blueAmount"] ?: @65 intValue];
    title = [NSString stringWithFormat:@"%@", [[settings valueForKey:@"notificationsText"] ?: @"Notifications" stringValue] ];
    noTop = [[settings objectForKey:@"noTop"] ?: @(NO) boolValue];
    noBottom = [[settings objectForKey:@"noBottom"] ?: @(NO) boolValue];

    if (enabled) {
        %init(ping);
    }
}