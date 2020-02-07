/**
 * @author Serhii Mamontov
 */
#import "NSData+YHVGZIP.h"
#import <zlib.h>


#pragma mark Interface implementation

@implementation NSData (YHVGZIP)


#pragma mark - GZIP

- (NSData *)YHV_unzipped {
    if (self.length == 0) {
        return self;
    }
    
    NSMutableData *unzipped = nil;
    NSUInteger window = 47;
    BOOL done = NO;
    
    int status;
    z_stream stream;
    bzero(&stream, sizeof(stream));
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.next_in = (Bytef *)self.bytes;
    stream.avail_in = (uint)self.length;
    stream.avail_out = 0;
    status = inflateInit2(&stream, window);
    
    if (status == Z_OK) {
        BOOL isOperationCompleted = NO;
        unzipped = [[NSMutableData alloc] initWithLength:(self.length * 2)];
        
        while (!isOperationCompleted) {
            if ((status == Z_BUF_ERROR)  || stream.total_out >= unzipped.length) {
                [unzipped increaseLengthBy:1024];
            }
            stream.next_out = (Bytef*)unzipped.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(unzipped.length - stream.total_out);

            status = inflate(&stream, Z_SYNC_FLUSH);
            isOperationCompleted = ((status != Z_OK) && (status != Z_BUF_ERROR));
        }

        status = inflateEnd(&stream);
        done = (status == Z_OK || status == Z_STREAM_END);

        if (status == Z_OK && done) {
            [unzipped setLength:stream.total_out];
        }
    }

    return unzipped.length ? unzipped : nil;
}


#pragma mark -

@end
