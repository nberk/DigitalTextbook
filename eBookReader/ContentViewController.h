//
//  ContentViewController.h
//  eBookReader
//
//  Created by Shang Wang on 3/19/13.
//  Copyright (c) 2013 Andreea Danielescu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>
#import <Slt/Slt.h>
#import <OpenEars/FliteController.h>
#import "KnowledgeModule.h"
#import "ThumbNailController.h"
#import "PopoverView.h"
#import "LogFileController.h"
#ifndef CONTENTVIEWCONTROLLER_H
#define CONTENTVIEWCONTROLLER_H

@class NoteViewController;
@class BookViewController;
@class HighLightWrapper;
@class HighLight;
@class ThumbNailIconWrapper;

@interface ContentViewController : UIViewController< PopoverViewDelegate, UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate>
{
    PopoverView *pv; //popOver view
    CGPoint pvPoint;// position where pop over view shows
    FliteController *fliteController;
    Slt *slt;
}
#endif


@property (strong, nonatomic) IBOutlet UIWebView *webView; // the webview which displays the content
@property (strong, nonatomic) id dataObject;// sotres the HTML data
@property (strong, nonatomic) id url; //the URL link to display HTML content
@property (nonatomic) BOOL isMenuShow;
@property (nonatomic, retain) IBOutlet UILabel *currentPageLabel; //indicates the current page number
@property (nonatomic) int pageNum; //current page number
@property (nonatomic) int totalpageNum;//total page number
@property (strong, nonatomic) BookViewController *parent_BookViewController; //stores the its parent view, in order to call the parent controlller methods
@property (strong, nonatomic) NSMutableArray *highlightTextArray;//stores the highlighted text in an array
@property (strong, nonatomic) KnowledgeModule *knowledge_module;
@property (strong, nonatomic) FliteController *fliteController;
@property (strong, nonatomic) Slt *slt;
@property (strong, nonatomic) ThumbNailController *thumbNailController; //thumbnail controller which controls the thunbail icon position
@property (strong, nonatomic) LogFileController* logFileController;
@property (nonatomic, retain) HighLightWrapper *bookHighLight;//the highlight wrapper pased from the bookviewcontroller to control the highlight info in the book
@property (nonatomic, retain) ThumbNailIconWrapper *bookthumbNailIcon;


-(void)setingUpMenuItem;
-(void)refresh;
-(void)createWebNote : (CGPoint) show_at_point URL:(NSURLRequest*) urlrequest isWriteToFile:(BOOL)iswrite isNewIcon: (BOOL)isNew;
-(NoteViewController*)createNote : (CGPoint) show_at_point NoteText:(NSString*) m_note_text isWriteToFile:(BOOL)iswrite;
- (void)highlightStringWithColor:(NSString*)color;
- (void)callJavaScriptMethod:(NSString*)method;
-(void)saveHighlightToXML:(NSString*)color_string;
- (NSInteger)highlightAllOccurencesOfString:(NSString*)str;
-(void)loadHghLight;
-(int)ifHighlightCollapse: (HighLight*) temp_highlight;
-(void)loadThumbNailIcon;

@end