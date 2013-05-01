#import <Accounts/Accounts.h>
#import <UIKit/UIKit.h>
#import <Social/Social.h>
#include <objc/runtime.h>
#import "CaptainHook.h"

#define PreferencesChangedNotification "com.autopear.privatespace.preferenceschanged"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/com.autopear.privatespace.plist"

@interface PSSpecifier : NSObject {
}
@property(retain) NSString * identifier;
@end

@interface PSListController {
}
-(void)removeSpecifier:(PSSpecifier *)specifier animated:(BOOL)animate;
-(void)removeSpecifier:(PSSpecifier *)specifier;
-(PSSpecifier *)specifierForID:(NSString *)identifier;
-(void)insertSpecifier:(PSSpecifier *)specifier afterSpecifier:(PSSpecifier *)specifier;
-(int)indexOfSpecifier:(PSSpecifier *)specifier;
-(void)removeSpecifierAtIndex:(int)index;
@end

@interface PrefsListController {
	PSSpecifier* _twitterSpecifier;
	PSSpecifier* _facebookSpecifier;
	PSSpecifier* _weiboSpecifier;
}
-(NSArray *)specifiers;
@end

@interface SoundsPrefController {
}
-(void)removeSpecifierID:(NSString *)specifierID;
@end

@interface PrivacyController {
}
-(void)removeSpecifierID:(NSString *)specifierID;
@end

@interface SBWeeApp {
}
@property(readonly, nonatomic) NSString *sectionID; // @synthesize sectionID=_sectionID;
@end

@interface AddBookmarkUIActivity : UIActivity {
}
-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems;
@end

@interface AddToHomeScreenUIActivity : UIActivity {
}
-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems;
@end

@interface AddToReadingListUIActivity : UIActivity {
}
-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems;
@end
@interface UIAlertButton : UIButton {
    float _imageOffset;
}

@property float imageOffset;

- (id)image;
- (float)imageOffset;
- (id)initWithTitle:(id)arg1;
- (void)layoutSubviews;
- (void)setEnabled:(BOOL)arg1;
- (void)setHighlighted:(BOOL)arg1;
- (void)setImage:(id)arg1 forState:(unsigned int)arg2;
- (void)setImageOffset:(float)arg1;
- (void)setTitle:(id)arg1;
- (id)title;
@end

static BOOL tweakEnabled = YES;
static PSSpecifier *weiboSpecifier = nil;
static PSSpecifier *twitterSpecifier = nil;
static PSSpecifier *facebookSpecifier = nil;
static BOOL isAppBlockTwitter = YES;
static BOOL isAppBlockFacebook = YES;
static BOOL isAppBlockWeibo = YES;
static BOOL isAppBlockOthers = YES;
//Facebook
static BOOL hideFacebookInSettings = NO;
static BOOL hideFacebookInActivity = NO;
static BOOL hideFacebookInWidget = NO;
static BOOL hideFacebookComposer = NO;
//Twitter
static BOOL hideTwitterInSettings = NO;
static BOOL hideTwitterInActivity = NO;
static BOOL hideTwitterInWidget = NO;
static BOOL hideTwitterComposer = NO;
//Weibo
static BOOL hideWeiboInSettings = NO;
static BOOL hideWeiboInActivity = NO;
static BOOL hideWeiboComposer = NO;
static BOOL forceWeiboEnabled = NO;
//Others
static BOOL hideMail = NO;
static BOOL hideMessage = NO;
static BOOL hideContacts = NO;
static BOOL hidePrint = NO;
static BOOL hideCopy = NO;
static BOOL hideCamera = NO;
static BOOL hideWallpaper = NO;
static BOOL hideYouTube = NO;
static BOOL hideFlickr = NO;
static BOOL hideTudou = NO;
static BOOL hideVimeo = NO;
static BOOL hideYouku = NO;
static BOOL hideMMS = NO;
static BOOL hidePhotoStream = NO;
static BOOL hidePublish = NO;
//App Store & iTunes
static BOOL hideGift = NO;
//Safari
static BOOL hideBookmark = NO;
static BOOL hideHomeScreen = NO;
static BOOL hideReadingList = NO;

static void LoadPreferences()
{
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    
    if ([prefs objectForKey:@"PSEnabled"])
        tweakEnabled = [[prefs objectForKey:@"PSEnabled"] boolValue];
    else
        tweakEnabled = YES;
    
    //Facebook
    if ([prefs objectForKey:@"PSFacebookInSettings"])
        hideFacebookInSettings = [[prefs objectForKey:@"PSFacebookInSettings"] boolValue];
    else
        hideFacebookInSettings = NO;
    
    if ([prefs objectForKey:@"PSFacebookInActivity"])
        hideFacebookInActivity = [[prefs objectForKey:@"PSFacebookInActivity"] boolValue];
    else
        hideFacebookInActivity = NO;
    
    if ([prefs objectForKey:@"PSFacebookInNotificationCenter"])
        hideFacebookInWidget = [[prefs objectForKey:@"PSFacebookInNotificationCenter"] boolValue];
    else
        hideFacebookInWidget = NO;
    
    if ([prefs objectForKey:@"PSFacebookComposer"])
        hideFacebookComposer = [[prefs objectForKey:@"PSFacebookComposer"] boolValue];
    else
        hideFacebookComposer = NO;
    
    //Twitter
    if ([prefs objectForKey:@"PSTwitterInSettings"])
        hideTwitterInSettings = [[prefs objectForKey:@"PSTwitterInSettings"] boolValue];
    else
        hideTwitterInSettings = NO;
    
    if ([prefs objectForKey:@"PSTwitterInActivity"])
        hideTwitterInActivity = [[prefs objectForKey:@"PSTwitterInActivity"] boolValue];
    else
        hideTwitterInActivity = NO;
    
    if ([prefs objectForKey:@"PSTwitterInNotificationCenter"])
        hideTwitterInWidget = [[prefs objectForKey:@"PSTwitterInNotificationCenter"] boolValue];
    else
        hideTwitterInWidget = NO;
    
    if ([prefs objectForKey:@"PSTwitterComposer"])
        hideTwitterComposer = [[prefs objectForKey:@"PSTwitterComposer"] boolValue];
    else
        hideTwitterComposer = NO;
    
    //Weibo
    if ([prefs objectForKey:@"PSWeiboInSettings"])
        hideWeiboInSettings = [[prefs objectForKey:@"PSWeiboInSettings"] boolValue];
    else
        hideWeiboInSettings = NO;
    
    if ([prefs objectForKey:@"PSWeiboInActivity"])
        hideWeiboInActivity = [[prefs objectForKey:@"PSWeiboInActivity"] boolValue];
    else
        hideWeiboInActivity = NO;
    
    if ([prefs objectForKey:@"PSWeiboComposer"])
        hideWeiboComposer = [[prefs objectForKey:@"PSWeiboComposer"] boolValue];
    else
        hideWeiboComposer = NO;
    
    if ([prefs objectForKey:@"PSWeiboForceEnabled"])
        forceWeiboEnabled = [[prefs objectForKey:@"PSWeiboForceEnabled"] boolValue];
    else
        forceWeiboEnabled = NO;
    
    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    // If dylib load to daemon, bundleIdentifier = nil.
    // stringByAppendingString:nil call will crash daemon.
    if (bundleIdentifier)
    {
        id disablePref = [prefs objectForKey:[@"PSFacebook-" stringByAppendingString:bundleIdentifier]];
        isAppBlockFacebook = disablePref ? [disablePref boolValue] : YES;
        
        disablePref = [prefs objectForKey:[@"PSTwitter-" stringByAppendingString:bundleIdentifier]];
        isAppBlockTwitter = disablePref ? [disablePref boolValue] : YES;
        
        disablePref = [prefs objectForKey:[@"PSWeibo-" stringByAppendingString:bundleIdentifier]];
        isAppBlockWeibo = disablePref ? [disablePref boolValue] : YES;
        
        disablePref = [prefs objectForKey:[@"PSOthers-" stringByAppendingString:bundleIdentifier]];
        isAppBlockOthers = disablePref ? [disablePref boolValue] : YES;
    }
    
    if ([prefs objectForKey:@"PSMailInActivity"])
        hideMail = [[prefs objectForKey:@"PSMailInActivity"] boolValue];
    else
        hideMail = NO;
    
    if ([prefs objectForKey:@"PSMessageInActivity"])
        hideMessage = [[prefs objectForKey:@"PSMessageInActivity"] boolValue];
    else
        hideMessage = NO;
    
    if ([prefs objectForKey:@"PSAssignToContactInActivity"])
        hideContacts = [[prefs objectForKey:@"PSAssignToContactInActivity"] boolValue];
    else
        hideContacts = NO;
    
    if ([prefs objectForKey:@"PSPrintInActivity"])
        hidePrint = [[prefs objectForKey:@"PSPrintInActivity"] boolValue];
    else
        hidePrint = NO;
    
    if ([prefs objectForKey:@"PSCopyInActivity"])
        hideCopy = [[prefs objectForKey:@"PSCopyInActivity"] boolValue];
    else
        hideCopy = NO;
    
    if ([prefs objectForKey:@"PSSaveToCameraRollInActivity"])
        hideCamera = [[prefs objectForKey:@"PSSaveToCameraRollInActivity"] boolValue];
    else
        hideCamera = NO;
    
    if ([prefs objectForKey:@"PSWallpaperInActivity"])
        hideWallpaper = [[prefs objectForKey:@"PSWallpaperInActivity"] boolValue];
    else
        hideWallpaper = NO;
    
    if ([prefs objectForKey:@"PSYouTubeInActivity"])
        hideYouTube = [[prefs objectForKey:@"PSYouTubeInActivity"] boolValue];
    else
        hideYouTube = NO;
    
    if ([prefs objectForKey:@"PSFlickrInActivity"])
        hideFlickr = [[prefs objectForKey:@"PSFlickrInActivity"] boolValue];
    else
        hideFlickr = NO;
    
    if ([prefs objectForKey:@"PSTudouInActivity"])
        hideTudou = [[prefs objectForKey:@"PSTudouInActivity"] boolValue];
    else
        hideTudou = NO;
    
    if ([prefs objectForKey:@"PSVimeoInActivity"])
        hideVimeo = [[prefs objectForKey:@"PSVimeoInActivity"] boolValue];
    else
        hideVimeo = NO;
    
    if ([prefs objectForKey:@"PSYoukuInActivity"])
        hideYouku = [[prefs objectForKey:@"PSYoukuInActivity"] boolValue];
    else
        hideYouku = NO;
    
    if ([prefs objectForKey:@"PSPhotoStreamInActivity"])
        hidePhotoStream = [[prefs objectForKey:@"PSPhotoStreamInActivity"] boolValue];
    else
        hidePhotoStream = NO;
    
    if ([prefs objectForKey:@"PSMMSInActivity"])
        hideMMS = [[prefs objectForKey:@"PSMMSInActivity"] boolValue];
    else
        hideMMS = NO;
    
    if ([prefs objectForKey:@"PSPublishingInActivity"])
        hidePublish = [[prefs objectForKey:@"PSPublishingInActivity"] boolValue];
    else
        hidePublish = NO;
    
    if ([prefs objectForKey:@"PSGiftInActivity"])
        hideGift = [[prefs objectForKey:@"PSGiftInActivity"] boolValue];
    else
        hideGift = NO;
    
    if ([prefs objectForKey:@"PSBookmarkInActivity"])
        hideBookmark = [[prefs objectForKey:@"PSBookmarkInActivity"] boolValue];
    else
        hideBookmark = NO;
    
    if ([prefs objectForKey:@"PSHomeScreenInActivity"])
        hideHomeScreen = [[prefs objectForKey:@"PSHomeScreenInActivity"] boolValue];
    else
        hideHomeScreen = NO;
    
    if ([prefs objectForKey:@"PSReadingListInActivity"])
        hideReadingList = [[prefs objectForKey:@"PSReadingListInActivity"] boolValue];
    else
        hideReadingList = NO;
    
    [prefs release];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    LoadPreferences();
}

 %hook UIActivityViewController
-(NSArray *)excludedActivityTypes
{
    
    NSMutableArray *excludes = [NSMutableArray arrayWithArray:%orig];
    
    if (tweakEnabled)
    {
        if (hideFacebookInActivity && isAppBlockFacebook && ![excludes containsObject:UIActivityTypePostToFacebook])
            [excludes addObject:UIActivityTypePostToFacebook];
        
        if (hideTwitterInActivity && isAppBlockTwitter && ![excludes containsObject:UIActivityTypePostToTwitter])
            [excludes addObject:UIActivityTypePostToTwitter];
        
        if (hideWeiboInActivity && isAppBlockWeibo && ![excludes containsObject:UIActivityTypePostToWeibo])
            [excludes addObject:UIActivityTypePostToWeibo];
        
        if (hideMessage && isAppBlockOthers && ![excludes containsObject:UIActivityTypeMessage])
            [excludes addObject:UIActivityTypeMessage];
        
        if (hideMail && isAppBlockOthers && ![excludes containsObject:UIActivityTypeMail])
            [excludes addObject:UIActivityTypeMail];
        
        if (hidePrint && isAppBlockOthers && ![excludes containsObject:UIActivityTypePrint])
            [excludes addObject:UIActivityTypePrint];
        
        if (hideCopy && isAppBlockOthers && ![excludes containsObject:UIActivityTypeCopyToPasteboard])
            [excludes addObject:UIActivityTypeCopyToPasteboard];
        
        if (hideCamera && isAppBlockOthers && ![excludes containsObject:UIActivityTypeSaveToCameraRoll])
            [excludes addObject:UIActivityTypeSaveToCameraRoll];
        
        if (hidePhotoStream && isAppBlockOthers && ![excludes containsObject:@"PLActivityTypeAlbumStream"])
            [excludes addObject:@"PLActivityTypeAlbumStream"];
        
        if (hideYouTube && isAppBlockOthers && ![excludes containsObject:@"PLActivityTypePublishToYouTube"])
            [excludes addObject:@"PLActivityTypePublishToYouTube"];
        
        if (hideTudou && isAppBlockOthers && ![excludes containsObject:@"PLActivityTypePublishToTudou"])
            [excludes addObject:@"PLActivityTypePublishToTudou"];
        
        if (hideYouku && isAppBlockOthers && ![excludes containsObject:@"PLActivityTypePublishToYouku"])
            [excludes addObject:@"PLActivityTypePublishToYouku"];
        
        if (hideWallpaper && isAppBlockOthers && ![excludes containsObject:@"PLActivityTypeUseAsWallpaper"])
            [excludes addObject:@"PLActivityTypeUseAsWallpaper"];
        
        if (hideVimeo && isAppBlockOthers && ![excludes containsObject:@"PLActivityTypePublishToVimeo"])
            [excludes addObject:@"PLActivityTypePublishToVimeo"];
        
        if (hideGift && isAppBlockOthers && ![excludes containsObject:@"com.apple.AppStore.gift"])
            [excludes addObject:@"com.apple.AppStore.gift"];

        if (hideContacts && isAppBlockOthers)
        {
            if (![excludes containsObject:UIActivityTypeAssignToContact])
                [excludes addObject:UIActivityTypeAssignToContact];
            if (![excludes containsObject:@"PLActivityTypeAssignToContact"])
                [excludes addObject:@"PLActivityTypeAssignToContact"];
        }
    }

    return excludes;
}
%end

%hook PrefsListController
-(NSArray *)specifiers
{
    NSArray *specs = [NSArray arrayWithArray:%orig];
    weiboSpecifier = CHIvar(self, _weiboSpecifier, PSSpecifier *);
    facebookSpecifier = CHIvar(self, _facebookSpecifier, PSSpecifier *);
    twitterSpecifier = CHIvar(self, _twitterSpecifier, PSSpecifier *);
    return specs;
}
%end

%hook PSListController
-(void)viewDidLoad
{
    %orig;

    if (tweakEnabled)
    {
        if (forceWeiboEnabled && !hideWeiboInSettings && ![self specifierForID:@"WEIBO"])
            [self insertSpecifier:weiboSpecifier afterSpecifier:facebookSpecifier];
        
        int groupIndex = [self indexOfSpecifier:facebookSpecifier] - 2;
        
        if (hideFacebookInSettings)
            [self removeSpecifier:facebookSpecifier];
        if (hideTwitterInSettings)
            [self removeSpecifier:twitterSpecifier];
        if (hideWeiboInSettings)
            [self removeSpecifier:weiboSpecifier];
        
        if (![self specifierForID:@"TWITTER"] && ![self specifierForID:@"FACEBOOK"] && ![self specifierForID:@"WEIBO"])
            [self removeSpecifierAtIndex:groupIndex];
    }
}

- (void)removeSpecifier:(PSSpecifier *)specifier animated:(BOOL)animated
{
    if (tweakEnabled)
    {
        if (!(forceWeiboEnabled && !hideWeiboInSettings && [specifier.identifier isEqualToString:@"WEIBO"]))
            %orig(specifier, animated);
    }
    else
        %orig(specifier, animated);
}

- (void)removeSpecifier:(PSSpecifier *)specifier
{
    if (tweakEnabled)
    {
        if (!(forceWeiboEnabled && !hideWeiboInSettings && [specifier.identifier isEqualToString:@"WEIBO"]))
            %orig(specifier);
    }
    else
        %orig(specifier);
}
%end

%hook SoundsPrefController
-(id)specifiers
{
    NSArray *specs = %orig;
    
    if (tweakEnabled)
    {
        if (hideTwitterInSettings)
            [self removeSpecifierID:@"SENT_TWEET"];
        if (hideFacebookInSettings)
            [self removeSpecifierID:@"FACEBOOK_POST"];
    }
    return specs;
}
%end

%hook PrivacyController
-(id)specifiers
{
    NSArray *specs = %orig;
    
    if (tweakEnabled)
    {
        //Test whether weibo is supported
        bool weiboSupported = NO;
        for (PSSpecifier *spec in specs)
        {
            if ([spec.identifier isEqualToString:@"SINAWEIBO"])
            {
                weiboSupported = YES;
                break;
            }
        }
        
        if (hideTwitterInSettings)
            [self removeSpecifierID:@"TWITTER"];
        if (hideFacebookInSettings)
            [self removeSpecifierID:@"FACEBOOK"];
        if (weiboSupported && hideWeiboInSettings)
            [self removeSpecifierID:@"SINAWEIBO"];
        
        //Remove group
        if (hideTwitterInSettings && hideFacebookInSettings && (!weiboSupported || hideWeiboInSettings))
            [self removeSpecifierID:@"SOCIAL_PRIVACY_GROUP"];
    }
    return specs;
}
%end

%hook SLComposeViewController
+ (BOOL)isAvailableForServiceType:(NSString *)serviceType
{
    if (tweakEnabled)
    {
        if ([serviceType isEqualToString:SLServiceTypeFacebook] && hideFacebookComposer && isAppBlockFacebook)
            return NO;
    
        if ([serviceType isEqualToString:SLServiceTypeTwitter] && hideTwitterComposer && isAppBlockTwitter)
            return NO;
    
        if ([serviceType isEqualToString:SLServiceTypeSinaWeibo] && hideWeiboComposer && isAppBlockWeibo)
            return NO;
    }
    return %orig;
}

+ (SLComposeViewController *)composeViewControllerForServiceType:(NSString *)serviceType
{
    if (tweakEnabled)
    {
        if ([serviceType isEqualToString:SLServiceTypeFacebook] && hideFacebookComposer && isAppBlockFacebook)
            return nil;
        
        if ([serviceType isEqualToString:SLServiceTypeTwitter] && hideTwitterComposer && isAppBlockTwitter)
            return nil;
        
        if ([serviceType isEqualToString:SLServiceTypeSinaWeibo] && hideWeiboComposer && isAppBlockWeibo)
            return nil;
    }
    return %orig;

}
%end

%hook PLYoukuActivity
- (BOOL)_canPerformWithSuppliedActivityItems:(NSArray *)arg1
{
    if (tweakEnabled && hideYouku && isAppBlockOthers)
        return NO;
    else
        return %orig(arg1);
}
%end

%hook PLTudouActivity
- (BOOL)_canPerformWithSuppliedActivityItems:(NSArray *)arg1
{
    if (tweakEnabled && hideTudou && isAppBlockOthers)
        return NO;
    else
        return %orig(arg1);
}
%end

%hook PLYouTubeActivity
- (BOOL)_canPerformWithSuppliedActivityItems:(NSArray *)arg1
{
    if (tweakEnabled && hideYouTube && isAppBlockOthers)
        return NO;
    else
        return %orig(arg1);
}
%end

%hook PLWallpaperActivity
- (BOOL)_canPerformWithSuppliedActivityItems:(NSArray *)arg1
{
    if (tweakEnabled && hideWallpaper && isAppBlockOthers)
        return NO;
    else
        return %orig(arg1);
}
%end

%hook PLMailActivity
- (BOOL)_canPerformWithSuppliedActivityItems:(NSArray *)arg1
{
    if (tweakEnabled && hideMail && isAppBlockOthers)
        return NO;
    else
        return %orig(arg1);
}
%end

%hook PLMMSActivity
- (BOOL)_canPerformWithSuppliedActivityItems:(NSArray *)arg1
{
    if (tweakEnabled && hideMMS && isAppBlockOthers)
        return NO;
    else
        return %orig(arg1);
}
%end

%hook PLSaveToCameraRollActivity
- (BOOL)_canPerformWithSuppliedActivityItems:(NSArray *)arg1
{
    if (tweakEnabled && hideCamera && isAppBlockOthers)
        return NO;
    else
        return %orig(arg1);
}
%end

%hook PLPublishingActivity
- (BOOL)_canPerformWithSuppliedActivityItems:(NSArray *)arg1
{
    if (tweakEnabled && hidePublish && isAppBlockOthers)
        return NO;
    else
        return %orig(arg1);
}
%end

%hook PLAssignToContactActivity
- (BOOL)_canPerformWithSuppliedActivityItems:(NSArray *)arg1
{
    if (tweakEnabled && hideContacts && isAppBlockOthers)
        return NO;
    else
        return %orig(arg1);
}
%end

%hook PLAlbumStreamActivity
- (BOOL)_canPerformWithSuppliedActivityItems:(NSArray *)arg1
{
    if (tweakEnabled && hidePhotoStream && isAppBlockOthers)
        return NO;
    else
        return %orig(arg1);
}
%end

%hook AddBookmarkUIActivity
-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (tweakEnabled && hideBookmark && isAppBlockOthers)
        return NO;
    else
        return %orig(activityItems);
}
%end

%hook AddToReadingListUIActivity
-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (tweakEnabled && hideReadingList && isAppBlockOthers)
        return NO;
    else
        return %orig(activityItems);
}
%end

%hook AddToHomeScreenUIActivity
-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (tweakEnabled && hideHomeScreen && isAppBlockOthers)
        return NO;
    else
        return %orig(activityItems);
}
%end
/*
%hook UIActionSheet
- (void)showInView:(UIView *)view
{
    %orig(view);
    
    int firstButton = 0, lastButton = 0;
    int readButton;
    for (int i=0; i<[self.subviews count]; i++)
    {
        UIView *view = [self.subviews objectAtIndex:i];

        if ([[NSString stringWithFormat:@"%s", class_getName([view class])] isEqualToString:@"UIAlertButton"])
        {
            if (firstButton == 0)
                firstButton = i;

            lastButton = i; //Cancel button
                
            if ([[(UIAlertButton *)view title] isEqualToString:@"添加到阅读列表"])
                readButton = i;
        }
    }
    
    [[self.subviews objectAtIndex:readButton] removeFromSuperview];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {}
    else
    {
        if (self.frame.size.width == 320.0f)
        {
            for (int i=readButton; i<lastButton; i++)
            {
                UIView *view = [self.subviews objectAtIndex:i];
                
                CGRect frame = view.frame;
                frame.origin.y -= 53;
                view.frame = frame;
            }
            CGRect frame = self.frame;
            frame.origin.y += 53;
            frame.size.height -= 53;
            self.frame = frame;
        }
        else
        {
            UIView *view = CHIvar(self, _buttonTableView, UIView *);
            UITableView *tableView = [view.subviews objectAtIndex:0];
            NSLog(@"numberOfSections %d", [tableView numberOfSections]);
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
            [[tableView cellForRowAtIndexPath:indexPath] removeFromSuperview];
        }
        
    }
}

%end*/

static BOOL weeAppLoaded = NO;

%hook SBWeeApp
- (void)viewWillAppear
{
    if ([self.sectionID isEqualToString:@"com.apple.SocialWeeApp"])
        weeAppLoaded = NO;
    %orig;
}

- (UIView *)view
{
    UIView *view = %orig;
    if ([self.sectionID isEqualToString:@"com.apple.SocialWeeApp"])
        weeAppLoaded = YES;
    return view;
}

%end

%hook ACAccountStore
+ (int)accountsWithAccountTypeIdentifierExist:(NSString *)identifier
{
    if (tweakEnabled && weeAppLoaded)
    {
        if (hideTwitterInWidget && [identifier isEqualToString:ACAccountTypeIdentifierTwitter])
        {
            NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
            if (bundleIdentifier)
            {
                if ([bundleIdentifier isEqualToString:@"com.apple.springboard"])
                    return 2;
            }
        }
        
        if (hideFacebookInWidget && [identifier isEqualToString:ACAccountTypeIdentifierFacebook])
        {
            NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
            if (bundleIdentifier)
            {
                if ([bundleIdentifier isEqualToString:@"com.apple.springboard"])
                    return 2;
            }
        }
    }
    
    return %orig(identifier);
}
%end

%ctor
{
    @autoreleasepool
    {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
        LoadPreferences();
    }
}