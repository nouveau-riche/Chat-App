import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const onConversationCreated = functions.firestore
  .document("Conversations/{conversationID}")
  .onCreate((snapshot, context) => {
    let data = snapshot.data();
    let conversationID = context.params.conversationID;
    if (data) {
      let members = data.members;
      for (let index = 0; index < members.length; index++) {
        let currentUserID = members[index];
        let remainingUsersIDs = members.filter(
          (u: string) => u !== currentUserID
        );
        remainingUsersIDs.forEach((m: string) => {
          return admin
            .firestore()
            .collection("users")
            .doc(m)
            .get()
            .then((_doc) => {
              let userData = _doc.data();
              if (userData) {
                return admin
                  .firestore()
                  .collection("users")
                  .doc(currentUserID)
                  .collection("Conversations")
                  .doc(m)
                  .create({
                    'conversationID': conversationID,
                    'name': userData.name,
                    'image': userData.imageUrl,
                    'type': 'text',
                  });
              }
              return null;
            })
            .catch(() => {
              return null;
            });
        });
      }
    }
    return null;
  });

export const onConversationUpdated = functions.firestore
  .document("Conversations/{chatID}")
  .onUpdate((change, context) => {
    let data = change?.after.data();
    if (data) {
      let members = data.members;
      let lastMessage = data.messages[data.messages.length - 1];
      for (let index = 0; index < members.length; index++) {
        let currentUserID = members[index];
        let remainingUsersIDs = members.filter(
          (u: string) => u !== currentUserID
        );
        remainingUsersIDs.forEach((u: string) => {
          return admin
            .firestore()
            .collection("users")
            .doc(currentUserID)
            .collection("Conversations")
            .doc(u)
            .update({
              'lastMessage': lastMessage.message,
              'timestamp': lastMessage.timestamp,
              'unseenCount': admin.firestore.FieldValue.increment(1),
              'type': lastMessage.type,
            });
        });
      }
    }
    return null;
  });
