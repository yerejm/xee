//
//  File.swift
//  Xee
//
//  Created by C.W. Betts on 3/8/17.
//
//

import Cocoa

extension XeeTransformation {
	var isFlipped: Bool {
		return XeeTransformationIsFlipped(self)
	}
	
	var isNonTrivial: Bool {
		return XeeTransformationIsNonTrivial(self)
	}
	
	var inverse: XeeTransformation {
		return XeeInverseOfTransformation(self)
	}
	
	func combine(with: XeeTransformation) -> XeeTransformation {
		return XeeCombineTransformations(self, with)
	}
	
	func matrixWith(width: Float, height: Float) -> XeeMatrix {
		return XeeMatrixForTransformation(self, width, height)
	}
}


func *(lhs: XeeMatrix, rhs: XeeMatrix) -> XeeMatrix {
	return XeeMultiplyMatrices(lhs, rhs)
}

prefix func -(val: XeeMatrix) -> XeeMatrix {
	return XeeInverseMatrix(val)
}

extension XeeMatrix {
	func transform(point: NSPoint) -> NSPoint {
		return XeeTransformPoint(self, point)
	}
	
	func transform(rect: NSRect) -> NSRect {
		return XeeTransformRect(self, rect)
	}
	
	init(scaleMatrixWithX x: Float, y: Float) {
		self = XeeScaleMatrix(x, y)
	}
	
	init(translateMatrixWithX x: Float, y: Float) {
		self = XeeTranslationMatrix(x, y)
	}
	
	init(TransformRect r1: NSRect, _ r2: NSRect) {
		self = XeeTransformRectToRectMatrix(r1, r2)
	}


	mutating func inverse() {
		self = self.formInverse
	}
	
	var formInverse: XeeMatrix {
		return XeeInverseMatrix(self)
	}
}

public func ==(lhs: XeeSpan, rhs: XeeSpan) -> Bool {
	return XeeSpansIdentical(lhs, rhs)
}

extension XeeSpan: Equatable {
	var end: CInt {
		return XeeSpanEnd(self)
	}
	
	var isEmpty: Bool {
		return XeeSpanEmpty(self)
	}
	
	func contains(point: CInt) -> Bool {
		return XeePointInSpan(point, self)
	}
	
	/*
XeeSpan XeeSpanDifference(XeeSpan old,XeeSpan new);
*/
	func union(_ span1: XeeSpan) -> XeeSpan {
		return XeeSpanUnion(self, span1)
	}
	
	mutating func formUnion(_ span2: XeeSpan) {
		self = XeeSpanUnion(self, span2)
	}
	
	func intersection(_ span1: XeeSpan) -> XeeSpan {
		return XeeSpanIntersection(self, span1)
	}
	
	mutating func formIntersection(_ span1: XeeSpan) {
		self = XeeSpanIntersection(self, span1)
	}

	/*
	static inline int XeeSpanPastEnd(XeeSpan span) { return span.start+span.length; }
	static inline BOOL XeePointInSpan(int point,XeeSpan span) { return point>=XeeSpanStart(span)&&point<XeeSpanPastEnd(span); }
	static inline BOOL XeeSpanStartsInSpan(XeeSpan span,XeeSpan inspan) { return XeePointInSpan(XeeSpanStart(span),inspan); }
	static inline BOOL XeeSpanEndsInSpan(XeeSpan span,XeeSpan inspan) { return XeePointInSpan(XeeSpanEnd(span),inspan); }
	static inline XeeSpan XeeSpanShifted(XeeSpan span,int offset) { return XeeMakeSpan(XeeSpanStart(span)+offset,XeeSpanLength(span)); }
	*/
	
}

