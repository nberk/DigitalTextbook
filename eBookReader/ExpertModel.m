//  ExpertModel.m
//  Study
//
//  Created by Shang Wang on 2/19/19.
//  Copyright © 2019 Shang Wang. All rights reserved.
//
#import "ExpertModel.h"
#import "LogDataWrapper.h"
#import "LogDataParser.h"
#import "CmapLinkWrapper.h"
#import "CmapNodeWrapper.h"
#import "NodeCell.h"
#import "CmapController.h"

@interface ExpertModel ()

@end

@implementation ExpertModel
@synthesize logArray;
@synthesize stateArray;
@synthesize parentCmapController;
@synthesize bookLinkWrapper;
@synthesize bookNodeWrapper;
@synthesize unUsedStateArray;
@synthesize readActionCount;
@synthesize readFeedbackCount;
@synthesize startPosition;
@synthesize keyConceptsAry;
@synthesize missingConceptsAry;
@synthesize pageTimeMap;
@synthesize startTimeSecond;
@synthesize prePageNum;
@synthesize pageStayTimeMap;
@synthesize preTimeSecond;
@synthesize kc1;
@synthesize kc2;
@synthesize comparePageLeft;
@synthesize comparePageRight;
@synthesize sequentialAddCount;
@synthesize nodeName1;
@synthesize nodeName2;
@synthesize NodenamePage;
@synthesize keyLinksAry;
@synthesize bookLogDataWrapper;
@synthesize lastFeedbackSecond;
@synthesize actionTimer;
@synthesize templateActionTimer;
@synthesize backNaviTimber;
@synthesize backNavicount;
@synthesize crossLinkCount;
@synthesize crosslinkTimer;
@synthesize missingCrossLinkLeftNodename;
@synthesize missingCrossLinkRightNodename;
@synthesize noCrossLinkFBMsg;
@synthesize hasShownFirstCrossLink;
@synthesize templateConnectTimer;
@synthesize FB_BackNaviCount;
@synthesize FB_NoActionCount;
@synthesize FB_PositiveCount;
@synthesize FB_NoBackCount;
@synthesize FB_NoCrossLink;
@synthesize RB_RRRCount;
@synthesize FB_NoTemplate;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    readActionCount=0;
    readFeedbackCount=0;
    startPosition=0;
    KnowledgeModel* KM=[[KnowledgeModel alloc]init];
    keyConceptsAry=[KM getKeyConceptLists];
    
    FB_BackNaviCount=0;
    FB_NoActionCount=0;
    FB_PositiveCount=0;
    FB_NoBackCount=0;
    FB_NoCrossLink=0;
    RB_RRRCount=0;
    FB_NoTemplate=0;
}

-(void)startAllTimer{
    [self resetActionTimer];
    [self startTemplateConectTimer];
    [self startBackNaviTimer];
    [self startNoNaviTemplateCheckTimer];
    [self startNoCrossLinkTimer];
}

-(void)disableAllTimer{
    [backNaviTimber invalidate];
    [actionTimer invalidate];
    [crosslinkTimer invalidate];
    [templateActionTimer invalidate];
    [templateConnectTimer invalidate];
}

-(void)setupKM{
    readActionCount=0;
    sequentialAddCount=0;
    readFeedbackCount=0;
    startPosition=0;
    backNavicount=0;
    crossLinkCount=0;
    KnowledgeModel* KM=[[KnowledgeModel alloc]init];
    keyConceptsAry=[KM getKeyConceptLists];
    keyLinksAry= [KM getKeyLinkLists];
    missingConceptsAry= [[NSMutableArray alloc]init];
    pageTimeMap=[[NSMutableDictionary alloc]init];
    pageStayTimeMap=[[NSMutableDictionary alloc]init];
    prePageNum=1;
    preTimeSecond=0;
    startTimeSecond=0;
    //initialize page stay time dictionary
    for(int i=0; i<100;i++){
        NSString* keyString= [NSString stringWithFormat:@"%d",i];
        pageStayTimeMap[keyString]=@"0.0";
    }
    [self startAllTimer];
}



-(void)resetBackNaviTimer{
    [backNaviTimber invalidate];
    [self startBackNaviTimer];
}


-(void)startBackNaviTimer{
    backNaviTimber = [NSTimer scheduledTimerWithTimeInterval: 420
                                                   target: self
                                                 selector:@selector(noBackNavi:)
                                                 userInfo: nil repeats:YES];
}

-(void)noBackNavi:(NSTimer *)timer {
    if(FB_BackNaviCount>1){
        return;
    }
    [parentCmapController showBackNavigationFeedbackMessage];
    FB_BackNaviCount++;
}



-(void)startActionTimer{
    actionTimer = [NSTimer scheduledTimerWithTimeInterval: 240
                                                  target: self
                                                selector:@selector(onTick:)
                                                userInfo: nil repeats:YES];
}

-(void)onTick:(NSTimer *)timer {
    //NSLog(@"Timer Triggered!\n\n\n");
    if(FB_NoActionCount>1){
        return;
    }
    [parentCmapController showNoActionFeedbackmessage];
    FB_NoActionCount++;
}

-(void)resetActionTimer{
    [actionTimer invalidate];
    [self startActionTimer];
}


-(void)startTemplateConectTimer{
    templateConnectTimer = [NSTimer scheduledTimerWithTimeInterval: 800
                                                   target: self
                                                 selector:@selector(checkTemplateConnect:)
                                                 userInfo: nil repeats:NO];
}


-(void)checkTemplateConnect:(NSTimer *)timer {
    if(FB_NoTemplate>1){
        return;
    }
    BOOL isTemplateAllConnected= [parentCmapController isTemplateAllConnect];
    if(!isTemplateAllConnected){
        [parentCmapController showTemplateFeedbackMessage];
        FB_NoTemplate++;
    }
}


-(void)startNoNaviTemplateCheckTimer{
    templateActionTimer = [NSTimer scheduledTimerWithTimeInterval: 240
                                                           target: self
                                                         selector:@selector(onTemplateTick:)
                                                         userInfo: nil repeats:NO];
}

-(void)onTemplateTick:(NSTimer *)timer {
    if(parentCmapController.templateClickCount<3){
        [parentCmapController showTemplateNoTapFeedbackMessage];
    }
}



-(void)startNoCrossLinkTimer{

    crosslinkTimer = [NSTimer scheduledTimerWithTimeInterval: 360
                                                           target: self
                                                         selector:@selector(onNoCrossLink:)
                                                         userInfo: nil repeats:YES];
    
}


-(void)onNoCrossLink:(NSTimer *)timer {
    if(FB_NoCrossLink>1){
        return;
    }
    
    if(crossLinkCount<1){
        noCrossLinkFBMsg= [self getMissingCrossLinkMsg];
        if(noCrossLinkFBMsg.length>5){
            [parentCmapController showNoCrossLinkFeedbackMessage: YES];
        }else{
            [parentCmapController showNoCrossLinkFeedbackMessage: NO];
        }
     
        FB_NoCrossLink++;
    }
    crossLinkCount=0;
}




-(void)evaluate{
    LogData *lastdata= [logArray lastObject];
    LogData *secondLastData= [logArray objectAtIndex: ([logArray count]-2)];
    NSString* lastAction=lastdata.action;
    NSString* secondLastAction=secondLastData.action;
    if (  [secondLastAction rangeOfString:@"Application Loaded"].location != NSNotFound) {
        stateArray=[[NSMutableArray alloc]init];
        startPosition= (int)[logArray count]-2;
        startTimeSecond= [secondLastData.timeInSecond doubleValue];
        preTimeSecond=startTimeSecond;
        if(startPosition<0){
            startPosition=0;
        }
    }

    BOOL ismeaningful= [self isMeaningfulAction: lastdata];
    if (!ismeaningful){
        return;
    }
    
    
    if( [lastAction rangeOfString:@"creat"].location == NSNotFound  || [lastAction rangeOfString:@"Linking"].location == NSNotFound){
        [self resetActionTimer];
    }
    
    
    
    if( [lastAction rangeOfString:@"urned to page"].location == NSNotFound){
        readActionCount=0;
    }
    
    if( [lastAction rangeOfString:@"urned to page"].location != NSNotFound || [lastAction rangeOfString:@"Linking concepts"].location != NSNotFound) {
        double curentTimeSecond= [lastdata.timeInSecond doubleValue];
        //curentTimeSecond=curentTimeSecond-preTimeSecond;
        int page=lastdata.page;
        if( prePageNum>0){
            double readTime= curentTimeSecond-preTimeSecond;
            //NSLog(@"\n\n\n\n\n\n\n\n\n\n\n Page %d  Stay Time: %f\n\n\n",prePageNum,readTime);
            NSString* prePageString= [NSString stringWithFormat:@"%d", prePageNum];
            NSString* preTimeStayString= pageStayTimeMap[prePageString];
            double prePageStayTime= [preTimeStayString doubleValue];
            double newStayTime=readTime+prePageStayTime;
            NSString* newStayTimeString= [NSString stringWithFormat:@"%.2f", newStayTime];
            pageStayTimeMap[prePageString]=newStayTimeString;
        }
        preTimeSecond=curentTimeSecond;
        prePageNum=page;
    }
    
    
    //check if NNN feature
    if (  [lastAction rangeOfString:@"creat"].location != NSNotFound){
        
        
        
        sequentialAddCount++;
        NSString* nodeName=lastdata.input;
        if ([nodeName isEqualToString:@"null"]){
            NSLog(@"");
        }
        if( (![nodeName isEqualToString:@"null"]) &&sequentialAddCount>2 ){
            [parentCmapController showAddAddAddFeedbackmessage];
            sequentialAddCount=0;
        }
    }
    
    
    
    if (  [lastAction rangeOfString:@"Linking concepts"].location != NSNotFound){
        sequentialAddCount=0;
    }
    
    stateArray=[[NSMutableArray alloc]init];
    int prePage=0;
    BOOL isPosNavi=YES;
    NSString* currentState=@"Load";
    
    
    if(0== [bookNodeWrapper.cmapNodes count]){
        bookNodeWrapper=[CmapNodeParser loadCmapNode];
    }
    if(0== [bookLinkWrapper.cmapLinks count]){
        bookLinkWrapper=[CmapLinkParser loadCmapLink];
    }
    
    
    NodenamePage = [[NSMutableDictionary alloc] init];
    for(CmapNode* node in bookNodeWrapper.cmapNodes){
        NSString *pageString = [NSString stringWithFormat:@"%d",node.pageNum];
        NSString* nodeName=node.text;
        NodenamePage[nodeName]=pageString;
    }
    
   // for ( LogData *data in  logArray){
    for(int i=startPosition; i<[logArray count];i++){
        LogData* data= [logArray objectAtIndex:i];
        int page =data.page;
        NSString* action=data.action;
        NSString* input=data.input;
        NSString* selection=data.selection;
      
        if (  [action rangeOfString:@"Application Loaded"].location != NSNotFound) {
            stateArray=[[NSMutableArray alloc]init];
            prePage=0;
        }
        
        
        if (  [action rangeOfString:@"creat"].location != NSNotFound) {
            currentState=@"A";
    
        
        }else if(  [action.lowercaseString rangeOfString:@"hyperlink"].location != NSNotFound  ){
            currentState=@"H";
             [stateArray addObject:currentState];
            
        }
        
        else if( [action rangeOfString:@"urned to page"].location != NSNotFound){
            //upDatePage time
        
            if(page>prePage){
                currentState=@"R";
                //NSString* secondLastAction=secondLastData.action;
                [stateArray addObject:currentState];
                isPosNavi=YES;
            }else if ( page<prePage){
                if(isPosNavi){
                    currentState=@"P";
                    [stateArray addObject:currentState];
                    isPosNavi=NO;
                }else if (!isPosNavi){
                    currentState=@"B";
                    [stateArray addObject:currentState];
                }
            }
            prePage=page;
            
        }else if([action rangeOfString:@"Linking concepts"].location != NSNotFound ){
      
                currentState=@"L";
                NSString* leftNodename=input;
                NSString* rightNodeName=selection;
                NSString* leftNodePageString=@"0";
                NSString* rightNodePageString=@"0";
                
                if(  [NodenamePage objectForKey: leftNodename]){
                    leftNodePageString=NodenamePage[leftNodename];
                }
                if (  [NodenamePage objectForKey:rightNodeName ] ){
                    rightNodePageString=NodenamePage[rightNodeName];
                }
                int delta=abs(  [leftNodePageString intValue]-[rightNodePageString intValue]    );
                if (delta>0){
                    currentState=@"C";
                    nodeName1=leftNodename;
                    nodeName2=rightNodeName;
                    comparePageLeft=[leftNodePageString intValue];
                    comparePageRight=[rightNodePageString intValue];
                    double leftStayTime = [self returnNodePageStayTime:leftNodename];
                    double rightStayTime= [self returnNodePageStayTime:rightNodeName];
                    if( leftStayTime>5&& rightStayTime>5){
                        currentState=@"G";
                    }else{
                        
                    }
                
                }
            [stateArray addObject:currentState];
            }
    }
    
    for (NSString *st in stateArray){
        NSLog(@"%@",st);
    }
    
     if([currentState isEqualToString:@"R"] && [secondLastData.action containsString:@"End tutorial"]  ){
         
     }else if([currentState isEqualToString:@"R"] ){
        readActionCount++;
        missingConceptsAry= [self getMissingConcepts:bookNodeWrapper.cmapNodes Page:lastdata.page KeyConceptList:keyConceptsAry];
        
    }else if([currentState isEqualToString:@"H"]){
    }
    else{
        readActionCount=0;
    }
     if([currentState isEqualToString:@"P"]||[currentState isEqualToString:@"B"]){
         [self resetBackNaviTimer];
         if(stateArray.count>1){
             NSString *lastState= [stateArray objectAtIndex:stateArray.count-2];
             if ( ![lastState isEqualToString:@"H"] ){
                     backNavicount++;
             }
         }
         if(1==backNavicount){
             [parentCmapController showFirstBackNavigationMessage];
         }
         
     }

    
    // if user creates a cross link, check if reading or comparing has been done.
    if([lastAction isEqualToString:@"Update Link name from list"] ){
        kc1=nil;
        kc2=nil;

        NSString*  preState=[stateArray objectAtIndex: [stateArray count]-1];
        if([preState isEqualToString:@"G"]){
            
            int stateCount=(int)[stateArray count];
            if( stateCount<3 ){
                return;
            }
            NSString* pre1= [stateArray objectAtIndex: stateCount-2];
            NSString* pre2= [stateArray objectAtIndex: stateCount-3];
            if( [pre1 isEqualToString:@"P"] ||[pre1 isEqualToString:@"B"] ||[pre2 isEqualToString:@"P"] ){
                [parentCmapController showPositiveFeedbackmessage];
            }
        }
        if( ([preState isEqualToString:@"C"]||[preState isEqualToString:@"G"])    ){
            crossLinkCount++;
            [self checkCrossLinkFeedback];
        }
        
        if([preState isEqualToString:@"C"]){
            
            for (KeyConcept* kc in keyConceptsAry){
                if ([nodeName1.lowercaseString rangeOfString: kc.name].location != NSNotFound) {
                    kc1=kc;
                }
                if ([nodeName2.lowercaseString rangeOfString: kc.name].location != NSNotFound) {
                    kc2=kc;
                }
            }
             [parentCmapController showCompareFeedbackmessage];
        }
    }
    

    
    if(readActionCount>2){
        readFeedbackCount++;
        if(RB_RRRCount>1){
            return;
        }
        [parentCmapController showReadFeedbackmessage];
        RB_RRRCount++;
        readActionCount=0;
    }
}//end of evaluate


-(BOOL)isMeaningfulAction:(LogData*)log{
    NSString* action=log.action;
    BOOL ismeaningful=NO;
    if ([action rangeOfString:@"creat"].location != NSNotFound) {
        ismeaningful=YES;
    }
    if ([action rangeOfString:@"urned to page"].location != NSNotFound) {
        ismeaningful=YES;
    }
    if ([action rangeOfString:@"Linking concepts"].location != NSNotFound) {
        ismeaningful=YES;
    }
    if ([action rangeOfString:@"hyperlink"].location != NSNotFound) {
        ismeaningful=YES;
    }
    if ([action rangeOfString:@"Update Link name from list"].location != NSNotFound) {
        ismeaningful=YES;
    }
    
    if ([action rangeOfString:@"End tutorial view"].location != NSNotFound) {
        ismeaningful=YES;
    }
    return ismeaningful;
}


-(NSMutableArray*)getMissingConcepts:  (NSMutableArray*)nodeAry Page: (int)page  KeyConceptList: (NSMutableArray*) keylist{
    NSMutableArray* missingConcepts=[[NSMutableArray alloc]init];
    for( KeyConcept* kc in keylist){
        NSString* name=kc.name;
        NSString* subName=kc.subName;
        int currentPage=page;
        BOOL isMIssing=YES;
        for (CmapNode* node in nodeAry){
            NSString* lowString=node.text.lowercaseString;
            if (   ([lowString rangeOfString:name].location != NSNotFound) || ([node.text rangeOfString:subName].location != NSNotFound) ||kc.page>(page-1)  ) {
                isMIssing=NO;
            }
        }
        if(isMIssing){
            [missingConcepts addObject:kc];
        }
    }
   
    parentCmapController.feedbackCtr.missingConceptAry=missingConcepts;
    return missingConcepts;
}


-(double)returnNodePageStayTime: (NSString*)nodeName{
    NSString* leftNodePageString=@"0";
    if(  [NodenamePage objectForKey: nodeName]){
        leftNodePageString=NodenamePage[nodeName];
    }

    int leftNodeInt=[leftNodePageString intValue];

    NSString* leftNodePageStringNew= [NSString stringWithFormat:@"%d", leftNodeInt+1];
    NSString* leftStayTimeString= pageStayTimeMap[leftNodePageStringNew];

    double leftStayTime=[leftStayTimeString doubleValue];

    
    return leftStayTime;
    
}


-(void)checkCrossLinkFeedback{
    if(hasShownFirstCrossLink){
        return;
    }
        [parentCmapController showPositiveCrossLinkFeedbackMessage];
    hasShownFirstCrossLink=YES;
    return;
}

-(NSString*)getMissingCrossLinkMsg{
    NSString* msg=@"";
    NSMutableArray* linksAry=parentCmapController.conceptLinkArray;
    for(KeyLink* kc in keyLinksAry){
        NSString* leftNodeContainName= [parentCmapController isNodesContainKeywords:kc.leftName];
        NSString* isRightNodeContainName= [parentCmapController isNodesContainKeywords:kc.rightname];
        if(leftNodeContainName.length>0&&leftNodeContainName.length>0){
            if(  ! [parentCmapController isKeyLinkExist:kc]){
                msg= [[NSString alloc]initWithFormat:@"How do you describe the relationship between \"%@\" and \"%@\" ?",leftNodeContainName,isRightNodeContainName];
            }
            
        }
        
    }
    return msg;
}


@end
