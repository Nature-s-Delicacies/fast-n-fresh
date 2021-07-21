import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:natures_delicacies/consts/constants.dart';
import 'package:natures_delicacies/models/delivery_boys.dart';
import 'package:natures_delicacies/models/delivery_status_list.dart';
import 'package:natures_delicacies/models/feedback.dart';
import 'package:natures_delicacies/models/order.dart';
import 'package:natures_delicacies/models/pending_orders.dart';
import 'package:natures_delicacies/models/previous_orders.dart';
import 'package:natures_delicacies/models/product.dart';
import 'package:natures_delicacies/models/product_category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderUtils {
  String categoryCreation;
  String productCreation;
  String orderCreation;
  String ordersFetched;
  String fetchDeliveryBoys;
  String fetchPendingOrders;
  String fetchFeedbacks;
  String fetchDeliveryStatus;

  Future<ProductCategory> createCategory(ProductCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    String adminToken = prefs.getString('token');
    var headers = {'Authorization': 'Bearer $adminToken', 'Content-Type': 'application/json'};

    return await http
        .post(
      Uri.https(BASE_URL, CREATE_CATEGORY_URL),
      body: jsonEncode(category.toJson()),
      headers: headers,
    )
        .then((http.Response response) async {
      if (response.statusCode == 400) {
        categoryCreation = json.decode(response.body)['error'];
      } else {
        categoryCreation = 'Category Created Successfully!';
      }
      return ProductCategory.fromJson(json.decode(response.body));
    });
  }

  Future<Product> createProduct(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    String adminToken = prefs.getString('token');
    var headers = {'Authorization': 'Bearer $adminToken', 'Content-Type': 'application/json'};

    return await http
        .post(
      Uri.https(BASE_URL, CREATE_PRODUCT_URL),
      body: jsonEncode(product.toJson()),
      headers: headers,
    )
        .then((http.Response response) async {
      if (response.statusCode == 200) {
        productCreation = 'Product Created Successfully!';
      } else {
        productCreation = json.decode(response.body)['error'];
      }
      return Product.fromJson(json.decode(response.body));
    });
  }

  Future<List<ProductCategory>> getCategories() async {
    List<ProductCategory> categories = [];
    final response = await http.get(
      Uri.https(BASE_URL, USER_GET_CATEGORIES_URL),
    );

    var extract = json.decode(response.body);
    var categoriesJson = extract['categoryList'];
    if (response.statusCode == 200) {
      for (Map i in categoriesJson) {
        categories.add(ProductCategory.fromJson(i));
      }
    } else {
      throw new Exception('Couldn\'t fetch data');
    }
    return categories;
  }

  Future<List<Product>> getProducts(String category) async {
    List<Product> products = [];
    final response = await http.get(
      Uri.https(BASE_URL, USER_GET_PRODUCTS_URL + category),
    );
    var extract = json.decode(response.body);
    var productsJson = extract['products'];
    if (response.statusCode == 200) {
      for (Map i in productsJson) {
        products.add(Product.fromJson(i));
      }
    } else {
      throw new Exception('Couldn\'t fetch data');
    }
    return products;
  }

  Future<Order> placeOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('token');
    var headers = {'Authorization': 'Bearer $userToken', 'Content-Type': 'application/json'};

    return await http
        .post(Uri.https(BASE_URL, USER_ORDERS_URL),
            body: jsonEncode(order.toJson()), headers: headers)
        .then((http.Response response) async {
      if (response.statusCode == 200) {
        orderCreation = 'Order Created Successfully!';
      } else {
        orderCreation = json.decode(response.body)['error'];
      }
      return Order.fromJson(json.decode(response.body));
    });
  }

  Future<List<PrevOrders>> getPreviousOrders() async {
    final prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('token');
    var headers = {'Authorization': 'Bearer $userToken'};

    PreviousOrders previousOrders;

    final response = await http.get(Uri.https(BASE_URL, USER_ORDERS_URL), headers: headers);

    if (response.statusCode == 200) {
      ordersFetched = 'Orders Fetched Successfully!';
      previousOrders = new PreviousOrders.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception('Couldn\'t fetch orders');
    }
    return previousOrders.prevOrders;
  }

  Future<List<DeliveryBoy>> getDeliveryBoys() async {
    final prefs = await SharedPreferences.getInstance();
    String adminToken = prefs.getString('token');
    var headers = {'Authorization': 'Bearer $adminToken'};

    DeliveryBoyList deliveryBoyList;

    final response = await http.get(Uri.https(BASE_URL, GET_DELIVERY_BOYS_URL), headers: headers);

    if (response.statusCode == 200) {
      fetchDeliveryBoys = 'Delivery Boys Fetched Successfully!';
      deliveryBoyList = new DeliveryBoyList.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception('Couldn\'t get delivery boys');
    }
    return deliveryBoyList.deliveryBoys;
  }

  Future assignOrder(String orderId, String deliveryBoyName) async {
    final prefs = await SharedPreferences.getInstance();
    String adminToken = prefs.getString('token');
    var headers = {
      'Authorization': 'Bearer $adminToken',
      'Content-Type': 'application/json',
    };
    var body = jsonEncode(<String, String>{
      "orderId": orderId,
      "deliveryBoyName": deliveryBoyName,
    });
    String toastMessage;

    final response = await http.patch(
      Uri.https(BASE_URL, ADMIN_ORDERS_URL),
      headers: headers,
      body: body,
    );

    var extract = json.decode(response.body);
    if (response.statusCode == 200) {
      toastMessage = extract['message'];
    } else {
      toastMessage = extract['e'];
    }
    return toastMessage;
  }

  Future sendFeedback(String message, double rating, String deliveryBoyName) async {
    final prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('token');
    var headers = {
      'Authorization': 'Bearer $userToken',
      'Content-Type': 'application/json',
    };

    var body = jsonEncode({
      "message": message,
      "rating": rating,
      "deliveryBoyName": deliveryBoyName,
    });
    String toastMessage;

    final response = await http.post(
      Uri.https(BASE_URL, USER_FEEDBACKS_URL),
      headers: headers,
      body: body,
    );

    var extract = json.decode(response.body);
    if (response.statusCode == 200) {
      toastMessage = extract['message'];
    } else {
      toastMessage = extract['e'];
    }
    return toastMessage;
  }

  Future<List<PendingOrders>> getPendingOrders() async {
    final prefs = await SharedPreferences.getInstance();
    String adminToken = prefs.getString('token');
    var headers = {'Authorization': 'Bearer $adminToken'};

    PendingOrdersList pendingOrdersList;

    final response = await http.get(Uri.https(BASE_URL, ADMIN_ORDERS_URL), headers: headers);

    if (response.statusCode == 200) {
      fetchPendingOrders = 'Orders Fetched Successfully!';
      pendingOrdersList = new PendingOrdersList.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception('Couldn\'t get pending orders');
    }
    return pendingOrdersList.pendingOrders;
  }

  Future<List<Feedbacks>> getAdminFeedbacks() async {
    final prefs = await SharedPreferences.getInstance();
    String adminToken = prefs.getString('token');
    var headers = {'Authorization': 'Bearer $adminToken'};

    FeedbackList feedbackList;

    final response = await http.get(Uri.https(BASE_URL, ADMIN_FEEDBACKS_URL), headers: headers);

    if (response.statusCode == 200) {
      fetchFeedbacks = 'Feedbacks Fetched Successfully!';
      feedbackList = new FeedbackList.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception('Couldn\'t get feedbacks');
    }
    return feedbackList.feedbacks;
  }

  Future<List<PendingDeliveryStatus>> getDeliveryStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String adminToken = prefs.getString('token');
    var headers = {'Authorization': 'Bearer $adminToken'};

    DeliveryStatusList deliveryStatusList;

    final response =
        await http.get(Uri.https(BASE_URL, ADMIN_DELIVERY_STATUS_URL), headers: headers);

    if (response.statusCode == 200) {
      fetchDeliveryStatus = 'Delivery Status Fetched Successfully!';
      deliveryStatusList = DeliveryStatusList.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception('Couldn\'t get delivery status');
    }
    return deliveryStatusList.deliveryStatus;
  }
}
