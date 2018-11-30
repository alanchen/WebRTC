//
//  WebRTCAppFirestoreManager.m
//  BeFluent
//
//  Created by alan on 2018/10/1.
//  Copyright © 2018 alan. All rights reserved.
//

#import "WebRTCAppFirestoreManager.h"

static NSString *kRootCollectionName = @"webrtc-connection";
static NSString *kRoomThreadCollectionName = @"message";

@interface WebRTCAppFirestoreManager()
@property (nonatomic,strong) FIRFirestore *db;
@property (nonatomic,strong) NSMutableDictionary *listeners;
@property (nonatomic,strong) NSMutableArray *iceServers;

@end

@implementation WebRTCAppFirestoreManager


+(WebRTCAppFirestoreManager *)sharedInstance
{
    static WebRTCAppFirestoreManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WebRTCAppFirestoreManager alloc] init];
        FIRFirestore *db = [FIRFirestore firestoreForApp:[FIRApp defaultApp]];
        FIRFirestoreSettings *settings = db.settings;
        settings.timestampsInSnapshotsEnabled = YES;
        settings.persistenceEnabled = NO;
        db.settings = settings;

        sharedInstance.db = db;
        sharedInstance.listeners = [@{} mutableCopy];
    });
    
    return sharedInstance;
}

-(void)sendMessage:(id)msg toRoom:(NSString *)roomId
{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",kRootCollectionName, roomId, kRoomThreadCollectionName];
    [[self.db collectionWithPath:path] addDocumentWithData:msg completion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error adding document: %@", error);
        }
    }];
}

-(void)deleteDocRef:(FIRDocumentReference *)docRef
{
    [docRef deleteDocumentWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {  NSLog(@"Error removing document: %@", error); }
    }];
}
-(void)removeObserverThreadWithRoomId:(NSString *)roomId
{
    id listener = [self.listeners objectForKey:roomId];
    if(listener){
        [listener remove];
        [self.listeners removeObjectForKey:roomId];
    }
}

-(void)observeThreadWithRoomId:(NSString *)roomId didAddWithBlock:(void (^)(FIRQueryDocumentSnapshot *snapshot))block
{
    [self removeObserverThreadWithRoomId:roomId];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",kRootCollectionName, roomId, kRoomThreadCollectionName];
    id listener = [[self.db collectionWithPath:path] addSnapshotListener:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        [[snapshot documentChanges] enumerateObjectsUsingBlock:^(FIRDocumentChange * _Nonnull diff, NSUInteger idx, BOOL * _Nonnull stop) {
            if (diff.type == FIRDocumentChangeTypeAdded) {
                if(diff.document && block){
                    block(diff.document);
                }
            }
        }];
    }];
    
    if(listener){
        [self.listeners setObject:listener forKey:roomId];
    }
}

-(void)getAllMessagesOfRoom:(NSString *)roomId completion:(void (^)(NSArray<FIRQueryDocumentSnapshot *> *))completion
{
    NSString *collectionPath = [NSString stringWithFormat:@"%@/%@/%@",kRootCollectionName, roomId, kRoomThreadCollectionName];
    [[self.db collectionWithPath:collectionPath] getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        NSArray *documents = [snapshot documents];
        if(completion) completion(documents);
    }];
}

-(void)deleteAllMessagesOfRoom:(NSString *)roomId completion:(void (^)(void))completion
{
    [self getAllMessagesOfRoom:roomId completion:^(NSArray<FIRQueryDocumentSnapshot *> *list) {
        if([list count] == 0){
            if(completion) completion();
            return ;
        }
        
        [list enumerateObjectsUsingBlock:^(FIRQueryDocumentSnapshot * _Nonnull snapshot, NSUInteger idx, BOOL * _Nonnull stop) {
            [snapshot.reference deleteDocumentWithCompletion:^(NSError * _Nullable error) {
                if(idx == [list count] - 1){
                    if(completion) completion();
                }
            }];
        }];
    }];
}

-(void)getIceServersWithCompletion:(void (^)(NSArray *servers))completion
{
    if([self.iceServers count]){
        if(completion) completion(self.iceServers);
        return;
    }
    
    [[self.db collectionWithPath:@"ice"] getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        NSArray *documents = [snapshot documents];
        if([documents count] == 0){
            if(completion) completion(@[]);
        }else{
            __block NSMutableArray *result = [@[] mutableCopy];
            [documents enumerateObjectsUsingBlock:^(FIRQueryDocumentSnapshot * _Nonnull snapshot, NSUInteger idx, BOOL * _Nonnull stop) {
                if([snapshot.documentID isEqualToString:@"stun"] || [snapshot.documentID isEqualToString:@"turn"] ){
                    id data = snapshot.data;
                    NSArray *urls = [data objectForKey:@"urls"];
                    if(urls){ [result addObjectsFromArray:urls]; }
                }
            }];
            
            if([result count]){
                self.iceServers = result;
            }
            
            if(completion) completion( self.iceServers);
        }
    }];
}


@end
