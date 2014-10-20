//
//  ARNFetchedResultsController.h
//  ARNFetchedResultsController
//
//  Created by Airin on 10/06/2014.
//  Copyright (c) 2014 Airin. All rights reserved.
//

@import CoreData;

typedef void (^AFRWillChangeContentBlock)(NSFetchedResultsController *frController);
typedef void (^AFRDidChangeSectionBlock)(id <NSFetchedResultsSectionInfo> sectionInfo, NSFetchedResultsChangeType type, NSUInteger sectionIndex);
typedef void (^AFRDidChangeObjectBlock)(id anObject, NSFetchedResultsChangeType type, NSIndexPath *indexPath, NSIndexPath *newIndexPath);
typedef void (^AFRDidChangeContentBlock)(NSFetchedResultsController *frController);

@interface ARNFetchedResultsController : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, copy) AFRWillChangeContentBlock willChangeContentBlock;
@property (nonatomic, copy) AFRDidChangeSectionBlock didChangeSectionBlock;
@property (nonatomic, copy) AFRDidChangeObjectBlock didChangeObjectBlock;
@property (nonatomic, copy) AFRDidChangeContentBlock didChangeContentBlock;

- (void)performFetchWithContext:(NSManagedObjectContext *)context
                   fetchRequest:(NSFetchRequest *)fetchRequest
             sectionNameKeyPath:(NSString *)keyPath
                     fetchLimit:(int)fetchLimit
                      cacheName:(NSString *)cacheName;

- (void)disConnect;

- (NSArray *)fetchObjects;
- (NSInteger)sectionCount;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSArray *)objectsForSection:(NSInteger)section;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (id)objectForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForEntityInTableView:(NSManagedObject *)entity;

@end
