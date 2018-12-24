//
//  GSMetalView.swift
//  MetalDemo
//
//  Created by birney on 2018/12/24.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

import UIKit

class GSMetalView: UIView {

    
    /// MTLDevice 对象代表一个可以执行指令的 GPU. MTLDevice 协议提供了查询设备功能、创建 Metal 其他对象等方法
    var device: MTLDevice!
    
    /// 即一个管理队列，由 Device 创建。它持有一串需要被执行的 Command Buffer， Command Buffer 由 Command Queue 创建，它又包含多个特定的 Command Encoder 。
    var commonQueue: MTLCommandQueue!
    
    var pipelineState: MTLRenderPipelineState!
    
    override class var layerClass : AnyClass {
        return CAMetalLayer.self;
    }
    
    var metalLayer: CAMetalLayer {
        return layer as! CAMetalLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        render()
    }
    
    func setup() {
        
        device = MTLCreateSystemDefaultDevice()
        commonQueue = device?.makeCommandQueue()
        setupPipeline()
    }
    
    func setupPipeline()  {
        let library = device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: "vertexShader")
        let fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalLayer.pixelFormat
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func render() {
        /// 取到当前需要用于显示的 drawable 对象。
        guard let drawable = metalLayer.nextDrawable() else {
            return
        }
        
        /*
                给 GPU 下发对应的指令，渲染管线才能有序的进行工作，
                而具体的指令，在 Metal 中则是通过 MTLCommandEncoder
                (渲染相关的，具体是 MTLRenderCommandEncoder）来体现。
         
                为了生成 MTLRenderCommandEncoder，需要依赖 MTLRenderPassDescriptor
                render pass 是一个渲染过程的描述，包含了一组附件（attachment）的集合。
                所谓的 attachment，可以简单理解成渲染操作要应用到的渲染目标，比如我们要渲染到的纹理。
                常见的附件有：
                    colorAttachments，用于写入颜色数据
                    depthAttachment，用于写入深度信息
                    stencilAttachment，允许我们基于一些条件丢弃指定片段
                目前我们只要关心 colorAttachments。

                TLRenderPassDescriptor 还可以告诉 Metal 在一个渲染的过程中需要做什么动作，
                可配置的属性也比较多，我们目前关心的只有：
                    texture：关联的纹理，即渲染目标。必须设置，不然内容不知道要渲染到哪里。不设置会报错：failed assertion `No rendertargets set in RenderPassDescriptor.'
                    loadAction：决定前一次 texture 的内容需要清除、还是保留
                    storeAction：决定这次渲染的内容需要存储、还是丢弃
                    clearColor：当 loadAction 是 MTLLoadActionClear 时，则会使用对应的颜色来覆盖当前 texture（用某一色值逐像素写入）
                */
        let renderPassDescripor = MTLRenderPassDescriptor()
        renderPassDescripor.colorAttachments[0].clearColor = MTLClearColorMake(0.48, 0.74, 0.92, 1)
        renderPassDescripor.colorAttachments[0].texture = drawable.texture
        renderPassDescripor.colorAttachments[0].loadAction = .clear
        renderPassDescripor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commonQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescripor)!
        commandEncoder.setRenderPipelineState(pipelineState)
        let vertices = [GSVertex(position: [ 0.5, -0.5], color: [1, 0, 0, 1]),
                        GSVertex(position: [-0.8, -0.5], color: [0, 1, 0, 1]),
                        GSVertex(position: [ 0.0,  0.5], color: [0, 0, 1, 1])]
        commandEncoder.setVertexBytes(vertices, length: MemoryLayout<GSVertex>.size * 3, index: Int(GSVertexInputIndexVertices.rawValue))
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

}
