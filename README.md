# Yet Another HTTP VCR

[![CocoaPods](https://img.shields.io/cocoapods/v/YAHTTPVCR.svg)](https://cocoapods.org/pods/YAHTTPVCR)
[![CocoaPods](https://img.shields.io/cocoapods/metrics/doc-percent/YAHTTPVCR.svg)](https://cocoapods.org/pods/YAHTTPVCR)
[![CocoaPods](https://img.shields.io/cocoapods/l/YAHTTPVCR.svg)](https://cocoapods.org/pods/YAHTTPVCR)
[![CocoaPods](https://img.shields.io/cocoapods/dt/YAHTTPVCR.svg)](https://cocoapods.org/pods/YAHTTPVCR)
[![Code Coverage](https://img.shields.io/codecov/c/github/parfeon/YAHTTPVCR.svg)](https://travis-ci.org/parfeon/YAHTTPVCR)
[![Build Status](https://img.shields.io/travis/parfeon/YAHTTPVCR.svg)](https://travis-ci.org/parfeon/YAHTTPVCR)

This is one more VCR to the list of already existing tools. Expiration to functionality and operation has been taken from [VCR.py](https://vcrpy.readthedocs.io/en/latest/).  

It is pretty simple HTTP(S) stubbing tool which solely implement VCR recording and playback functionality (no need to use third-party stubbing tools).  

This is single page documentation, but it is also available on separate pages in [Wiki](https://github.com/parfeon/YAHTTPVCR/wiki).

## Configuration

Library is pretty configuration is pretty simple. All configuration can be specified on singleton VCR instance using [`+setupWithConfiguration:`](#-voidsetupwithconfigurationvoidyhvconfiguration-configurationblock)   method and adjusted during cassette insertion with [`+insertCassetteWithConfiguration:`](#-yhvcassette-insertcassettewithconfigurationvoidyhvconfiguration-configurationblock) method.  

Configuration represented by **YHVConfiguration** class and has following parameters:  

##### [`@property (nonatomic, copy) NSString *cassettesPath`](#property-nonatomic-copy-nsstring-cassettespath)
Attribute: **Required**

Reference on path where recorded cassettes is stored. This path will be used to compose path to concrete cassette using [cassettePath](#property-nonatomic-copy-nsstring-cassettepath).  

_NOTE:_ It is desirable what this property point to bundle directory (with `.bundle` extension).  

##### [`@property (nonatomic, copy) NSString *cassettePath`](#property-nonatomic-copy-nsstring-cassettepath)
Attribute: **Required**

Reference on path where cassette is stored or will be stored (relative to [cassettesPath](#property-nonatomic-copy-nsstring-cassettespath)).  

_NOTE:_ VCR is capable to serialize cassettes using one of supported file types: Property List (cassette path should have `plist` extension) and JSON (cassette path should have `json` extension). _JSON_ serializer used by default in case if extension is missing from cassette path.

##### [`@property (nonatomic, copy) id hostFilter`](#property-nonatomic-copy-id-hostfilter)

Reference on object which can be used to filter requests for recording/playback. Object can be array with list of allowed hosts or `YHVHostFilterBlock` block which allow dynamically decide whether request should be recorded/stub played or not.

###### Example
```objc
// Record only requests sent to apple.com
configuration.hostFilter = @[@"apple.com"];

// Record all requests which has been sent to httpbin service.
configuration.hostsFilter = ^BOOL (NSString *host) {
    return [host rangeOfString:@"httpbin"].location != NSNotFound;
};
```

##### [`@property (nonatomic, nullable, copy) NSArray *matchers`](#property-nonatomic-nullable-copy-nsarray-matchers)

Reference on list of registered matchers which will be used by VCR to identify whether stubbed request can be used instead of original or not.  

Available matchers:  
 * `YHVMatcher.method` - matcher based on used request's HTTP method.  
   Requests will match if both of them has same HTTP request method (like `GET` or `POST`).  
 * `YHVMatcher.uri` - matcher based on request's complete URI.  
   Requests will match only if both has same URI string (includes: schema, host, port, path and query parameters).  
 * `YHVMatcher.scheme` - matcher based on URI schema.  
   Requests will match if both use URI with same schema (like `http` or `https`).  
 * `YHVMatcher.host` - matcher based on URI domain.  
   Requests will match only if both has same domain in used URI.  
 * `YHVMatcher.port` - matcher based on URI host port.
   Requests will match only if both has same host port in used URI or doesn't have it at all.  
 * `YHVMatcher.path` - matcher based on URI path segment.  
   Requests will match only if both has same path segment in used URI.
 * `YHVMatcher.query` - matcher based on URI query segment.  
   Requests will match only if both has same query segment in used URI. 
 * `YHVMatcher.headers` - matcher based on request headers.
   Requests will match only if both has same set of header field and values.  
 * `YHVMatcher.body` - matched based on POST body.  
   Requests will match only if they both has `POST` HTTP method and POST body.  
##### [`@property (nonatomic, assign) YHVRecordMode recordMode`](#property-nonatomic-assign-yhvrecordmode-recordmode)

Recording mode used to figure out whether request can be stored on cassette at this moment or not.  

Available modes:  
 * `YHVRecordOnce` - mode in which requests will be written only to new cassette.  
   This mode useful when it is required to create cassette and track whether any unexpected requests is sent (in this case VCR will throw and exception).  
 * `YHVRecordNew` - mode in which requests will be recorded at current play head position.  
   This mode useful in cases when new test cases has been added to suite and response for them should be stubbed as well. With this mode will be impossible to track whether code send unexpected requests.  
 * `YHVRecordNone` - mode in which requests can't be written at all.  
   This mode completely protects cassette from writings (almost like `YHVRecordOnce` which allow to write initial cassette).  
 * `YHVRecordAll` - mode in which any requests will be written. When cassette inserted and this mode is set, all it's content will be removed. 
   This mode useful in cases when stubbed content outdated since remote changed output format or information which is sent.

##### [`@property (nonatomic, assign) YHVPlaybackMode playbackMode`](#property-nonatomic-assign-yhvplaybackmode-playbackmode)

Playback mode is used to figure out how data should be passed to URL loading system.  
Response on request is not single entry in cassette and consist from: response instance (`NSHTTPURLResponse`) and response body (`NSData` or `NSError` in case if error happened during request processing). There can be multiple response body entries on cassette in case if body was too big to send it with single packet.  
Sometimes cassette may contain stubs for multiple requests and they randomly (in order of sending) located on cassette's tape. So, there is no guarantee what after one response body packet will be another one for same request. Stubs playback in this case controlled by specified mode.

Available modes:  
 * `YHVChronologicalPlayback` - default mode in which next recorded scene will be played only if previous one has been completed.  
   With this mode and stubs for multiple requests located on tape, next stub component will be played only after previous confirmed stub receive. This mode is natural direction in which requests will complete at same moment as they completed when has been recorded.  
 * `YHVMomentaryPlayback` - mode in which recorded scenes played in same order as they has been recorded, but complete right after they has been sent.  
   With this mode and stubs for multiple requests located on tape, next stub component will be played only after all stub components for previous request has been played.  

##### [`@property (nonatomic, copy) YHVPathFilterBlock pathFilter`](#property-nonatomic-copy-yhvpathfilterblock-pathfilter)

Reference on block which allow to filter out sensitive data from request URI path segment, before it will be stored as stub on cassette.

###### Example
```objc
/**
 * In example below, we return path segment where any occurrence of our
 * username replaced with 'bob'.
 */
configuration.pathFilter = ^NSString *(NSURLRequest *request) {
    return [request.URI.path stringByReplacingOccurrencesOfString:@"<username>" withString:@"bob"];
};
```

##### [`@property (nonatomic, copy) id queryParametersFilter`](#property-nonatomic-copy-id-queryparametersfilter)

Reference on object which can be used to filter sensitive data from request URI query segment, before it will be stored as stub on cassette.  
Object can be `NSDictionary` instance where keys represent name of query parameter and value is original data replacement. It is possible to remove query fields with value by specifying `[NSNull null]` for it in dictionary.  
Object also can be `YHVQueryParametersFilterBlock` block which allow dynamically change query arguments.  

###### Example
```objc
/**
 * In example below, we remove 'token' query and replace 'signature' with
 * own value which will be stored as stub.
 */
configuration.queryParametersFilter = @{ @"token": [NSNull null], @"signature": @"secret-signature" };

// This block is identical to filter configuration with NSDictionary above.
configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *queryParameters) {
    [queryParameters removeObjectForKey:@"token"];
    queryParameters[@"signature"] = @"secret-signature";
};
```

##### [`@property (nonatomic, copy) id postBodyFilter`](#property-nonatomic-copy-id-postbodyfilter)

Reference on object which can be used to filter sensitive data from request POST body, before it will be stored as stub on cassette.  
Object can be `NSDictionary` instance where keys represent name of keys and value is original data replacement. It is possible to remove header fields with value by specifying `[NSNull null]` for it in dictionary.
`NSDictionary` can be used only if `application/json` or `application/x-www-form-urlencoded` data is sent along with request.  
Object also can be `YHVPostBodyFilterBlock` block which allow dynamically change header fields.  

###### Example
```objc
/**
 * In example below allow to remove 'fullName' and replace 'pwd' field in 
 * POST body represented by 'application/json' or 
 * 'application/x-www-form-urlencoded' content-type.
 */
configuration.postBodyFilter = @{ @"fullName": [NSNull null], @"pwd": @"pwd" };

/**
 * In example below, we replace 'sender:alex' string in POST body with 
 * 'sender:bob' which will be part of stored stub.
 */
configuration.postBodyFilter = ^NSData * (NSURLRequest *request) {
    NSString *message = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    message = [request.URI.path stringByReplacingOccurrencesOfString:@"sender:alex" withString:@"sender:bob"];

    return [message dataUsingEncoding:NSUTF8StringEncoding];
};
```

##### [`@property (nonatomic, copy) id responseBodyFilter`](#property-nonatomic-copy-id-responsebodyfilter)

Reference on object which can be used to filter sensitive data from request response body, before it will be stored as stub on cassette.  
Object can be `NSDictionary` instance where keys represent name of header fields and value is original data replacement. It is possible to remove header fields with value by specifying `[NSNull null]` for it in dictionary.
`NSDictionary` can be used only if `application/json` or `application/x-www-form-urlencoded` data is sent along with request.  
Object also can be `YHVResponseBodyFilterBlock` block which allow dynamically change header fields.  

###### Example
```objc
/**
 * In example below allow to remove 'token' from response body represented 
 * by 'application/json' or 'application/x-www-form-urlencoded' content-type.
 */
configuration.responseBodyFilter = @{ @"token": [NSNull null] };

/**
 * In example below, we remove 'sender:bob' string from response body before 
 * it will be stored as stub.
 */
configuration.responseBodyFilter = ^NSData * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    responseString = [request.URI.path stringByReplacingOccurrencesOfString:@"sender:bob" withString:@""];

    return [responseString dataUsingEncoding:NSUTF8StringEncoding];
};
```

##### [`@property (nonatomic, copy) YHVBeforeRecordRequestBlock beforeRecordRequest`](#property-nonatomic-copy-yhvbeforerecordrequestblock-beforerecordrequest)

Reference on block which allow to make final adjustments to `NSURLRequest` instance, before it will be stored as stub on cassette.

###### Example
```objc
/**
 * In example below, we change used HTTP method.
 */
configuration.beforeRecordRequest = ^NSURLRequest *(NSURLRequest *request) {
    NSMutableURLRequest *changedRequest = [request mutableCopy];
    changedRequest.HTTPMethod = @"GET";
    
    return changedRequest;
};
```

##### [`@property (nonatomic, copy) YHVBeforeRecordResponseBlock beforeRecordResponse`](#property-nonatomic-copy-yhvbeforerecordresponseblock-beforerecordresponse)

Reference on block which allow to make final adjustments to `NSURLRequest` instance, before it will be stored as stub on cassette.

###### Example
```objc
/**
 * In example below, we remove received service data from stub.
 */
configuration.beforeRecordRequest = ^NSArray * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
    return @[response];
};
```

## API

### VCR

#### Properties

##### [`@property (class, nonatomic, readonly, strong) YHVCassette *cassette`](#property-class-nonatomic-readonly-strong-yhvcassette-cassette)

Reference on cassette which currently inserted into VCR.

##### [`@property (class, nonatomic, readonly, strong) NSDictionary<NSString *, YHVMatcherBlock> *matchers`](#property-class-nonatomic-readonly-strong-nsdictionarynsstring--yhvmatcherblock-matchers)

Reference on map of registered request matchers to their GCD blocks.

#### Methods

##### [`+ (void)setupWithConfiguration:(void(^)(YHVConfiguration *configuration))block`](#-voidsetupwithconfigurationvoidyhvconfiguration-configurationblock)  

Configure shared VCR instance. This method can be called multiple times to override default VCR configuration.

###### Example
```objc
NSString *uniquePath = [@[NSTemporaryDirectory(), [NSUUID UUID].UUIDString] 
                        componentsJoinedByString:@"/"];

[YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
    configuration.cassettesPath = [uniquePath stringByAppendingPathExtension:@"bundle"];
    configuration.hostFilter = @[@"apple.com"];
}];
```

##### [`+ (YHVCassette *)insertCassetteWithPath:(NSString *)path`](#-yhvcassette-insertcassettewithpathnsstring-path)  

Insert new or existing cassette into VCR. This method is shortcut to [`+insertCassetteWithConfigurationL:`](#-yhvcassette-insertcassettewithconfigurationvoidyhvconfiguration-configurationblock) with predefined [cassettePath](#property-nonatomic-copy-nsstring-cassettepath).  

Returns reference on inserted cassette which can be used further in code.

###### Example
```objc
// Insert cassette restored from JSON.
YHVCassette *cassette = [YHVVCR insertCassetteWithPath:@"SearchStubCassette"];
```

##### [`+ (YHVCassette *)insertCassetteWithConfiguration:(void(^)(YHVConfiguration *configuration))block`](#-yhvcassette-insertcassettewithconfigurationvoidyhvconfiguration-configurationblock)  

Insert new or existing cassette into VCR with cassette-level configuration. This method allow to override configuration provided by VCR (it won't rewrite configuration in VCR itself).  

###### Example
```objc
YHVCassette *cassette = [YHVVCR insertCassetteWithConfiguration:^(YHVConfiguration *configuration) {
    configuration.cassettePath = @"SearchStubCassette";
    configuration.playbackMode = YHVMomentaryPlayback;
}];
```

##### [`+ (void)ejectCassette`](#-voidejectcassette)  

Eject previously inserted cassette from VCR. After cassette has been removed, no new requests will be recorded or stubbed.  

###### Example
```objc
[YHVVCR insertCassetteWithPath:@"SearchStubCassette"];
// Work with stubbed data.
[YHVVCR ejectCassette];
```

##### [`+ (void)registerMatcher:(NSString *)identifier withBlock:(YHVMatcherBlock)block`](#-voidregistermatchernsstring-identifier-withblockyhvmatcherblockblock)  

Register new matcher block with specified identifier. Matchers used to check whether cassette contain stubbed request for one which has been sent by user's code.

Before `request` will be passed to matcher, it will be passed through [`beforeRecordRequest`](#property-nonatomic-copy-yhvbeforerecordrequestblock-beforerecordrequest) and all configured filters.  

###### Example
```objc
[YHVVCR registerMatcher:@"hostAndPort" withBlock:^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) {
    YHVMatcherBlock hostMatcher = YHVVCR.matchers[YHVMatchers.host];
    YHVMatcherBlock portMatcher = YHVVCR.matchers[YHVMatchers.port];
    
    return hostMatcher(request, stubRequest) && portMatcher(request, stubRequest);
}];
```

##### [`+ (void)unregisterMatcher:(NSString *)identifier`](#-voidunregistermatchernsstring-identifier)  

Unregister custom matcher by it's identifier.  
This method can't be used to remove following default matchers: `YHVMatcher.method`, `YHVMatcher.uri`, `YHVMatcher.scheme`, `YHVMatcher.host`, `YHVMatcher.port`, `YHVMatcher.path`, `YHVMatcher.query`, `YHVMatcher.headers` and `YHVMatcher.body`.

###### Example
```objc
// Remove previously added matcher.
[YHVVCR unregisterMatcher:@"hostAndPort"];
```

### Cassette

#### Properties

##### [`@property (nonatomic, readonly, copy) YHVConfiguration *configuration`](#property-nonatomic-readonly-copy-yhvconfiguration-configuration)

Reference on merged configuration object (merged with VCR configuration) which will be used to handle requests and stubbing data for them.

##### [`@property (nonatomic, readonly, assign) NSUInteger playCount`](#property-nonatomic-readonly-assign-nsuinteger-playcount)

Contains number of fully stubbed requests - those for which response and data has been provided (data task finished data load and reported with handling blocks).  

##### [`@property (nonatomic, readonly, assign) BOOL allPlayed`](#property-nonatomic-readonly-assign-bool-allplayed)

Whether cassette has been played to end of tape or not.

##### [`@property (nonatomic, readonly, assign, getter = isNewCassette) BOOL newCassette`](#property-nonatomic-readonly-assign-getter--isnewcassette-bool-newcassette)

Whether this is new cassette or not. If cassette is new, part of record limitations doesn't apply.

##### [`@property (nonatomic, readonly, assign, getter = isWriteProtected) BOOL writeProtected`](#property-nonatomic-readonly-assign-getter--iswriteprotected-bool-writeprotected)

Whether new requests can be written onto cassette or not. Only existing cassettes with `YHVRecordOnce` recording mode and `YHVRecordNone` may cause this property to return **YES**.

##### [`@property (nonatomic, readonly, strong) NSArray<NSURLRequest *> *requests`](#property-nonatomic-readonly-strong-nsarraynsurlrequest--requests)

Reference on list of requests for which cassette store data for stubbing.

##### [`@property (nonatomic, readonly, strong) NSArray<NSArray *> *responses`](#property-nonatomic-readonly-strong-nsarraynsarray--responses)

Reference on list of responses where each entry consist from nested array, where first element is _NSURLResponse_ instance and second _NSData_ or _NSError_ (depending from whether request success or error has been recorded).

### XCTestCase

Library has helper class (`YHVTestCase`) which perform additional tasks by default to make it easier to use with tests.  
Among default actions taken by helper is cassettes path composition (test suite name will be name of `bundle`) including cassette name generation (based on test case method name).  

#### Properties

##### [`@property (nonatomic, readonly, copy) NSString *cassettesPath`](#property-nonatomic-readonly-copy-nsstring-cassettespath)

Reference on location where cassettes is stored or will be recorded. If new cassettes has been recorded, it is possible to print this value from test suite to find location where `bundle` has been stored.

_NOTE:_ If fixtures already recorded, bundles should be stored (and copied in) inside of `Fixture` folder.

##### [`@property (nonatomic, readonly, copy) NSString *cassettePath`](#property-nonatomic-readonly-copy-nsstring-cassettepath)

Reference on full path to currently used cassette.  

#### Method

`YHVTestCase` subclasses will inherit `YHVTestCaseDelegate` protocol adoption and will be able to dynamically adjust configuration used by VCR and cassette.  
##### [`- (BOOL)shouldSetupVCR`](#--boolshouldsetupvcr)  

Implement this method inside of class with tests to tell whether VCR should be used or not.

###### Example
```objc
- (BOOL)shouldSetupVCR {
    // Use VCR only in case if test case method contain 'Stubbed' in it's name.
    return [self.name rangeOfString:@"Stubbed"].location != NSNotFound;
}
```

##### [`- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration`](#--voidupdatevcrconfigurationfromdefaultconfigurationyhvconfiguration-configuration)  

This callback used by `YHVTestCase` right before `configuration` object will be passed to VCR with [`+setupWithConfiguration:`](#-voidsetupwithconfigurationvoidyhvconfiguration-configurationblock). This is last chance to modify configuration before VCR configuration for test case will be completed.

###### Example
```objc
- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
    /** 
     * Record any requests from test case which contain 'OutdatedStub' in it's 
     * name (something changed and stubbed data should be reloaded).
     */
    if ([self.name rangeOfString:@"OutdatedStub"].location != NSNotFound) {
        configuration.recordMode = YHVRecordAll;
    }
}
```

##### [`- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration`](#--voidupdatevcrconfigurationfromdefaultconfigurationyhvconfiguration-configuration-1)  

This callback used by `YHVTestCase` right before `configuration` object will be passed to VCR with [`+insertCassetteWithConfiguration:`](#-yhvcassette-insertcassettewithconfigurationvoidyhvconfiguration-configurationblock). This is last chance to modify cassette configuration before VCR configuration for test case will be completed.

###### Example
```objc
- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
    /**
     * Change responses playback flow from chronological to momentary - in this
     * mode when requested, stubbed data will be returned till data task will 
     * report completion.
     */ 
    if ([self.name rangeOfString:@"Momentary"].location != NSNotFound) {
        configuration.playbackMode = YHVMomentaryPlayback;
    }
}
```
