import Benchmark
import ZippyJSONBenchmark_Library

extension BenchmarkSuite {
    func benchmark(
        name: String,
        run: @escaping () throws -> Void,
        setup: @escaping () -> Void = { },
        teardown: @escaping () -> Void = {}
    ) {
        return self.register(benchmark: Benchmarking(name: name, run: run, setup: setup, teardown: teardown))
        
    }
}

struct Benchmarking: AnyBenchmark {
    func setUp() {
        self._setup()
    }
    
    func run(_ state: inout Benchmark.BenchmarkState) throws {
        try self._run()
    }
    
    func tearDown() {
        self._teardown()
    }
    
    let name: String
    let settings: [BenchmarkSetting] = []
    private let _run: () throws -> Void
    private let _setup: () -> Void
    private let _teardown: () -> Void
    
    init(
        name: String,
        run: @escaping () throws -> Void,
        setup: @escaping () -> Void,
        teardown: @escaping () -> Void
    ) {
        self.name = name
        self._run = run
        self._setup = setup
        self._teardown = teardown
    }
}
