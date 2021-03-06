import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flcubittest/data/model/weather.dart';
import 'package:flcubittest/data/weather_repository.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository _weatherRepository;

  WeatherBloc(this._weatherRepository) : super(WeatherInitial());

  @override
  Stream<Transition<WeatherEvent, WeatherState>> transformEvents(Stream<WeatherEvent> events, transitionFn) {
    return (events as Subject).debounceTime(Duration(milliseconds: 300));
  }

  @override
  Stream<WeatherState> mapEventToState(
    WeatherEvent event,
  ) async* {
    if (event is GetWeather) {
      try {
        yield WeatherLoading();
        final weather = await _weatherRepository.fetchWeather(event.cityName);
        yield WeatherLoaded(weather);
      } on NetworkException {
        yield WeatherError("Couldn't fetch weather. Is the device online?");
      }
    }
  }
}
