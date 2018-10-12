//
//  WebRTCAppFIRDBManager.m
//  BeFluent
//
//  Created by alan on 2018/10/12.
//  Copyright © 2018 alan. All rights reserved.
//

#import "WebRTCAppFIRDBManager.h"
#import "FIRApp+WebRTCApp.h"


static NSString *kRootCollectionName = @"webrtc-connection";
static NSString *kRoomThreadCollectionName = @"message";

@interface WebRTCAppFIRDBManager()

@property (nonatomic,strong) FIRDatabaseReference *ref;
@property (nonatomic,strong) NSMutableDictionary *listeners;
@property (nonatomic,strong) NSMutableArray *iceServers;

@end

@implementation WebRTCAppFIRDBManager

+(WebRTCAppFIRDBManager *)sharedInstance
{
    static WebRTCAppFIRDBManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FIRDatabase *db = [FIRDatabase databaseForApp:[FIRApp webRTCApp]];
        db.persistenceEnabled = NO;
        FIRDatabaseReference *ref = [db reference];
        sharedInstance = [[WebRTCAppFIRDBManager alloc] init];
        sharedInstance.ref = ref;
        sharedInstance.listeners = [@{} mutableCopy];
    });

    return sharedInstance;
}

-(void)getIceServersWithCompletion:(void (^)(NSArray *servers))completion
{
    if([self.iceServers count]){
        if(completion) completion(self.iceServers);
        return;
    }
    
    [[self.ref child:@"ice"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        id data = snapshot.value;
        
        NSMutableArray *result = [@[] mutableCopy];
        NSArray *s1 = [data objectForKey:@"stun"];
        NSArray *s2 = [data objectForKey:@"turn"];
        if(s1 && [s1 isKindOfClass:[NSArray class]]){
            [result addObjectsFromArray:s1];
        }
        if(s2 && [s2 isKindOfClass:[NSArray class]]){
            [result addObjectsFromArray:s2];
        }
        
        if([result count]){
            self.iceServers = result;
        }
        
        if(completion) completion( self.iceServers );
    }];
}

-(FIRDatabaseReference *)referencWithRoomId:(NSString *)roomId
{
    FIRDatabaseReference *ref = [[[self.ref child:kRootCollectionName] child:roomId] child:kRoomThreadCollectionName];
    return ref;
}

-(void)sendMessage:(id)msg toRoom:(NSString *)roomId
{
    FIRDatabaseReference *ref = [[self referencWithRoomId:roomId] childByAutoId];
    [ref setValue:msg];
}

-(void)deleteDocRef:(FIRDatabaseReference *)ref
{
    [ref removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
         if (error != nil) {  NSLog(@"Error removing document: %@", error); }
    }];
}

-(void)deleteAllMessagesOfRoom:(NSString *)roomId completion:(void (^)(void))completion
{
    FIRDatabaseReference *ref = [[[self.ref child:kRootCollectionName] child:roomId] child:kRoomThreadCollectionName];
    [ref removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(completion) completion();
    }];
}

-(void)removeObserverThreadWithRoomId:(NSString *)roomId
{
    id listener = [self.listeners objectForKey:roomId];
    if(listener){
        [(FIRDatabaseReference *)listener removeAllObservers];
        [self.listeners removeObjectForKey:roomId];
    }
}

-(void)observeThreadWithRoomId:(NSString *)roomId didAddWithBlock:(void (^)(FIRDataSnapshot *snapshot))block
{
    [self removeObserverThreadWithRoomId:roomId];
    
    FIRDatabaseReference *ref = [self referencWithRoomId:roomId];
    [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(snapshot && block){
            block(snapshot);
        }
    }];
    
    if(ref){
        [self.listeners setObject:ref forKey:roomId];
    }
}

-(void)getAllMessagesOfRoom:(NSString *)roomId completion:(void (^)(NSEnumerator<FIRDataSnapshot *> *))completion
{
    [[self referencWithRoomId:roomId] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(completion) completion([snapshot children]);
    }];
}

@end
