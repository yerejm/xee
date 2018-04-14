#import "XeeJPEGLoader.h"

@interface XeeJPEGImage (LosslessSaving)

- (XeeSaveFormatFlags)losslessSaveFlags;
@property (readonly, copy) NSString *losslessFormat;
@property (readonly, copy) NSString *losslessExtension;
- (BOOL)losslessSaveTo:(NSString *)path flags:(XeeSaveFormatFlags)flags;

@end
