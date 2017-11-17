## 获取一个model的所有属性并给有相同属性的model赋值

```objective-c
- (void)getAllPropertiesWithOtherInfo:(NSObject *)otherInfo {
    u_int count;
    objc_property_t *properties = class_copyPropertyList([otherInfo class], &count);
    for (int i = 0; i<count; i++)
    {
        const char *char_f = property_getName(properties[i]);
        if (char_f) {
            NSString *propertyName = [NSString stringWithUTF8String:char_f];
            SEL selector = NSSelectorFromString(propertyName);
            if ([self respondsToSelector:selector] == YES ) {
                [self setValue:[otherInfo valueForKey:propertyName] forKey:propertyName];
            }
        }
    }
    free(properties);
}
```