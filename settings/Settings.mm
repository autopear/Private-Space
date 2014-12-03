#import <Preferences/Preferences.h>

#define PreferencesChangedNotification "com.autopear.privatespace.preferenceschanged"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/com.autopear.privatespace.plist"

@interface PrivateSpaceListController: PSListController {
}
@end

@implementation PrivateSpaceListController

- (id)specifiers {
	if(_specifiers == nil) {
        NSMutableArray *specifiers = [NSMutableArray array];
        for (PSSpecifier *specifier in [self loadSpecifiersFromPlistName:@"PrivateSpace" target:self]) {
            if ([specifier propertyForKey:@"pl_filter"]) {
                NSDictionary *filterDict = [specifier propertyForKey:@"pl_filter"];
                if ([filterDict objectForKey:@"CoreFoundationVersion"]) {
                    NSArray *filters = [filterDict objectForKey:@"CoreFoundationVersion"];
                    if ([filters count] == 1) {
                        CGFloat minVer = [[filters objectAtIndex:0] floatValue];
                        if (kCFCoreFoundationVersionNumber < minVer)
                            continue;
                    }
                    if ([filters count] == 2) {
                        CGFloat ver1 = [[filters objectAtIndex:0] floatValue];
                        CGFloat ver2 = [[filters objectAtIndex:1] floatValue];
                        if (ver1 < ver2) {
                            if (kCFCoreFoundationVersionNumber < ver1 || kCFCoreFoundationVersionNumber > ver2)
                                continue;
                        } else {
                            if (kCFCoreFoundationVersionNumber < ver2 || kCFCoreFoundationVersionNumber > ver1)
                                continue;
                        }
                    }
                }
            }
            [specifiers addObject:specifier];
        }
        _specifiers = [specifiers retain];
	}
	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PreferencesFilePath];
    if ([dict objectForKey:[specifier propertyForKey:@"key"]])
        return [dict objectForKey:[specifier propertyForKey:@"key"]];
    else
        return [specifier propertyForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PreferencesFilePath]];
    [defaults setObject:value forKey:[specifier propertyForKey:@"key"]];
    [defaults writeToFile:PreferencesFilePath atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(PreferencesChangedNotification), NULL, NULL, YES);
}

@end
