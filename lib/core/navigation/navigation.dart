import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';

abstract class AppFlowController<T> extends StateNotifier<T> {
  AppFlowController(T state) : super(state);

  final GlobalKey<NavigatorState> _navigator = GlobalKey();

  T get _state => state;

  set _state(T s) => state = s;

  List<Page<Object>> onGeneratePages(T state, List<Page<Object>> currentPages);
}

class _AppRouteNavigator<T extends AppFlowController<Object>>
    extends StatefulWidget {
  const _AppRouteNavigator({
    Key? key,
    required this.controller,
  })  : assert(controller != null),
        super(key: key);

  final T controller;

  @override
  _AppRouteNavigatorState<T> createState() => _AppRouteNavigatorState<T>();
}

class _AppRouteNavigatorState<T extends AppFlowController<Object>>
    extends State<_AppRouteNavigator<T>> {
  List<Page<Object>> _pages = <Page<Object>>[];
  bool _didPop = false;

  final List<Object> _history = <Object>[];

  @override
  void initState() {
    super.initState();
    _removeListener = widget.controller.addListener(_listen);
    _pages = widget.controller.onGeneratePages(
      widget.controller._state,
      List<Page<Object>>.of(
        _pages,
      ),
    );
    _history.add(widget.controller._state);
  }

  RemoveListener? _removeListener;

  void _listen(Object state) {
    // if (_controller._completed) {
    //   if (widget.onComplete != null) {
    //     return widget.onComplete!(_state);
    //   }
    //   if (mounted) {
    //     return Navigator.of(context).pop(_state);
    //   }
    // }
    if (_didPop) {
      _didPop = false;
      return;
    }

    setState(() {
      _pages = widget.controller
          // ignore: always_specify_types
          .onGeneratePages(state, List.of(_pages));
      _history.add(state);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _removeListener?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.controller._navigator,
      pages: _pages,
      // ignore: always_specify_types
      onPopPage: (Route route, dynamic result) {
        if (_history.isNotEmpty) {
          _history.removeLast();
          _didPop = true;
          widget.controller._state = _history.last;
        }
        if (_pages.length > 1) {
          _pages.removeLast();
        }
        setState(() {});
        return route.didPop(result);
      },
    );
  }
}

class AppRoute {
  AppRoute(this.routeInformation);

  final RouteInformation routeInformation;
}

class AppRouteDelegate<T extends AppFlowController<Object>>
    extends RouterDelegate<AppRoute>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<AppRoute>,
        LocatorMixin {
  AppRouteDelegate(this.controller) {
    _removeListener = controller.addListener((Object state) {
      _listen();
    });
  }

  RemoveListener? _removeListener;

  void _listen() {
    notifyListeners();
  }

  final T controller;

  @override
  void dispose() {
    _removeListener?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppRouteNavigator<T>(
      controller: controller,
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => controller._navigator;

  @override
  Future<void> setNewRoutePath(AppRoute configuration) async {
    print(configuration.routeInformation);
  }
}

class AppRouteParser extends RouteInformationParser<AppRoute> {
  @override
  Future<AppRoute> parseRouteInformation(RouteInformation routeInformation) {
    return Future<AppRoute>.value(AppRoute(routeInformation));
  }

  @override
  RouteInformation restoreRouteInformation(AppRoute configuration) {
    return configuration.routeInformation;
  }
}
