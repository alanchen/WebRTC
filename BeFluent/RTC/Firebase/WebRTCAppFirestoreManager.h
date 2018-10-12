//
//  WebRTCAppFirestoreManager.h
//  BeFluent
//
//  Created by alan on 2018/10/1.
//  Copyright © 2018 alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FirebaseFirestore/FirebaseFirestore.h>

@import Firebase;

@interface WebRTCAppFirestoreManager : NSObject

+(WebRTCAppFirestoreManager *)sharedInstance;

-(void)sendMessage:(id)msg toRoom:(NSString *)roomId;

-(void)deleteDocRef:(FIRDocumentReference *)docRef;

-(void)deleteAllMessagesOfRoom:(NSString *)roomId completion:(void (^)(void))completion;

-(void)removeObserverThreadWithRoomId:(NSString *)roomId;

-(void)observeThreadWithRoomId:(NSString *)roomId
               didAddWithBlock:(void (^)(FIRQueryDocumentSnapshot *snapshot))block;

-(void)getAllMessagesOfRoom:(NSString *)roomId
                 completion:(void (^)(NSArray<FIRQueryDocumentSnapshot *> *list))completion;

-(void)getIceServersWithCompletion:(void (^)(NSArray *servers))completion;

@end
