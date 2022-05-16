//
//  GZFileTool.m
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2021/11/5.
//

#import "GZFileTool.h"
#import <SSZipArchive/SSZipArchive.h>
@interface GZFileTool() {
    NSTimeInterval _lastCheckFreeSpace;
}
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) dispatch_queue_t synchro_queue;
@end


#define synchro_queue_name [NSString stringWithFormat:@"com.map-sdk-ios.navireport.reportqueue"]

@implementation GZFileTool

#pragma mark -- life cycle
static GZFileTool *shared = nil;
static dispatch_once_t onceToken;
+ (instancetype)shareInstence {
    dispatch_once(&onceToken, ^{
        shared = [[super allocWithZone:NULL] init];
    });
    return shared;
}

+ (void)destoryInstence {
    shared = nil;
    onceToken = 0l;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstence];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager new];
        _synchro_queue = dispatch_queue_create([synchro_queue_name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    return self;
}

- (void)dealloc {
    NSLog(@"====dealloc===");
}

#pragma mark --
#pragma mark -- 公用
- (BOOL)deleteDerectorAtPath:(NSString *)path {
    return [_fileManager removeItemAtPath:path error:nil];
}

#pragma mark -- 文件夹

- (BOOL)createFolderWithFolderPath:(NSString *)folderPath {
    NSAssert(folderPath && [folderPath isKindOfClass:[NSString class]] && [folderPath length] > 0, @"folderPath is empty");
    NSError * error;
    [_fileManager createDirectoryAtPath:folderPath
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:&error];
    if (error) { return NO; }
    return YES;
}

- (BOOL)folderExistsForPath:(NSString *)strDirPath {
    if (strDirPath.length < 1) { return NO; }
    BOOL bDir = NO;
    BOOL bExist = [_fileManager fileExistsAtPath:strDirPath isDirectory:&bDir];
    if (bDir && bExist) { return YES; }
    return NO;
}

#pragma mark -- File manager

- (BOOL)fileExistsAtPath:(NSString *)path {
    NSAssert(path && [path length] > 0, @"path is empty!");
    BOOL bDir = NO;
    BOOL bExist = [_fileManager fileExistsAtPath:path isDirectory:&bDir];
    if (!bDir && bExist) { return YES; }
    return NO;
}

- (BOOL)createFileWithFilePath:(NSString *)filePath {
    NSAssert(filePath && [filePath length] > 0, @"filePath is empty!");
    if (![self fileExistsAtPath:filePath]) {
        return [_fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return YES;
}

- (BOOL)writeDataWithData:(NSString *)txt filePath:(NSString *)filePath {
    NSAssert(filePath && [filePath length] > 0, @"filePath is empty!");
    if (![self fileExistsAtPath:filePath]) {
        NSLog(@"写入文件，文件不存在，不予处理");
        return NO;
    }
    if (!txt || ![txt isKindOfClass:[NSString class]] || [txt length] <=0) { NSLog(@"写入文件，数据为空，不予处理"); }
    __block NSError *error = nil;
    dispatch_async(_synchro_queue, ^{
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        [fileHandle seekToEndOfFile];
        if (@available(iOS 13.0, *)) {
            [fileHandle writeData:[txt dataUsingEncoding:NSUTF8StringEncoding] error:&error];
        } else {
            [fileHandle writeData:[txt dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [fileHandle closeFile];        
    });
    return (error ? NO : YES);
}

- (NSData *)readDataWithFilePath:(NSString *)filePath {
    NSAssert(filePath && [filePath length] > 0, @"filePath is empty!");
    NSData *data = nil;
    if (![self fileExistsAtPath:filePath]) {
        NSLog(@"读取文件，%@文件不存在，不予处理",filePath);
        return data;
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    data = [fileHandle readDataToEndOfFile];
    return data;
}

#pragma mark --
#pragma mark -- 文件信息

- (NSInteger)getFileCountWithFolderPath:(NSString *)folderPath {
    NSAssert(folderPath && [folderPath length] > 0, @"path is empty!");
    return 0;
}

- (float)getSizeWithFolderPath:(NSString *)folderPath {
    NSAssert(folderPath && [folderPath length] > 0, @"folderPath is empty!");
    return 0.f;
}

- (DerectorType)derectorTypeAtPath:(NSString *)path {
    BOOL isDir = NO;
    DerectorType derectorType = DerectorTypeFile;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if(isDir) {
        derectorType = DerectorTypeFolder;
    }
    return derectorType;
}

#pragma mark --
#pragma mark -- 解压文件夹相关

- (NSArray<NSString *> *)quesryNameOfChildFilesAtFolderPath:(NSString *)folderPath
                                                 extendType:(NSString *)extendType {
    if (![self folderExistsForPath:folderPath]) {
        return @[];
    }
    __block NSMutableArray <NSString *> *folderPaths = [[NSMutableArray alloc] init];
    NSDirectoryEnumerator *dirEnumerator = [_fileManager enumeratorAtPath:folderPath];
    [dirEnumerator.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
        if (path && [path length] > 0) {
            NSString *lastName = [NSURL fileURLWithPath:path].lastPathComponent;
            if (lastName && [lastName hasSuffix:extendType]) {
                [folderPaths addObject:[folderPath stringByAppendingFormat:@"/%@",path]];
            }
        }
    }];
    return folderPaths;
}

- (BOOL)createZipFileAtPath:(NSString *)zipPath
                   subPaths:(NSArray<NSString *> *)subPaths {
    NSAssert(zipPath && [zipPath length] > 0 && subPaths && [subPaths count] >0, @"zipPath or subPaths is empty or nil");
    if (![self fileExistsAtPath:zipPath]) {
        [self createFileWithFilePath:zipPath];
    }
    return [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:subPaths];
}

- (BOOL)copyFilesAtDesFolderPath:(NSString *)desFolderPath overWrite:(BOOL)overWrite sourceFilePaths:(NSArray<NSString *> *)sourceFilePaths {
    NSAssert(desFolderPath && [desFolderPath length] > 0 && sourceFilePaths, @"desPath is empty or nil");
    if (![self folderExistsForPath:desFolderPath]) {
        [self createFolderWithFolderPath:desFolderPath];
    } else {
        if (overWrite) {
            if ([self deleteDerectorAtPath:desFolderPath]) {
                [self createFolderWithFolderPath:desFolderPath];
            } else {
                NSLog(@"复写文件失败");
                return NO;
            }
        }
    }
    __weak typeof(self) weakSelf = self;
    [sourceFilePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (obj && [obj length] > 0 && [strongSelf fileExistsAtPath:obj]) {
            NSString *lastPathComment = [NSURL fileURLWithPath:obj].lastPathComponent;
            if (lastPathComment && [lastPathComment hasSuffix:@".txt"]) {
                NSString *newDesFilePath = [desFolderPath stringByAppendingFormat:@"/%@",lastPathComment];
                NSError *error = nil;
                [_fileManager copyItemAtPath:obj toPath:newDesFilePath error:&error];
                if (error) { NSLog(@"【%@】 copt to 【%@】is failure ",obj,desFolderPath); }
            }
        }
    }];
    return YES;
}

- (NSURL *)pathForFolderPath:(NSString *)folderPath
                    fileName:(NSString *)fileName
                  extendType:(NSString *)extendType {
    __block NSURL *pathUrl = nil;
    NSArray <NSString *> *sourceFilePaths = [[GZFileTool shareInstence] quesryNameOfChildFilesAtFolderPath:folderPath extendType:@".txt"];
    [sourceFilePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            NSURL *desPathUrl = [NSURL fileURLWithPath:obj];
            if (desPathUrl.lastPathComponent && [desPathUrl.lastPathComponent isEqualToString:[NSString stringWithFormat:@"%@%@",fileName,extendType]]) {
                pathUrl = desPathUrl;
                *stop = YES;
            }
        }
    }];
    return pathUrl;
}


@end
