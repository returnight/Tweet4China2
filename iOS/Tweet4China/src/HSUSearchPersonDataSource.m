//
//  HSUSearchPersonDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 10/20/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUSearchPersonDataSource.h"

@implementation HSUSearchPersonDataSource

- (void)fetchDataWithSuccess:(HSUTwitterAPISuccessBlock)success failure:(HSUTwitterAPIFailureBlock)failure
{
    if (![self.keyword length]) {
        return;
    }
    NSString *keyword = self.keyword;
    [TWENGINE searchUserWithKeyword:self.keyword success:^(id responseObj) {
        if ([self.keyword isEqualToString:keyword]) {
            success(responseObj);
        }
    } failure:^(NSError *error) {
        if ([self.keyword isEqualToString:keyword]) {
            failure(error);
        }
    }];
}

- (void)loadMore
{
    [super loadMore];
    
    [self fetchDataWithSuccess:^(id responseObj) {
        NSArray *users = responseObj;
        [self.data removeAllObjects];
        for (NSDictionary *user in users) {
            HSUTableCellData *cellData =
            [[HSUTableCellData alloc] initWithRawData:user dataType:kDataType_Person];
            [self.data addObject:cellData];
        }
        
        [self.delegate preprocessDataSourceForRender:self];
        [self.delegate dataSource:self didFinishLoadMoreWithError:nil];
        self.loadingCount --;
    } failure:^(NSError *error) {
        [TWENGINE dealWithError:error errTitle:_(@"Load search result failed")];
        [self.delegate dataSource:self didFinishLoadMoreWithError:error];
    }];
}

@end
