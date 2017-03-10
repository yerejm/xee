#import <Foundation/Foundation.h>

#import "PDFNameCollisionPreventer.h"
#import "PDFStream.h"
#import "PDFEncryptionHandler.h"

extern NSString *PDFWrongMagicException;
extern NSString *PDFInvalidFormatException;
extern NSString *PDFParserException;

@interface PDFParser:NSObject
{
	CSHandle *fh;

	NSMutableDictionary *objdict;
	NSMutableArray *unresolved;

	NSDictionary *trailerdict;
	PDFEncryptionHandler *encryption;
}

+(PDFParser *)parserWithHandle:(CSHandle *)handle;
+(PDFParser *)parserForPath:(NSString *)path;

-(instancetype)initWithHandle:(CSHandle *)handle;

@property (readonly, getter=isEncrypted) BOOL encrypted;
@property (readonly) BOOL needsPassword;
-(BOOL)setPassword:(NSString *)password;

-(NSDictionary *)objectDictionary;
-(NSDictionary *)trailerDictionary;
-(NSDictionary *)rootDictionary;
-(NSDictionary *)infoDictionary;

-(NSData *)permanentID;
-(NSData *)currentID;

-(NSDictionary *)pagesRoot;

-(PDFEncryptionHandler *)encryptionHandler;

-(void)parse;

-(NSDictionary *)parsePDFXref;
-(int)parseSimpleInteger;

-(id)parsePDFObject;

-(id)parsePDFTypeWithParent:(PDFObjectReference *)parent;
-(NSNull *)parsePDFNull;
-(NSNumber *)parsePDFBoolStartingWith:(int)c;
-(NSNumber *)parsePDFNumberStartingWith:(int)c;
-(NSString *)parsePDFWord;
-(NSString *)parsePDFStringWithParent:(PDFObjectReference *)parent;
-(NSData *)parsePDFHexStringStartingWith:(int)c parent:(PDFObjectReference *)parent;
-(NSArray *)parsePDFArrayWithParent:(PDFObjectReference *)parent;
-(NSDictionary *)parsePDFDictionaryWithParent:(PDFObjectReference *)parent;

-(void)resolveIndirectObjects;

-(void)_raiseParserException:(NSString *)error;

@end



@interface PDFString:NSObject <NSCopying>
{
	NSData *data;
	PDFObjectReference *ref;
	__unsafe_unretained PDFParser *parser;
}

-(id)initWithData:(NSData *)bytes parent:(PDFObjectReference *)parent parser:(PDFParser *)owner;

@property (readonly, retain) NSData *data;
@property (readonly, retain) PDFObjectReference *reference;
@property (readonly, copy) NSData *rawData;
@property (readonly, copy) NSString *string;

@end



@interface PDFObjectReference:NSObject <NSCopying>
{
	int num,gen;
}

+(instancetype)referenceWithNumber:(int)objnum generation:(int)objgen;
+(instancetype)referenceWithNumberObject:(NSNumber *)objnum generationObject:(NSNumber *)objgen;

-(instancetype)initWithNumber:(int)objnum generation:(int)objgen NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (readonly) int number;
@property (readonly) int generation;

@end
