import "package:dartz/dartz.dart";
import "package:pomodore/features/task_management/data/data_sources/tasks_local_data_source.dart";
import "package:pomodore/features/task_management/data/models/pomodoro_model.dart";
import "package:pomodore/features/task_management/data/models/task_model.dart";
import "package:pomodore/features/task_management/domain/entities/analysis_entity.dart";
import "package:pomodore/features/task_management/domain/entities/daily_information_entity.dart";
import "package:pomodore/features/task_management/domain/entities/pomodoro_entity.dart";
import "package:pomodore/features/task_management/domain/repositories/task_repository.dart";

import "../../domain/entities/task_entity.dart";
import "../models/analysis_model.dart";

class TaskRepositoryImpl implements TaskRepository {
  final TasksLocalDataSource localDataSource;

  TaskRepositoryImpl(this.localDataSource);

  @override
  Future<Either<String, bool>> addTask(TaskEntity task) async {
    late Either<String, bool> result;

    final bool state = await localDataSource.addTask(task);

    if (!state) {
      result = const Left("error");
    } else {
      result = const Right(true);
    }
    return result;
  }

  @override
  Future<Either<String, List<TaskEntity>>> getTaskByDate(DateTime date) async {
    late Either<String, List<TaskEntity>> result;

    final List<Map<String, dynamic>>? rawList =
        await localDataSource.getSpecificDateTasks(date);

    if (rawList != null) {
      final List<TaskEntity> list =
          TaskModel.sortTasksByDateTime(TaskModel.parseRawList(rawList));
      result = Right(list);
    } else {
      result = const Left("error");
    }

    return result;
  }

  @override
  Future<Either<String, List<PomodoroEntity>>> getAllTodayPomodoros() async {
    late Either<String, List<PomodoroEntity>> result;

    final List<Map<String, dynamic>>? rawList =
        await localDataSource.getSpecificDateTasks(DateTime.now());

    if (rawList != null) {
      final List<PomodoroEntity> convertedList = PomodoroModel.parseRawList(rawList);
      result = Right(convertedList);
    } else {
      result = const Left("error");
    }

    return result;
  }

  @override
  Future<Either<String, DailyInformationEntity>> getDailyInformation() async {
    late Either<String, DailyInformationEntity> result;

    final int completedTasksQuantity =
        await localDataSource.getCompletedTaskQuantity();
    final int tasksQuantity = await localDataSource.getAllTodayTaskQuantity();
    final int dailyGoal = await localDataSource.getDailyGoalQuantity() ?? 1;
    double processPercentage = 0;

    if (tasksQuantity == 0) {
      processPercentage = 0;
    } else if (dailyGoal < completedTasksQuantity) {
      processPercentage = 1;
    } else {
      processPercentage =
          double.parse((completedTasksQuantity / dailyGoal).toStringAsFixed(1));
    }

    final DailyInformationEntity item = DailyInformationEntity(
        dailyGoalQuantity: dailyGoal,
        taskQuantity: tasksQuantity,
        completedTaskQuantity: completedTasksQuantity,
        processPercentage: processPercentage);

    if (tasksQuantity == 0 && completedTasksQuantity != 0) {
      result = const Left("error");
    } else {
      result = Right(item);
    }

    return result;
  }

  @override
  Future<Either<String, AnalysisEntity>> getAnalysis() async {
    late Either<String, AnalysisEntity> result;

    final Map<String, dynamic>? rawData = await localDataSource.getAnalysisPageData();

    if (rawData != null) {
      final AnalysisEntity analysis = AnalysisModel.fromJson(rawData);
      result = Right(analysis);
    } else {
      result = const Left("error");
    }

    return result;
  }

  @override
  Future<Either<String, bool>> checkDailyGoal() async {
    late Either<String, bool> result;

    final bool? rawData = await localDataSource.checkDailyGoal();
    if (rawData != null) {
      result = Right(rawData);
    } else {
      result = const Left("error");
    }

    return result;
  }

  @override
  Future<Either<String, bool>> saveDailyGoal(int count) async {
    late Either<String, bool> result;

    final bool rawData = await localDataSource.saveDailyGoal(count);
    if (rawData) {
      result = Right(rawData);
    } else {
      result = const Left("error");
    }

    return result;
  }

  @override
  Future<Either<String, String>> deleteTask(String id) async {
    late Either<String, String> result;

    final String? status = await localDataSource.deleteTask(id);

    if (status != null) {
      result = Right(status);
    } else {
      result = const Left("error");
    }

    return result;
  }

  @override
  Future<Either<String, String>> completeTask(TaskEntity taskEntity) async {
    late Either<String, String> result;

    final String? status = await localDataSource.completeTask(taskEntity);

    if (status != null) {
      result = Right(status);
    } else {
      result = const Left("error");
    }

    return result;
  }

  @override
  Future<Either<String, String>> editTask(TaskEntity task) async {
    late Either<String, String> result;

    final String? status = await localDataSource.editTask(task);

    if (status != null) {
      result = Right(status);
    } else {
      result = const Left("error");
    }

    return result;
  }
}
