import "package:bloc_test/bloc_test.dart";
import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";
import "package:pomodore/features/configuration/domain/entities/settings_entity.dart";
import "package:pomodore/features/configuration/domain/usecases/change_locale_usecase.dart";
import "package:pomodore/features/configuration/domain/usecases/change_settings_usecase.dart";
import "package:pomodore/features/configuration/domain/usecases/change_theme_usecase.dart";
import "package:pomodore/features/configuration/domain/usecases/get_locale_usecase.dart";
import "package:pomodore/features/configuration/domain/usecases/get_settings_usecase.dart";
import "package:pomodore/features/configuration/domain/usecases/get_theme_usecase.dart";
import "package:pomodore/features/configuration/presentation/blocs/settings_bloc/settings_bloc.dart";

import "settings_bloc_test.mocks.dart";

@GenerateMocks([
  GetSettingsUseCase,
  ChangeSettingsUseCase,
  ChangeLocaleUseCase,
  GetLocaleUseCase,
  ChangeThemeUseCase,
  GetThemeUseCase,
])
void main() {
  final MockGetSettingsUseCase getSettingsUseCase = MockGetSettingsUseCase();
  final MockChangeSettingsUseCase changeSettingsUseCase = MockChangeSettingsUseCase();
  final MockChangeLocaleUseCase changeLocaleUseCase = MockChangeLocaleUseCase();
  final MockGetLocaleUseCase getLocaleUseCase = MockGetLocaleUseCase();
  final MockChangeThemeUseCase changeThemeUseCase = MockChangeThemeUseCase();
  final MockGetThemeUseCase getThemeUseCase = MockGetThemeUseCase();

  SettingsBloc getBlocInstance() => SettingsBloc(
        getSettingUseCase: getSettingsUseCase,
        changeSettingsUseCase: changeSettingsUseCase,
        changeLocaleUseCase: changeLocaleUseCase,
        getLocaleUseCase: getLocaleUseCase,
        getThemeUseCase: getThemeUseCase,
        changeThemeUseCase: changeThemeUseCase,
      );

  SettingsEntity getSettingEntity() => const SettingsEntity(
        notification: true,
        sound: true,
        vibration: true,
        appUpdates: true,
        newTips: true,
        ads: true,
      );

  group("SettingFromDeviceFetched Event", () {
    group("SettingFetched success test", () {
      blocTest(
        "emit SettingFetchingLoading and SettingFetchingSuccess",
        build: () {
          when(getSettingsUseCase.call()).thenAnswer(
              (realInvocation) => Future.value(Right(getSettingEntity())));

          return getBlocInstance();
        },
        act: (bloc) => bloc.add(SettingsFromDeviceFetched()),
        expect: () => [
          SettingFetchingLoading(),
          SettingFetchingSuccess(getSettingEntity()),
        ],
      );
    });
    group("SettingFetched fail test", () {
      blocTest(
        "emit SettingFetchingLoading and SettingFetchingSuccess",
        build: () {
          when(getSettingsUseCase.call()).thenAnswer(
              (realInvocation) => Future.value(const Left("error")));

          return getBlocInstance();
        },
        act: (bloc) => bloc.add(SettingsFromDeviceFetched()),
        expect: () => [
          SettingFetchingLoading(),
          SettingFetchingFail(),
        ],
      );
    });
  });
}
