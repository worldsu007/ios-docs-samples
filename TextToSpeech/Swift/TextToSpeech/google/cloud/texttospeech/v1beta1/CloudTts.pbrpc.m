#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import "google/cloud/texttospeech/v1beta1/CloudTts.pbrpc.h"
#import "CloudTts.pbobjc.h"
#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

#import <googleapis/Annotations.pbobjc.h>

@implementation TextToSpeech

// Designated initializer
- (instancetype)initWithHost:(NSString *)host {
  self = [super initWithHost:host
                 packageName:@"google.cloud.texttospeech.v1beta1"
                 serviceName:@"TextToSpeech"];
  return self;
}

// Override superclass initializer to disallow different package and service names.
- (instancetype)initWithHost:(NSString *)host
                 packageName:(NSString *)packageName
                 serviceName:(NSString *)serviceName {
  return [self initWithHost:host];
}

#pragma mark - Class Methods

+ (instancetype)serviceWithHost:(NSString *)host {
  return [[self alloc] initWithHost:host];
}

#pragma mark - Method Implementations

#pragma mark ListVoices(ListVoicesRequest) returns (ListVoicesResponse)

/**
 * Returns a list of [Voice][google.cloud.texttospeech.v1beta1.Voice]
 * supported for synthesis.
 */
- (void)listVoicesWithRequest:(ListVoicesRequest *)request handler:(void(^)(ListVoicesResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListVoicesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Returns a list of [Voice][google.cloud.texttospeech.v1beta1.Voice]
 * supported for synthesis.
 */
- (GRPCProtoCall *)RPCToListVoicesWithRequest:(ListVoicesRequest *)request handler:(void(^)(ListVoicesResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListVoices"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListVoicesResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark SynthesizeSpeech(SynthesizeSpeechRequest) returns (SynthesizeSpeechResponse)

/**
 * Synthesizes speech synchronously: receive results after all text input
 * has been processed.
 */
- (void)synthesizeSpeechWithRequest:(SynthesizeSpeechRequest *)request handler:(void(^)(SynthesizeSpeechResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToSynthesizeSpeechWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Synthesizes speech synchronously: receive results after all text input
 * has been processed.
 */
- (GRPCProtoCall *)RPCToSynthesizeSpeechWithRequest:(SynthesizeSpeechRequest *)request handler:(void(^)(SynthesizeSpeechResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SynthesizeSpeech"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SynthesizeSpeechResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
#endif
