import UIKit

class AnalyticsViewController: UIViewController {
    
    private let viewModel: AnalyticsModelInterface
    
    init(viewModel: AnalyticsModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var testLogButton = Button(
        title: "Log test event",
        color: .systemBlue,
        action: viewModel.logTestEvent
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    private func configureView() {
        view.backgroundColor = .systemBackground
        configureTestButton()
    }
    
    private func configureTestButton() {
        view.addSubview(testLogButton)
        NSLayoutConstraint.activate([
            testLogButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            testLogButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            testLogButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0)
        ])
    }
}