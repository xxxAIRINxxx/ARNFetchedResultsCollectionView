
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

@property (nonatomic, strong) NSMutableArray *sectionChanges;
@property (nonatomic, strong) NSMutableArray *objectChanges;

@end

@implementation ARNFetchedResultsCollectionView

- (void)dealloc
{
    [_fetchedResultsController disConnect];
}

- (void)commonInit
{
    self.fetchedResultsController = [[ARNFetchedResultsController alloc] init];
    
    self.sectionChanges = [NSMutableArray array];
    self.objectChanges = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    
    self.fetchedResultsController.didChangeSectionBlock = ^(id <NSFetchedResultsSectionInfo> sectionInfo, NSFetchedResultsChangeType type, NSUInteger sectionIndex){
        
        if (!weakSelf) { return; }
        
        NSMutableDictionary *change = [NSMutableDictionary new];
        switch (type) {
            case NSFetchedResultsChangeInsert:
                change[@(type)] = @(sectionIndex);
                break;
            case NSFetchedResultsChangeDelete:
                change[@(type)] = @(sectionIndex);
                break;
            default:
                break;
        }
        [weakSelf.sectionChanges addObject:change];
    };
    
    self.fetchedResultsController.didChangeObjectBlock = ^(id anObject, NSFetchedResultsChangeType type, NSIndexPath *indexPath, NSIndexPath *newIndexPath) {
        if (!weakSelf) { return; }
        
        NSMutableDictionary *change = [NSMutableDictionary new];
        switch (type) {
            case NSFetchedResultsChangeInsert:
                change[@(type)] = newIndexPath;
                break;
                
            case NSFetchedResultsChangeDelete:
                change[@(type)] = indexPath;
                break;
                
            case NSFetchedResultsChangeUpdate: {
                if (!newIndexPath) {
                    change[@(type)] = @[indexPath];
                }
                else {
                    change[@(NSFetchedResultsChangeDelete)] = @[indexPath];
                    change[@(NSFetchedResultsChangeInsert)] = @[newIndexPath];
                }
                break;
            }
                
            case NSFetchedResultsChangeMove:
                change[@(type)] = @[indexPath, newIndexPath];
                break;
            default:
                break;
        }
    };
    
    self.fetchedResultsController.didChangeContentBlock = ^{
        if (!weakSelf) { return; }
        
        if ([weakSelf.sectionChanges count] > 0) {
            [weakSelf performBatchUpdates:^{
                for (NSDictionary *change in weakSelf.sectionChanges) {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop){
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type) {
                            case NSFetchedResultsChangeInsert:
                                [weakSelf insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [weakSelf deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            default:
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
        
        if ([weakSelf.objectChanges count] > 0 && ![weakSelf.sectionChanges count]) {
            // UICollectionViewにバグがあるための対応らしい
            if ([weakSelf shouldReloadCollectionViewToPreventKnowIssue] || !weakSelf.window) {
                [weakSelf reloadData];
            } else {
                [weakSelf performBatchUpdates:^{
                    for (NSDictionary *change in weakSelf.objectChanges) {
                        [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop){
                            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                            switch (type) {
                                case NSFetchedResultsChangeInsert:
                                    [weakSelf insertItemsAtIndexPaths:@[obj]];
                                    break;
                                    
                                case NSFetchedResultsChangeDelete:
                                    [weakSelf deleteItemsAtIndexPaths:@[obj]];
                                    break;
                                    
                                case NSFetchedResultsChangeUpdate:
                                    [weakSelf reloadItemsAtIndexPaths:@[obj]];
                                    break;
                                case NSFetchedResultsChangeMove:
                                    [weakSelf moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                    break;
                            }
                        }];
                    }
                } completion:nil];
            }
        }
        
        [weakSelf.sectionChanges removeAllObjects];
        [weakSelf.objectChanges removeAllObjects];
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

- (BOOL)shouldReloadCollectionViewToPreventKnowIssue
{
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop){
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
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
