
//
//  ARNFetchedResultsCollectionView.h
//  ARNFetchedResultsCollectionView
//
//  Created by Airin on 10/06/2014.
//  Copyright (c) 2014 Airin. All rights reserved.
//
// c.f. https://github.com/AshFurrow/UICollectionView-NSFetchedResultsController

@import CoreData;

@interface ARNFetchedResultsCollectionView : UICollectionView

- (void)performFetchWithContext:(NSManagedObjectContext *)context
                   fetchRequest:(NSFetchRequest *)fetchRequest
             sectionNameKeyPath:(NSString *)keyPath
                     fetchLimit:(int)fetchLimit
                      cacheName:(NSString *)cacheName;

- (NSArray *)fetchObjects;
- (NSInteger)sectionCount;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSArray *)objectsForSection:(NSInteger)section;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (id)objectForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForEntityInTableView:(NSManagedObject *)entity;

@end