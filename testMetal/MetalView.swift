import MetalKit

struct Vertex {
    var position: vector_float4
    var pointSize: Float
    var color: vector_float4
}

struct Poi {
    var x: float_t
    var y: float_t
    var lf: UInt32
}

class MetalView: MTKView {
    
    let startTime = Date()
    
    var points = Array<Poi>()
//    let device = MTLCreateSystemDefaultDevice()!
    private var renderPipeline: MTLRenderPipelineState!
    private let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
//    private var renderPipelineState: MTLRenderPipelineState!

    public func setup() {
        self.device = MTLCreateSystemDefaultDevice()
        guard let library = self.device?.makeDefaultLibrary() else {
            NSLog("Failed to create library")
            return
        }
        let vertexFunction = library.makeFunction(name: "vertex_func")
        let fragmentFunction = library.makeFunction(name: "fragment_func")
        self.renderPipelineDescriptor.vertexFunction = vertexFunction
        self.renderPipelineDescriptor.fragmentFunction = fragmentFunction
        self.renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm


    }

    public func setPoint(init ini: Bool) -> Poi {
        var lf: UInt32!
        if ini {
            lf = arc4random_uniform(1000)
        } else {
            lf = 300
        }
        var tmp = arc4random_uniform(200)
        let x = Float(tmp) / 100.0 - 1.0
        tmp = arc4random_uniform(200)
        let y = Float(tmp) / 100.0 - 1.0
        return Poi(x: x, y: y, lf: lf)
    }
    
    public func setPoints() {
        let x_count = 20
        let y_count = 20
        for _ in 0..<Int(x_count) {
            for _ in 0..<Int(y_count) {
                points.append(setPoint(init: true))
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let renderPassDescriptor = self.currentRenderPassDescriptor, let drawable = self.currentDrawable else {
            return
        }

        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.8, 0.8, 0.8, 0.1)
        let commandBuffer = device?.makeCommandQueue()?.makeCommandBuffer()
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            
        for i in 0..<points.count {
            points[i].lf += 1
            
            if points[i].lf < 300 {
                continue
            } else if (points[i].lf > 1000) {
                points[i] = setPoint(init: false)
            }
            points[i].x = points[i].x + 0.002
            points[i].y = points[i].y + 0.004

            var vertexData = [Vertex(position: [points[i].x, points[i].y, 0.0, 1.0], pointSize: Float(10.0), color: [0.4, 0.4, 0.4, 1]),]
            print(points[i].lf)
//            var vertexData = [Vertex(position: [points[i].x-1.0, points[i].y-1.0, 0.0, 1.0], color: [1, 0, 0, 1]),
//                              Vertex(position: [ points[i].x-0.9, points[i].y-1, 0.0, 1.0], color: [0, 1, 0, 1]),
//                              Vertex(position: [points[i].x-0.95,  points[i].y-0.95, 0.0, 1.0], color: [0, 0, 1, 1]),]

            let vertexBuffer = device?.makeBuffer(bytes: vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, options:[])

            do {
                let renderPipelineState = try self.device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
                renderCommandEncoder?.setRenderPipelineState(renderPipelineState!)
                renderCommandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//                renderCommandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
                renderCommandEncoder?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 3, instanceCount: 1)
            } catch let error {
                NSLog("\(error)")
            }

        }
        renderCommandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
