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
    
    [self initNetworkCommunication];
    
    _messages = [[NSMutableArray alloc] init];
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

-(void)messageReceived:(NSString *)message
{
    [_messages addObject:message];
    [self.tableview reloadData];
    
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:_messages.count-1 inSection:0];
    [self.tableview scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
}

- (IBAction)joinChatTapped:(id)sender
{
    NSString *response =@"";
    if (_inputNameTextfield.text !=nil || ![_inputNameTextfield.text isEqualToString:@""]) {
        response = [NSString stringWithFormat:@"iam:%@",_inputNameTextfield.text];
        NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [_outputStream write:[data bytes] maxLength:data.length];
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

- (IBAction)sendMessageTapped:(id)sender
{
    NSString *response = @"";
    if (_inputMessageTextfield.text !=nil || ![_inputMessageTextfield.text isEqualToString:@""]) {
        response = [NSString stringWithFormat:@"msg:%@",_inputMessageTextfield.text];
        NSData *data = [NSData dataWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [_outputStream write:data.bytes maxLength:data.length];
        _inputMessageTextfield.text = @"";
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ChatCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *text = (NSString *)[_messages objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    
    return cell;
}

#pragma mark - NSStreamDelegate
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    NSLog(@"流事件:%lu",(unsigned long)eventCode);
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"流已打开");
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"流有数据");
            if (aStream == _inputStream) {
                uint8_t buffer[1024];
                NSInteger len;
                
                while ([_inputStream hasBytesAvailable]) {
                    len = [_inputStream read:buffer maxLength:sizeof(buffer)];
                    
                    if (len>0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        output = [output stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                        output = [output stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                        
                        if (output) {
                            NSLog(@"服务器:%@",output);
                            [self messageReceived:output];
                        }
                    }
                }
            }
            
            break;
        
        case NSStreamEventErrorOccurred:
            NSLog(@"没有连接上主机");
            
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"流停止");
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            break;
        default:
            NSLog(@"Unknown event");
            break;
    }
}
@end
