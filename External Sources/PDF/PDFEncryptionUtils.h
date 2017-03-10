#import <Foundation/Foundation.h>
#import <XADMaster/CSHandle.h>
#import <XADMaster/CSBlockStreamHandle.h>
#import "PDFNameCollisionPreventer.h"

extern NSString *PDFMD5FinishedException;

@interface PDFMD5Engine:NSObject

+(instancetype)engine;
+(NSData *)digestForData:(NSData *)data;
+(NSData *)digestForBytes:(const void *)bytes length:(NSUInteger)length;

-(instancetype)init;

-(void)updateWithData:(NSData *)data;
-(void)updateWithBytes:(const void *)bytes length:(NSUInteger)length;

-(NSData *)digest;
-(NSString *)hexDigest;

@end

@interface PDFAESHandle:CSBlockStreamHandle

-(instancetype)initWithHandle:(CSHandle *)handle key:(NSData *)keydata;

-(void)resetBlockStream;
-(int)produceBlockAtOffset:(off_t)pos;

@end
