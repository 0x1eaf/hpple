//
//  TFHppleElement.m
//  Hpple
//
//  Created by Geoffrey Grosenbach on 1/31/09.
//
//  Copyright (c) 2009 Topfunky Corporation, http://topfunky.com
//  Copyright (c) 2016 Hpple authors and contributors, see AUTHORS file
//  for more details.
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


#import "TFHppleElement.h"
#import "TFHpple.h"
#import <libxml/tree.h>

@interface TFHpple (PrivateMethods)

- (NSArray *)performQuery:(NSString *)query fromNode:(xmlNodePtr)node;

@end


@interface TFHppleElement () {
    xmlNodePtr _node;
}

@property (nonatomic, readonly) TFHpple *document;

@end


@implementation TFHppleElement

- (instancetype)initWithNode:(void *)node document:(TFHpple *)document {
    self = [super init];
    if (self) {
        _node = node;
        _document = document;
    }
    return self;
}

#pragma mark -

- (NSString *)raw {
    xmlBufferPtr buffer = xmlBufferCreate();
    xmlNodeDump(buffer, _node->doc, _node, 0, 0);
    NSString *rawContent = [NSString stringWithUTF8String:(const char *)buffer->content];
    xmlBufferFree(buffer);
    return rawContent;
}

- (NSString *)content {
    NSString *content = nil;
    xmlChar *nodeContent = xmlNodeGetContent(_node);
    if (nodeContent) {
        content = [NSString stringWithUTF8String:(const char *)nodeContent];
        xmlFree(nodeContent);
    }
    return content;
}

- (NSString *)tagName {
    return _node->name ? [NSString stringWithUTF8String:(const char *)_node->name] : nil;
}

- (NSArray *)children {
    NSMutableArray *children = [NSMutableArray array];
    xmlNodePtr childNode = _node->children;
    while (childNode) {
        [children addObject:[[TFHppleElement alloc] initWithNode:childNode document:self.document]];
        childNode = childNode->next;
    }
    return children.count > 0 ? children : nil; // fixme?
}

- (TFHppleElement *)firstChild {
    return self.children.firstObject;
}

- (NSDictionary *)attributes {
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    [self enumerateAttributesUsingBlock:^(NSString *name, NSString *value) {
        [attributes setObject:(value ?: [NSNull null]) forKey:name];
    }];
    return attributes;
}

- (void)enumerateAttributesUsingBlock:(void (^)(NSString *, NSString *))block {
    xmlAttr *attribute = _node->properties;
    while (attribute) {
        block([NSString stringWithUTF8String:(const char *)attribute->name], [self attributeWithName:attribute->name]);
        attribute = attribute->next;
    }
}

- (NSString *)attributeWithName:(const xmlChar *)name {
    xmlChar *value = xmlGetProp(_node, name);
    NSString *object = value ? [NSString stringWithUTF8String:(const char *)value] : nil;
    if (value) {
        xmlFree(value);
    }
    return object;
}

- (NSString *)objectForKey:(NSString *)key {
    return [self attributeWithName:(xmlChar *)key.UTF8String];
}

- (id)description {
    return [super description]; // FIXME!
}

- (BOOL)hasChildren {
    return _node->children != NULL;
}

- (BOOL)isTextNode {
    return xmlNodeIsText(_node);
}

- (TFHppleElement *)parent {
    return _node->parent ? [[TFHppleElement alloc] initWithNode:_node->parent document:self.document] : nil;
}

- (NSArray *)childrenWithTagName:(NSString *)tagName {
    NSMutableArray *matches = [NSMutableArray array];
    for (TFHppleElement *child in self.children) {
        if ([child.tagName isEqualToString:tagName]) {
            [matches addObject:child];
        }
    }
    return matches;
}

- (TFHppleElement *)firstChildWithTagName:(NSString *)tagName {
    for (TFHppleElement *child in self.children) {
        if ([child.tagName isEqualToString:tagName]) {
            return child;
        }
    }
    return nil;
}

- (NSArray *)childrenWithClassName:(NSString *)className {
    NSMutableArray *matches = [NSMutableArray array];
    for (TFHppleElement *child in self.children) {
        if ([[child objectForKey:@"class"] isEqualToString:className]) {
            [matches addObject:child];
        }
    }
    return matches;
}

- (TFHppleElement *)firstChildWithClassName:(NSString *)className {
    for (TFHppleElement *child in self.children) {
        if ([[child objectForKey:@"class"] isEqualToString:className]) {
            return child;
        }
    }
    return nil;
}

- (TFHppleElement *)firstTextChild {
    for (TFHppleElement *child in self.children) {
        if ([child isTextNode]) {
            return child;
        }
    }
    return nil;
}

- (NSString *)text {
    return self.firstTextChild.content;
}

// Returns all elements at xPath.
- (NSArray *)searchWithXPathQuery:(NSString *)xPathOrCSS {
    return [self.document performQuery:xPathOrCSS fromNode:_node];
}

// Custom keyed subscripting
- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

@end
