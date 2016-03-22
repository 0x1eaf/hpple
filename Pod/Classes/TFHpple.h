//
//  TFHpple.h
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

#import "TFHppleElement.h"


@interface TFHpple : NSObject

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSString *encoding;
@property (nonatomic, readonly, getter=isXML) BOOL xml;

@property (nonatomic, readonly) NSString *doctype;

- (instancetype)initWithData:(NSData *)data encoding:(NSString *)encoding isXML:(BOOL)isXML;
- (instancetype)initWithData:(NSData *)data isXML:(BOOL)isXML;
- (instancetype)initWithXMLData:(NSData *)data encoding:(NSString *)encoding;
- (instancetype)initWithXMLData:(NSData *)data;
- (instancetype)initWithHTMLData:(NSData *)data encoding:(NSString *)encoding;
- (instancetype)initWithHTMLData:(NSData *)data;

+ (instancetype)hppleWithData:(NSData *)data encoding:(NSString *)encoding isXML:(BOOL)isXML;
+ (instancetype)hppleWithData:(NSData *)data isXML:(BOOL)isXML;
+ (instancetype)hppleWithXMLData:(NSData *)data encoding:(NSString *)encoding;
+ (instancetype)hppleWithXMLData:(NSData *)data;
+ (instancetype)hppleWithHTMLData:(NSData *)data encoding:(NSString *)encoding;
+ (instancetype)hppleWithHTMLData:(NSData *)data;

- (NSArray *)searchWithXPathQuery:(NSString *)xPathOrCSS;
- (TFHppleElement *)peekAtSearchWithXPathQuery:(NSString *)xPathOrCSS;

@end
