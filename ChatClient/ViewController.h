//
//  ViewController.h
//  ChatClient
//
//  Created by ycpjobs on 16/3/24.
//  Copyright © 2016年 ycpjobs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<NSStreamDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *joinChatView;
@property (nonatomic, strong) IBOutlet UITextField *inputNameTextfield;
@property (nonatomic, strong) IBOutlet UIButton *joinChatButton;
@property (nonatomic, strong) IBOutlet UITextField *inputMessageTextfield;
@property (nonatomic, strong) IBOutlet UIButton *sendMessageButton;
@property (nonatomic, strong) IBOutlet UITableView *tableview;
@property (nonatomic, strong) IBOutlet UIView *chatView;

@property (nonatomic,strong) NSInputStream *inputStream;
@property (nonatomic,strong) NSOutputStream *outputStream;
@property (nonatomic,strong) NSMutableArray *messages;

- (IBAction)joinChatTapped:(id)sender;
- (IBAction)sendMessageTapped:(id)sender;
@end

