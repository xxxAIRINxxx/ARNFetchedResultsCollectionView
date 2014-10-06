//
//  ARNFetchedResultsController.m
//  ARNFetchedResultsController
//
//  Created by Airin on 10/06/2014.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import "ARNFetchedResultsController.h"

@interface ARNFetchedResultsController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ARNFetchedResultsController

- (void)dealloc
{
    [self disConnect];
}

- (void)disConnect
{
    if (_fetchedResultsController) {
        _fetchedResultsController.delegate = nil;
        _fetchedResultsController          = nil;
    }
}

- (void)performFetchWithContext:(NSManagedObjectContext *)context
                   fetchRequest:(NSFetchRequest *)fetchRequest
             sectionNameKeyPath:(NSString *)keyPath
                     fetchLimit:(int)fetchLimit
                      cacheName:(NSString *)cacheName
{
    [self disConnect];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:keyPath
                                                                                   cacheName:cacheName];
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController.fetchRequest setFetchLimit:fetchLimit];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"performFetchWithContext error!!! : %@", [error debugDescription]);
        abort();
    }
}

- (NSArray *)fetchObjects
{
    if (!self.fetchedResultsController) { return nil; }
    
    return self.fetchedResultsController.fetchedObjects;
}

- (NSInteger)sectionCount
{
    if (!self.fetchedResultsController) { return 0; }
    
    return [[self.fetchedResultsController sections] count];
}

- (NSString *)titleForHeaderInSection:(NSInteger)section
{
    if (!self.fetchedResultsController) { return nil; }
    
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSArray *)objectsForSection:(NSInteger)section
{
    if (!self.fetchedResultsController) { return nil; }
    
    return (NSArray *) [[[self.fetchedResultsController sections] objectAtIndex:section] object];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (!self.fetchedResultsController) { return 0; }
    
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath
{
    if (!self.fetchedResultsController) { return nil; }
    
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForEntityInTableView:(NSManagedObject *)entity
{
    if (!self.fetchedResultsController) { return nil; }
    
    return [self.fetchedResultsController indexPathForObject:entity];
}

// -----------------------------------------------------------------------------------------------------------------------//
#pragma mark - NSFetchedResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (self.fetchedResultsController != controller) { return; }
    
    if (self.willChangeContentBlock) {
        self.willChangeContentBlock();
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo> )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    if (self.fetchedResultsController != controller) { return; }
    
    if (self.didChangeSectionBlock) {
        self.didChangeSectionBlock(sectionInfo, type, sectionIndex);
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.fetchedResultsController != controller) { return; }
    
    if (self.didChangeObjectBlock) {
        self.didChangeObjectBlock(anObject, type, indexPath, newIndexPath);
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (_fetchedResultsController != controller) { return; }
    
    if (self.didChangeContentBlock) {
        self.didChangeContentBlock();
    }
}

@end
