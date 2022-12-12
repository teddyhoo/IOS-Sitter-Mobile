//
//  VisitNoteView.m
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 12/29/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//

#import "VisitNoteView.h"
#import "VisitsAndTracking.h"
#import "VisitProgressView.h"

@interface VisitNoteView() <UITextViewDelegate> {

    VisitsAndTracking *sharedVisits;
    VisitDetails *visitInfo;
    DataClient *clientInfo;
    VisitProgressView *parentViewRef;    
    int char_per_line;
    int globalFontSize;
    int offsetReportY;
    UITextView *noteTextView;
    CGRect noteViewOldFrame;

}

@end


@implementation VisitNoteView

-(instancetype)initWithFrame:(CGRect)frame 
                   visitInfo:(VisitDetails*)visit 
                  clientInfo:(DataClient*)client 
                  parentView:(UIView*)parent {
    
    
    sharedVisits = [VisitsAndTracking sharedInstance];
    visitInfo = visit;
    clientInfo = client;
    char_per_line = 30;
    offsetReportY = 70;
    
    
    return [self initWithFrame:frame];
    
}
-(instancetype)initWithFrame:(CGRect)frame {


    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];

    if (self) {
        

    }
    
    return self;
}

-(void) beginTextEdit:(id)sender {
    NSLog(@"----BEGIN text edit");
}
-(void) endTextEdit:(id)sender {
    NSLog(@"----END text editing");
    VisitDetails *asyncVisitInfo = visitInfo;
    dispatch_queue_t myWrite = dispatch_queue_create("MyWrite", NULL);
    dispatch_async(myWrite, ^{
        [asyncVisitInfo writeVisitDataToFile];
    });    
    
    [self dismissKeyboard];
    
}
-(BOOL) textFieldShouldReturn:(UITextField *)theTextField{
    NSLog(@"----RESIGN FIRST RESPONDER");
    return YES;
    
}
-(BOOL) textViewShouldBeginEditing:(UITextView *)aTextView {
    NSLog(@"----BEGIN editing with tag Num: %li", (long)aTextView.tag);
    //if (aTextView.tag == 1) {
        
        return YES;
        
    //} else {
        
    //    return NO;
        
    //}
}
-(BOOL) textViewShouldEndEditing:(UITextView *)aTextView {
    //NSLog(@"----END editing");
    visitInfo.visitNoteBySitter = noteTextView.text;
    [self dismissKeyboard];
    return YES;
}
-(void) textViewDidEndEditing:(UITextView *)textView {
    visitInfo.visitNoteBySitter = textView.text;
    [textView resignFirstResponder];
    [self dismissKeyboard];    
}
-(void) keyboardWillShowNotification:(NSNotification *)notification {
    
}
-(void) keyboardWillHideNotification:(NSNotification *)notification {}
-(void) updateTextViewContentInset {

}
-(void) keyboardDidShow:(NSNotification *)note {
    NSValue *keyboardFrameValue = [note userInfo][UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    CGRect r = noteTextView.frame;
    //NSLog(@"KEYBOARD frame x: %f y: %f width: %f height: %f", r.origin.x, r.origin.y, r.size.width, r.size.height);
    r.size.height -= CGRectGetHeight(keyboardFrame);
    noteTextView.frame = r;        
}
-(void) textViewDidChangeSelection:(UITextView *)textView {
    //NSLog(@"DID CHANGE SELECTION ");
    [textView layoutIfNeeded];
    CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    caretRect.size.height += textView.textContainerInset.bottom;
    [textView scrollRectToVisible:caretRect animated:NO];
}
-(void) dismissKeyboard {
    //NSLog(@"DISMISS keyboard");
    VisitDetails *asyncVisitInfo = visitInfo;
    dispatch_queue_t myWrite = dispatch_queue_create("MyWrite", NULL);
    dispatch_async(myWrite, ^{
        [asyncVisitInfo writeVisitDataToFile];
    });    
    [self endEditing:YES];    
}

@end
