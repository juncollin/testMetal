import MetalKit

struct Vertex {
    var position: vector_float4
    var color: vector_float4
}

struct Poi {
    var x: float_t
    var y: float_t
}

class MetalView: MTKView {
    
    let startTime = Date()
    
    var points = Array<Poi>()
    
    public func setPoints() {
        let poi = Poi(x: 0.1, y: 0.1)
        points.append(poi)
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let nowTime = Date()
//        let dif = (Float)(nowTime.timeIntervalSince(startTime) / 10.0)
        
        self.device = MTLCreateSystemDefaultDevice()
        guard let device = self.device else {
            NSLog("Failed to create Metal device")
            return
        }
        
        // TODO: 速度ベクトルを計算
        
        points[0].x = points[0].x + 0.0001
        points[0].y = points[0].y + 0.001

        
        let vertexData = [Vertex(position: [points[0].x-0.1, points[0].y, 0.0, 1.0], color: [1, 0, 0, 1]),
                          Vertex(position: [ points[0].x, points[0].y, 0.0, 1.0], color: [0, 1, 0, 1]),
                          Vertex(position: [points[0].x-0.05,  points[0].y + 0.05, 0.0, 1.0], color: [0, 0, 1, 1]),]
        let vertexBuffer = device.makeBuffer(bytes: vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, options:[])
        
        guard let library = device.makeDefaultLibrary() else {
            NSLog("Failed to create library")
            return
        }
        let vertexFunction = library.makeFunction(name: "vertex_func")
        let fragmentFunction = library.makeFunction(name: "fragment_func")
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            let renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
            guard let renderPassDescriptor = self.currentRenderPassDescriptor, let drawable = self.currentDrawable else {
                return
            }
            
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.7, 0, 1.0)
            let commandBuffer = device.makeCommandQueue()?.makeCommandBuffer()
            let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            renderCommandEncoder?.setRenderPipelineState(renderPipelineState)
            
            
            
            renderCommandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderCommandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
            renderCommandEncoder?.endEncoding()
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        } catch let error {
            NSLog("\(error)")
        }
    }
}
