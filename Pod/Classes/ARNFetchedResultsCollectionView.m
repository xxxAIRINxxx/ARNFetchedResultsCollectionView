//
//  ARNFetchedResultsCollectionView.m
//  ARNFetchedResultsCollectionView
//
//  Created by Airin on 10/06/2014.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import "ARNFetchedResultsCollectionView.h"

#import <ARNFetchedResultsController.h>

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface ARNFetchedResultsCollectionView ()

@property (nonatomic, strong) ARNFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSBlockOperation *blockOperation;

@property (nonatomic, assign) BOOL shouldReloadCollectionView;

@end

@implementation ARNFetchedResultsCollectionView

- (void)dealloc
{
    [self disConnect];
}

- (void)disConnect
{
    [_fetchedResultsController disConnect];
}

- (void)commonInit
{
    self.fetchedResultsController = [[ARNFetchedResultsController alloc] init];
    
    __weak typeof(self) weakSelf = self;
    
    self.fetchedResultsController.willChangeContentBlock = ^(NSFetchedResultsController *frController) {
        weakSelf.blockOperation = [[NSBlockOperation alloc] init];
        weakSelf.shouldReloadCollectionView = NO;
    };
    
    self.fetchedResultsController.didChangeSectionBlock = ^(id <NSFetchedResultsSectionInfo> sectionInfo, NSFetchedResultsChangeType type, NSUInteger sectionIndex){
        
        if (!weakSelf) { return; }
        
        switch (type) {
            case NSFetchedResultsChangeInsert: {
                [weakSelf.blockOperation addExecutionBlock:^{
                    [weakSelf insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                }];
                break;
            }
            case NSFetchedResultsChangeDelete: {
                [weakSelf.blockOperation addExecutionBlock:^{
                    [weakSelf deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                }];
                break;
            }
            case NSFetchedResultsChangeUpdate: {
                [weakSelf.blockOperation addExecutionBlock:^{
                    [weakSelf reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                }];
                break;
            }
            default:
                break;
        }
    };
    
    self.fetchedResultsController.didChangeObjectBlock = ^(id anObject, NSFetchedResultsChangeType type, NSIndexPath *indexPath, NSIndexPath *newIndexPath) {
        if (!weakSelf) { return; }
        
        switch (type) {
            case NSFetchedResultsChangeInsert: {
                if ([weakSelf numberOfSections] > 0) {
                    if ([weakSelf numberOfItemsInSection:indexPath.section] == 0) {
                        weakSelf.shouldReloadCollectionView = YES;
                    } else {
                        [weakSelf.blockOperation addExecutionBlock:^{
                            [weakSelf insertItemsAtIndexPaths:@[newIndexPath]];
                        }];
                    }
                } else {
                    weakSelf.shouldReloadCollectionView = YES;
                }
                break;
            }
            case NSFetchedResultsChangeDelete: {
                if ([weakSelf numberOfItemsInSection:indexPath.section] == 1) {
                    weakSelf.shouldReloadCollectionView = YES;
                } else {
                    [weakSelf.blockOperation addExecutionBlock:^{
                        [weakSelf deleteItemsAtIndexPaths:@[indexPath]];
                    }];
                }
                break;
            }
                
            case NSFetchedResultsChangeUpdate: {
                [weakSelf.blockOperation addExecutionBlock:^{
                    [weakSelf reloadItemsAtIndexPaths:@[indexPath]];
                }];
                break;
            }
                
            case NSFetchedResultsChangeMove: {
                [weakSelf.blockOperation addExecutionBlock:^{
                    [weakSelf deleteItemsAtIndexPaths:@[indexPath]];
                    [weakSelf insertItemsAtIndexPaths:@[newIndexPath]];
                }];
                break;
            }
            default:
                break;
        }
    };
    
    self.fetchedResultsController.didChangeContentBlock = ^(NSFetchedResultsController *frController){
        if (!weakSelf) { return; }
        
        if (weakSelf.shouldReloadCollectionView) {
            [weakSelf reloadData];
        } else {
            [weakSelf performBatchUpdates:^{
                [weakSelf.blockOperation start];
            } completion:nil];
        }
    };
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if (!(self = [super initWithFrame:frame collectionViewLayout:layout])) { return nil; }
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) { return nil; }
    
    [self commonInit];
    
    return self;
}

- (void)performFetchWithContext:(NSManagedObjectContext *)context
                   fetchRequest:(NSFetchRequest *)fetchRequest
             sectionNameKeyPath:(NSString *)keyPath
                     fetchLimit:(int)fetchLimit
                      cacheName:(NSString *)cacheName
{
    [self.fetchedResultsController performFetchWithContext:context
                                              fetchRequest:fetchRequest
                                        sectionNameKeyPath:keyPath
                                                fetchLimit:fetchLimit
                                                 cacheName:cacheName];
}

- (NSArray *)fetchObjects
{
    return [self.fetchedResultsController fetchObjects];
}

- (NSInteger)sectionCount
{
    return [self.fetchedResultsController sectionCount];
}

- (NSString *)titleForHeaderInSection:(NSInteger)section
{
    return [self.fetchedResultsController titleForHeaderInSection:section];
}

- (NSArray *)objectsForSection:(NSInteger)section
{
    return [self.fetchedResultsController objectsForSection:section];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [self.fetchedResultsController numberOfRowsInSection:section];
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectForIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForEntityInTableView:(NSManagedObject *)entity
{
    return [self.fetchedResultsController indexPathForEntityInTableView:entity];
}

@end
