import Foundation
import RxSwift
import RxDataSources
import Action

typealias TaskSection = AnimatableSectionModel<String, TaskItem>

struct TasksViewModel {
  let sceneCoordinator: SceneCoordinatorType
  let taskService: TaskServiceType

  // Challenge 2
  lazy var statistics: Observable<TaskStatistics> = self.taskService.statistics()

  init(taskService: TaskServiceType, coordinator: SceneCoordinatorType) {
    self.taskService = taskService
    self.sceneCoordinator = coordinator
  }

  func onToggle(task: TaskItem) -> CocoaAction {
    return CocoaAction {
      return self.taskService.toggle(task: task).map { _ in }
    }
  }

  func onDelete(task: TaskItem) -> CocoaAction {
    return CocoaAction {
      return self.taskService.delete(task: task)
    }
  }

  func onUpdateTitle(task: TaskItem) -> Action<String, Void> {
    return Action { newTitle in
      return self.taskService.update(task: task, title: newTitle).map { _ in }
    }
  }

  var sectionedItems: Observable<[TaskSection]> {
    return self.taskService.tasks()
      .map { results in
        let dueTasks = results
          .filter("checked == nil")
          .sorted(byKeyPath: "added", ascending: false)

        let doneTasks = results
          .filter("checked != nil")
          .sorted(byKeyPath: "checked", ascending: false)

        return [
          TaskSection(model: "  Due Tasks", items: dueTasks.toArray()),
          TaskSection(model: "  Done Tasks", items: doneTasks.toArray())
        ]
    }
  }

  func onCreateTask() -> CocoaAction {
    return CocoaAction { _ in
      return self.taskService
        .createTask(title: "")
        .flatMap { task -> Observable<Void> in
          let editViewModel = EditTaskViewModel(task: task,
                                                coordinator: self.sceneCoordinator,
                                                updateAction: self.onUpdateTitle(task: task),
                                                cancelAction: self.onDelete(task: task))
          return self.sceneCoordinator
            .transition(to: Scene.editTask(editViewModel), type: .modal)
            .asObservable()
            .map { _ in }
      }
    }
  }

  lazy var editAction: Action<TaskItem, Swift.Never> = { this in
    return Action { task in
      let editViewModel = EditTaskViewModel(
        task: task,
        coordinator: this.sceneCoordinator,
        updateAction: this.onUpdateTitle(task: task)
      )
      return this.sceneCoordinator
        .transition(to: Scene.editTask(editViewModel), type: .modal)
        .asObservable()
    }
  }(self)

  // Challenge 1
  lazy var deleteAction: Action<TaskItem, Void> = { (service: TaskServiceType) in
    return Action { item in
      return service.delete(task: item)
    }
  }(self.taskService)
}
