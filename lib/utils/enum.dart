enum TextSizes { small, medium, large }

enum OrderStatus { processing, shipped, delivered }

enum ImageSourceType { camera, gallery }
enum ConnectionType { Mobile, Wifi }

enum PaymentMethods {
  paypal,
  googlePay,
  applePay,
  visa,
  masterCard,
  creditCard,
  payStack,
  razorPay,
  paytm,
  phonePay
}

enum toastType { error, success, information, warning }

enum Status { Active, Deactive }

enum ErrorType { Msg, Widget, Both }

enum LoadingType { dialog, animation }

/// gst include or not
enum GSTConfigType { Included, Excluded }

/// sale tax configuration
enum TaxConfigType { Inclusive, Exclusive }
