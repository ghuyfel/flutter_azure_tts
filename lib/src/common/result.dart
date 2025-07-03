/// A generic result type for handling success and error cases
sealed class Result<T, E> {
  const Result();
}

class Success<T, E> extends Result<T, E> {
  const Success(this.value);
  final T value;
}

class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);
  final E error;
}

extension ResultExtensions<T, E> on Result<T, E> {
  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;
  
  T? get valueOrNull => switch (this) {
    Success(value: final value) => value,
    Failure() => null,
  };
  
  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(error: final error) => error,
  };
  
  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) {
    return switch (this) {
      Success(value: final value) => onSuccess(value),
      Failure(error: final error) => onFailure(error),
    };
  }
}