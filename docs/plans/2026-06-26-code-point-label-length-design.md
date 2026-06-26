# Code-Point Vendor-Label Length Design

Status: Completed

## Problem

Battery labels are validated by Unicode code point, but the 80-character bound
uses `String.length()`. Supplementary-plane characters occupy two UTF-16 code
units, so an otherwise valid label can be rejected before the code-point scan.

## Options

1. Keep UTF-16 code-unit length as the bound.
2. Call `codePointCount` before the existing scan, adding a second traversal.
3. Count code points inside the existing validation loop and fail after 80.

## Decision

Use option 3. It aligns the length boundary with the existing code-point
security scan in one pass and preserves Java 7 compatibility.
