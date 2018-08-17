## WBNetworkingLite

[![CI Status](http://img.shields.io/travis/zsk425/WBNetworkingLite.svg?style=flat-square)](https://travis-ci.org/zsk425/WBNetworkingLite)
[![Version](https://img.shields.io/cocoapods/v/WBNetworkingLite.svg?style=flat-square)](http://cocoadocs.org/docsets/WBNetworkingLite)
[![License](https://img.shields.io/cocoapods/l/WBNetworkingLite.svg?style=flat-square)](http://cocoadocs.org/docsets/WBNetworkingLite)
[![Platform](https://img.shields.io/cocoapods/p/WBNetworkingLite.svg?style=flat-square)](http://cocoadocs.org/docsets/WBNetworkingLite)

基于NSURLSession的轻量级网络库。
主要封装了常用的GET, POST, Put,Delete上传, 下载请求。

主要更新:
* 请求参数可扩展,无需重载大量同名方法，代码调用简洁明了。
* 网络库内部配置通用HttpHeaderFields,外部扩展可配置自定义默认的HttpHeaderFields，自定义默认的parameters，无需外实现类文件。
* 上传请求更新，可自由配置上传文件类型。
* 支持restful Api，并新增Put,Delete请求方式。

###### 安装

```ruby
platform :ios, '7.0'
pod "WBNetworkingLite"
```

###### 初始化配置

```
[WBNetworking setupConfig:^(WBRequestConfig *config) {
    config.baseUrl = @"https://api.douban.com";
    config.timeoutInterval     = 10;
    config.defaultParameters   = @{@"no":[WBKeychain uudi]};
    config.defaultHeaderFields = @{
                                 @"Accept-Encoding":@"gzip, deflate, sdch",
                                 @"Accept-Language":@"keep-alive",
                                 @"appChannel":@"App Store"
                                 };
}];

```

更新配置(只会更新，不会替换字段的值)

```
[WBNetworking updateConfig:^(WBRequestConfig * _Nonnull config) {
   config.defaultParameters = @{@"token":token};
}];

```

###### GET请求

``` objectivec
[WBNetworking GET:^(WBRequestConfig *request) {
    request.url = @"/v2/movie/coming_soon";
} response:^(id response, NSError *error) {
    NSLog(@"response:%@", response);
}];

```

###### POST请求

``` objectivec
[WBNetworking POST:^(WBRequestConfig *request) {
    request.url = @"/lawyer/login";
    request.parameters = @{@"user":@"18565823225", @"pwd":@"96E79218965EB72C92A549DD5A330112"};
} response:^(id response, NSError *error) {
    NSLog(@"response:%@", response);
}];


```

###### PUT请求

``` objectivec
[WBNetworking PUT:^(WBRequestConfig *request) {
    request.url = @"/lawyer/past-case";
    request.rf_parameters = @[@"wans"];
    request.parameters = @{@"username":@"wans",@"password":@"123"};
} response:^(id response, NSError *error) {
    NSLog(@"response:%@", response);
}];


```

###### Delete请求

``` objectivec
[WBNetworking DELETE:^(WBRequestConfig *request) {
    request.url = @"/lawyer/past-case";
    request.rf_parameters = @[@"深圳"];
} response:^(id response, NSError *error) {
    NSLog(@"response:%@", response);
}];


```

###### 上传请求

```objectivec

NSData *data = UIImageJPEGRepresentation(self.imageView.image, 0.5);

[WBNetworking UPLOAD:^(WBRequestConfig *request) {
    request.url = @"/lawyer/lawyer-logo";
} uploadData:^(WBUploadData *uploadData) {
    uploadData.name = @"logo";
    uploadData.filename = @"logo.jpg";
    uploadData.contentType = @"image/jpg";
    uploadData.data = data;
} uploadPercent:^(float percent) {
    NSLog(@"percent >> %f", percent);
} response:^(id response, NSError *error) {
    NSLog(@"response:%@", response);
}];

```

###### 下载请求
```objectivec
[WBNetworking DOWNLOAD:^(WBRequestConfig *request) {
    request.url = @"https://img6.bdstatic.com/img/image/public/yuanjihuasy.png";
} response:^(id  response, NSError *error) {
    self.imageView.image = [UIImage imageWithData:response];
}];
```

###### 取消请求
>请求与请求地址url关联，可以通过url取消正在发送的请求。

```objectivec
[WBNetworking CANCLE:@"/user/get-activity-img"];
```
