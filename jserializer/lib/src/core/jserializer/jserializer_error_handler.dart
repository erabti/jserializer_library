sealed class JSerializerErrorHandler<ModelT> {
  const JSerializerErrorHandler();

  const factory JSerializerErrorHandler.throwValue({
    Object? error,
    StackTrace? stackTrace,
  }) = JSerializerErrorHandlerThrow<ModelT>;

  const factory JSerializerErrorHandler.returnValue(ModelT Function() callback) =
      JSerializerErrorHandlerHandle<ModelT>;
}

class JSerializerErrorHandlerThrow<ModelT>
    extends JSerializerErrorHandler<ModelT> {
  const JSerializerErrorHandlerThrow({this.error, this.stackTrace});

  final Object? error;
  final StackTrace? stackTrace;
}

class JSerializerErrorHandlerHandle<ModelT>
    extends JSerializerErrorHandler<ModelT> {
  const JSerializerErrorHandlerHandle(this.callback);

  final ModelT Function() callback;
}
