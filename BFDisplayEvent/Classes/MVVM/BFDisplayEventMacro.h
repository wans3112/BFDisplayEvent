//
//  BFDisplayEventMacro.h
//  HomePage https://github.com/wans3112/BFDisplayEvent
//  避免block循环引用的宏
//
//  Created by wans on 2018/8/10.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#ifndef BFDisplayEventMacro_h
#define BFDisplayEventMacro_h

#ifndef em_weakify
#if DEBUG
#if __has_feature(objc_arc)
#define em_weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define em_weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define em_weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define em_weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef em_strongify
#if DEBUG
#if __has_feature(objc_arc)
#define em_strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define em_strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define em_strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define em_strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#endif /* BFDisplayEventMacro_h */
