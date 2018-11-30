//
//  WebRTCAppFIRDBManager.m
//  BeFluent
//
//  Created by alan on 2018/10/12.
//  Copyright © 2018 alan. All rights reserved.
//

#import "WebRTCAppFIRDBManager.h"

@implementation FIROptions(WebRTCApp)

+(FIROptions *)optionsWithGoogleAppID:(NSString *)GoogleAppID
                          GCMSenderID:(NSString *)GCMSenderID
                             bundleID:(NSString *)bundleID
                               APIKey:(NSString *)APIKey
                             clientID:(NSString *)clientID
                          databaseURL:(NSString *)databaseURL
                        storageBucket:(NSString *)storageBucket
                            projectID:(NSString *)projectID
{
    FIROptions *options = [[FIROptions alloc] initWithGoogleAppID:GoogleAppID GCMSenderID:GCMSenderID];
    options.bundleID = bundleID;
    options.APIKey = APIKey;
    options.clientID = clientID;
    options.databaseURL = databaseURL;
    options.storageBucket = storageBucket;
    options.projectID = projectID;
    
    return options;
}

@end

/////////////////////////////////////////
/////////////////////////////////////////

static NSString *kChildName = @"call";

@interface WebRTCAppFIRDBManager()

@property (nonatomic,strong) FIRDatabaseReference *dbRef;
@property (nonatomic,strong) FIRDatabaseReference *listeningRef;
@property (nonatomic) FIRDatabaseHandle handle;
@property (nonatomic,strong) NSMutableArray *iceServers;

@end

@implementation WebRTCAppFIRDBManager

+(WebRTCAppFIRDBManager *)sharedInstance
{
    static WebRTCAppFIRDBManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WebRTCAppFIRDBManager alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Private

-(FIRDatabaseReference *)referencWithRoomId:(NSString *)roomId
{
    FIRDatabaseReference *ref = [[self.dbRef child:kChildName] child:roomId];
    return ref;
}

#pragma mark - Public

-(void)setupAppWithOptions:(FIROptions *)options
{
//    [FIRApp configureWithOptions:options];
//    FIRDatabase *db = [FIRDatabase databaseForApp:[FIRApp defaultApp]];
    
    [FIRApp configureWithName:@"webrtc" options:options];
    FIRApp *app = [FIRApp appNamed:@"webrtc"];
    FIRDatabase *db = [FIRDatabase databaseForApp:app];
    
    db.persistenceEnabled = NO;
    FIRDatabaseReference *ref = [db reference];
    self.dbRef = ref;
}

-(void)signInWithToken:(NSString *)token completion:(void (^)(BOOL success))completion
{
    if(!token){
        if(completion) completion(NO);
        return;
    }
    
    if([[FIRAuth auth] currentUser]){
        [self signOut];
    }
    
    [[FIRAuth auth] signInWithCustomToken:token
                               completion:^(FIRAuthDataResult * _Nullable authResult,  NSError * _Nullable error)
     {
         if(error){
             NSLog(@"Firebase signin error %@", error);
             if(completion) completion(NO);
             return;
         }
         
         if(completion) completion(YES);
     }];
}

-(void)signOut
{
    [[FIRAuth auth] signOut:nil];
}

-(void)getIceServersWithCompletion:(void (^)(NSArray *servers))completion
{
    if(completion) completion(@[]);
    return;
    
    if([self.iceServers count]){
        if(completion) completion(self.iceServers);
        return;
    }

    [[self.dbRef child:@"ice"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
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

-(FIRDatabaseReference *)sendMessage:(id)msg toRoom:(NSString *)roomId
{
    FIRDatabaseReference *ref = [[self referencWithRoomId:roomId] childByAutoId];
    [ref setValue:msg];
    return ref;
}

-(void)getAllMessagesOfRoom:(NSString *)roomId completion:(void (^)(NSEnumerator<FIRDataSnapshot *> *))completion
{
    [[self referencWithRoomId:roomId] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(completion) completion([snapshot children]);
    }];
}

#pragma mark -

-(void)deleteDocRef:(FIRDatabaseReference *)ref
{
    [ref removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
         if (error != nil) {  NSLog(@"Error removing document: %@", error); }
    }];
}

-(void)deleteAllMessagesOfRoom:(NSString *)roomId completion:(void (^)(void))completion
{
    FIRDatabaseReference *ref = [self referencWithRoomId:roomId];
    [ref removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(completion) completion();
    }];
}

#pragma mark -

-(void)removeCurrentObserver
{
    if(self.listeningRef && self.handle){
        [self.listeningRef removeObserverWithHandle:self.handle];
    }
    
    self.listeningRef = nil;
    self.handle = 0;
}

-(void)observeThreadWithRoomId:(NSString *)roomId didAddWithBlock:(void (^)(FIRDataSnapshot *snapshot))block
{
    [self removeCurrentObserver];

    FIRDatabaseReference *ref = [self referencWithRoomId:roomId];
    self.listeningRef = ref;
    self.handle = [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(snapshot && block){
            block(snapshot);
        }
    }];
}


@end
