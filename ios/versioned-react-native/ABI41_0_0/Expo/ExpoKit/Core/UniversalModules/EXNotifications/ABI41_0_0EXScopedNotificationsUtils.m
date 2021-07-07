// Copyright 2018-present 650 Industries. All rights reserved.

#import "ABI41_0_0EXScopedNotificationsUtils.h"

@implementation ABI41_0_0EXScopedNotificationsUtils

+ (BOOL)shouldNotificationRequest:(UNNotificationRequest *)request beHandledByExperience:(NSString *)scopeKey
{
  NSString *notificationScopeKey = request.content.userInfo[@"experienceId"];
  if (!notificationScopeKey) {
    return true;
  }
  return [notificationScopeKey isEqual:scopeKey];
}

+ (BOOL)shouldNotification:(UNNotification *)notification beHandledByExperience:(NSString *)scopeKey
{
  return [ABI41_0_0EXScopedNotificationsUtils shouldNotificationRequest:notification.request beHandledByExperience:scopeKey];
}

+ (NSString *)scopedIdentifierFromId:(NSString *)unscopedId forExperience:(NSString *)scopeKey
{
  NSString *scope = [ABI41_0_0EXScopedNotificationsUtils escapedString:scopeKey];
  NSString *escapedCategoryId = [ABI41_0_0EXScopedNotificationsUtils escapedString:unscopedId];
  return [NSString stringWithFormat:@"%@/%@", scope, escapedCategoryId];
}

+ (BOOL)isId:(NSString *)identifier scopedByExperience:(NSString *)scopeKey
{
  NSString *scopeFromCategoryId = [ABI41_0_0EXScopedNotificationsUtils getScopeAndIdentifierFromScopedIdentifier:identifier].scopeKey;
  return [scopeFromCategoryId isEqualToString:scopeKey];
}

+ (ScopedIdentifierComponents)getScopeAndIdentifierFromScopedIdentifier:(NSString *)scopedIdentifier
{
  NSString *scope = @"";
  NSString *identifier = @"";
  NSString *pattern = @"^"
                       "((?:[^/\\\\]|\\\\[/\\\\])*)" // escaped scope key
                       "/"                           // delimiter
                       "((?:[^/\\\\]|\\\\[/\\\\])*)" // escaped original category identifier
                       "$";
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                         options:0
                                                                           error:nil];
  NSTextCheckingResult *match = [regex firstMatchInString:scopedIdentifier
                                                  options:0
                                                    range:NSMakeRange(0, scopedIdentifier.length)];
  if (!match) {
    // No delimiter found, so no scope associated with this identifier
    identifier = scopedIdentifier;
  } else {
    scope = [scopedIdentifier substringWithRange:[match rangeAtIndex:1]];
    identifier = [scopedIdentifier substringWithRange:[match rangeAtIndex:2]];
  }
  ScopedIdentifierComponents components;
  components.scopeKey = [ABI41_0_0EXScopedNotificationsUtils unescapedString:scope];
  components.identifier = [ABI41_0_0EXScopedNotificationsUtils unescapedString:identifier];
  return components;
}

+ (NSString *)escapedString:(NSString*)string
{
  return [[string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
    stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
}

+ (NSString *)unescapedString:(NSString*)string
{
  return [[string stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"]
          stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
}

# pragma mark Legacy notification category scoping

+ (BOOL)isLegacyCategoryId:(NSString *)scopedCategoryId scopedByScopeKey:(NSString *)scopeKey
{
  NSString* legacyScopingPrefix = [NSString stringWithFormat:@"%@-", scopeKey];
  return [scopedCategoryId hasPrefix:legacyScopingPrefix];
}

// legacy categories were stored under an unescaped experienceId
+ (NSString *)unscopedLegacyCategoryIdentifierWithId:(NSString *)scopedCategoryId
                         forScopeKey:(NSString *)scopeKey
{
  NSString* legacyScopingPrefix = [NSString stringWithFormat:@"%@-", scopeKey];
  return [scopedCategoryId stringByReplacingOccurrencesOfString:legacyScopingPrefix
                                                     withString:@""
                                                        options:NSAnchoredSearch
                                                          range:NSMakeRange(0, [scopedCategoryId length])];
}

@end
