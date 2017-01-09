# 使用类目（Categories）给类添加一个属性

### 使用runtime提供的方法

```
void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
id objc_getAssociatedObject(id object, const void *key)
```

```
#import <objc/runtime.h>

static char const * const ObjectTagKey = "ObjectTag";

@implementation UIView (ObjectTagAdditions)
@dynamic objectTag;
- (id)objectTag {
    return objc_getAssociatedObject(self, ObjectTagKey);
}

- (void)setObjectTag:(id)newObjectTag {
    objc_setAssociatedObject(self, ObjectTagKey, newObjectTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
```