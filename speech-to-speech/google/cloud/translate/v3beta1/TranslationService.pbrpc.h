#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
#import "TranslationService.pbobjc.h"
#endif

#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import <ProtoRPC/ProtoService.h>
#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>
#endif

@class BatchTranslateTextRequest;
@class CreateGlossaryRequest;
@class DeleteGlossaryRequest;
@class DetectLanguageRequest;
@class DetectLanguageResponse;
@class GetGlossaryRequest;
@class GetSupportedLanguagesRequest;
@class Glossary;
@class ListGlossariesRequest;
@class ListGlossariesResponse;
@class Operation;
@class SupportedLanguages;
@class TranslateTextRequest;
@class TranslateTextResponse;

#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
  #import <googleapis/Annotations.pbobjc.h>
  #import <googleapis/Operations.pbobjc.h>
#if defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS) && GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
  #import <Protobuf/Timestamp.pbobjc.h>
#else
  #import "google/protobuf/Timestamp.pbobjc.h"
#endif
#endif

@class GRPCProtoCall;


NS_ASSUME_NONNULL_BEGIN

@protocol TranslationService <NSObject>

#pragma mark TranslateText(TranslateTextRequest) returns (TranslateTextResponse)

/**
 * Translates input text and returns translated text.
 */
- (void)translateTextWithRequest:(TranslateTextRequest *)request handler:(void(^)(TranslateTextResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * Translates input text and returns translated text.
 */
- (GRPCProtoCall *)RPCToTranslateTextWithRequest:(TranslateTextRequest *)request handler:(void(^)(TranslateTextResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark DetectLanguage(DetectLanguageRequest) returns (DetectLanguageResponse)

/**
 * Detects the language of text within a request.
 */
- (void)detectLanguageWithRequest:(DetectLanguageRequest *)request handler:(void(^)(DetectLanguageResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * Detects the language of text within a request.
 */
- (GRPCProtoCall *)RPCToDetectLanguageWithRequest:(DetectLanguageRequest *)request handler:(void(^)(DetectLanguageResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetSupportedLanguages(GetSupportedLanguagesRequest) returns (SupportedLanguages)

/**
 * Returns a list of supported languages for translation.
 */
- (void)getSupportedLanguagesWithRequest:(GetSupportedLanguagesRequest *)request handler:(void(^)(SupportedLanguages *_Nullable response, NSError *_Nullable error))handler;

/**
 * Returns a list of supported languages for translation.
 */
- (GRPCProtoCall *)RPCToGetSupportedLanguagesWithRequest:(GetSupportedLanguagesRequest *)request handler:(void(^)(SupportedLanguages *_Nullable response, NSError *_Nullable error))handler;


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
- (void)batchTranslateTextWithRequest:(BatchTranslateTextRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler;

/**
 * Translates a large volume of text in asynchronous batch mode.
 * This function provides real-time output as the inputs are being processed.
 * If caller cancels a request, the partial results (for an input file, it's
 * all or nothing) may still be available on the specified output location.
 * 
 * This call returns immediately and you can
 * use google.longrunning.Operation.name to poll the status of the call.
 */
- (GRPCProtoCall *)RPCToBatchTranslateTextWithRequest:(BatchTranslateTextRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler;


#pragma mark CreateGlossary(CreateGlossaryRequest) returns (Operation)

/**
 * Creates a glossary and returns the long-running operation. Returns
 * NOT_FOUND, if the project doesn't exist.
 */
- (void)createGlossaryWithRequest:(CreateGlossaryRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler;

/**
 * Creates a glossary and returns the long-running operation. Returns
 * NOT_FOUND, if the project doesn't exist.
 */
- (GRPCProtoCall *)RPCToCreateGlossaryWithRequest:(CreateGlossaryRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ListGlossaries(ListGlossariesRequest) returns (ListGlossariesResponse)

/**
 * Lists glossaries in a project. Returns NOT_FOUND, if the project doesn't
 * exist.
 */
- (void)listGlossariesWithRequest:(ListGlossariesRequest *)request handler:(void(^)(ListGlossariesResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * Lists glossaries in a project. Returns NOT_FOUND, if the project doesn't
 * exist.
 */
- (GRPCProtoCall *)RPCToListGlossariesWithRequest:(ListGlossariesRequest *)request handler:(void(^)(ListGlossariesResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetGlossary(GetGlossaryRequest) returns (Glossary)

/**
 * Gets a glossary. Returns NOT_FOUND, if the glossary doesn't
 * exist.
 */
- (void)getGlossaryWithRequest:(GetGlossaryRequest *)request handler:(void(^)(Glossary *_Nullable response, NSError *_Nullable error))handler;

/**
 * Gets a glossary. Returns NOT_FOUND, if the glossary doesn't
 * exist.
 */
- (GRPCProtoCall *)RPCToGetGlossaryWithRequest:(GetGlossaryRequest *)request handler:(void(^)(Glossary *_Nullable response, NSError *_Nullable error))handler;


#pragma mark DeleteGlossary(DeleteGlossaryRequest) returns (Operation)

/**
 * Deletes a glossary, or cancels glossary construction
 * if the glossary isn't created yet.
 * Returns NOT_FOUND, if the glossary doesn't exist.
 */
- (void)deleteGlossaryWithRequest:(DeleteGlossaryRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler;

/**
 * Deletes a glossary, or cancels glossary construction
 * if the glossary isn't created yet.
 * Returns NOT_FOUND, if the glossary doesn't exist.
 */
- (GRPCProtoCall *)RPCToDeleteGlossaryWithRequest:(DeleteGlossaryRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler;


@end


#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
/**
 * Basic service implementation, over gRPC, that only does
 * marshalling and parsing.
 */
@interface TranslationService : GRPCProtoService<TranslationService>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
#endif

NS_ASSUME_NONNULL_END

