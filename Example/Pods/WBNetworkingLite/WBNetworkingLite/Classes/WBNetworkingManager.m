//
//  WBNetworkingManager.m
//  WBExampleProject
//
//  Created by wans on 2017/5/9.
//  Copyright © 2017年 wans. All rights reserved.
//

#import "WBNetworkingManager.h"
#import "objc/runtime.h"
#import "WBNetworking.h"

static NSString *const WBNetworkingContentTypeUrlEncoded       =   @"application/x-www-form-urlencoded";
static NSString *const WBNetworkingContentTypeJson             =   @"application/json";

// 打印日志
#ifdef DEBUG
#define WBNWLog(format, ...) \
if( ![WBNetworking config].disEnableLog ){ \
printf("%s\n", [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] ); \
}
#else
#define WBNWLog(format, ...)
#endif

@interface WBNetworkingManager ()<NSURLSessionTaskDelegate>

@property (nonatomic,strong) NSString            *url, *originalUrl;

@property (nonatomic,strong) id                  parameters;

@property (nonatomic,strong) NSArray             *rf_parameters;

@property (nonatomic,strong) NSString            *method;

@property (nonatomic,strong) NSString            *contentType;

@property (nonatomic,strong) NSMutableURLRequest *mutableRequest;

// 保存接受数据
@property (nonatomic,strong) NSMutableData       *receiveData;

@property (nonatomic,strong) NSProgress          *progress;

@end

@implementation WBNetworkingManager

- (id)setupRequest:(id)instance block:(WBHttpRequestConfig)request {
    if (request) {
        request(instance);
    }
    return instance;
}

- (instancetype)initWithRequest:(WBHttpRequestConfig)request method:(NSString *)method {

    self = [super init];
    if ( self ) {
        
        WBRequestConfig *order = [self setupRequest:[WBRequestConfig new] block:request];
        self.url           = order.url;
        self.parameters    = order.parameters;
        self.rf_parameters = order.rf_parameters;
        self.contentType   = order.contentType;
        
        self.method        = method;
        
        self.receiveData   = [NSMutableData data];
    }
    
    return self;
}

/**
 配置请求头
 */
- (void)setRequest {

    NSString *methodName = self.method;
    
    NSURL *requestURL = [NSURL URLWithString:self.url];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:requestURL];
    
    NSString *queryString = nil;
    if ( [self.method isEqualToString:kWBHttpMethodGet] ) {
        
        queryString = QueryStringFromParameters(self.parameters);
        if (queryString && queryString.length > 0) {
            queryString = [NSString stringWithFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", queryString];

            NSString *requestUrl = [[mutableRequest.URL absoluteString] stringByAppendingString:queryString];
            mutableRequest.URL = [NSURL URLWithString:requestUrl];
            
            if ( self.parameters ) {
                [mutableRequest addValue:WBNetworkingContentTypeUrlEncoded forHTTPHeaderField:@"Content-Type"];
            }
        }
    }else if ( [self.method isEqualToString:kWBHttpMethodDownLoad] ) {
        
        methodName = kWBHttpMethodGet;
        
    }else if ( [self.method isEqualToString:kWBHttpMethodUpload] ) {
        
        methodName = kWBHttpMethodPost;
    }
    
    NSMutableDictionary *httpHeaderFields = @{}.mutableCopy;
    // 添加内部固定的默认http header fields
    NSDictionary *commonHeaderFields = AddCommonHttpHeaderFields();
    if ( commonHeaderFields ) {
        [httpHeaderFields addEntriesFromDictionary:commonHeaderFields];
    }
    
    // 添加外部传入自定义http header fields
    NSDictionary *defaultHeaderFields = [WBNetworking config].defaultHeaderFields;
    if ( defaultHeaderFields ) {
        [httpHeaderFields addEntriesFromDictionary:defaultHeaderFields];
    }
    
    // 设置httpHeaderFields
    for (NSString *field in httpHeaderFields.allKeys) {
        [mutableRequest setValue:httpHeaderFields[field] forHTTPHeaderField:field];
    }
    
    // 设置超时时间
    mutableRequest.timeoutInterval = [WBNetworking config].timeoutInterval;
    mutableRequest.HTTPMethod = methodName;
    mutableRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    // 设置Content-Type
    if ( self.contentType && self.contentType.length > 0 ) {
        [mutableRequest addValue:self.contentType forHTTPHeaderField:@"Content-Type"];
    }

    self.mutableRequest = mutableRequest;
    
    WBNWLog(@"请求地址(%@):%@\n请求参数:%@\n", self.mutableRequest.HTTPMethod, self.url, self.parameters);
}

/**
 配置请求体
 */
- (void)setBody {

    if ( [self.method isEqualToString:kWBHttpMethodUpload] ) {
    
        [self setHttpBodyWithUpload];
        return;
    }
    
    // POST || PUT || DELETE
    if ( [self.method isEqualToString:kWBHttpMethodPost] || [self.method isEqualToString:kWBHttpMethodPut] ) {
        if (self.parameters) {
            id bodyDataString = self.parameters;
            if ( ![self.mutableRequest valueForHTTPHeaderField:@"Content-Type"] ) {
                [self.mutableRequest addValue:WBNetworkingContentTypeUrlEncoded forHTTPHeaderField:@"Content-Type"];
                bodyDataString = QueryStringFromParameters(self.parameters);
            }
            
            NSData *bodyData = [bodyDataString dataUsingEncoding:NSUTF8StringEncoding];

            [self.mutableRequest setHTTPBody:bodyData];
        }
    }
}

/**
 执行请求，

 @param response 完成回调
 */
- (void)setTask:(WBHttpResponse)response {
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    // 保存session，用于后面获取并解引用
    objc_setAssociatedObject(self, "session", session, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ( [self.method isEqualToString:kWBHttpMethodUpload] ) {
        
        NSURLSessionUploadTask *task = [session uploadTaskWithStreamedRequest:self.mutableRequest];
        
        objc_setAssociatedObject(session, "response", response, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        [[self class] addTaskWithKey:self.originalUrl task:task];

        [task resume];
        
    }else if ( [self.method isEqualToString:kWBHttpMethodDownLoad] ) {
      
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:self.mutableRequest];
                
        objc_setAssociatedObject(session, "response", response, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [[self class] addTaskWithKey:self.originalUrl task:task];
        
        [task resume];
        
    }else {
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:self.mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable responseData, NSError * _Nullable error) {
            
            [[self class] removeTaskWithKey:self.originalUrl];
            
            [self releaseSession];

            id meta;
            if ( data ) {
                NSString *reslut = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                meta = DictionaryWithJsonString(reslut);

                WBNWLog(@"请求返回(%@:%@):\n%@", self.mutableRequest.HTTPMethod, self.url, jsonPrettyString(meta));
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                response(meta, error);
            });
            
        }];

        [[self class] addTaskWithKey:self.originalUrl task:task];

        [task resume];
        
        
    } 
}

- (void)configProgress:(WBHttpProgress)progressBlock {
    
    objc_setAssociatedObject(self, "progressBlock", progressBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)configUploadData:(WBHttpUploadData)uploadDataBlock {

    objc_setAssociatedObject(self, "uploadData", uploadDataBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)excuteTaskResponse:(WBHttpResponse)response {

    [self setRequest];
    [self setBody];
    [self setTask:response];
}

#pragma mark - NSURLSessionTaskDelegate

/**
 请求进度回调

 @param session 会话
 @param task 任务
 @param bytesSent 本次写入的长度
 @param totalBytesSent 目前共写入的长度
 @param totalBytesExpectedToSend 期望的长度，也就是总长度
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    WBHttpProgress progressBlock = objc_getAssociatedObject(self, "progressBlock");
    if ( !self.progress ) {
        self.progress = [NSProgress progressWithTotalUnitCount:totalBytesExpectedToSend];
    }
    self.progress.completedUnitCount = totalBytesSent;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( progressBlock )  progressBlock(self.progress);
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveData:(nonnull NSData *)data {
    
    [self.receiveData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    // 将Task解引用并销毁
    [self releaseSession];
    
    // 移除当前Task
    [[self class] removeTaskWithKey:self.originalUrl];
    
    // 如果下载成功会NSURLSessionDownloadDelegate中成功回调
    if ( [self.method isEqualToString:kWBHttpMethodDownLoad] ) {
        return;
    }
    
    WBHttpResponse response = objc_getAssociatedObject(session, "response");
    
    if ( response ) {
        NSString *reslut = [[NSString alloc] initWithData:self.receiveData encoding:NSUTF8StringEncoding];
        id meta = DictionaryWithJsonString(reslut);
        WBNWLog(@"请求返回(%@:%@):\n%@", self.mutableRequest.HTTPMethod, self.url, jsonPrettyString(meta));
        
        response(meta, error);
    }
}

/**
 等待当前Task结束后关闭,Delegate收到这个事件之后会被解引用。
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
//    NSLog(@"session finishTasksAndInvalidate %@", [error description]);
}

/**
 处理HTTPS请求

 @param session 会话
 @param challenge 质询
 @param completionHandler 回调
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    // 判断是否是信任服务器证书
    if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        // 告诉服务器，客户端信任证书
        // 创建凭据对象
        NSURLCredential *credntial = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        // 通过completionHandler告诉服务器信任证书
        completionHandler(NSURLSessionAuthChallengeUseCredential,credntial);
    }
    NSLog(@"protectionSpace = %@",challenge.protectionSpace);
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    WBHttpProgress progressBlock = objc_getAssociatedObject(self, "progressBlock");
    if ( !self.progress ) {
        self.progress = [NSProgress progressWithTotalUnitCount:totalBytesExpectedToWrite];
    }
    self.progress.completedUnitCount = totalBytesWritten;
    
    if ( progressBlock )  progressBlock(self.progress);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    // 将Task解引用并销毁
    [self releaseSession];
    
    // 移除当前Task
    [[self class] removeTaskWithKey:self.originalUrl];

    NSData *downloadData = [NSData dataWithContentsOfURL:location];
    
    WBNWLog(@"请求返回(%@:%@):\n下载路径:%@", self.mutableRequest.HTTPMethod, self.url, location.absoluteString);

    WBHttpResponse response = objc_getAssociatedObject(session, "response");
    if ( response ) response(downloadData, NULL);
}

#pragma mark - Task Getter && Setter

static NSMutableDictionary *currentTasks;

+ (NSURLSessionTask *)taskWithKey:(NSString *)key {
    
    return currentTasks[key];
}

+ (void)addTaskWithKey:(NSString *)key task:(NSURLSessionTask *)task {
    
    if ( !currentTasks ) {
        currentTasks = [@{} mutableCopy];
    }
    
    if ( !task ) {
        return;
    }
    
    currentTasks[key] = task;
}

+ (void)removeTaskWithKey:(NSString *)key {
    
    if ( [currentTasks.allKeys containsObject:key] ) {
        [currentTasks removeObjectForKey:key];
    }
}

#pragma mark - Private Methods

/**
 拼接上传文件
 */
- (void)setHttpBodyWithUpload {
    
    WBHttpUploadData uploadDataBlock = objc_getAssociatedObject(self, "uploadData");
    
    WBUploadData *uploadData = [[WBUploadData alloc] init];
    if(uploadDataBlock) uploadDataBlock(uploadData);
    
    // 分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    // 分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    // 结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    // 要上传的数据
    NSData* data = uploadData.data;
    // http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    // 遍历keys
    
    for (NSString *key in ((NSDictionary *)self.parameters).allKeys ) {
        
        // 添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        // 添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        // 添加字段的值
        [body appendFormat:@"%@\r\n", self.parameters[key]];
    }
    
    // 添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", uploadData.name, uploadData.filename];
    // 声明上传文件的格式
    [body appendFormat:@"Content-Type: %@\r\n\r\n", uploadData.contentType];
    
    // 声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    
    NSMutableData *requestData=[NSMutableData data];
    
    [requestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [requestData appendData:data];
    [requestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    // 设置HTTPHeader
    [self.mutableRequest setValue:content forHTTPHeaderField:@"Content-Type"];
    // 设置Content-Length
    [self.mutableRequest setValue:[NSString stringWithFormat:@"%ld", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    // 设置http body
    [self.mutableRequest setHTTPBody:requestData];
    
}

/**
 将字典转化为key-value拼接字符串

 @param parameters 参数字典
 @return 键值拼接字符串
 */
NSString * QueryStringFromParameters(NSDictionary *parameters) {
    
    NSMutableDictionary *finalParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if ( !finalParams ) {
        finalParams = [NSMutableDictionary dictionary];
    }
    
    if ( finalParams.count == 0 ) {
        return @"";
    }
    
    __block NSMutableString *queryString = [[NSMutableString alloc] init];
    
    [finalParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        // 服务器接收参数的 key 值.
        NSString *paramaterKey = key;
        // 参数内容
        NSString *paramaterValue = obj;
        
        // appendFormat :可变字符串直接拼接的方法!
        [queryString appendFormat:@"%@=%@&",paramaterKey,paramaterValue];
    }];
    
    NSString *body = [queryString substringToIndex:queryString.length - 1];
    
    // Url编码
    body = [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return body;
}

/**
 网络请求默认请求headerfields
 
 @return 参数字典
 */
NSDictionary * AddCommonHttpHeaderFields() {

    NSMutableDictionary *defaultHeaders = [@{} mutableCopy];

    defaultHeaders[@"platform"] = @"IOS";
    
    NSString *appVersion = [[WBNetworking config].defaultHeaderFields objectForKey:@"appVersion"];
    if ( !appVersion ) {
        appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        defaultHeaders[@"appVersion"] = appVersion;
    }
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], appVersion ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    
    defaultHeaders[@"User-Agent"] = userAgent;
    
    return defaultHeaders;
}

/**
 等待当前Task结束后解除Delegate的引用
 */
- (void)releaseSession {
    
    NSURLSession *session = objc_getAssociatedObject(self, "session");
    if( session ) {
        [session finishTasksAndInvalidate];
    }
}

#pragma mark - Getter&&Setter

- (void)setParameters:(id)parameters {
    
    if ( !_parameters ) {
        
        if ( parameters && [parameters isKindOfClass:NSDictionary.class] ) {
            NSMutableDictionary *realParams = [@{} mutableCopy];
            
            if ( parameters ) {
                [realParams addEntriesFromDictionary:parameters];
            }
            
            if ( [WBNetworking config].defaultParameters ) {
                [realParams addEntriesFromDictionary:[WBNetworking config].defaultParameters];
            }
            _parameters = realParams;
            
            return;
        }
        _parameters = parameters;
    }
}

/**
 *
 初始化host地址
 [WBNetworking setupConfig:^(WBNetworkingConfig *config) {
     config.baseUrl = @"http://192.168.10.224:7080";
 }];
 *
 */
- (void)setUrl:(NSString *)url {
    
    if ( !_url || _url.length == 0 ) {
        
        NSString *baseUrl = [[WBNetworking config].baseUrl lowercaseString];
        
        // restful请求方式会改变url，所以保存原始url，用于销毁处理
        _originalUrl = url;
        
        NSAssert(baseUrl.length > 0 && [baseUrl hasPrefix:@"http"], @"无效服务器地址，请先在AppDelegate里初始化服务器地址！！！");
        
        if ( baseUrl && url && ![url hasPrefix:@"http"]) {
            url = [baseUrl stringByAppendingString:url];
        }
        
        _url = url;
    }
}

- (void)setRf_parameters:(NSArray *)rf_parameters {
    
    _rf_parameters = rf_parameters;
    NSMutableString *restfulParams = [NSMutableString string];
    if ( rf_parameters && rf_parameters.count > 0 ) {
        [rf_parameters enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [restfulParams appendFormat:@"/%@", obj];
        }];
        // 中文转码，再生成restful风格请求地址
        _url = [_url stringByAppendingString:[restfulParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
}

/**
 输出格式化json字符串

 @param dic 字典
 @return json字符串
 */
NSString * jsonPrettyString(NSDictionary *dic) {
    if ([NSJSONSerialization isValidJSONObject:dic]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
}

/**
 把格式化的JSON格式的字符串转换成字典
 
 @param jsonString JSON格式的字符串
 @return 字典
 */
NSDictionary * DictionaryWithJsonString(NSString *jsonString) {
    
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    
    return dic;
}

#pragma mark - dealloc

- (void)dealloc {
    
#if DEBUG
    NSLog(@"- [%@ dealloc]",[self class]);
#endif
}

@end
