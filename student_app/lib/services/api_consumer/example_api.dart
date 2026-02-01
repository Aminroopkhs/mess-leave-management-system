import 'api_client.dart';

final ApiClient _apiClient = ApiClient();

// Future<List<BusRoute>> getBusRoutes() async {
//   final List<dynamic> data = await _apiClient.get("/api/BusRoutes");

//   return data.map((route) => BusRoute.fromJson(route)).toList();
// }

// Future<BusRoute?> getBusRouteById(int routeId) async {
//   final data = await _apiClient.get("/api/BusRoutes/$routeId");

//   if (data == null) return null;
//   return BusRoute.fromJson(data);
// }
