#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import "google/cloud/translate/v3beta1/TranslationService.pbrpc.h"
#import "TranslationService.pbobjc.h"
#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

#import <googleapis/Annotations.pbobjc.h>
#import <googleapis/Operations.pbobjc.h>
#if defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS) && GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
#import <Protobuf/Timestamp.pbobjc.h>
#else
#import "google/protobuf/Timestamp.pbobjc.h"
#endif

@implementation TranslationService

// Designated initializer
- (instancetype)initWithHost:(NSString *)host {
  self = [super initWithHost:host
                 packageName:@"google.cloud.translation.v3beta1"
                 serviceName:@"TranslationService"];
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

#pragma mark TranslateText(TranslateTextRequest) returns (TranslateTextResponse)

/**
 * Translates input text and returns translated text.
 */
- (void)translateTextWithRequest:(TranslateTextRequest *)request handler:(void(^)(TranslateTextResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToTranslateTextWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Translates input text and returns translated text.
 */
- (GRPCProtoCall *)RPCToTranslateTextWithRequest:(TranslateTextRequest *)request handler:(void(^)(TranslateTextResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"TranslateText"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[TranslateTextResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark DetectLanguage(DetectLanguageRequest) returns (DetectLanguageResponse)

/**
 * Detects the language of text within a request.
 */
- (void)detectLanguageWithRequest:(DetectLanguageRequest *)request handler:(void(^)(DetectLanguageResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDetectLanguageWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Detects the language of text within a request.
 */
- (GRPCProtoCall *)RPCToDetectLanguageWithRequest:(DetectLanguageRequest *)request handler:(void(^)(DetectLanguageResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DetectLanguage"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[DetectLanguageResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetSupportedLanguages(GetSupportedLanguagesRequest) returns (SupportedLanguages)

/**
 * Returns a list of supported languages for translation.
 */
- (void)getSupportedLanguagesWithRequest:(GetSupportedLanguagesRequest *)request handler:(void(^)(SupportedLanguages *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetSupportedLanguagesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Returns a list of supported languages for translation.
 */
- (GRPCProtoCall *)RPCToGetSupportedLanguagesWithRequest:(GetSupportedLanguagesRequest *)request handler:(void(^)(SupportedLanguages *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetSupportedLanguages"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SupportedLanguages class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark BatchTranslateText(BatchTranslateTextRequest) returns (Operation)

/**
 * Translates a large volume of text in asynchronous batch mode.
 * This function provides real-time output as the inputs are being processed.
 * If caller cancels a request, the partial results (for an input file, it's
 * all or nothing) may still be available on the specified output location.
 * 
 * This call returns immediately and you can
 * use google.longrunning.Operation.name to poll the status of the call.
 */
- (void)batchTranslateTextWithRequest:(BatchTranslateTextRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToBatchTranslateTextWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Translates a large volume of text in asynchronous batch mode.
 * This function provides real-time output as the inputs are being processed.
 * If caller cancels a request, the partial results (for an input file, it's
 * all or nothing) may still be available on the specified output location.
 * 
 * This call returns immediately and you can
 * use google.longrunning.Operation.name to poll the status of the call.
 */
- (GRPCProtoCall *)RPCToBatchTranslateTextWithRequest:(BatchTranslateTextRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"BatchTranslateText"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Operation class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark CreateGlossary(CreateGlossaryRequest) returns (Operation)

/**
 * Creates a glossary and returns the long-running operation. Returns
 * NOT_FOUND, if the project doesn't exist.
 */
- (void)createGlossaryWithRequest:(CreateGlossaryRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToCreateGlossaryWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Creates a glossary and returns the long-running operation. Returns
 * NOT_FOUND, if the project doesn't exist.
 */
- (GRPCProtoCall *)RPCToCreateGlossaryWithRequest:(CreateGlossaryRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"CreateGlossary"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Operation class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListGlossaries(ListGlossariesRequest) returns (ListGlossariesResponse)

/**
 * Lists glossaries in a project. Returns NOT_FOUND, if the project doesn't
 * exist.
 */
- (void)listGlossariesWithRequest:(ListGlossariesRequest *)request handler:(void(^)(ListGlossariesResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListGlossariesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Lists glossaries in a project. Returns NOT_FOUND, if the project doesn't
 * exist.
 */
- (GRPCProtoCall *)RPCToListGlossariesWithRequest:(ListGlossariesRequest *)request handler:(void(^)(ListGlossariesResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListGlossaries"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListGlossariesResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetGlossary(GetGlossaryRequest) returns (Glossary)

/**
 * Gets a glossary. Returns NOT_FOUND, if the glossary doesn't
 * exist.
 */
- (void)getGlossaryWithRequest:(GetGlossaryRequest *)request handler:(void(^)(Glossary *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetGlossaryWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Gets a glossary. Returns NOT_FOUND, if the glossary doesn't
 * exist.
 */
- (GRPCProtoCall *)RPCToGetGlossaryWithRequest:(GetGlossaryRequest *)request handler:(void(^)(Glossary *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetGlossary"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Glossary class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark DeleteGlossary(DeleteGlossaryRequest) returns (Operation)

/**
 * Deletes a glossary, or cancels glossary construction
 * if the glossary isn't created yet.
 * Returns NOT_FOUND, if the glossary doesn't exist.
 */
- (void)deleteGlossaryWithRequest:(DeleteGlossaryRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDeleteGlossaryWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Deletes a glossary, or cancels glossary construction
 * if the glossary isn't created yet.
 * Returns NOT_FOUND, if the glossary doesn't exist.
 */
- (GRPCProtoCall *)RPCToDeleteGlossaryWithRequest:(DeleteGlossaryRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DeleteGlossary"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Operation class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
#endif
