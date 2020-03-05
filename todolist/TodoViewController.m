#import "TodoViewController.h"
#import "MaterialDialogs.h"
#import "TodoSectionController.h"
#import <IGListKit/IGListKit.h>

@interface TodoViewController () <IGListAdapterDataSource>

@property(nonatomic) MDCDialogTransitionController *dialogTransitionController;

@end

@implementation TodoViewController {
  IGListAdapter *_adapter;
  NSArray<NSString *> *_todos;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    _todos = @[ @"Buy milk", @"Walk the dog", @"Buy eggs" ];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(add)];
    self.navigationItem.rightBarButtonItem = add;
    self.navigationItem.title = @"Todos";
  }
  return self;
}

- (void)loadView {
  IGListAdapterUpdater *updater = [[IGListAdapterUpdater alloc] init];
  IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:self];
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

  UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
  collectionView.backgroundColor = [UIColor whiteColor];

  adapter.collectionView = collectionView;
  adapter.dataSource = self;
  _adapter = adapter;

  self.view = collectionView;
}

#pragma mark IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
  return @[ @([NSDate timeIntervalSinceReferenceDate]) ];
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
  __weak typeof(self) weakSelf = self;
  return [[TodoSectionController alloc] initWithTodos:_todos
                                       deleteCallback:^(NSInteger index) {
                                         [weakSelf deleteItem:index];
                                       }];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
  return nil;
}

#pragma mark private method

- (void)add {
  MDCAlertController *alertController = [MDCAlertController alertControllerWithTitle:@"Add item" message:nil];
  UITextField *textField = [[UITextField alloc] init];
  textField.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];

  alertController.accessoryView = textField;

  __weak typeof(self) weakSelf = self;
  MDCAlertAction *alertAction = [MDCAlertAction actionWithTitle:@"OK"
                                                        handler:^(MDCAlertAction *action) {
                                                          typeof(self) strongSelf = weakSelf;
                                                          if (!strongSelf) {
                                                            return;
                                                          }
                                                          NSArray *newTodos =
                                                              [strongSelf->_todos arrayByAddingObject:textField.text];
                                                          strongSelf->_todos = newTodos;
                                                          [strongSelf updateTodos];
                                                        }];

  [alertController addAction:alertAction];
  [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteItem:(NSInteger)index {
  NSMutableArray *todos = [NSMutableArray arrayWithArray:_todos];
  [todos removeObjectAtIndex:index];
  _todos = todos;
  [self updateTodos];
}

- (void)updateTodos {
  [_adapter performUpdatesAnimated:YES completion:nil];
}

@end
