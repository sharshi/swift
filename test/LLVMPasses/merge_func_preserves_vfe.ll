; RUN: %swift-llvm-opt -swift-merge-functions -swiftmergefunc-threshold=2 %s | %FileCheck %s

@g1 = external global i1
@g2 = external global i1
@g3 = external global i1

declare { i8*, i1 } @llvm.type.checked.load(i8*, i32, metadata)

define i1 @merge_candidate_a(i8* %ptr, i32 %offset) {
    %1 = call { i8*, i1 } @llvm.type.checked.load(i8* %ptr, i32 %offset, metadata !"common_metadata")
    %2 = extractvalue { i8*, i1 } %1, 1
    %3 = load i1, i1* @g1
    %4 = and i1 %2, %3
    ret i1 %4
}

define i1 @merge_candidate_b(i8* %ptr, i32 %offset) {
    %1 = call { i8*, i1 } @llvm.type.checked.load(i8* %ptr, i32 %offset, metadata !"common_metadata")
    %2 = extractvalue { i8*, i1 } %1, 1
    %3 = load i1, i1* @g2
    %4 = and i1 %2, %3
    ret i1 %4
}
; CHECK-LABEL: @merge_candidate_b
; CHECK: call i1 @merge_candidate_aTm
; CHECK: ret

define i1 @merge_candidate_c(i8* %ptr, i32 %offset) {
    %1 = call { i8*, i1 } @llvm.type.checked.load(i8* %ptr, i32 %offset, metadata !"different_metadata")
    %2 = extractvalue { i8*, i1 } %1, 1
    %3 = load i1, i1* @g3
    %4 = and i1 %2, %3
    ret i1 %4
}
; CHECK-LABEL: @merge_candidate_c
; CHECK-NOT: call i1 @merge_candidate_aTm
; CHECK: ret
