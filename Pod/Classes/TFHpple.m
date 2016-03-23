//
//  TFHpple.m
//  Hpple
//
//  Created by Geoffrey Grosenbach on 1/31/09.
//
//  Copyright (c) 2009 Topfunky Corporation, http://topfunky.com
//
//  MIT LICENSE
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TFHpple.h"
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLtree.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>


@implementation TFHpple {
@private
    xmlDocPtr _document;
    xmlXPathContextPtr _context;
}

- (id)initWithData:(NSData *)data encoding:(NSString *)encoding isXML:(BOOL)isXML {
    self = [super init];
    if (self) {
        _data = data;
        _encoding = encoding;
        _xml = isXML;

        if (isXML) {
            _document = xmlReadMemory(data.bytes, (int)data.length, "", encoding.UTF8String, XML_PARSE_RECOVER);
        } else {
            _document = htmlReadMemory(data.bytes, (int)data.length, "", encoding.UTF8String, HTML_PARSE_RECOVER | HTML_PARSE_NODEFDTD | HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
        }
        if (!_document) {
            NSLog(@"Unable to parse."); // FIXME!
            return nil;
        }

        /* Create xpath evaluation context */
        _context = xmlXPathNewContext(_document);
        if(_context == NULL) {
            NSLog(@"Unable to create XPath context."); // FIXME!
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    xmlXPathFreeContext(_context);
    xmlFreeDoc(_document);
}

- (instancetype)initWithData:(NSData *)data isXML:(BOOL)isXML {
    return [self initWithData:data encoding:nil isXML:isXML];
}

- (instancetype)initWithXMLData:(NSData *)data encoding:(NSString *)encoding {
    return [self initWithData:data encoding:encoding isXML:YES];
}

- (instancetype)initWithXMLData:(NSData *)data {
    return [self initWithData:data encoding:nil isXML:YES];
}

- (instancetype)initWithHTMLData:(NSData *)data encoding:(NSString *)encoding {
    return [self initWithData:data encoding:encoding isXML:NO];
}

- (instancetype)initWithHTMLData:(NSData *)data {
    return [self initWithData:data encoding:nil isXML:NO];
}

+ (instancetype)hppleWithData:(NSData *)data encoding:(NSString *)encoding isXML:(BOOL)isXML {
    return [[self alloc] initWithData:data encoding:encoding isXML:isXML];
}

+ (instancetype)hppleWithData:(NSData *)data isXML:(BOOL)isXML {
    return [self hppleWithData:data encoding:nil isXML:isXML];
}

+ (instancetype)hppleWithHTMLData:(NSData *)data encoding:(NSString *)encoding {
    return [self hppleWithData:data encoding:encoding isXML:NO];
}

+ (instancetype)hppleWithHTMLData:(NSData *)data {
    return [self hppleWithData:data encoding:nil isXML:NO];
}

+ (instancetype)hppleWithXMLData:(NSData *)data encoding:(NSString *)encoding {
    return [self hppleWithData:data encoding:encoding isXML:YES];
}

+ (instancetype)hppleWithXMLData:(NSData *)data {
    return [[self class] hppleWithData:data encoding:nil isXML:YES];
}

#pragma mark -

- (NSString *)doctype {
    NSString *doctype = nil;
    if (_document->intSubset) {
        xmlBufferPtr buffer = xmlBufferCreate();
        xmlDtd *dtd = _document->intSubset;
        xmlNodeDump(buffer, dtd->doc, (xmlNodePtr)dtd, 0, 0);
        doctype = [NSString stringWithUTF8String:(const char *)buffer->content];
        xmlBufferFree(buffer);
    }
    return doctype;
}

- (BOOL)isXHTML {
    if (!self.xml) {
        TFHppleElement *root = [[TFHppleElement alloc] initWithNode:xmlDocGetRootElement(_document) document:self];
        return [root.tagName.lowercaseString isEqualToString:@"html"] &&
               [[[root objectForKey:@"xmlns"] lowercaseString] isEqualToString:@"http://www.w3.org/1999/xhtml"];
    }
    return NO;
}

// Returns all elements at xPath.
- (NSArray *)searchWithXPathQuery:(NSString *)xPathOrCSS {
    return [self performQuery:xPathOrCSS fromNode:xmlDocGetRootElement(_document)];
}

// Returns first element at xPath
- (TFHppleElement *)peekAtSearchWithXPathQuery:(NSString *)xPathOrCSS {
    return [self searchWithXPathQuery:xPathOrCSS].firstObject;
}

#pragma mark - Private Methods

- (NSArray *)performQuery:(NSString *)query fromNode:(xmlNodePtr)node {
    NSParameterAssert(query);
    if (!query) {
        return nil; // FIXME! (Should raise)
    }

    /* Evaluate xpath expression */
    //xmlXPathObjectPtr xpathObj = xmlXPathEvalExpression((xmlChar *)query.UTF8String, _context);
    xmlXPathObjectPtr xpathObj = xmlXPathNodeEval(node, (xmlChar *)query.UTF8String, _context);
    if(xpathObj == NULL) {
        NSLog(@"Unable to evaluate XPath.");
        return nil;
    }

    xmlNodeSetPtr nodes = xpathObj->nodesetval;
    if (!nodes) {
        NSLog(@"Nodes was nil.");
        xmlXPathFreeObject(xpathObj);
        return nil;
    }

    NSMutableArray *resultNodes = [NSMutableArray array];
    for (NSInteger index = 0; index < nodes->nodeNr; index++) {
        [resultNodes addObject:[[TFHppleElement alloc] initWithNode:nodes->nodeTab[index] document:self]];

    }
    
    /* Cleanup */
    xmlXPathFreeObject(xpathObj);

    return resultNodes;
}

@end
