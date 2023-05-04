import Benchmark
import ZippyJSONBenchmark_Library

let shopAppleBenchmarkSuite = BenchmarkSuite(name: "Apple Decoder") { suite in
    suite.benchmark(name: "Decode shop info") {
        ZippyJSONBenchmark.decodeShopApple()
    }
}

let shopZippyBenchmarkSuite = BenchmarkSuite(name: "Zippy Decoder") { suite in
    suite.benchmark(name: "Decode shop info") {
        ZippyJSONBenchmark.decodeShopZippy()
    }
}

let pdpAppleBenchmarkSuite = BenchmarkSuite(name: "Apple Decoder") { suite in
    suite.benchmark(name: "Decode PDPSecondPriority") {
        ZippyJSONBenchmark.decodePDPApple()
    }
}

let pdpZippyBenchmarkSuite = BenchmarkSuite(name: "Zippy Decoder") { suite in
    suite.benchmark(name: "Decode PDPSecondPriority") {
        ZippyJSONBenchmark.decodePDPZippy()
    }
}
