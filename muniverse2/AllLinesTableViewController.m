
//
//  AllLinesTableViewController.m
//  muniverse2
//
//  Created by Nick O'Neill on 8/2/12.
//  Copyright (c) 2012 Nick O'Neill. All rights reserved.
//

#import "AllLinesTableViewController.h"
#import "AppDelegate.h"
#import "Line.h"
#import "LineDisplayCell.h"
#import "LineDetailViewController.h"

@interface AllLinesTableViewController ()

@end

@implementation AllLinesTableViewController

typedef enum {
    kBusType,
    kMetroType,
    kHistoricType
} LineType;

@synthesize frc=_frc;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.type addTarget:self action:@selector(lineTypeChange:) forControlEvents:UIControlEventValueChanged];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    self.moc = app.managedObjectContext;

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:80/255.0f green:109/255.0f blue:131/255.0f alpha:1];
    
    NSError *error;
    if (![[self frc] performFetch:&error]) {
        NSLog(@"whoops with Lines frc: %@",error);
    }
}

- (NSFetchedResultsController *)frc {
    
    if (_frc != nil) {
        return _frc;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    
    if (self.type.selectedSegmentIndex == kBusType) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == NO && %K == NO",@"metro",@"historic"];
        [fetchRequest setPredicate:pred];
    } else if (self.type.selectedSegmentIndex == kMetroType) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == YES",@"metro"];
        [fetchRequest setPredicate:pred];
    } else if (self.type.selectedSegmentIndex == kHistoricType) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == YES",@"historic"];
        [fetchRequest setPredicate:pred];
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"allLinesSort" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.moc sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.frc = theFetchedResultsController;
    _frc.delegate = self;
    
    return _frc;
}

- (void)lineTypeChange:(id)sender
{
    _frc = nil;
    
    NSError *err;
    [[self frc] performFetch:&err];
    [[self tableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    _frc = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.type.selectedSegmentIndex == kHistoricType) {
        return 2;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.type.selectedSegmentIndex == kHistoricType) {
        if (section == 0) {
            return @"Historic Streetcar";
        } else {
            return @"Cable Car";
        }
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.type.selectedSegmentIndex == kHistoricType) {
        // blah, totally unhappy with this
        if (section == 0) {
            return 1;
        } else {
            return 3;
        }
    } else {
        id sectionInfo = [[[self frc] sections] objectAtIndex:section];

        return [sectionInfo numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LineCell";
    
    LineDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)ip
{
    Line *line;
    if (self.type.selectedSegmentIndex == kHistoricType) {
        // yep, also unhappy with this
        NSIndexPath *newip;
        if ([ip section] == 0) {
            newip = [NSIndexPath indexPathForRow:0 inSection:0];
        } else {
            newip = [NSIndexPath indexPathForRow:[ip row]+1 inSection:0];
        }
        line = [[self frc] objectAtIndexPath:newip];
    } else {
        line = [[self frc] objectAtIndexPath:ip];
    }
    
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Icon_%@.png",line.shortname]];
    cell.imageView.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"Icon_%@-h.png",line.shortname]];

    cell.textLabel.text = line.name;
    cell.detailTextLabel.text = line.fullDesc;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - frc delegate stuff

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
//    [self.tableView beginUpdates];
//}
//
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
//    
//    UITableView *tableView = self.tableView;
//    
//    switch(type) {
//            
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray
//                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray
//                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//    
//    switch(type) {
//            
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
//    [self.tableView endUpdates];
//}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Line *selectedLine;
    
    if (self.type.selectedSegmentIndex == kHistoricType) {
        // uh, this is teh sux
        NSIndexPath *tablepath = [self.tableView indexPathForSelectedRow];
        
        NSIndexPath *frcpath = [NSIndexPath indexPathForRow:0 inSection:0];
        if ([tablepath section] == 1) {
            frcpath = [NSIndexPath indexPathForRow:[tablepath row]+1 inSection:0];
        }
        
        selectedLine = [[self frc] objectAtIndexPath:frcpath];
    } else {
        selectedLine = [[self frc] objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    }
    
    [(LineDetailViewController *)[segue destinationViewController] setLine:selectedLine];
}

@end
