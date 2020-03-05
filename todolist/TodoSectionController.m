#import "TodoCell.h"
#import "TodoSectionController.h"

@interface TodoCellController : NSObject

- (instancetype)initWithIndex:(NSInteger)index deleteCallback:(void (^)(NSInteger index))deleteCallback;

- (void)didDelete;

@end

@implementation TodoCellController {
  NSInteger _index;
  void (^_deleteCallback)(NSInteger);
}

- (instancetype)initWithIndex:(NSInteger)index deleteCallback:(void (^)(NSInteger))deleteCallback {
  if (self = [super init]) {
    _index = index;
    _deleteCallback = deleteCallback;
  }
  return self;
}

- (void)didDelete {
  _deleteCallback(_index);
}

@end

@implementation TodoSectionController {
  NSArray<NSString *> *_todos;
  NSArray<TodoCellController *> *_cellControllers;
}

- (instancetype)initWithTodos:(NSArray<NSString *> *)todos deleteCallback:(nonnull void (^)(NSInteger))deleteCallback {
  if (self = [super init]) {
    _todos = [todos copy];

    NSMutableArray *controllers = [NSMutableArray array];
    for (NSInteger i = 0; i < [_todos count]; ++i) {
      TodoCellController *controller = [[TodoCellController alloc] initWithIndex:i deleteCallback:deleteCallback];
      [controllers addObject:controller];
    }
    _cellControllers = controllers;
  }
  return self;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
  return CGSizeMake(self.collectionContext.containerSize.width, 48);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
  TodoCell *cell = [self.collectionContext dequeueReusableCellOfClass:[TodoCell class]
                                                 forSectionController:self
                                                              atIndex:index];
  cell.text = _todos[index];

  TodoCellController *controller = _cellControllers[index];
  [cell.deleteButton addTarget:controller action:@selector(didDelete) forControlEvents:UIControlEventTouchUpInside];

  return cell;
}

- (NSInteger)numberOfItems {
  return [_todos count];
}

- (CGFloat)minimumLineSpacing {
  return 8;
}

@end
