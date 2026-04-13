// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:io';

import 'package:path/path.dart' as p;

void main(List<String> arguments) {
  String? featureName;
  bool useBloc = false;
  bool useRiverpod = false;

  for (int i = 0; i < arguments.length; i++) {
    final arg = arguments[i];
    if (arg == '--name' || arg == '-n') {
      if (i + 1 < arguments.length) {
        featureName = arguments[i + 1];
        i++;
      }
    } else if (arg == '--use-bloc' || arg == '-b') {
      useBloc = true;
    } else if (arg == '--use-riverpod' || arg == '-r') {
      useRiverpod = true;
    } else if (arg == '--help' || arg == '-h') {
      _printUsage();
      exit(0);
    }
  }

  if (featureName == null || featureName.isEmpty) {
    print('Error: Feature name is required. Use -n or --name.');
    _printUsage();
    exit(1);
  }

  final projectRoot = Directory.current.path;
  final libDir = p.join(projectRoot, 'lib');
  final featuresDir = p.join(libDir, 'features');
  final featurePath = p.join(featuresDir, featureName);

  _createDirectory(p.join(featurePath, 'data'));
  _createDirectory(p.join(featurePath, 'domain'));
  _createDirectory(p.join(featurePath, 'presentation'));

  _createDirectory(p.join(featurePath, 'data', 'datasources'));
  _createDirectory(p.join(featurePath, 'data', 'models'));
  _createDirectory(p.join(featurePath, 'data', 'repositories'));

  _createDirectory(p.join(featurePath, 'domain', 'entities'));
  _createDirectory(p.join(featurePath, 'domain', 'repositories'));
  _createDirectory(p.join(featurePath, 'domain', 'usecases'));

  _createDirectory(p.join(featurePath, 'presentation', 'screen'));
  if (useBloc) {
    _createDirectory(p.join(featurePath, 'presentation', 'bloc'));
  }

  if (useRiverpod) {
    _createDirectory(p.join(featurePath, 'provider'));
  }

  _createFile(
    p.join(
      featurePath,
      'data',
      'datasources',
      '${featureName}_datasource.dart',
    ),
    _generateDatasourceContent(featureName),
  );
  _createFile(
    p.join(
      featurePath,
      'data',
      'models',
      '${featureName}_sample_request_impl.dart',
    ),
    _generateModelsContent(
      '${featureName}_sample_request',
      _capitalize('${featureName}SampleRequest'),
    ),
  );
  _createFile(
    p.join(
      featurePath,
      'data',
      'models',
      '${featureName}_sample_response_impl.dart',
    ),
    _generateModelsContent(
      '${featureName}_sample_response',
      _capitalize('${featureName}SampleResponse'),
    ),
  );
  _createFile(
    p.join(
      featurePath,
      'data',
      'repositories',
      '${featureName}_repository_impl.dart',
    ),
    _generateRepositoryImplContent(featureName),
  );

  _createFile(
    p.join(
      featurePath,
      'domain',
      'entities',
      '${featureName}_sample_request.dart',
    ),
    _generateEntitiesContent(_capitalize('${featureName}SampleRequest')),
  );
  _createFile(
    p.join(
      featurePath,
      'domain',
      'entities',
      '${featureName}_sample_response.dart',
    ),
    _generateEntitiesContent(_capitalize('${featureName}SampleResponse')),
  );
  _createFile(
    p.join(
      featurePath,
      'domain',
      'repositories',
      '${featureName}_repository.dart',
    ),
    _generateRepositoryContent(featureName),
  );
  _createFile(
    p.join(
      featurePath,
      'domain',
      'usecases',
      '${featureName}_sample_usecase.dart',
    ),
    _generateUsecaseContent(featureName),
  );

  _createFile(
    p.join(featurePath, 'presentation', 'screen', '${featureName}_screen.dart'),
    _generateScreenContent(featureName, useBloc, useRiverpod),
  );
  if (useBloc) {
    _createFile(
      p.join(featurePath, 'presentation', 'bloc', '${featureName}_bloc.dart'),
      _generateBlocContent(featureName),
    );
    _createFile(
      p.join(featurePath, 'presentation', 'bloc', '${featureName}_event.dart'),
      _generateEventContent(featureName),
    );
    _createFile(
      p.join(featurePath, 'presentation', 'bloc', '${featureName}_state.dart'),
      _generateStateContent(featureName),
    );
  }
  if (useRiverpod) {
    _createFile(
      p.join(featurePath, 'provider', '${featureName}_provider.dart'),
      _generateProviderContent(featureName),
    );
  }

  print('Feature "$featureName" created successfully!');
  if (useBloc) {
    print('Using Bloc pattern.');
  }
}

void _printUsage() {
  print(
    'Usage: create_feature --name <feature_name> [-b | --use-bloc] [-h | --help]',
  );
  print('\nOptions:');
  print('  -n, --name        Required. The name of the feature to create.');
  print('  -b, --use-bloc    Optional. Use Bloc pattern for the feature.');
  print('  -h, --help        Show this help message.');
}

void _createDirectory(String path) {
  final directory = Directory(path);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
    print('Created directory: $path');
  }
}

void _createFile(String path, String content) {
  final file = File(path);
  if (!file.existsSync()) {
    file.writeAsStringSync(content);
    print('Created file: $path');
  }
}

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String _generateDatasourceContent(String featureName) {
  return "import '../models/${featureName}_sample_request_impl.dart';\nimport '../models/${featureName}_sample_response_impl.dart';\n\nabstract class ${_capitalize(featureName)}Datasource {\n  Future<${_capitalize(featureName)}SampleResponseImpl?> sample(\n    ${_capitalize(featureName)}SampleRequestImpl params,\n  );\n}\n\nclass ${_capitalize(featureName)}DatasourceImpl extends ${_capitalize(featureName)}Datasource {\n  @override\n  Future<${_capitalize(featureName)}SampleResponseImpl?> sample(\n    ${_capitalize(featureName)}SampleRequestImpl params,\n  ) async {\n    return ${_capitalize(featureName)}SampleResponseImpl();\n  }\n}\n";
}

String _generateModelsContent(String featureName, String className) {
  return "import '../../domain/entities/$featureName.dart';\n\nclass ${className}Impl extends $className {}\n";
}

String _generateRepositoryImplContent(String featureName) {
  return "import '../../domain/repositories/${featureName}_repository.dart';\nimport '../datasources/${featureName}_datasource.dart';\nimport '../models/${featureName}_sample_request_impl.dart';\nimport '../models/${featureName}_sample_response_impl.dart';\n\nclass ${_capitalize(featureName)}RepositoryImpl extends ${_capitalize(featureName)}Repository {\n  const ${_capitalize(featureName)}RepositoryImpl({required this.datasource});\n  final ${_capitalize(featureName)}Datasource datasource;\n\n  @override\n  Future<${_capitalize(featureName)}SampleResponseImpl?> sample(\n    ${_capitalize(featureName)}SampleRequestImpl params,\n  ) async {\n    return await datasource.sample(params);\n  }\n}\n";
}

String _generateEntitiesContent(String className) {
  return "abstract class $className {}";
}

String _generateRepositoryContent(String featureName) {
  return "import '../entities/${featureName}_sample_request.dart';\nimport '../entities/${featureName}_sample_response.dart';\n\nabstract class ${_capitalize(featureName)}Repository {\n  const ${_capitalize(featureName)}Repository();\n\n  Future<${_capitalize(featureName)}SampleResponse?> sample(\n    covariant ${_capitalize(featureName)}SampleRequest params,\n  );\n}\n";
}

String _generateUsecaseContent(String featureName) {
  return "import '../../../../core/usecase/usecase.dart';\nimport '../entities/${featureName}_sample_request.dart';\nimport '../entities/${featureName}_sample_response.dart';\nimport '../repositories/${featureName}_repository.dart';\n\nclass ${_capitalize(featureName)}SampleUsecase implements Usecase<${_capitalize(featureName)}SampleResponse?, ${_capitalize(featureName)}SampleRequest> {\n  ${_capitalize(featureName)}SampleUsecase({required this.repository});\n  final ${_capitalize(featureName)}Repository repository;\n\n  @override\n  Future<${_capitalize(featureName)}SampleResponse?> call(${_capitalize(featureName)}SampleRequest params) async {\n    return await repository.sample(params);\n  }\n}\n";
}

String _generateScreenContent(
  String featureName,
  bool useBloc,
  bool useRiverpod,
) {
  String content = "import 'package:flutter/material.dart';\n";

  if (useBloc) {
    content += "import 'package:flutter_bloc/flutter_bloc.dart';\n";
  }
  if (useRiverpod) {
    content += "import 'package:flutter_riverpod/flutter_riverpod.dart';\n\n";
    content += "import '../../provider/${featureName}_provider.dart';\n";
  } else {
    if (useBloc) {
      content +=
          "\nimport '../../data/datasources/${featureName}_datasource.dart';\n";
      content +=
          "import '../../data/repositories/${featureName}_repository_impl.dart';\n";
      content +=
          "import '../../domain/usecases/${featureName}_sample_usecase.dart';\n";
    }
  }
  if (useBloc) {
    content += "import '../bloc/${featureName}_bloc.dart';\n";
    content += "import '../bloc/${featureName}_state.dart';\n";
  }
  content +=
      "\nclass ${_capitalize(featureName)}Screen extends ${useRiverpod ? 'ConsumerWidget' : 'StatelessWidget'} {\n  const ${_capitalize(featureName)}Screen({super.key});\n\n  @override\n  Widget build(BuildContext context${useRiverpod ? ', WidgetRef ref' : ''}) {\n    ";
  if (useBloc) {
    if (useRiverpod) {
      content +=
          "final bloc = ref.read<${_capitalize(featureName)}Bloc>(${featureName}BlocProvider);\n    return Scaffold(\n      body: BlocBuilder<${_capitalize(featureName)}Bloc, ${_capitalize(featureName)}State>(\n        bloc: bloc,\n        builder: (context, state) {\n          return const SizedBox();\n        },\n      ),\n    );\n  }\n}\n";
    } else {
      content +=
          "final bloc = ${_capitalize(featureName)}Bloc(\n      usecase: ${_capitalize(featureName)}SampleUsecase(\n        repository: ${_capitalize(featureName)}RepositoryImpl(\n          datasource: ${_capitalize(featureName)}DatasourceImpl(),\n        ),\n      ),\n    );\n    return BlocProvider(\n      create: (context) => bloc,\n      child: BlocBuilder<${_capitalize(featureName)}Bloc, ${_capitalize(featureName)}State>(\n        builder: (context, state) {\n          return Scaffold();\n        },\n      ),\n    );\n  }\n}\n";
    }
  } else {
    content += "return Scaffold();\n  }\n}\n";
  }
  return content;
}

String _generateBlocContent(String featureName) {
  return "import 'package:bloc/bloc.dart';\n\nimport '../../domain/usecases/${featureName}_sample_usecase.dart';\nimport '${featureName}_event.dart';\nimport '${featureName}_state.dart';\n\nclass ${_capitalize(featureName)}Bloc extends Bloc<${_capitalize(featureName)}Event, ${_capitalize(featureName)}State> {\n  ${_capitalize(featureName)}SampleUsecase usecase;\n\n  ${_capitalize(featureName)}Bloc({required this.usecase}) : super(${_capitalize(featureName)}IdleState()) {\n    on<${_capitalize(featureName)}Event>((event, emit) {});\n  }\n}\n";
}

String _generateEventContent(String featureName) {
  return "abstract class ${_capitalize(featureName)}Event {}";
}

String _generateStateContent(String featureName) {
  return "abstract class ${_capitalize(featureName)}State {}\n\nclass ${_capitalize(featureName)}IdleState extends ${_capitalize(featureName)}State {}";
}

String _generateProviderContent(String featureName) {
  return "import 'package:flutter_riverpod/flutter_riverpod.dart';\n\nimport '../data/datasources/${featureName}_datasource.dart';\nimport '../data/repositories/${featureName}_repository_impl.dart';\nimport '../domain/repositories/${featureName}_repository.dart';\nimport '../domain/usecases/${featureName}_sample_usecase.dart';\nimport '../presentation/bloc/${featureName}_bloc.dart';\n\nfinal ${featureName}DatasourceProvider = Provider<${_capitalize(featureName)}Datasource>(\n  (ref) => ${_capitalize(featureName)}DatasourceImpl(),\n);\n\nfinal ${featureName}RepositoryProvider = Provider<${_capitalize(featureName)}Repository>(\n  (ref) => ${_capitalize(featureName)}RepositoryImpl(\n    datasource: ref.read<${_capitalize(featureName)}Datasource>(\n      ${featureName}DatasourceProvider,\n    ),\n  ),\n);\n\nfinal ${featureName}SampleUsecaseProvider =\n    Provider<${_capitalize(featureName)}SampleUsecase>(\n      (ref) => ${_capitalize(featureName)}SampleUsecase(\n        repository: ref.read<${_capitalize(featureName)}Repository>(\n          ${featureName}RepositoryProvider,\n        ),\n      ),\n    );\n\nfinal ${featureName}BlocProvider = Provider<${_capitalize(featureName)}Bloc>(\n  (ref) => ${_capitalize(featureName)}Bloc(\n    usecase: ref.read<${_capitalize(featureName)}SampleUsecase>(\n      ${featureName}SampleUsecaseProvider,\n    ),\n  ),\n);\n";
}
