# WKWebView与JS的交互

1.如果想要获取html对应的操作，首先我们要给WKWebView注入一个方法名：

```objective-c
[_wkWebView.configuration.userContentController addScriptMessageHandler:self name:@"对应的方法名"];
```

这个方法名和html里要传给iOS端的方法名一样，在htlm里这样写：

```html
window.webkit.messageHandlers.(对应的方法名).postMessage("需要传递的数据")
```

然后在WKWebView的WKScriptMessageHandler(类似代理，记得挂上)，当Html里调用上面那个方法的时候，就会有对应的回调信息,在回调信息里根据对应的名称来执行操作：

```objective-c
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if([message.name isEqualToString:jsName])//此处name为JS传出信息打包的标志<name>
    {
    
    }
}
```

记得在结束这个WKWebView页面的时候要把刚才加上的给移除了：

```objective-c
[_wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"对应的方法名"];
```

2.如果我们要给html传输数据执行对应的js：

```objective-c
//设置JS
NSString *inputValueJS = @"方法名(传的参数)";
//执行JS
[thisVC.wkWebView evaluateJavaScript:inputValueJS completionHandler:^(id _Nullable response, NSError * _Nullable error) {
    NSLog(@"value: %@ error: %@", response, error);
}];
```

如果Html里有对应方法的话，就会执行这个方法