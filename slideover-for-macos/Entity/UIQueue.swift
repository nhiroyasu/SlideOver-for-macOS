import Foundation

/// @mockable
protocol UIQueue {
    func mainAsync(execute work: @escaping () -> Void)
    func mainAsyncAfter(deadline: DispatchTime, execute work: @escaping () -> Void)
}

extension DispatchQueue: UIQueue {
    func mainAsync(execute work: @escaping () -> Void) {
        DispatchQueue.main.async {
            work()
        }
    }
    
    func mainAsyncAfter(deadline: DispatchTime, execute work: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            work()
        }
    }
}
