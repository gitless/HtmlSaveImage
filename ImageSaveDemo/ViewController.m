//
//  ViewController.m
//  ImageSaveDemo
//
//  Created by v on 16/2/26.
//  Copyright © 2016年 v. All rights reserved.
//

#import "ViewController.h"
#import "UnpreventableUILongPressGestureRecognizer.h"
#import "UIWebView+WebViewAdditions.h"
@interface ViewController ()<UIActionSheetDelegate,UIWebViewDelegate>
@property (strong , nonatomic) UIWebView *webview;
@property (strong , nonatomic) UIActionSheet *actionActionSheet;
@property (copy , nonatomic)NSString * selectedLinkURL;
@property (copy , nonatomic)NSString * selectedImageURL;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webview = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _webview.delegate = self;
    [self.view addSubview:_webview];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.jianshu.com/p/c2e1cde8d119"]]];
   
    UnpreventableUILongPressGestureRecognizer *longPressRecognizer = [[UnpreventableUILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.allowableMovement = 20;
    longPressRecognizer.minimumPressDuration = 1.0f;
    [_webview addGestureRecognizer:longPressRecognizer];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint pt = [gestureRecognizer locationInView:self.webview];
        
        // convert point from view to HTML coordinate system
        CGSize viewSize = [self.webview frame].size;
        CGSize windowSize = [self.webview windowSize];
        CGFloat f = windowSize.width / viewSize.width;
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0) {
            pt.x = pt.x * f;
            pt.y = pt.y * f;
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offset = [self.webview scrollOffset];
            pt.x = pt.x * f + offset.x;
            pt.y = pt.y * f + offset.y;
        }
        
        [self openContextualMenuAt:pt];
    }
}

- (void)openContextualMenuAt:(CGPoint)pt{
   
    NSString *path =[[NSBundle mainBundle] pathForResource:@"JSTools" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [_webview stringByEvaluatingJavaScriptFromString:jsCode];
    
    // get the Tags at the touch location
    NSString *tags = [_webview stringByEvaluatingJavaScriptFromString:
                      [NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%li,%li);",(long)pt.x,(long)pt.y]];
    
    NSString *tagsHREF = [_webview stringByEvaluatingJavaScriptFromString:
                          [NSString stringWithFormat:@"MyAppGetLinkHREFAtPoint(%li,%li);",(long)pt.x,(long)pt.y]];
    
    NSString *tagsSRC = [_webview stringByEvaluatingJavaScriptFromString:
                         [NSString stringWithFormat:@"MyAppGetLinkSRCAtPoint(%li,%li);",(long)pt.x,(long)pt.y]];
    
    NSLog(@"tags : %@",tags);
    NSLog(@"href : %@",tagsHREF);
    NSLog(@"src : %@",tagsSRC);
    if (!_actionActionSheet) {
        _actionActionSheet = nil;
    }
    _actionActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil];
    
    _selectedLinkURL = @"";
    _selectedImageURL = @"";
    
    // If an image was touched, add image-related buttons.
    if ([tags rangeOfString:@",IMG,"].location != NSNotFound) {
        _selectedImageURL = tagsSRC;
        
        if (_actionActionSheet.title == nil) {
            _actionActionSheet.title = tagsSRC;
        }
        
        [_actionActionSheet addButtonWithTitle:@"保存图片"];
        [_actionActionSheet addButtonWithTitle:@"复制图片链接"];
    }
    // If a link is pressed add image buttons.
    if ([tags rangeOfString:@",A,"].location != NSNotFound){
        _selectedLinkURL = tagsHREF;
        
        _actionActionSheet.title = tagsHREF;
        [_actionActionSheet addButtonWithTitle:@"打开链接"];
        [_actionActionSheet addButtonWithTitle:@"复制链接"];
    }
    
    if (_actionActionSheet.numberOfButtons > 0) {
        [_actionActionSheet addButtonWithTitle:@"取消"];
        _actionActionSheet.cancelButtonIndex = (_actionActionSheet.numberOfButtons-1);
        [_actionActionSheet showInView:_webview];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"打开链接"]){
        [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_selectedLinkURL]]];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"复制链接"]){
        [[UIPasteboard generalPasteboard] setString:_selectedLinkURL];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"复制图片链接"]){
        [[UIPasteboard generalPasteboard] setString:_selectedImageURL];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"保存图片"]){
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_selectedImageURL]]];
//            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        
        //        });
//            去缓存中去取  比较省流量
            NSURLCache *cache =[NSURLCache sharedURLCache];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_selectedImageURL]];
            NSData *imgData = [cache cachedResponseForRequest:request].data;
            UIImage *images = [UIImage imageWithData:imgData];
            UIImageWriteToSavedPhotosAlbum(images, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

       
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(!error){
        NSLog(@"save success");
    }else{
        NSLog(@"save failed");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    
    return YES;
}
@end
