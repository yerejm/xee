#import "PDFEncryptionUtils.h"

NSString *PDFMD5FinishedException = @"PDFMD5FinishedException";

@implementation PDFMD5Engine

+ (PDFMD5Engine *)engine
{
	return [[[self alloc] init] autorelease];
}

+ (NSData *)digestForData:(NSData *)data
{
	return [self digestForBytes:[data bytes] length:[data length]];
}

+ (NSData *)digestForBytes:(const void *)bytes length:(NSUInteger)length
{
	PDFMD5Engine *md5 = [[self alloc] init];
	[md5 updateWithBytes:bytes length:length];
	NSData *res = [md5 digest];
	[md5 release];
	return res;
}

- (id)init
{
	if (self = [super init]) {
		CC_MD5_Init(&md5);
		done = NO;
	}
	return self;
}

- (void)updateWithData:(NSData *)data
{
	[self updateWithBytes:[data bytes] length:[data length]];
}

- (void)updateWithBytes:(const void *)bytes length:(NSUInteger)length
{
	if (done)
		[NSException raise:PDFMD5FinishedException format:@"Attempted to update a finished %@ object", [self class]];
	if (length > INT_MAX) {
		//split up the blocks
		NSInteger i;
		for (i = 0; i < length - INT_MAX; i += INT_MAX) {
			CC_MD5_Update(&md5, bytes + i, INT_MAX);
		}
		CC_LONG final = length % INT_MAX;
		CC_MD5_Update(&md5, bytes + i, final);
    } else {
		CC_MD5_Update(&md5, bytes, (CC_LONG)length);
    }
}

- (NSData *)digest
{
	if (!done) {
		CC_MD5_Final(digest_bytes, &md5);
		done = YES;
	}
	return [NSData dataWithBytes:digest_bytes length:16];
}

- (NSString *)hexDigest
{
	if (!done) {
		CC_MD5_Final(digest_bytes, &md5);
		done = YES;
	}
	return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
									  digest_bytes[0], digest_bytes[1], digest_bytes[2], digest_bytes[3],
									  digest_bytes[4], digest_bytes[5], digest_bytes[6], digest_bytes[7],
									  digest_bytes[8], digest_bytes[9], digest_bytes[10], digest_bytes[11],
									  digest_bytes[12], digest_bytes[13], digest_bytes[14], digest_bytes[15]];
}

- (NSString *)description
{
	if (done) {
		return [NSString stringWithFormat:@"<%@ with digest %@>", [self class], [self hexDigest]];
	} else {
		return [NSString stringWithFormat:@"<%@, unfinished>", [self class]];
	}
}

@end

@implementation PDFAESHandle

- (id)initWithHandle:(CSHandle *)handle key:(NSData *)keydata
{
	if (self = [super initWithParentHandle:handle]) {
		parenthandle = [handle retain];
		key = [keydata copy];

		iv = [parent copyDataOfLength:16];
		startoffs = [parent offsetInFile];

		[self setBlockPointer:streambuffer];

		NSDictionary *keyStuff = @{(id)kSecAttrKeyType : (id)kSecAttrKeyTypeAES};
		aeskey = SecKeyCreateFromData((CFDictionaryRef)keyStuff, (CFDataRef)key, NULL);
	}
	return self;
}

- (void)dealloc
{
	[parent release];
	[key release];
	[iv release];
	CFRelease(aeskey);
	[super dealloc];
}

- (void)resetBlockStream
{
	[parenthandle seekToFileOffset:startoffs];
	memcpy(ivbuffer, [iv bytes], 16);
}

- (int)produceBlockAtOffset:(off_t)pos
{
	uint8_t inbuf[16];
	[parenthandle readBytes:16 toBuffer:inbuf];
	SecTransformRef decrypt = SecDecryptTransformCreate(aeskey, NULL);
	SecTransformSetAttribute(decrypt, kSecEncryptionMode, kSecModeCBCKey, NULL);
	SecTransformSetAttribute(decrypt, kSecIVKey, (CFDataRef)[NSData dataWithBytesNoCopy:ivbuffer length:16 freeWhenDone:NO], NULL);
	NSData *encData = [NSData dataWithBytes:inbuf length:sizeof(inbuf)];

	SecTransformSetAttribute(decrypt, kSecTransformInputAttributeName,
							 (CFDataRef)encData, NULL);

	NSData *decryptedData = CFBridgingRelease(SecTransformExecute(decrypt, NULL));
	[decryptedData getBytes:streambuffer length:16];
	CFRelease(decrypt);

	if ([parenthandle atEndOfFile]) {
		[self endBlockStream];
		int val = streambuffer[15];
		if (val > 0 && val <= 16) {
			for (int i = 1; i < val; i++) {
				if (streambuffer[15 - val] != val) {
					return 0;
				}
			}
			return 16 - val;
		} else {
			return 0;
		}
	} else {
		return 16;
	}
}

@end
