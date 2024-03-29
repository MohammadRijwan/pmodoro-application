import "package:bloc/bloc.dart";
import "package:dartz/dartz.dart";
import "package:equatable/equatable.dart";
import "package:pomodore/features/task_management/domain/entities/task_entity.dart";
import "package:pomodore/features/task_management/domain/usecases/edit_task_usecase.dart";
import "package:pomodore/features/task_management/domain/usecases/get_all_categories_usecase.dart";

import "../../../domain/entities/category_entity.dart";
import "../../../domain/usecases/add_category_usecase.dart";
import "../../../domain/usecases/add_task_usecase.dart";
import "../../../domain/usecases/complete_task_usecase.dart";
import "../../../domain/usecases/delete_task_usecase.dart";
import "../../../domain/usecases/get_specific_date_tasks_usecase.dart";

part "tasks_event.dart";

part "tasks_state.dart";

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final AddTaskUsecase addTaskUsecase;
  final AddCategoryUsecase addCategoryUsecase;
  final GetSpecificDateTasksUseCase getSpecificDateTasks;
  final GetAllCategoriesUseCase getAllCategories;
  final CompleteTaskUseCase completeTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final EditTaskUseCase editTaskUseCase;

  TasksBloc({
    required this.addTaskUsecase,
    required this.addCategoryUsecase,
    required this.getSpecificDateTasks,
    required this.getAllCategories,
    required this.completeTaskUseCase,
    required this.deleteTaskUseCase,
    required this.editTaskUseCase,
  }) : super(TasksInitial()) {
    on<TasksEvent>((event, emit) {});
    on<TaskAdded>(_taskAdded);
    on<CategoryAdded>(_categoryAdded);
    on<SpecificDateTasksFetched>(_todayTasksFetched);
    on<CategoriesFetched>(_categoriesFetched);
    on<TaskCompleted>(_taskCompleted);
    on<TaskDeleted>(_taskDeleted);
    on<DateAdded>(_dateAdded);
    on<TaskEdited>(_taskEdited);
  }

  void _dateAdded(DateAdded event, Emitter emit) {
    emit(AddDateLoading());
    emit(AddDateSuccess(event.dateTime));
  }

  // void saveCurrentPomodoroOnDatabase(PomodoroEntity item) =>
  //     addPomodoroToDbUseCase.call(params: item);

  _taskEdited(TaskEdited event, Emitter emit) async {
    emit(EditTaskLoading());

    final Either<String, String> result =
        await editTaskUseCase.call(params: event.item);

    result.fold(
      (l) => emit(EditTaskFailure()),
      (r) => emit(EditTaskSuccess()),
    );
  }

  _taskDeleted(TaskDeleted event, Emitter<TasksState> emit) async {
    emit(TaskDeleteLoading());

    final Either<String, String> result =
        await deleteTaskUseCase.call(params: event.id);
    result.fold(
      (l) => emit(TaskDeleteFailure()),
      (r) => emit(TaskDeleteSuccess()),
    );
  }

  _taskCompleted(TaskCompleted event, Emitter<TasksState> emit) async {
    emit(TaskCompleteLoading());

    final Either<String, String> result =
        await completeTaskUseCase.call(params: event.taskEntity);

    result.fold(
      (l) => emit(TaskCompleteFailure()),
      (r) => emit(TaskCompleteSuccess()),
    );
  }

  _categoriesFetched(CategoriesFetched event, Emitter<TasksState> emit) async {
    emit(CategoriesFetchLoading());

    final Either<String, List<CategoryEntity>> result = await getAllCategories.call();
    result.fold(
      (l) => emit(CategoriesFetchFailure()),
      (r) => emit(CategoriesFetchSuccess(r)),
    );
  }

  _todayTasksFetched(
      SpecificDateTasksFetched event, Emitter<TasksState> emit) async {
    emit(SpecificDateTasksReceivedLoading());

    final Either<String, List<TaskEntity>> result =
        await getSpecificDateTasks.call(params: event.data);
    result.fold(
      (l) => emit(SpecificDateTasksReceivedFailure()),
      (r) => emit(SpecificDateTasksReceivedSuccess(r)),
    );
  }

  _taskAdded(TaskAdded event, Emitter<TasksState> emit) async {
    emit(TaskAddLoading());

    final Either<String, bool> result = await addTaskUsecase.call(params: event.data);
    result.fold(
      (l) => emit(TaskAddFailure()),
      (r) => emit(TaskAddSuccess()),
    );
  }

  _categoryAdded(CategoryAdded event, Emitter<TasksState> emit) async {
    emit(CategoryAddLoading());

    final Either<String, bool> result =
        await addCategoryUsecase.call(params: event.data);
    result.fold(
      (l) => emit(CategoryAddFailure()),
      (r) => emit(CategoryAddSuccess()),
    );
  }
}
