//
//  AdSdkHttpRequest.m
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/20.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import "AdSdkHttpRequest.h"
#import "AdSdkLogCenter.h"

@interface NSString (AdSdkHttpRequest)
-(NSString *) URLEncodedString;
-(NSString *) URLEncodedStringWithCFStringEncoding: (CFStringEncoding)encoding;
@end

@implementation NSString (AdSdkHttpRequest)
- (NSString *)URLEncodedString{
    return [self URLEncodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}
- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding{
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[self mutableCopy], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), encoding));
}
@end

@implementation AdSdkHttpRequest
@synthesize timeout;
@synthesize postDataType = _postDataType;

+(AdSdkHttpRequest *) initWithURL:(NSString *)url httpMethod:(NSString *)httpMethod params:(NSDictionary *)params httpHeaderFields:(NSDictionary *)httpHeaderFields shortTimeoutType:(NSInteger)timeout postDataType:(HttpRequestPostDataType)postDataType delegate:(id<HttpRequestDelegate>)delegate{
    
    AdSdkHttpRequest * request = [[AdSdkHttpRequest alloc]init];
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.timeout = timeout;
    request.httpHeaderFields = httpHeaderFields;
    request.postDataType = postDataType;
    request.delegate = delegate;
    
    return request;
}

+(NSString *)serialzeURL: (NSString *)baseURL
                   params: (NSDictionary *)params
               httpMethod: (NSString *)httpMethod{
    if (![[httpMethod uppercaseString] isEqualToString:@"GET"]) {
        return baseURL;
    }
    
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
    if (nil != params) {
        NSString * queryPrefix = parsedURL.query ? @"&" : @"?";
        NSString * query = [AdSdkHttpRequest jasonStringFromDictionary: params];
        return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
    }
    
    return baseURL;
}

+(NSString *)jasonStringFromDictionary: (NSDictionary *)dict {
    if (!dict) {
        return nil;
    }
    
    NSData * jsonStr = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString * str = [[NSString alloc]initWithData:jsonStr encoding:NSUTF8StringEncoding];
    
    return str;
}

+(NSString *)stringFormDictionary: (NSDictionary *)dict {
    NSArray * sortArray = [dict allKeys];
    
    NSArray *array = [sortArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSMutableArray * pairs = [NSMutableArray array];
    for (int i = 0; i < array.count; i++) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", [array objectAtIndex:i], [dict objectForKey:[array objectAtIndex:i]]]];
    }
    
    if (1 == pairs.count) {
        return [pairs componentsJoinedByString:@""];
    }
    
    return [pairs componentsJoinedByString:@"&"];
}


- (NSData *) synchronousConnect{
    //TOOD:判断网络是否异常
    NSString *urlString = [AdSdkHttpRequest serialzeURL:_url params:_params httpMethod:_httpMethod];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
    
    [request setHTTPMethod:_httpMethod];
    
    if ([[_httpMethod uppercaseString] isEqualToString:@"POST"]){
        [request setHTTPBody:[self postBody]];
    }
    
    for (NSString *key in [_httpHeaderFields keyEnumerator]){
        [request setValue:[_httpHeaderFields objectForKey:key] forHTTPHeaderField:key];
    }
    
    RLog(LD,@"HttpRequest Method-->%@",[request HTTPMethod]);
    RLog(LD,@"HttpRequest URL-->%@",[request URL]);
    
//    if (_httpHeaderFields) {
//        for (NSString *key in [_httpHeaderFields keyEnumerator]) {
//            RLog(LD,@"HttpRequest header field is-->%@,value is-->%@",key,[request valueForHTTPHeaderField:key]);
//        }
//    }
    
//    if ([[_httpMethod uppercaseString] isEqualToString:@"POST"]) {
//        NSString *str = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
////        RLog(LD,@"HttpRequest post data is-->%@",str);
//    }
    
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    RLog(LD, @"sync HttpRequest Response Status Code-->%d",(int)[(NSHTTPURLResponse *)response statusCode]);
    if ([self.delegate respondsToSelector:@selector(request: didReceiveResCode:)]) {
        [self.delegate request:self didReceiveResCode:[(NSHTTPURLResponse*)response statusCode]];
    }
    
    return data;
}

-(void)asynchronousConnect {
    //判断网络异常
    NSString * urlString = [AdSdkHttpRequest serialzeURL:_url params:_params httpMethod:_httpMethod];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];
    
    [request setHTTPMethod:_httpMethod];
    
    if ([[_httpMethod uppercaseString] isEqualToString:@"POST"]) {
        [request setHTTPBody:[self postBody]];
    }
}

#pragma mark - NSURLConnection Delegate Methods

-(void)connection: (NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    resData = [[NSMutableData alloc]init];

    RLog(LD, @"native HttpRequest->Response Status Code--->%d", (int)[(NSHTTPURLResponse*)response statusCode]);
    
    if ([self.delegate respondsToSelector:@selector(request: didReceiveResCode:)]) {
        [self.delegate request:self didReceiveResCode:[(NSHTTPURLResponse*)response statusCode]];
    }
    
    if ([self.delegate respondsToSelector:@selector(request: didReceiveResponse:)]) {
        [self.delegate request: self didReceiveResponse:response];
    }
}

-(void)connection: (NSURLConnection *)connection didReceiveData:(NSData *)data{
    if ([self.delegate respondsToSelector:@selector(request: didReceiveRawData:)]) {
        [self.delegate request:self didReceiveRawData:data];
    }
    
    return [resData appendData:data];
}

-(NSCachedURLResponse *)connection: (NSURLConnection *)connection
willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    return nil;
}

-(void)connectionDidFinishLoading: (NSURLConnection *)theConnection{
    NSString * str = [[NSString alloc]initWithData:resData encoding:NSUTF8StringEncoding];
    RLog(LD, @"HttpRequest->response data is: %@", str);
    
    if ([self.delegate respondsToSelector:@selector(request: didFinishLoadingWithResult:)]) {
        [self.delegate request:self didFinishLoadingWithResult:resData];
    }
    
    [connection cancel];
    connection = nil;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [self.delegate request:self didFailWithError:error];
    }
    [self disconnect];
}

#pragma LDHttpRequest Private Method

+(void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString{
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSMutableData *)postBody{
    NSMutableData *body = [NSMutableData data];
    
    if (_postDataType == HttpRequestPostDataTypeNormal) {
        [AdSdkHttpRequest appendUTF8Body:body dataString:[AdSdkHttpRequest jasonStringFromDictionary:_params]];
    }else if(_postDataType == HttpRequestPostDataTypeMultipart){
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        for (id key in [_params keyEnumerator]) {
            if (([[_params valueForKey:key] isKindOfClass:[UIImage class]]) || ([[_params valueForKey:key] isKindOfClass:[NSData class]]))
            {
                [dataDictionary setObject:[_params valueForKey:key] forKey:key];
            }
            
            [AdSdkHttpRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, [_params valueForKey:key]]];
        }
        
        if ([dataDictionary count] > 0) {
            for (id key in dataDictionary) {
                NSObject *dataParam = [dataDictionary valueForKey:key];
                if ([dataParam isKindOfClass:[UIImage class]]) {
                    NSData* imageData = UIImagePNGRepresentation((UIImage *)dataParam);
                    [AdSdkHttpRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file.png\"\r\n", key]];
                    [AdSdkHttpRequest appendUTF8Body:body dataString:@"Content-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
                    [body appendData:imageData];
                }else if([dataParam isKindOfClass:[NSData class]]){
                    [AdSdkHttpRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key]];
                    [AdSdkHttpRequest appendUTF8Body:body dataString:@"Content-Type: content/unknown\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
                    [body appendData:(NSData*)dataParam];
                }
            }
        }
    }
    
    return body;
}

-(void)disconnect{
    @try {
        resData = nil;
        [connection cancel];
        connection = nil;
    } @catch (NSException *exception) {
        RLog(LE, @"web request exception %@", exception);
    } @finally {
        
    }
}

@end
