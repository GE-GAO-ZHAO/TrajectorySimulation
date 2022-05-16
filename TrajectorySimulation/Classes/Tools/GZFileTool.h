//
//  GZFileTool.h
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2021/11/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// @enum 目录类型
typedef NS_ENUM(NSUInteger, DerectorType) {
    DerectorTypeFile   = 0, // 文件
    DerectorTypeFolder = 2  // 文件夹
};

#define DocumentFilePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define CacheFilePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define TempFilePath NSTemporaryDirectory()

/// @class 主要处理文件相关操作
@interface GZFileTool : NSObject

#pragma mark -- life cycle

+ (instancetype)shareInstence;
+ (void)destoryInstence;

#pragma mark --
#pragma mark -- 公用

/// @brief 删除文件目录
/// @param path 路径
- (BOOL)deleteDerectorAtPath:(NSString *)path;

#pragma mark -- 文件夹
/// @brief 创建文件夹
/// @param folderPath 文件夹路径
- (BOOL)createFolderWithFolderPath:(NSString *)folderPath;

#pragma mark -- 文件
/// @brief 是否存在文件
/// @param path 文件路径  folder/file name
- (BOOL)fileExistsAtPath:(NSString *)path;

/// @brief 创建文件
/// @param filePath 文件路径  folder/file name
- (BOOL)createFileWithFilePath:(NSString *)filePath;

/// @brief 写入文件
/// @param txt  文本
/// @param filePath 文件路径  folder/file name
- (BOOL)writeDataWithData:(NSString *)txt filePath:(NSString *)filePath;

/// @brief 读取文件
/// @param filePath 路径
- (NSData *)readDataWithFilePath:(NSString *)filePath;

/// @brief 获取文件夹下文件的条数
/// @param folderPath 文件夹路径  folde
- (NSInteger)getFileCountWithFolderPath:(NSString *)folderPath;

/// @brief 获取文件夹下文件的已占用内存
/// @param folderPath 文件夹路径  folde
- (float)getSizeWithFolderPath:(NSString *)folderPath;

#pragma mark -- 解压文件夹相关

/// @brief 查找出某一个目录所有的文件
/// @param folderPath 文件夹路径
/// @param extendType 文件扩展字段 .txt .zip等
- (NSArray<NSString *> *)quesryNameOfChildFilesAtFolderPath:(NSString *)folderPath extendType:(NSString *)extendType;

/// @brief 创建zip文件
/// @param zipPath zip文件夹路径
/// @param subPaths 存放在zip下所有的文件路径
- (BOOL)createZipFileAtPath:(NSString *)zipPath
                   subPaths:(NSArray<NSString *> *)subPaths;

/// @brief 遍历目录所有文件的路径
- (NSArray<NSString *> *)quesryNameOfChildFilesAtFolderPath:(NSString *)folderPath
                                                 extendType:(NSString *)extendType;

/// @brief 复制文件里的数据到目标文件
/// @param desFolderPath 目标文件夹路径
/// @param overWrite 复制时是否进行复写
/// @param sourceFilePaths 源文件路径列表
- (BOOL)copyFilesAtDesFolderPath:(NSString *)desFolderPath
                       overWrite:(BOOL)overWrite
                 sourceFilePaths:(NSArray<NSString *> *)sourceFilePaths;

/// @brief 获取某文件在在某目录下的uri
/// @param folderPath 目标文件夹路径
/// @param fileName 文件名字
/// @param extendType 文件扩展信息
- (NSURL *)pathForFolderPath:(NSString *)folderPath
                    fileName:(NSString *)fileName
                  extendType:(NSString *)extendType;

@end

NS_ASSUME_NONNULL_END
