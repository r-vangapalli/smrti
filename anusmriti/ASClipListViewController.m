//
//  ASClipListViewController.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASClipListViewController.h"

#import <ReactiveObjC.h>
#import "ASClipList.h"
#import "ASClip.h"
#import "ASClipRef.h"
#import "NSDate+as.h"

@interface ASClipListViewController ()

@property(nonatomic, weak) IBOutlet UIButton *editClipButton;
@property(nonatomic, weak) IBOutlet UIButton *addClipButton;
@property(nonatomic, weak) IBOutlet UIStepper *repeatCountStepper;

@property(nonatomic, weak) ASClipRef *selectedClipRef;

@property(nonatomic, weak) ASClipList *clipList;

@property(nonatomic, weak) IBOutlet UIView *editorContainer;

@end

@implementation ASClipListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipListSelected:) name:@"asClipListSelected" object:nil];

    @weakify(self);
    [[RACObserve(self, repeatCountStepper.value) distinctUntilChanged] subscribeNext:^(NSNumber *value) {
        @strongify(self);
        [self.clipList setRepeatCount:value.integerValue forClipRefId:self.selectedClipRef.itemId];
        [self refresh];
    }];

    [[RACObserve(self, editClipButton.selected) distinctUntilChanged] subscribeNext:^(NSNumber *isEditing) {
        @strongify(self);
        self.repeatCountStepper.hidden = !isEditing.boolValue;
    }];
    [[RACObserve(self, selectedClipRef) distinctUntilChanged] subscribeNext:^(ASClipRef *clipRef) {
        @strongify(self);
        if (clipRef) {
            self.repeatCountStepper.value = [self.clipList repeatCountForClipRefId:clipRef.itemId];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refresh {
    [self.tableView reloadData];
    if (self.selectedClipRef) {
        NSUInteger selectedIndex = [self.clipList indexOfClipRef:self.selectedClipRef];
        if (NSNotFound != selectedIndex) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

- (void)clipListSelected:(NSNotification *)notification {
    self.clipList = notification.object;
    [self refresh];
    [self selectNextClip];
}

- (void)clearSelection {
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    if (selectedPath) {
        self.selectedClipRef = nil;
        [self.tableView deselectRowAtIndexPath:selectedPath animated:YES];
    }
}

- (void)selectNextClip {
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    NSIndexPath *pathToSelect = nil;
    if (!selectedPath) { // nothing selected so select the first row
        pathToSelect = [NSIndexPath indexPathForRow:0 inSection:0];
    } else {
        for (NSUInteger index = selectedPath.item+1; index < self.clipList.clipRefCount; index++) {
            NSUInteger repeatCount = [self.clipList repeatCountForClipRefId:[self.clipList clipRefAtIndex:index].itemId];
            if (repeatCount > 0) {
                pathToSelect = [NSIndexPath indexPathForRow:index inSection:0];
                break;
            }
        }
    }
    if (pathToSelect) {
        [self.tableView selectRowAtIndexPath:pathToSelect animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        self.selectedClipRef = [self.clipList clipRefAtIndex:pathToSelect.item];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"asClipRefSelected" object:self.selectedClipRef];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.clipList.clipRefCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"asClipTableCell" forIndexPath:indexPath];
    
    ASClipRef* clipRef = [self.clipList clipRefAtIndex:indexPath.item];
    ASClip *clip = [self.clipList clipForClipRef:clipRef];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [NSString stringWithFormat:@"(%lu) %@ %@-%@", (unsigned long)[self.clipList repeatCountForClipRefId:clipRef.itemId], clip.name, [NSDate formatTimeInterval:clip.startTime], [NSDate formatTimeInterval:clip.endTime]];
    return cell;
}

- (IBAction)addClip:(UIButton *)addClipButton {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    if (path) {
        [self.clipList cloneClipRefAt:path.item];
        [self refresh];
    }
}

- (IBAction)editClip:(UIButton *)editClipButton {
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    if (self.tableView.isEditing) {
        [self.tableView setEditing:NO animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"asIsClipEditing" object:@(NO)];
    } else {
        [self.tableView setEditing:YES animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"asIsClipEditing" object:@(YES)];
    }
    self.editClipButton.selected = self.tableView.isEditing;
    [self.tableView selectRowAtIndexPath:selectedPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.clipList deleteClipRefAt:indexPath.item];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self.clipList moveClipRefFromLocation:fromIndexPath.item toLocation:toIndexPath.item];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *selectedPath = self.tableView.indexPathForSelectedRow;
    if (!selectedPath || selectedPath.item != indexPath.item)
        return indexPath;
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedClipRef = [self.clipList clipRefAtIndex:indexPath.item];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"asClipRefSelected" object:self.selectedClipRef];;
}

- (void)tableView:(UITableView *)tableView didDeSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedClipRef = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"asClipRefUnselected" object:[self.clipList clipRefAtIndex:indexPath.item]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0;
}

@end
