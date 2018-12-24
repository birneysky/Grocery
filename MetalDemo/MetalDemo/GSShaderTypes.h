//
//  GSShaderTypes.h
//  MetalDemo
//
//  Created by birney on 2018/12/24.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#ifndef GSShaderTypes_h
#define GSShaderTypes_h

#include <simd/simd.h>

typedef enum GSVertexInputIndex
{
    GSVertexInputIndexVertices = 0,
    GSVertexInputIndexCount    = 1,
} GSVertexInputIndex;

typedef struct
{
    vector_float2 position;
    vector_float4 color;
} GSVertex;

#endif /* GSShaderTypes_h */
