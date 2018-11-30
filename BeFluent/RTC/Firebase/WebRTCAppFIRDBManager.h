//
//  WebRTCAppFIRDBManager.h
//  BeFluent
//
//  Created by alan on 2018/10/12.
//  Copyright © 2018 alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FirebaseDatabase/FirebaseDatabase.h>

@import Firebase;

@interface FIROptions(WebRTCApp)

+(FIROptions *)optionsWithGoogleAppID:(NSString *)GoogleAppID
                          GCMSenderID:(NSString *)GCMSenderID
                             bundleID:(NSString *)bundleID
                               APIKey:(NSString *)APIKey
                             clientID:(NSString *)clientID
                          databaseURL:(NSString *)databaseURL
                        storageBucket:(NSString *)storageBucket
                            projectID:(NSString *)projectID;

@end


@interface WebRTCAppFIRDBManager : NSObject

+(WebRTCAppFIRDBManager *)sharedInstance;

-(void)setupAppWithOptions:(FIROptions *)options;
-(void)signInWithToken:(NSString *)token completion:(void (^)(BOOL success))completion;
-(void)signOut;

-(void)getIceServersWithCompletion:(void (^)(NSArray *servers))completion;
-(FIRDatabaseReference *)sendMessage:(id)msg toRoom:(NSString *)roomId;
-(void)getAllMessagesOfRoom:(NSString *)roomId completion:(void (^)(NSEnumerator<FIRDataSnapshot *> *))completion;

-(void)deleteDocRef:(FIRDatabaseReference *)docRef;
-(void)deleteAllMessagesOfRoom:(NSString *)roomId completion:(void (^)(void))completion;

-(void)removeCurrentObserver;
-(void)observeThreadWithRoomId:(NSString *)roomId didAddWithBlock:(void (^)(FIRDataSnapshot *snapshot))block;


@end
