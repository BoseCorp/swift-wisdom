import XCTest
import RxSwift
import RxCocoa
@testable import SwiftWisdom


class OperatorTests: XCTestCase {

    func testBehaviorRelayBinding() {
        let disposeBag = DisposeBag()
        let label = UILabel()
        let relay = BehaviorRelay<String?>(value: nil)

        label.rx.text <- relay >>> disposeBag
        XCTAssertEqual(nil, label.text)

        relay.accept("hello")
        XCTAssertEqual("hello", label.text)

        relay.accept(nil)
        XCTAssertEqual(nil, label.text)
    }

    func testNonOptionalBehaviorRelayBindingToOptionalObserver() {
        let disposeBag = DisposeBag()
        let label = UILabel()
        let relay = BehaviorRelay<String>(value: "")

        label.rx.text <- relay >>> disposeBag
        XCTAssertEqual("", label.text)

        relay.accept("hello")
        XCTAssertEqual("hello", label.text)
    }

    func testObserverBinding() {
        let disposeBag = DisposeBag()
        let button = UIButton()
        let observable = Observable<String?>.just("hello")
        XCTAssertEqual(nil, button.title(for: .normal))
        button.rx.title(for: .normal) <- observable >>> disposeBag
        XCTAssertEqual("hello", button.title(for: .normal))
    }

    func testAddCompositeDisposable() {
        let compositeDisposable = CompositeDisposable()
        let observable = Observable<String?>.never()
        XCTAssertEqual(0, compositeDisposable.count)
        UILabel().rx.text <- observable >>> compositeDisposable
        XCTAssertEqual(1, compositeDisposable.count)
    }
    
    func testBindingToBehaviorRelay() {
        let disposeBag = DisposeBag()
        let sut = BehaviorRelay<String>(value: "")
        let behaviorRelay = BehaviorRelay<String>(value: "hello")

        sut <- behaviorRelay >>> disposeBag
        XCTAssertEqual(behaviorRelay.value, sut.value)
        XCTAssertEqual("hello", sut.value)

        behaviorRelay.accept("world")
        XCTAssertEqual(behaviorRelay.value, sut.value)
    }
    
    func testTwoWayBindingWithBehaviorRelay() {
        let disposeBag = DisposeBag()
        let textField = UITextField()
        let behaviorRelay = BehaviorRelay<String?>(value: nil)

        textField.rx.text <-> behaviorRelay >>> disposeBag
        behaviorRelay.accept("hello")
        XCTAssertEqual("hello", textField.text)
        
        textField.text = "world"
        textField.sendActions(for: .editingChanged)
        XCTAssertEqual("world", behaviorRelay.value)
    }

}
