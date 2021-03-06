//
//  HSUShadowsocksViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 13-12-30.
//  Copyright (c) 2013年 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUShadowsocksViewController.h"
#import <RETableViewManager/RETableViewManager.h>
#import <RETableViewManager/RETableViewOptionsController.h>
#import "HSUProxySettingsViewController.h"

@interface HSUShadowsocksViewController ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
@property (nonatomic, strong) RETableViewManager *manager;
#endif

@end

@implementation HSUShadowsocksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _(@"Shadowsocks");
    self.tableView = [[UITableView alloc] initWithFrame:self.tableView.frame style:UITableViewStyleGrouped];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    
    RETableViewSection *section = [RETableViewSection section];
    [self.manager addSection:section];
    
    NSArray *sss = [[NSUserDefaults standardUserDefaults] objectForKey:HSUShadowsocksSettings];
    for (NSDictionary *ss in sss) {
        NSString *ssserver = ss[HSUShadowsocksSettings_Server];
        NSString *ssport = ss[HSUShadowsocksSettings_RemotePort];
        NSString *title = ssserver ? S(@"%@:%@", ssserver, ssport) : _(@"Default");
        if (ss[HSUShadowsocksSettings_Buildin]) {
            title = S(@"Buildin Server %d", ([sss indexOfObject:ss] + 1));
        } else {
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
        }
        
        UITableViewCellAccessoryType accessoryType = [ss[HSUShadowsocksSettings_Selected] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        RETableViewItem *item =
        [RETableViewItem itemWithTitle:title
                         accessoryType:accessoryType
                      selectionHandler:^(RETableViewItem *item)
         {
             NSMutableArray *sss = [[[NSUserDefaults standardUserDefaults] objectForKey:HSUShadowsocksSettings] mutableCopy];
             for (int i=0; i<sss.count; i++) {
                 NSDictionary *ss = sss[i];
                 NSMutableDictionary *mss = ss.mutableCopy;
                 BOOL selected = [ss[HSUShadowsocksSettings_Server] isEqualToString:ssserver] &&
                 [ss[HSUShadowsocksSettings_RemotePort] isEqualToString:ssport];
                 mss[HSUShadowsocksSettings_Selected] = @(selected);
                 sss[i] = mss;
             }
             [[NSUserDefaults standardUserDefaults] setObject:sss forKey:HSUShadowsocksSettings];
             [[NSUserDefaults standardUserDefaults] synchronize];
             [self.navigationController popViewControllerAnimated:YES];
             [[HSUAppDelegate shared] stopShadowsocks];
         }];
        if (!ss[HSUShadowsocksSettings_Selected] && !ss[HSUShadowsocksSettings_Buildin]) {
            item.editingStyle = UITableViewCellEditingStyleDelete;
        }
        item.deletionHandler = ^(RETableViewItem *item) {
            NSMutableArray *sss = [[[NSUserDefaults standardUserDefaults] objectForKey:HSUShadowsocksSettings] mutableCopy];
            for (NSDictionary *ss in sss) {
                if ([ss[HSUShadowsocksSettings_Server] isEqualToString:ssserver] &&
                    [ss[HSUShadowsocksSettings_RemotePort] isEqualToString:ssport]) {
                    
                    [sss removeObject:ss];
                }
            }
            [[NSUserDefaults standardUserDefaults] setObject:sss forKey:HSUShadowsocksSettings];
            [[NSUserDefaults standardUserDefaults] synchronize];
        };
        [section addItem:item];
    }
    
    [section addItem:
     [RETableViewItem itemWithTitle:_(@"Add New")
                      accessoryType:UITableViewCellAccessoryDisclosureIndicator
                   selectionHandler:^(RETableViewItem *item)
      {
          // push proxy settings view controller
          HSUProxySettingsViewController *proxySettingsVC = [[HSUProxySettingsViewController alloc] init];
          [self.navigationController pushViewController:proxySettingsVC animated:YES];
      }]];
#endif
}

@end
