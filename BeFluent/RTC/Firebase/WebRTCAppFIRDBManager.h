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

@interface WebRTCAppFIRDBManager : NSObject

+(WebRTCAppFIRDBManager *)sharedInstance;

-(void)getIceServersWithCompletion:(void (^)(NSArray *servers))completion;

-(void)sendMessage:(id)msg toRoom:(NSString *)roomId;

-(void)deleteDocRef:(FIRDatabaseReference *)docRef;

-(void)deleteAllMessagesOfRoom:(NSString *)roomId completion:(void (^)(void))completion;

-(void)removeObserverThreadWithRoomId:(NSString *)roomId;

-(void)observeThreadWithRoomId:(NSString *)roomId didAddWithBlock:(void (^)(FIRDataSnapshot *snapshot))block;

-(void)getAllMessagesOfRoom:(NSString *)roomId completion:(void (^)(NSEnumerator<FIRDataSnapshot *> *))completion;

@end
