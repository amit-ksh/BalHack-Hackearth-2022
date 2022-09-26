import ballerina/random;
import ballerina/http;

// TYPES
public type Item record {|
  string item;
  int quantity;
|};

public type OrderRequest record {|
  string? username;
  Item[] order_items;
|};

type UserOrder record {|
  string order_id;
  int total;
  string status = "pending";
  Item[] order_items;
|};

// DATA STORE
map<int> cakeMenu = {
  "Butter Cake": 15,
  "Chocolate Cake": 20,
  "Tres Leches": 25
};
map<UserOrder> orders = {};

// MAIN
service / on new http:Listener(port) {
    
    // RETRIEVE THE MENU
    resource function get menu() returns json {
      return cakeMenu.toJson();
    }

    // RETRIEVE THE ORDER STATUS
    resource function get 'order/[string orderId]() returns json|http:NotFound {
      if !orders.hasKey(orderId) {
        http:NotFound status = {
          status: new()
        };
        return status;
      }

      return {
        order_id: orderId,
        status: orders.get(orderId).status
      };
    }

    // PLACE AN ORDER
    resource function post 'order(@http:Payload OrderRequest user_order) 
      returns json|http:BadRequest|error {
        
      if user_order.username == "" || 
      user_order.order_items.length() == 0 {
        return http:STATUS_BAD_REQUEST;
      }

      map<boolean> isItemPresent = {};

      int total = 0;
      foreach Item item in user_order.order_items {
        if item.quantity <= 0 || 
        isItemPresent[item.item] == true || 
        cakeMenu[item.item] == () {
          return http:STATUS_BAD_REQUEST;
        }

        total += item.quantity * cakeMenu.get(item.item);
        isItemPresent[item.item] = true;
      }

      string id =  string`${check random:createIntInRange(1, 100)}`;
      UserOrder new_order = {
        order_id: id,
        total: total,
        order_items: user_order.order_items
      };

      orderStatus[id] = "pending";
      orders[id] = new_order;
      return {
        order_id: id,
        total: total
      };
    }

    // UPDATE THE ORDER
    resource function put 'order/[string orderId](@http:Payload Item[] order_items) 
      returns json|http:NotFound|http:Forbidden|http:BadRequest {
      if !orders.hasKey(orderId) {
        http:NotFound status = {
          status: new()
        };
        return status;
      }
      if orders.get(orderId).status != "pending" {
        http:Forbidden status = {
          status: new()
        };
        return status;
      }
      if orders.get(orderId).length() != order_items.length() {
        http:BadRequest status = {
          status: new()
        };
        return status;
      }

      orders[orderId].order_items = order_items;

      int total = 0;
      foreach Item item in orders.get(orderId).order_items {
        total += item.quantity * cakeMenu.get(item.item);
      }

      orders[orderId].total = total;

      return {
        order_id: orderId,
        total: total
      };
    }

    // DELETE THE ORDER
    resource function delete 'order/[string orderId]()
      returns http:Ok|http:NotFound|http:Forbidden {
      if !orders.hasKey(orderId) {
        http:NotFound status = {
          status: new()
        };
        return status;
      }
      if orders.get(orderId).status != "pending" {
        http:Forbidden status = {
          status: new()
        };
        return status;
      }

      _ = orders.remove(orderId);
      return http:OK;
    }
}