//
//  ViewController.m
//  ChatClient
//
//  Created by ycpjobs on 16/3/24.
//  Copyright © 2016年 ycpjobs. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - private methods
-(void)initNetworkCommunication{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 8080, &readStream, &writeStream);
    
    //self.inputStream = (NSInputStream *)readStream
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream*)writeStream;
    
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
}

- (IBAction)joinChatTapped:(id)sender
{
    NSString *response;
    if (_inputMessageTextfield.text !=nil || ![_inputMessageTextfield.text isEqualToString:@""]) {
        response = [NSString stringWithFormat:@"iam:%@",_inputMessageTextfield.text];
        NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [self.outputStream write:[data bytes] maxLength:data.length];
        [self.view bringSubviewToFront:self.chatView];
    }else {
        UIAlertController *alert  = [UIAlertController alertControllerWithTitle:@"提示" message:@"请填写昵称" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction= [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
