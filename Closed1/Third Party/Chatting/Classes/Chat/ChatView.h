

#import "utilities.h"

#import "StickersView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView : JSQMessagesViewController <UIGestureRecognizerDelegate, RNGridMenuDelegate, UIImagePickerControllerDelegate, IQAudioRecorderViewControllerDelegate, StickersDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (id)initWith:(NSDictionary *)dictionary;

@end

