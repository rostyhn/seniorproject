//
//  Renderer.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 10/27/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import Foundation
import MetalKit
import ModelIO
import simd
 
struct Uniforms {
    var modelViewMatrix: float4x4
    var projectionMatrix: float4x4
}

struct FractalUniforms {
    var iTime: Float
}


class Renderer: NSObject, MTKViewDelegate
{
    let device: MTLDevice
    let mtkView: MTKView
    let depthStencilState: MTLDepthStencilState
    var vertexDescriptor: MTLVertexDescriptor!
    var meshes: [MTKMesh] = []
    var renderPipeline: MTLRenderPipelineState!
    var computePipeline: MTLComputePipelineState!
    let commandQueue: MTLCommandQueue
    var time: Float = 0
    var mode: Int //tells the renderer to either render the about screen scene or the main menu scene;
                  //0 - Main 1 - About
    var cameraWorldPosition = SIMD3<Float>(0,0,5)
    var vertexFunction : MTLFunction?
    var fragmentFunction : MTLFunction?
    var inputBuffer : MTLBuffer?
    
    
    
    init(view: MTKView, device: MTLDevice, mode: Int)
    {
        self.mtkView = view
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.depthStencilState = Renderer.buildDepthStencilState(device: device)
        self.mode = mode
        super.init()
        if(self.mode == 0)
        {
            loadResources()
        }
        buildPipeline()
    }
    
    func buildPipeline()
    {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Could not load default library from main bundle")
        }

        //set shaders here
        if(self.mode == 0)
        {
            vertexFunction = library.makeFunction(name: "vertex_main")
            fragmentFunction = library.makeFunction(name: "fragment_main")
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            
            pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
            pipelineDescriptor.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
            pipelineDescriptor.vertexDescriptor = vertexDescriptor
            do {
                renderPipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                fatalError("Could not create render pipeline state object: \(error)")
            }
        }
        else
        {
            let kernel = library.makeFunction(name: "compute")
            self.inputBuffer = device.makeBuffer(length: MemoryLayout<Float>.size, options: [])
            computePipeline = try! device.makeComputePipelineState(function: kernel!)
            
        }
    }
    
    func loadResources()
    {
        let modelURL = Bundle.main.url(forResource: "brain-simple-mesh", withExtension: "obj")!
        
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: MemoryLayout<Float>.size * 3, bufferIndex: 0)
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: MemoryLayout<Float>.size * 6, bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<Float>.size * 8)
        self.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        
        let bufferAllocator = MTKMeshBufferAllocator(device: device)
        let asset = MDLAsset(url: modelURL, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
        
        do {
            (_, meshes) = try MTKMesh.newMeshes(asset: asset, device: device)
        } catch {
            fatalError("Could not extract meshes from Model I/O asset")
        }
        
    }
    
    static func buildDepthStencilState(device: MTLDevice) -> MTLDepthStencilState {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        return device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //<#code#>
    }
    
    func draw(in view: MTKView) {
        if(self.mode == 0)
        {
            let commandBuffer = commandQueue.makeCommandBuffer()!
        if let renderPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            commandEncoder.setDepthStencilState(depthStencilState)
            time += 1 / Float(mtkView.preferredFramesPerSecond)
            var scale = Float(0.5)
            
            let angle = -time
            let modelMatrix = float4x4(rotationAbout: SIMD3<Float>(0, 1, 0), by: angle) *  float4x4(scaleBy: scale)

            let viewMatrix = float4x4(translationBy: -cameraWorldPosition)
            let modelViewMatrix = viewMatrix * modelMatrix
            
            
            let aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
            let projectionMatrix = float4x4(perspectiveProjectionFov: Float.pi / 3, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100)
            
            var uniforms = Uniforms(modelViewMatrix: modelViewMatrix, projectionMatrix: projectionMatrix)
            
            commandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 1)
            
            commandEncoder.setRenderPipelineState(renderPipeline)
            
            for mesh in meshes {
                let vertexBuffer = mesh.vertexBuffers.first!
                commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)
                
                for submesh in mesh.submeshes {
                    let indexBuffer = submesh.indexBuffer
                    commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                         indexCount: submesh.indexCount,
                                                         indexType: submesh.indexType,
                                                         indexBuffer: indexBuffer.buffer,
                                                         indexBufferOffset: indexBuffer.offset)
                }
            }
            commandEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            
            commandBuffer.commit()
        }
    }
    else
        {
             if let drawable = view.currentDrawable
             {
                 time += Float(1.0/60.0)
                
                 //input
                 let inputBufferPtr = inputBuffer!.contents().bindMemory(to: Float.self, capacity: 1)
                 inputBufferPtr.pointee = Float(time)
                 
                
                 guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
                 guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
                 commandEncoder.setComputePipelineState(computePipeline)
                 commandEncoder.setTexture(drawable.texture, index: 0)
                 commandEncoder.setBuffer(inputBuffer, offset: 0, index: 0)
                 let w = computePipeline.threadExecutionWidth
                 let h = computePipeline.maxTotalThreadsPerThreadgroup / w;
                 let threadGroupCount = MTLSizeMake(w, h, 1)
                 let threadGroups = MTLSizeMake((drawable.texture.width + w - 1) / w,
                                            (drawable.texture.height + h - 1) / h,
                                            1)
                 commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
                 commandEncoder.endEncoding()
                 commandBuffer.present(drawable)
                 commandBuffer.commit()
             }
        }
        
    }
}
