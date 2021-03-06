//
//  FavoritesViewController.h
//  muniverse2
//
//  Created by Nick O'Neill on 8/19/12.
//  Copyright (c) 2012 Nick O'Neill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic,strong) NSManagedObjectContext *moc;
@property (nonatomic,strong) NSFetchedResultsController *frc;
@property (strong) IBOutlet UIBarButtonItem *refresh;
@property (strong) UIBarButtonItem *refreshing;

- (IBAction)refreshAll:(id)sender;
- (IBAction)editButton:(id)sender;

@end
