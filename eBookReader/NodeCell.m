//
//  NodeCell.m
//  eBookReader
//
//  Created by Shang Wang on 3/3/14.
//  Copyright (c) 2014 Andreea Danielescu. All rights reserved.
//

#import "NodeCell.h"

#import "CmapController.h"
#import "ContentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+i7Rotate360.h"
#import "LSHorizontalScrollTabViewDemoViewController.h"
#import "BookViewController.h"
#import "MapFinderViewController.h"
#import "BookPageViewController.h"
#import "QAFinderViewController.h"
#import "RelationTextView.h"
#import "TrainingViewController.h"
#import "LogDataWrapper.h"
#import "ConditionSetup.h"
//#import "RelationTextView.h"
@implementation NodeCell
@synthesize showPoint;
@synthesize text;
@synthesize parentCmapController;
@synthesize pressing;
@synthesize longPressRecognizer;
@synthesize isInitialed;
@synthesize linkingUrl;
@synthesize linkingUrlTitle;
@synthesize savedUrls;
@synthesize relatedNodesArray;
@synthesize linkLayerArray;
@synthesize relationTextArray;
@synthesize bookHighLight;
@synthesize bookthumbNailIcon;
@synthesize bookTitle;
@synthesize showType;
@synthesize bookPagePosition;
@synthesize waitAnim;
@synthesize nodeType;
@synthesize hasHighlight;
@synthesize hasNote;
@synthesize hasWeblink;
@synthesize parentContentViewController;
@synthesize tapRecognizer;
@synthesize pageNum;
@synthesize conceptName;
@synthesize overlay;
@synthesize bookLogData;
@synthesize userName;
@synthesize linkTextview2;
@synthesize enableHyperLink;
@synthesize createType;
@synthesize isAlertShowing;
@synthesize pv; //pop up to take notes
@synthesize appendedNoteString; //to save notes
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isInitialed=NO;
        showType=1;
        relatedNodesArray=[[NSMutableArray alloc] init];
        linkLayerArray=[[NSMutableArray alloc] init];
        relationTextArray=[[NSMutableArray alloc] init];
        savedUrls = [[NSMutableArray alloc] init];
        pageNum=0;
        overlay = [[GHContextMenuView alloc] init];
        overlay.dataSource = self;
        overlay.delegate = self;
        hasHighlight=NO;
        hasNote=NO;
        hasWeblink=NO;
    }
    return self;
}

//To update the thumbnail icons below the node
-(void) updateThumbIcons {
    
    for(UIView* subview in self.view.subviews){
        if([subview isKindOfClass:[UIImageView class]])
        {
            // do somthing
        [subview removeFromSuperview];
        }
    }
    if(hasNote){ // created from "+" (manually)
       // [self addNoteThumb];
    }
    if(hasWeblink){ // created from web browser
       // [self addWebThumb];
    }
    if(hasHighlight){ // created from book
       // [self addHighlightThumb];
    }

}
-(void)viewDidAppear:(BOOL)animated{
    [self updateViewSize];
    [self updateThumbIcons];
    hasNote=NO;
    for (UIGestureRecognizer *recognizer in self.text.gestureRecognizers) {
        recognizer.enabled = NO;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
            recognizer.enabled = NO;
    }
    for (UIGestureRecognizer *recognizer in self.text.gestureRecognizers) {
        recognizer.enabled = NO;
    }
    
    //[parentCmapController updateNodesPosition:self.view.center Node:self];
    text.delegate = self;
    self.view.layer.zPosition=2;
 
   /*
    [text addTarget:self
             action:@selector(textFieldDidBeginEditing:)
   forControlEvents:UIControlEventEditingDidBegin];
    
    [text addTarget:self
             action:@selector(textFieldDidChange:)
   forControlEvents:UIControlEventEditingChanged];
    
    [text addTarget:self
             action:@selector(textFieldDidEndEditing:)
   forControlEvents:UIControlEventEditingDidEnd];
    */
   /*
    hasNote=YES; //Manual
    hasWeblink=YES; //web browser
    hasHighlight=YES; // Book
    */
    //conceptName.text=text.text;
    /*
     int r = arc4random_uniform(3);
     if(1==r||2==r||[text.text isEqualToString:@"bud"]||[text.text isEqualToString:@"yeast cell"]){
     hasNote=YES;
     }
     r = arc4random_uniform(3);
     if(1==r||2==r){
     hasHighlight=YES;
     }
     r = arc4random_uniform(3);
     if(1==r||2==r){
     hasWeblink=YES;
     }
     */
    //set up the note view frame, size, icon image and gesture recognizer.
    text.textAlignment = NSTextAlignmentCenter;
    [self.view setFrame:CGRectMake(showPoint.x-self.view.frame.size.width/2, showPoint.y-self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    panGesture.delegate=self;
    [self.view addGestureRecognizer:panGesture];
    

    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tapGesture.delegate=self;
    [self.view addGestureRecognizer:tapGesture];
    /*
     relatedNodesArray=[[NSMutableArray alloc] init];
     linkLayerArray=[[NSMutableArray alloc] init];
     relationTextArray=[[NSMutableArray alloc] init];
     */
    self.view.layer.shadowOpacity = 0.4;
    self.view.layer.shadowRadius = 3;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(2, 2);
    self.view.layer.cornerRadius=8;
    //self.view.layer.masksToBounds=YES;
    
    text.delegate=self;
    //keyboard for ... cell
    text.keyboardType=UIKeyboardTypeASCIICapable;
    [text setReturnKeyType:UIReturnKeyDone];
    
    overlay = [[GHContextMenuView alloc] init];
    overlay.dataSource = self;
    overlay.delegate = self;
    
    
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){
            recognizer.enabled = NO;
        }
    }
    longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:overlay action:@selector(longPressDetected:)];
    [self.view addGestureRecognizer:longPressRecognizer];
    
    
    //text.enableRecognizer=NO;
    [text setUserInteractionEnabled:YES];
    /*
     tapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
     tapRecognizer.delegate=self;
     //    Attaching it to textfield
     text.enableRecognizer=YES;
     [text addGestureRecognizer:tapRecognizer];
     text.enableRecognizer=NO;
     */
    
    if(NO==isInitialed){
       parentCmapController.noteTakingNode=self;
        [text becomeFirstResponder];
    }
    
    
    // checks if node is created from a certain source and displays an icon in the corner
    /*
     if(hasNote){ // created from "+" (manually)
     [self addNoteThumb];
     }
     if(hasWeblink){ // created from web browser
     [self addWebThumb];
     }
     if(hasHighlight){ // created from book
     [self addHighlightThumb];
     }*/
    
    [self becomeFirstResponder];
    //self.view.layer.zPosition=2;
    enableHyperLink=NO;

   // text.editable = NO;
}

//enters a url string into the "savedUrls" array
-(void) enterIntoUrlArray {
    NSString *urlEnter = parentCmapController.parentBookPageViewController.myWebView.webAdrText.text;
    [savedUrls addObject: urlEnter];
    NSLog(@"element %@ has been added to the array of node '%@'", urlEnter, self.conceptName );
    
}

//sets linkingUrl to current url of web browser
-(void) setLinkingUrl{
    NSString *urlEnter = parentCmapController.parentBookPageViewController.myWebView.webAdrText.text;
   // NSLog(@"urlEnter = %@", urlEnter);
   // NSLog(@"concept name = %@", self.conceptName);
    linkingUrl = [NSURL URLWithString: urlEnter];
    linkingUrlTitle = [parentCmapController.parentBookPageViewController.myWebView.webBrowserView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

//Probably NOT CALLED because we no longer use textfields in the project
-(void)textFieldDidChange :(UITextField *)theTextField{
    CGRect textFrame=text.frame;
    CGRect viewFrame=self.view.frame;
    
    CGFloat length =  [text.text sizeWithAttributes:@{NSFontAttributeName:text.font}].width;
    length+=25;
    if(length>180){
        length=180;
    }
    textFrame.size.width=length;
    viewFrame.size.width=length;
    if(text.text.length<1){
        textFrame.size.width=20;
        viewFrame.size.width=20;
    }
    self.text.frame=textFrame;
    self.view.frame=viewFrame;
    
    [self updateThumbIcons];
    [self updateLink];
}


-(void)viewWillAppear:(BOOL)animated{
    CGFloat fontSize= 14.0f;
    CGRect r = [text.text boundingRectWithSize:CGSizeMake(200, 0)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                                       context:nil];
   // NSLog(@"fontSize = %f\tbounds = (%f x %f)",fontSize,r.size.width,r.size.height);//output the wrap size of the text
    CGRect textFrame=text.frame;
    CGRect viewFrame=self.view.frame;
    //To update width of textview to fit text
    CGFloat length = [text.text sizeWithAttributes:@{NSFontAttributeName:text.font}].width;
    //To update height of textview to fit text
    CGFloat height = [text.text sizeWithAttributes:@{NSFontAttributeName:text.font}].height;
    //Increase length
    length+=25;
    if(length>80){
        length=80;
        height+=25;
        textFrame.size.height=height;
        self.text.frame=textFrame;
    }
    //Increase height
    height+=12;
    /*  if(height>180){
     height=180;
     }*/
    //resize to new width
    textFrame.size.width=length;
    viewFrame.size.width=length;
    //resize to new height
    textFrame.size.height=height;
    viewFrame.size.height=height;
    
    if(text.text.length<1){
        textFrame.size.width=20;
        viewFrame.size.width=20;
    }
    
    self.text.frame=textFrame;
    self.view.frame=viewFrame;
    
    [self updateThumbIcons];
    [self becomeFirstResponder];
    [self updateLink];
    
    if(0==createType){
        text.backgroundColor=[UIColor colorWithRed:160.0/255.0 green:211.0/255.0 blue:172.0/255.0 alpha:1];
    }
}

//Updates View Size,
-(void)updateViewSize{
    CGRect textFrame=text.frame;
    CGRect viewFrame=self.view.frame;
    CGFloat length = [text.text sizeWithAttributes:@{NSFontAttributeName:text.font}].width;
    length+=20;
    if (length >= 100){
        length = 100;
    }
    CGFloat height = text.contentSize.height;
    //CGSize height2 = [text sizeThatFits:CGSizeMake(text.frame.size.width, text.frame.size.height)];
    //resize to new width
    textFrame.size.width=length;
    viewFrame.size.width=length;
    //resize to new height
   textFrame.size.height=height;
   viewFrame.size.height=height;
    
   // textFrame.size.height = height2.height;
   // viewFrame.size.height = height2.height;
    //Prevent textbox from just disappearing
    if(text.text.length<1){
        textFrame.size.width=20;
        viewFrame.size.width=20;
    }

    self.text.frame=textFrame;
    self.view.frame=viewFrame;
    
    [self updateThumbIcons];
    [self updateLink];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    /*
     if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]&&[otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]){
     return YES;
     }*/
    return NO;
}


- (void)textViewDidChange:(UITextView *)textView
{
 /*   textView.scrollEnabled = NO;
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    
    
    [textView sizeToFit];
    
    [self updateThumbIcons];
    //CGRect textFrame=textView.frame;
    // textFrame.size.width=7*textView.text.length+20;
    // textView.frame=textFrame;
    // textFrame.size.width=7*text.text.length+20;
    */
    [self updateViewSize];
}



-(void)textViewDidBeginEditing:(UITextView *)textView{
   parentCmapController.linkTextBeforeEditing=textView.text;
    CGSize screenSZ=[self screenSize];
   
    CGFloat offSet=(textView.frame.size.height+ textView.frame.origin.y-parentCmapController.conceptMapView.contentOffset.y)-(768-352)+88;
    NSLog(@"Height: %f, Origin: %f",textView.frame.size.height,textView.frame.origin.y);
    if(offSet>0){
        // NSLog(@"Blocked by keyboard!!");
        [parentCmapController scrollCmapView:(offSet)];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //disable emoji
    if ([textField isFirstResponder])
    {
        if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage])
        {
            return NO;
        }
    }

    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 20;
}


-(void)removeShadowAnim{
    [self.view.layer removeAllAnimations];
    self.view.layer.shadowOpacity = 0.4;
    self.view.layer.shadowRadius = 3;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(2, 2);
    [parentCmapController dismissLinkHint];
}

- (IBAction)pan:(UIPanGestureRecognizer *)gesture
{
    static CGPoint originalCenter;
    
    if(1==nodeType){
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [parentCmapController savePreviousStep];
        originalCenter = gesture.view.center;
        //gesture.view.layer.shouldRasterize = YES;
        NSString* positionString= [[NSString alloc]initWithFormat:@"x: %f, y: %f",showPoint.x, showPoint.y];
        [parentCmapController saveLog:[[ConditionSetup sharedInstance] getSessionID]  Action:@"Start update node position" Selection:conceptName Input:positionString PageNumber:parentCmapController.pageNum];
    }
    
    if(gesture.state==UIGestureRecognizerStateEnded){
        //save the concept map after pan gesture ended
        
       [parentCmapController updateNodesPosition:self.view.center Node:self];
       [parentCmapController getPreView:nil];
       [parentCmapController autoSaveMap];
       [parentCmapController updatePreviewLocation];
        
        NSString* positionString= [[NSString alloc]initWithFormat:@"x: %f, y: %f",showPoint.x, showPoint.y];
        [parentCmapController saveLog:[[ConditionSetup sharedInstance] getSessionID]  Action:@"End update node position" Selection:conceptName Input:positionString PageNumber:parentCmapController.pageNum];

    }
    
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        
        CGPoint translate = [gesture translationInView:gesture.view.superview];
        CGPoint posit=CGPointMake(originalCenter.x + translate.x, originalCenter.y + translate.y);
        
        //NSLog(@"X:%f",posit.x);
        //NSLog(@"Y:%f",posit.y);
        
        //if(posit.x<0||posit.x>500||posit.y<0||posit.y>768){
        if(posit.x<0||posit.x>parentCmapController.contentView.frame.size.width||posit.y<0||posit.y>(parentCmapController.contentView.frame.size.height-parentCmapController.toolBar.frame.size.height)){
            return;
        }

        gesture.view.center = CGPointMake(originalCenter.x + translate.x, originalCenter.y + translate.y);
        
        [self updateLink];
    }
    if (gesture.state == UIGestureRecognizerStateFailed ||
        gesture.state == UIGestureRecognizerStateCancelled)
    {
        // gesture.view.layer.shouldRasterize = NO;
    }
}


- (IBAction)tap:(UIPanGestureRecognizer *)gesture
{
    
    NSString* Hyperlink=[[NSUserDefaults standardUserDefaults] stringForKey:@"isHyperLinking"];
    
    if(YES==parentCmapController.isReadyToLink){
        if([text.text isEqualToString:parentCmapController.nodesToLink.text.text]){
            [parentCmapController showAlertwithTxt:@"Warning" body:@"Linking will be canceled."];
            parentCmapController.isReadyToLink=NO;
            parentCmapController.nodesToLink=nil;
            [self removeShadowAnim];
            [self becomeFirstResponder];
            return;
        }
        if([parentCmapController isLinkExist:parentCmapController.nodesToLink.text.text OtherName:text.text]){
            [parentCmapController showAlertwithTxt:@"Error" body:@"These two concepts are already linked."];
            [self becomeFirstResponder];
            return;
        }
        
        NSLog(@"Linking concepts!");
        [parentCmapController savePreviousStep];
        [relatedNodesArray addObject:parentCmapController.nodesToLink];
        [parentCmapController.nodesToLink.relatedNodesArray addObject:self];
        [parentCmapController.nodesToLink removeShadowAnim];
        
        CAShapeLayer* layer = [CAShapeLayer layer];
        RelationTextView* linkTextview= [[RelationTextView alloc]initWithFrame:CGRectMake(40, 40, 90, 35)];
        linkTextview.keyboardType=UIKeyboardTypeASCIICapable;
        //[linkTextview setReturnKeyType:UIReturnKeyDone];
        linkTextview.tag=parentCmapController.linkCount;
        linkTextview.editable=YES;
        linkTextview.delegate=self;
        linkTextview.textAlignment=NSTextAlignmentCenter;
        linkTextview.scrollEnabled=NO;
        linkTextview.parentCmapCtr=parentCmapController;
        linkTextview.leftNodeName=text.text;
        linkTextview.rightNodeName=parentCmapController.nodesToLink.text.text;
        parentCmapController.linkJustCreated=linkTextview;
        //edit name 
       // [linkTextview becomeFirstResponder];
        [relationTextArray addObject:linkTextview];
        ConceptLink *link = [[ConceptLink alloc] initWithName:self conceptName:parentCmapController.nodesToLink relation:linkTextview page:parentCmapController.pageNum];
        [parentCmapController addConcpetLink:link];
        parentCmapController.linkJustAdded=link;
        
        [parentCmapController.nodesToLink.relationTextArray addObject:linkTextview];
        [linkLayerArray addObject:layer];
        [parentCmapController.nodesToLink.linkLayerArray addObject:layer];
        
        CGPoint p1=[self getViewCenterPoint:self.view];
        CGPoint p2=[self getViewCenterPoint:parentCmapController.nodesToLink.view];
        linkTextview.center=CGPointMake((p1.x/2+p2.x/2), (p1.y/2+p2.y/2));
        
        [self.parentCmapController.conceptMapView addSubview:linkTextview];
        parentCmapController.isReadyToLink=NO;
        [self updateLink];
        //[parentCmapController endWait];
        [parentCmapController enableAllNodesEditting];
        [parentCmapController logLinkingConceptNodes:text.text ConnectedConcept:parentCmapController.nodesToLink.text.text];
        
        [parentCmapController.parentBookPageViewController showLinkNameFinder];
      
        
        
        //check if it's in training mode
        if(parentCmapController.parentBookPageViewController.isTraining){
            UIImage *image = [UIImage imageNamed:@"Train_selectRelation"];
            image=[self imageWithImage:image scaledToSize:CGSizeMake(300, 200)];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            
        [parentCmapController.parentBookPageViewController showAlertWithString:@"Good job! Now choose a word to represent the relationship from the list or input your own word":imageView];
        }
        return;
    }
    if(-1==pageNum && (linkingUrl == nil || [linkingUrl.absoluteString isEqualToString:@""])){ // Node created manually, no linking url
        return;
    }
  //  if(enableHyperLink&&(createType!=0)){
    NSString* istest=[[NSUserDefaults standardUserDefaults] stringForKey:@"isHyperLinking"];
    
    if([istest isEqualToString:@"YES"]){
        enableHyperLink=YES;
    }
    //Hyperlinking
    if(enableHyperLink){
        if (linkingUrl != nil && linkingUrl.absoluteString.length!=0 ){//created from web Browser
            [self.parentCmapController.parentBookPageViewController showWebView:linkingUrl.absoluteString atNode:self];
            
           // [self.parentCmapController.parentBookPageViewController showWebView:@"" atNode:self];
            NSString* LogString=[[NSString alloc] initWithFormat:@"Using hyperlink from concept: %d", parentCmapController.pageNum];
            //save info in log files
            LogData* newlog= [[LogData alloc]initWithName:userName SessionID:[[ConditionSetup sharedInstance] getSessionID] action:LogString selection:@"concept map view" input:self.conceptName pageNum:pageNum];
            [parentCmapController.bookLogDataWrapper addLogs:newlog];
            [LogDataParser saveLogData:parentCmapController.bookLogDataWrapper];
            return;
        }
        [parentCmapController.neighbor_BookViewController showFirstPage:pageNum];
        parentContentViewController.pageNum=pageNum+1;
     //   [parentCmapController logHyperNavigation:text.text];
        //log the hyperlinking action
        NSString* selectionString;
        if(createType==0){
            selectionString=@"Expert Node";
        }else{
            selectionString=@"Student Node";
        }
        [self.parentCmapController.parentBookPageViewController hideWebView];
        
        //save in log file
       
            NSString* LogString=[[NSString alloc] initWithFormat:@"Using hyperlink from concept: %@", self.conceptName];
        NSString *actionString=@"Hyperlink Navigation";
        if(0==createType){
            actionString=@"Hyperlink Navigation on Template";
        }
        
        LogData* newlog= [[LogData alloc]initWithName:userName SessionID:[[ConditionSetup sharedInstance] getSessionID] action:actionString selection:@"concept map view" input:conceptName pageNum:pageNum];
            [parentCmapController.bookLogDataWrapper addLogs:newlog];
            [LogDataParser saveLogData:parentCmapController.bookLogDataWrapper];
    }
    

    if(parentCmapController.isNavigateTraining&&enableHyperLink&&parentCmapController.isHyperlinkTraining){
        [parentCmapController.parentBookPageViewController showLinkingHint];
        
        NodeCell* cell= [parentCmapController createNodeFromBookForLink:CGPointMake( 250, 300) withName:@"link me" BookPos:CGPointMake(0, 0) page:1];
        cell.text.backgroundColor=[UIColor colorWithRed:247.0/255.0 green:176.0/255.0 blue:143.0/255.0 alpha:1];
        parentCmapController.isNavigateTraining=NO;
    }
}


- (IBAction)singleTap:(UIGestureRecognizer *)gesture{
    // parentCmapController.neighbor_BookViewController.pageNum=pageNum;
    if(-1==pageNum){
        return;
    }
    [parentCmapController.neighbor_BookViewController showFirstPage:pageNum];
    parentContentViewController.pageNum=pageNum+1;
}



-(void)createLink: (NodeCell*)cellToLink name: (NSString*)relationName{
   
     [parentCmapController savePreviousStep];
    if(!cellToLink){
        return;
    }
    
    [relatedNodesArray addObject:cellToLink];
    [cellToLink.relatedNodesArray addObject:self];
    [cellToLink removeShadowAnim];
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    RelationTextView* relation= [[RelationTextView alloc]initWithFrame:CGRectMake(40, 40, 80, 22)];
    relation.tag=2;
    relation.delegate=self;
    //relation.keyboardType=UIKeyboardTypeASCIICapable;
   // [linkTextview setReturnKeyType:UIReturnKeyDone];
    if(relationName.length<6){
        relation.frame=CGRectMake(relation.frame.origin.x, relation.frame.origin.y, 40, relation.frame.size.height);
    }
    
    //relation.backgroundColor=[UIColor clearColor];
    relation.tag=parentCmapController.linkCount;
    relation.delegate=self;
    relation.textAlignment=NSTextAlignmentCenter;
    relation.scrollEnabled=NO;
    relation.leftNodeName=text.text;
    relation.rightNodeName=cellToLink.text.text;
    
    relation.parentCmapCtr=parentCmapController;
    [relationTextArray addObject:relation];
    ConceptLink *link = [[ConceptLink alloc] initWithName:self conceptName:cellToLink relation:relation page:parentCmapController.pageNum];
    [parentCmapController addConcpetLink:link];
    
    [cellToLink.relationTextArray addObject:relation];
    [linkLayerArray addObject:layer];
    [cellToLink.linkLayerArray addObject:layer];
    
    CGPoint p1=[self getViewCenterPoint:self.view];
    CGPoint p2=[self getViewCenterPoint:cellToLink.view];
    relation.center=CGPointMake((p1.x/2+p2.x/2), (p1.y/2+p2.y/2));
    relation.text=relationName;
    [self.parentCmapController.conceptMapView addSubview:relation];
    [self updateLink];
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //disable emoji
    if ([textView isFirstResponder])
    {
        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textView textInputMode] primaryLanguage])
        {
            return NO;
        }
    }

    return textView.text.length + (text.length - range.length) <= 50;
}


-(void)waitForLink{
    self.view.layer.shadowColor=[UIColor redColor].CGColor;
    waitAnim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    waitAnim.fromValue = [NSNumber numberWithFloat:1.0];
    waitAnim.toValue = [NSNumber numberWithFloat:0.0];
    waitAnim.duration = 1.0;
    waitAnim.repeatCount=1000;
    waitAnim.autoreverses=YES;
    [self.view.layer addAnimation:waitAnim forKey:@"shadowOpacity"];
}


//remove all the links between other nodes.
-(void)removeLink{
    [parentCmapController savePreviousStep];
    int i=0;
    //NSMutableArray *deleteArray= [[NSMutableArray alloc]init];
    for (NodeCell* object in relatedNodesArray) {
        CAShapeLayer* layer=[linkLayerArray objectAtIndex:i];
        [layer removeFromSuperlayer];
        RelationTextView* relationText= [relationTextArray objectAtIndex:i];
        [relationText removeFromSuperview];
        //delete the link and text in the related node.
        int j=0;
        for(NodeCell *dCell in object.relatedNodesArray){
            if([dCell.text.text isEqualToString:self.text.text]){
                break;
            }else{
                j++;
            }
        }
        [object.relatedNodesArray removeObjectAtIndex:j];
        [object.linkLayerArray removeObjectAtIndex:j];
        [object.relationTextArray removeObjectAtIndex:j];
        i++;
    }
    
    NSMutableArray* delAry=[[NSMutableArray alloc]init];
    for(ConceptLink *link in parentCmapController.conceptLinkArray){
        if([link.leftNode.text.text isEqualToString:text.text]||[link.righttNode.text.text isEqualToString:text.text]){
            [delAry addObject:link];
        }
    }
    
    for(ConceptLink *link in delAry){
        //deletes the links in delarray
        NSString *linkFullName=[[NSString alloc]initWithFormat:@"%@***%@",link.leftNode.conceptName,link.righttNode.conceptName];
        
        LogData* newlog= [[LogData alloc]initWithName:userName SessionID:[[ConditionSetup sharedInstance] getSessionID] action:@"Deleting Links because concept was deleted" selection:linkFullName input:link.relation.text pageNum:pageNum];
        [bookLogData addLogs:newlog];
        [LogDataParser saveLogData:bookLogData];
        [parentCmapController.conceptLinkArray removeObject:link];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

-(void)removeLinkWithNode: (NodeCell*) LinkedNode{
    [parentCmapController savePreviousStep];
    int i=0;
    int bk=0;

    //NSMutableArray *deleteArray= [[NSMutableArray alloc]init];
    for (NodeCell* object in relatedNodesArray) {
        
        if([object.text.text isEqualToString:LinkedNode.text.text]){
           // [relatedNodesArray removeObject:object];
            bk=i;
        CAShapeLayer* layer=[linkLayerArray objectAtIndex:i];
        [layer removeFromSuperlayer];
        RelationTextView* relationText= [relationTextArray objectAtIndex:i];
        [relationText removeFromSuperview];
        //delete the link and text in the related node.
        int j=0;
        for(NodeCell *dCell in object.relatedNodesArray){
            if([dCell.text.text isEqualToString:self.text.text]){
                break;
            }else{
                j++;
            }
        }
        [object.relatedNodesArray removeObjectAtIndex:j];
        [object.linkLayerArray removeObjectAtIndex:j];
        [object.relationTextArray removeObjectAtIndex:j];
        }
        i++;
    }
    [relatedNodesArray removeObjectAtIndex:bk];
    [linkLayerArray removeObjectAtIndex:bk];
    [relationTextArray removeObjectAtIndex:bk];
    
    
    NSMutableArray* delAry=[[NSMutableArray alloc]init];
    for(ConceptLink *link in parentCmapController.conceptLinkArray){
        if(    ([link.leftNode.text.text isEqualToString:text.text]&&[link.righttNode.text.text isEqualToString:LinkedNode.text.text])
           ||([link.righttNode.text.text isEqualToString:text.text]&&[link.leftNode.text.text isEqualToString:LinkedNode.text.text])          ){
            [delAry addObject:link];
        }
    }
    
    for(ConceptLink *link in delAry){
        [parentCmapController.conceptLinkArray removeObject:link];
    }

}




-(void)updateLink{
    [parentCmapController savePreviousStep];
    int i=0;
    for (NodeCell* object in relatedNodesArray) {
        CAShapeLayer* layer=[linkLayerArray objectAtIndex:i];
        CGPoint p1=[self getViewCenterPoint:self.view];
        CGPoint p2=[self getViewCenterPoint:object.view];
        [self addLine:[self getViewCenterPoint:self.view] Point2:[self getViewCenterPoint:object.view] Layer:layer ];
        RelationTextView* relationText= [relationTextArray objectAtIndex:i];
        relationText.center=CGPointMake((p1.x/2+p2.x/2), (p1.y/2+p2.y/2));
        CGRect frame = relationText.frame;
        frame.size.height=relationText.contentSize.height;
        frame.size.width=relationText.contentSize.width;
        [relationText setFrame:frame];
        [self.parentCmapController.conceptMapView addSubview:relationText];
        relationText.layer.zPosition = 1;
        //[self.parentCmapController.conceptMapView sendSubviewToBack:relationText];
        i++;
    }
    
}



-(CGPoint)getViewCenterPoint:(UIView*)view {
    CGPoint point=CGPointMake(0, 0);
    point.x=view.frame.origin.x+view.frame.size.width/2;
    point.y=view.frame.origin.y+view.frame.size.height/2;
    return point;
}


- (void)addLine:(CGPoint)p1 Point2: (CGPoint)p2 Layer: (CAShapeLayer*) layer {
    layer.strokeColor = [[UIColor grayColor] CGColor];
    layer.lineWidth = 1.0;
    layer.fillColor = [[UIColor clearColor] CGColor];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    layer.path = [path CGPath];
    [self.parentCmapController.conceptMapView.layer insertSublayer:layer atIndex:0];
}


//points the position of the concept in the book.
- (void)addLineAtTop:(CGPoint)p1 Point2: (CGPoint)p2 Layer: (CAShapeLayer*) layer {
    // layer = [CAShapeLayer layer];
    layer.strokeColor = [[UIColor grayColor] CGColor];
    layer.lineWidth = 1.0;
    layer.fillColor = [[UIColor clearColor] CGColor];
    //[lineLaer removeFromSuperlayer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    // [shapeLayer removeFromSuperlayer];
    layer.path = [path CGPath];
    [self.parentCmapController.parent_ContentViewController.view.layer addSublayer:layer];
}



//get the screen sie
- (CGSize) screenSize
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}


- (NSInteger) numberOfMenuItems
{
    return 4;
}

//specify image names
-(UIImage*) imageForItemAtIndex:(NSInteger)index
{
    NSString* imageName = nil;
    switch (index) {
        case 0: // delete node
            imageName = @"deleteConcept";
            break;
        case 1: // link nodes
            imageName = @"link";
            break;
        case 2: // edit node name
            imageName = @"edit";
            break;
        case 3: // search on internet
            imageName= @"Node_Small";
            break;
        case 4: // taking notes
            imageName = @"webbrowser";
            break;
        default:
            break;
    }
    UIImage* img=[UIImage imageNamed:imageName];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation==UIInterfaceOrientationLandscapeLeft||orientation==UIInterfaceOrientationLandscapeRight) {
        img = [[UIImage alloc] initWithCGImage: img.CGImage
                                         scale: 1.0
                                   orientation: UIImageOrientationLeft];
    }
    return img;
}

//call back functions, decides what menu does
- (void) didSelectItemAtIndex:(NSInteger)selectedIndex forMenuAtPoint:(CGPoint)point
{
    NSString* msg = nil;
    switch (selectedIndex) {
        case 0: // delete node
        {
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Deleting"
                                                                message:@"Do you want to delete this concept node?"
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Yes", nil];
                [alert show];
            }
        }
            break;
        case 1: // link nodes
            msg = @"link Selected";
            [parentCmapController showLinkHint];
            parentCmapController.isReadyToLink=YES;
            parentCmapController.nodesToLink=self;
            [parentCmapController disableAllNodesEditting];
            // [parentCmapController startWait];
            [parentCmapController saveLog:[[ConditionSetup sharedInstance] getSessionID] Action:@"Start linking node" Selection:@"concept map view" Input:conceptName PageNumber:pageNum];
            [self waitForLink];
            break;
        case 2: //edit node name
            
        {
            CGFloat offSet = (self.view.frame.size.height+ self.view.frame.origin.y-parentCmapController.conceptMapView.contentOffset.y)-(768-352)+88;
            // NSLog(@"Height: %f, Origin: %f",pv.noteText.frame.size.height,pv.noteText.frame.origin.y);
            if(offSet>0){ // view is blocked by keyboard
                // NSLog(@"Blocked by keyboard!!");
                [parentCmapController scrollCmapView:(offSet)]; //scroll view so that view is not blocked
            }
            
            [parentCmapController saveLog:[[ConditionSetup sharedInstance] getSessionID] Action:@"Start editing node name" Selection:@"concept map view" Input:conceptName PageNumber:pageNum];
            parentCmapController.noteTakingNode=self;
            //This timer gives the view time to scroll before going to editNodename function
            [NSTimer scheduledTimerWithTimeInterval:0.3f
                                             target:self
                                           selector: @selector(editNodeName:)
                                           userInfo:nil
                                            repeats:NO];
        }
            break;
        case 3: // Note Taking
        {
            CGFloat offSet = (self.view.frame.size.height+ self.view.frame.origin.y-parentCmapController.conceptMapView.contentOffset.y)-(768-352)+88;
            // NSLog(@"Height: %f, Origin: %f",pv.noteText.frame.size.height,pv.noteText.frame.origin.y);
            if(offSet>0){ // view is blocked by keyboard
                // NSLog(@"Blocked by keyboard!!");
                [parentCmapController scrollCmapView:(offSet)]; //scroll view so that view is not blocked
            }
            [parentCmapController saveLog:[[ConditionSetup sharedInstance] getSessionID] Action:@"Start taking notes" Selection:@"concept map view" Input:conceptName PageNumber:pageNum];
            //This timer gives the view time to scroll before going to takeNote function
            [NSTimer scheduledTimerWithTimeInterval:0.3f
                                             target:self
                                           selector: @selector(takeNote:)
                                           userInfo:nil
                                            repeats:NO];
        }
            break;
        case 4: //Search Webview
        {
            //look up current text
            [parentCmapController.parentBookPageViewController showWebView: text.text atNode: self];
        }
            break;
        default:
            break;
    }
}

//Edits name of node
- (IBAction)editNodeName : (id)sender {
    parentCmapController.addedNode=self;
    [self.text setUserInteractionEnabled:YES];
    [self.text becomeFirstResponder];
}


//Allows user to take notes on the concept selected
- (IBAction)takeNote : (id)sender {
    NSString *takeNoteTitleString;
    if (self.hasHighlight){ //node  created from book
        takeNoteTitleString = [NSString stringWithFormat:@"Notes on \"%@\"     Page: %i", self.text.text, self.pageNum + 1];
    }
    else if (self.linkingUrl.absoluteString.length > 0){ //node created from web browser
        NSString *siteTitle = self.linkingUrlTitle;
        takeNoteTitleString = [NSString stringWithFormat:@"Notes on \"%@\"     Site: %@", self.text.text, siteTitle];
    }
    else {
        takeNoteTitleString = [NSString stringWithFormat:@"Notes on \"%@\"", self.text.text];
    }
    NSArray *popUpContent=[NSArray arrayWithObjects:@"NoteTaking", nil];
    PopoverView*pv=  [PopoverView showPopoverAtPoint: CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)
                             inView:self.view
                          withTitle:takeNoteTitleString
                    withStringArray:popUpContent
                           delegate:self];
    
    pv.noteText.delegate=parentCmapController; //We need this.
    parentCmapController.noteTakingNode = self; //sets noteTaking node to current node
    pv.noteText.font = [UIFont fontWithName:@"Helvetica" size:15];
    pv.noteText.text = appendedNoteString; //saves note text to string
    parentCmapController.showingPV=pv;
    /*CGFloat offSet=(pv.noteText.frame.size.height+ pv.noteText.frame.origin.y-parentCmapController.conceptMapView.contentOffset.y)-(768-352)+88;*/


}


//deletes selected node
-(void)deleteNode: (BOOL)delByUser{
    if(1==nodeType){
        [self.view removeFromSuperview];
        ThumbNailIcon *itemToDelete=nil;
        for(ThumbNailIcon *thumb in   parentContentViewController.bookthumbNailIcon.thumbnails){
            if(3==thumb.type&&[thumb.text isEqualToString:text.text]){
                itemToDelete=thumb;
                break;
            }
        }
        [parentContentViewController.bookthumbNailIcon.thumbnails removeObject:itemToDelete];
        [ThumbNailIconParser saveThumbnailIcon:parentContentViewController.bookthumbNailIcon];
        
    }
    
    NodeCell *cellToRemove;
    for(NodeCell* cell in parentCmapController.conceptNodeArray){
        if([cell.text.text isEqualToString:self.text.text]){
            cellToRemove=cell;
            break;
        }
    }
    [self removeLink];
    //parentCmapController
    [parentCmapController.conceptNodeArray removeObject:cellToRemove];
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
    [parentCmapController deleteHighlightwithWord:text.text];
    
    [parentCmapController updateNodesPosition:self.view.center Node:self];
    [parentCmapController getPreView:nil];
    
    //only logs concepts delete if it's user action
    if(delByUser){
        NSString* LogString=[[NSString alloc] initWithFormat:@"%@", text.text];
        LogData* newlog= [[LogData alloc]initWithName:userName SessionID:[[ConditionSetup sharedInstance] getSessionID] action:@"Deleting Concept" selection:@"concept map" input:LogString pageNum:pageNum];
        [bookLogData addLogs:newlog];
        [LogDataParser saveLogData:bookLogData];
    }
    [parentCmapController updatePreviewLocation];
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 1) {
        [self deleteNode:YES];
    }
    if(parentCmapController.parentBookPageViewController.isTraining&&[text.text isEqualToString:@"delete me"]){
        
        UIImage *image = [UIImage imageNamed:@"Train_pinch"];
        image=[self imageWithImage:image scaledToSize:CGSizeMake(300, 200)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
    [parentCmapController.parentBookPageViewController showAlertWithString:@"Good job! Now pinch to increase space for the concept mapping panel":imageView];
    parentCmapController.isPinchTraining=YES;
        
        for (NodeCell *cell in parentCmapController.conceptNodeArray)
        {
            [cell removeLink];
            [cell.view removeFromSuperview];
        }
        [parentCmapController.conceptNodeArray removeAllObjects];
        [parentCmapController.conceptLinkArray removeAllObjects];
    }
    
    /*
    for (NodeCell *cell in parentCmapController.conceptNodeArray)
    {
        [cell removeLink];
        [cell.view removeFromSuperview];
    }

     if(parentCmapController.parentBookPageViewController.isTraining&&[text.text isEqualToString:@"delete me"]){
         [parentCmapController.conceptNodeArray removeAllObjects];
         [parentCmapController.conceptLinkArray removeAllObjects];
     }*/
}
//for nodes from the "+" button-------------------------------------------------------------------------
-(void)addNoteThumb{
    if(NO==hasNote){
    UIImageView *thumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note_square.png"]];
    [thumb setFrame:CGRectMake(self.view.frame.size.width-7, self.view.frame.size.height, 14, 14)];
    [self.view addSubview:thumb];
    hasNote=YES;
    }
}
//for nodes from the web browser-------------------------------------------------------------------------
-(void)addWebThumb{
    UIImageView *thumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"safari_square.png"]];
    [thumb setFrame:CGRectMake(self.view.frame.size.width-7, self.view.frame.size.height, 14, 14)];
    [self.view addSubview:thumb];
}
//for nodes from the book-------------------------------------------------------------------------------
-(void)addHighlightThumb{
    UIImageView *thumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colorPlate.png"]];
    [thumb setFrame:CGRectMake(self.view.frame.size.width-7, self.view.frame.size.height, 14, 14)];
    [self.view addSubview:thumb];
}



-(void)showResources{
    [self.parentCmapController showResources];
}


//after editing the text in the textviews, update the conceptLinkArray
- (void)textViewDidEndEditing:(UITextView *)textView{
    // ConceptLink* linkToUpdate;
    if(0<textView.tag){ // finish editting relationship text
        if ([textView respondsToSelector:@selector(isTylerTextView)]){ //is TylerTextView, so editing node text
            NSLog(@"Edit node text...\n");
            
           // NSString* selectionString=[[NSString alloc]initWithFormat:@"",];
            NSString* inputString=[[NSString alloc] initWithFormat:@"%@", textView.text];
            LogData* newlog= [[LogData alloc]initWithName:userName SessionID:[[ConditionSetup sharedInstance] getSessionID] action:@"Update Node Name" selection:parentCmapController.linkTextBeforeEditing input:inputString pageNum:pageNum];
            [bookLogData addLogs:newlog];
            [LogDataParser saveLogData:bookLogData];
            
            if([inputString isEqualToString:@""]){ //empty string
                [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(showEMptyNodeAlert)
                                               userInfo:nil
                                                repeats:NO];
            }
            
            int sameNodeCount=0;
            for(NodeCell* cell in parentCmapController.conceptNodeArray){
                if([text.text isEqualToString:cell.text.text]){ //node has same name as some other node
                    sameNodeCount++;
                }
            }//end for
            
            if(sameNodeCount>1){ //node has same name
                [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(showDupliAlert)
                                               userInfo:nil
                                                repeats:NO];
            }
            if(!self.conceptName){ //conceptname is nil
                self.conceptName=self.text.text; //conceptname is current text
            }
        }
        else{//is not TylerTextView, editinglink names
            for(ConceptLink* view in parentCmapController.conceptLinkArray){
                if(view.relation.tag== textView.tag){
                    view.relation.text=textView.text;
                    NSLog(@"update link text...\n");
                    NSString* inputString=[[NSString alloc] initWithFormat:@"%@", textView.text];
                    
                    NSString* selectionString=[[NSString alloc] initWithFormat:@"%@***%@", view.leftNode.conceptName,view.righttNode.conceptName];
                    
                    LogData* newlog= [[LogData alloc]initWithName:userName SessionID:[[ConditionSetup sharedInstance] getSessionID] action:@"Update Link Name" selection:selectionString input:inputString pageNum:parentCmapController.pageNum];
                    [bookLogData addLogs:newlog];
                    [LogDataParser saveLogData:bookLogData];
                }//end if
            }//endfor
        }//end else
        // NSLog(@"finish editting");
    }//endif
    
    if(parentCmapController.isTraining){
        [parentCmapController.parentTrainingCtr showAlertWithString:@"Good job! Now try to delete a concept node"];
        [parentCmapController.parentTrainingCtr createDeleteTraining];
    }
    if(2!=textView.tag){
        [textView setUserInteractionEnabled:NO];
    }
    [textView resignFirstResponder];
    
}


//shows alert if a duplicate node exists
-(void)showDupliAlert{
    [text becomeFirstResponder];
     NSString* msg=[[NSString alloc]initWithFormat:@"Node with name \"%@\" already exists!",text.text];
    if(!isAlertShowing){
        [parentCmapController showAlertwithTxt:@"Warning" body:msg];
        isAlertShowing=YES;
    }else{
        isAlertShowing=NO;
    }
}


-(void)showEMptyNodeAlert{
    [text becomeFirstResponder];
    if(!isAlertShowing){
        [parentCmapController showAlertwithTxt:@"Warning" body:@"Please input the node name!"];
        isAlertShowing=YES;
    }else{
        isAlertShowing=NO;
    }
}



-(void)deleteLinkWithNode: (NodeCell*)cellToDel{
    NodeCell* cellBk;
    for (NodeCell* cell in relatedNodesArray){
        if([cell.text.text isEqualToString:cellToDel.text.text]){
            cellBk=cell;
        }
    }
    [relatedNodesArray removeObject:cellBk];
    
    
    NodeCell* cellToBk;
    for (NodeCell* cell in cellToDel.relatedNodesArray){
        if([cell.text.text isEqualToString:text.text]){
            cellToBk=cell;
        }
    }
    [cellToDel.relatedNodesArray removeObject:cellToBk];
}



-(void)highlightNode{
    NSString* istest=[[NSUserDefaults standardUserDefaults] stringForKey:@"isHyperLinking"];
    if(![istest isEqualToString:@"YES"]){
        return;
    }
    
    text.backgroundColor=[UIColor colorWithRed:(255/255.0) green:(178/255.0) blue:(102/255.0) alpha:0.9];
}

-(void)unHighlightNode{
    text.backgroundColor=[UIColor colorWithRed:(164/255.0) green:(219/255.0) blue:(232/255.0) alpha:1.0];
}

-(void)unHighlightExpertNode{
    text.backgroundColor=[UIColor colorWithRed:160.0/255.0 green:211.0/255.0 blue:172.0/255.0 alpha:1];
}


-(void)highlightLink: (NSString*)relatedNodeName{
    int i=0;
    for (NodeCell* object in relatedNodesArray) {
        CAShapeLayer* layer=[linkLayerArray objectAtIndex:i];
        if([object.text.text isEqualToString:relatedNodeName]){
            layer.fillColor = [UIColor blueColor].CGColor;
            return;
        }
        i++;
    }
    
}


@end
