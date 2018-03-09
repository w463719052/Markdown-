//
//  DataSourceReader.m
//  SmartvisionOCR
//

#import "DataSourceReader.h"
#import "RXMLElement.h"
#import "MainType.h"
#import "SubType.h"

#define kXmlPath [[NSBundle mainBundle] pathForResource:@"appTemplateConfig" ofType:@"xml"]


@implementation DataSourceReader

+(NSMutableArray *) getAllMainTypeDataSource{
    NSMutableArray *mainDataSource = [NSMutableArray arrayWithCapacity:0];
    NSString *xmlString = [NSString stringWithContentsOfFile:kXmlPath encoding:NSUTF8StringEncoding error:nil];
    if (xmlString.length == 0) {
        return nil;
    }
    RXMLElement *rootElement = [RXMLElement elementFromXMLString:xmlString encoding:NSUTF8StringEncoding];
    RXMLElement *procuct = [rootElement child:@"Product"];
    NSArray *SmartVisitions = [procuct children:@"SmartVisition"];
    for (RXMLElement *element in SmartVisitions) {
        MainType *type = [[MainType alloc] init];
        type.type = [element attribute:@"Type"];
        type.typeName = [element attribute:@"name"];
        type.selected = [element attribute:@"Selected"];
        
        [mainDataSource addObject:type];
    }
    
    return mainDataSource;
}

+(NSMutableArray *) getMainTypeDataSource{
    NSMutableArray *mainDataSource = [NSMutableArray arrayWithCapacity:0];
    NSString *xmlString = [NSString stringWithContentsOfFile:kXmlPath encoding:NSUTF8StringEncoding error:nil];
    if (xmlString.length == 0) {
        return nil;
    }
    RXMLElement *rootElement = [RXMLElement elementFromXMLString:xmlString encoding:NSUTF8StringEncoding];
    RXMLElement *procuct = [rootElement child:@"Product"];
    NSArray *SmartVisitions = [procuct children:@"SmartVisition"];
    for (RXMLElement *element in SmartVisitions) {
        MainType *type = [[MainType alloc] init];
        type.type = [element attribute:@"Type"];
        type.typeName = [element attribute:@"name"];
        type.selected = [element attribute:@"Selected"];
        if ([type.selected isEqualToString:@"YES"]) {
            [mainDataSource addObject:type];
        }
    }
    
    return mainDataSource;
}

+(NSMutableArray *) getSubTypeDataSource: (NSString *) mainType{
    NSMutableArray *subDataSource = [NSMutableArray arrayWithCapacity:0];
    NSString *xmlString = [NSString stringWithContentsOfFile:kXmlPath encoding:NSUTF8StringEncoding error:nil];
    RXMLElement *rootElement = [RXMLElement elementFromXMLString:xmlString encoding:NSUTF8StringEncoding];
    if (xmlString.length == 0) {
        return nil;
    }
    RXMLElement *product = [rootElement child:@"Product"];
    NSArray *SmartVisitions = [product children:@"SmartVisition"];
    for (RXMLElement *element in SmartVisitions) {
        if ([[element attribute:@"Type"] isEqualToString:mainType]) {
            NSArray *ScanningFrames = [element children:@"ScanningFrame"];
            for (RXMLElement *element in ScanningFrames) {
                SubType *subtype = [[SubType alloc] init];
                subtype.type = [element attribute:@"Type"];
                subtype.name = [element attribute:@"name"];
                subtype.OCRId = [element attribute:@"ocrId"];
                [subDataSource addObject:subtype];
            }
        }
    }

    return subDataSource;
}

@end
