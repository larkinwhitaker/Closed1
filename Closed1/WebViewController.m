//
//  WebViewController.m
//  Closed1
//
//  Created by Nazim on 26/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "WebViewController.h"
#import "NJKWebViewProgress.h"
#import "UINavigationController+NavigationBarAttribute.h"

@interface WebViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *goBackButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *goForwardButton;
@property(nonatomic)     NJKWebViewProgress *progressProxy;
;

@end

// MARK: Constants

NSString *const linkedInKey = @"81c2yrtk6svdpa";
NSString *const linkedInSecret = @"PfVeDFmQtj6Chp7D";
NSString *const authorizationEndPoint = @"https://www.linkedin.com/uas/oauth2/authorization";
NSString *const accessTokenEndPoint = @"https://www.linkedin.com/uas/oauth2/accessToken";



@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController configureNavigationBar:self];
    _webView.delegate = self;
    [self configureProxyWebView];
 
    
    if (_isLinkedinSelected) {
        [self startAuthorization];
    }else{
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: _urlString]];
        
        [_webView loadRequest:request];

    }

}

-(void)configureProxyWebView
{
    _progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = (id)self;
    
}
-(void)backButtonTapped: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)startAuthorization
{
    // Specify the response type which should always be "code".

    NSString *responseType = @"code";
    
    // Set the redirect URL. Adding the percent escape characthers is necessary.
    
    NSString *redirectURLs = @"https://com.appcoda.linkedin.oauth/oauth";
    
    NSString *escapedString = [redirectURLs stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

    
    
    
    // Create a random string based on the time interval (it will be in the form linkedin12345679).
    
    NSString *state = [NSString stringWithFormat:@"linkedin%zd", [NSDate timeIntervalSinceReferenceDate]];
    
    // Set preferred scope.
    NSString *scope = @"r_basicprofile+r_emailaddress";
    
    // Create the authorization URL string.
    
    NSString *authorizationURL = [NSString stringWithFormat:@"%@?response_type=%@&client_id=%@&redirect_uri=%@&state=%@&scope=%@", authorizationEndPoint,responseType,linkedInKey,escapedString,state,scope];
    
    NSLog(@"%@",authorizationURL);
    
    // Create a URL request and load it in the web view.
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authorizationURL]];
    
    [_webView loadRequest:request];
    


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Webview Delegates

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    _goForwardButton.enabled = [webView canGoForward];
    _goBackButton.enabled = [webView canGoBack];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    _goForwardButton.enabled = [webView canGoForward];
    _goBackButton.enabled = [webView canGoBack];
    
}
#pragma mark - NJProgress Bar Delegate Methods
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSURL *url = request.URL;
    
    NSRange token = [url.absoluteString rangeOfString:@"code"];
    if (token.location != NSNotFound)
    {
        NSString *urlParts = [[url.absoluteString componentsSeparatedByString:@"?"] objectAtIndex:1];
        
        NSString *code = [[urlParts componentsSeparatedByString:@"="] objectAtIndex:1];
        
        [self requestForAccessToken: code];
    }

    
    
    
    return YES;
}

-(void)requestForAccessToken: (NSString *)authorizationCode
{
    NSString *grantType = @"authorization_code";
    
    NSString *redirectURL = @"https://com.appcoda.linkedin.oauth/oauth";
    
    NSString *escapedString = [redirectURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

    // Set the POST parameters.
    NSString *postParams = [NSString stringWithFormat:@"grant_type=%@&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@",grantType,authorizationCode,escapedString,linkedInKey,linkedInSecret];
    
    NSLog(@"%@", postParams);
    
    // Convert the POST parameters into a NSData object.
    NSData *postData = [postParams dataUsingEncoding:NSUTF8StringEncoding];
    
    // Initialize a mutable URL request object using the access token endpoint URL string.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:accessTokenEndPoint]];
    
    // Indicate that we're about to make a POST request.
    request.HTTPMethod = @"POST";
    
    // Set the HTTP body using the postData object created above.
    request.HTTPBody = postData;
    // Add the required HTTP header field.
    
    [request addValue:@"application/x-www-form-urlencoded;" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];


    // Initialize a NSURLSession object.

    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *loadDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        if (httpResponse.statusCode == 200) {
            
        
            NSArray * arrayOfDictionaryFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            NSLog(@"%@", arrayOfDictionaryFromServer);
            
            NSString *acessToken = [arrayOfDictionaryFromServer valueForKey:@"access_token"];
            
            [[NSUserDefaults standardUserDefaults] setValue:acessToken forKey:@"LIAccessToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.delegate linkedInAcessToken:acessToken];
                [self dismissViewControllerAnimated:YES completion:nil];
            });

        }
    
    }];
    [loadDataTask resume];
    
    

}



@end
