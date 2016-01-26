//
//  MAXAutoDictionary.m
//  MAXAutoDictionary
//
//  Created by golven on 15/11/5.
//  Copyright © 2015年 Max. All rights reserved.
//

#import "MAXAutoDictionary.h"
#import <objc/runtime.h>

NSMutableDictionary *dataDictClass = nil;
id proxyObject = nil;


@interface ProxyOO : NSObject
- (void)sayHello;
@end

@implementation ProxyOO
- (void)sayHello{NSLog(@"Hellllll...");};
- (void)setNumber:(NSNumber *)number{
    NSLog(@"set number %@",number);
}
- (void)setView:(NSNumber *)number{
    NSLog(@"set number %@",number);
}
@end

#pragma mark -
#pragma mark MAXAutoDictionary()
//================================================================================================
@interface MAXAutoDictionary()

@property (nonatomic, strong) NSMutableDictionary *dataDict;

@end

#pragma mark -
#pragma mark MAXAutoDictionary
//================================================================================================
@implementation MAXAutoDictionary
@dynamic date;
@dynamic string;
@dynamic number;
@dynamic view;

- (instancetype)init {
    if (self = [super init]) {
        _dataDict = [[NSMutableDictionary alloc] init];
        dataDictClass = @{}.mutableCopy;
        proxyObject = [ProxyOO new];
    }
    return self;
}

/*
 当首次在MAXAutoDictionary实例上访问某个属性时，运行期系统还找不到对应的选择子，因为所需要的选择子既没有直接的实现，也没有合成出来。现在假设要写入testObj属性，那么系统会以“setTestObj:”为选择子调用“resolveInstanceMethod：”。同理，在调读取该属性时，系统也会调用“resolveInstanceMethod：”方法，只不过传入的选择子是testObj。在“resolveInstanceMethod：”方法中通过判断选择子的前缀是否是set，来分辨是set还是get。在这里需要用到“class_addMethod”方法，它可以动态的添加方法，用以处理给定的选择子。“class_addMethod”总共四个参数，第三个参数为函数指针，指向待添加的方法。最后一个参数为“类型编码”。可以在runtime的官方文档中查到。
     https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
 */

//getter
id autoDictionaryGetter(id self, SEL sel) {
    MAXAutoDictionary *dict = (MAXAutoDictionary *)self;
    NSMutableDictionary *dataDict = dict.dataDict;
    NSString *key = NSStringFromSelector(sel);
    return dataDict[key];
}

//for object
void autoDictionarySetter(id self, SEL sel, id value) {
    MAXAutoDictionary *dict = (MAXAutoDictionary *)self;
    NSMutableDictionary *dataDict = dict.dataDict;
    NSString *key = NSStringFromSelector(sel);//setTestObj:

    NSMutableString *tempKey = [key mutableCopy];
    [tempKey deleteCharactersInRange:NSMakeRange(0, 3)];//setTestObj:->TestObj:
    [tempKey deleteCharactersInRange:NSMakeRange(tempKey.length-1, 1)];//TestObj:->TestObj
    NSString *firstCharacter = [[tempKey substringToIndex:1] lowercaseString];// t
    [tempKey replaceCharactersInRange:NSMakeRange(0, 1) withString:firstCharacter];//TestObj -> testObj
    if (value) {
        [dataDict setObject:value forKey:tempKey];
    } else {
        [dataDict removeObjectForKey:tempKey];
    }
}

//for class
void autoDictionarySetter2(id self, SEL sel, id value) {
//    MAXAutoDictionary *dict = (MAXAutoDictionary *)self;
    NSMutableDictionary *dataDict = dataDictClass;
    NSString *key = NSStringFromSelector(sel);//setTestObj:
    
    NSMutableString *tempKey = [key mutableCopy];
    [tempKey deleteCharactersInRange:NSMakeRange(0, 3)];//setTestObj:->TestObj:
    [tempKey deleteCharactersInRange:NSMakeRange(tempKey.length-1, 1)];//TestObj:->TestObj
    NSString *firstCharacter = [[tempKey substringToIndex:1] lowercaseString];// t
    [tempKey replaceCharactersInRange:NSMakeRange(0, 1) withString:firstCharacter];//TestObj -> testObj
    if (value) {
        [dataDict setObject:value forKey:tempKey];
    } else {
        [dataDict removeObjectForKey:tempKey];
    }
}

+ (BOOL)resolveClassMethod:(SEL)sel{
    
    NSString *selectorString = NSStringFromSelector(sel);
    if ([selectorString hasPrefix:@"setClassString"]) {
        
        Class myClass = object_getClass(self);
        class_addMethod(myClass, sel, (IMP)autoDictionarySetter2, "v@:@");
    }
         
    return NO;
}

/* 不管返回YES或者是NO,它都会再次执行一次（forward）,即都将会给一次添加方法的机会。*/
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *selectorString = NSStringFromSelector(sel);
    if ([selectorString hasPrefix:@"setDate"]) {
        class_addMethod(self, sel, (IMP)autoDictionarySetter, "v@:@");
    } else {
        return NO;
    }
    
    return YES;
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    
    NSString *selectorString = NSStringFromSelector(aSelector);
    if ([selectorString hasPrefix:@"setNumber"]) {
        return proxyObject;//self;
    }
    
    if ([selectorString hasPrefix:@"setView"]) {
        return nil;
    }
    
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    
    id target = proxyObject;
    [anInvocation invokeWithTarget:target];
}

/*这里的签名也没有关系，只需要返回一个就行。即存在就行*/
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    
    NSString *selectorString = NSStringFromSelector(aSelector);
    if ([selectorString hasPrefix:@"setNumber"]) {
//        NSMethodSignature *sig = [NSMethodSignature methodSignatureForSelector:@selector(sayHello)];//==nil
        NSMethodSignature *sig = [NSMethodSignature instanceMethodSignatureForSelector:@selector(sayHello)];
        return sig;
    }
    
    if ([selectorString hasPrefix:@"setView"]) {
//        NSMethodSignature *sig = [NSMethodSignature instanceMethodSignatureForSelector:@selector(sayHello)];//==nil
//        NSMethodSignature *sig = [NSMethodSignature new];//==nil ,why?
        NSMethodSignature *sig = [proxyObject methodSignatureForSelector:@selector(sayHello)];
        return sig;
    }
    return nil;
}

- (void)sayHello{
    
    NSLog(@"hello");
}

+ (void)sayHello2{
    
    NSLog(@"");
}

@end

