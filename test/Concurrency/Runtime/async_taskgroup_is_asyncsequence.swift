// RUN: %target-run-simple-swift(-Xfrontend -enable-experimental-concurrency %import-libdispatch -parse-as-library) | %FileCheck %s --dump-input=always

// REQUIRES: executable_test
// REQUIRES: concurrency
// REQUIRES: libdispatch
// FIXME: unlock on other OSes
// REQUIRES: OS=macosx
// REQUIRES: CPU=x86_64

import Dispatch

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

func test_taskGroup_is_asyncSequence() async {
  let sum: Int = try! await Task.withGroup(resultType: Int.self) { group in
    for n in 1...10 {
      await group.add {
        print("add \(n)")
        return n
      }
    }

    var sum = 0
    for try await r in group { // here
      print("next: \(r)")
      sum += r
    }

    return sum
  }

  // CHECK: result: 55
  print("result: \(sum)")
}

@main struct Main {
  static func main()

async {
  await test_taskGroup_is_asyncSequence()
}

}
