#import <Foundation/Foundation.h>
#import <XADMaster/CSHandle.h>
#import <XADMaster/CSBlockStreamHandle.h>
#import "PDFNameCollisionPreventer.h"
#include <CommonCrypto/CommonDigest.h>
#include <Security/Security.h>

extern NSString *PDFMD5FinishedException;

@interface PDFMD5Engine : NSObject {
	CC_MD5_CTX md5;
	unsigned char digest_bytes[CC_MD5_DIGEST_LENGTH];
	BOOL done;
}

+ (instancetype)engine;
+ (NSData *)digestForData:(NSData *)data;
+ (NSData *)digestForBytes:(const void *)bytes length:(NSUInteger)length;

- (instancetype)init;

- (void)updateWithData:(NSData *)data;
- (void)updateWithBytes:(const void *)bytes length:(NSUInteger)length;

- (NSData *)digest;
- (NSString *)hexDigest;

@end

@interface PDFAESHandle : CSBlockStreamHandle {
	CSHandle *parenthandle;
	off_t startoffs;

	NSData *key, *iv;

	SecKeyRef aeskey;
	uint8_t ivbuffer[16], streambuffer[16];
}

- (instancetype)initWithHandle:(CSHandle *)handle key:(NSData *)keydata;

- (void)resetBlockStream;
- (int)produceBlockAtOffset:(off_t)pos;

@end
