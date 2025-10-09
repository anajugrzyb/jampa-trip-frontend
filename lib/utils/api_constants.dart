class ApiConstants {
  // Base URL do backend
  static const String baseUrl = 'http://localhost:1450';
  
  // Endpoints de autenticação
  static const String loginEndpoint = '/jampa-trip/api/v1/login';
  static const String refreshEndpoint = '/jampa-trip/api/v1/refresh';
  static const String registerClientEndpoint = '/jampa-trip/api/v1/clients';
  static const String registerCompanyEndpoint = '/jampa-trip/api/v1/companies';
  
  // Endpoints de perfil
  static const String profileEndpoint = '/jampa-trip/api/v1/profile';
  
  // Endpoints de tours
  static const String toursEndpoint = '/jampa-trip/api/v1/tours';
  static const String myToursEndpoint = '/jampa-trip/api/v1/companies/tours';
  
  // Endpoints de reservas
  static const String reservationsEndpoint = '/jampa-trip/api/v1/reservations';
  
  // Endpoints de pagamentos
  static const String pixPaymentEndpoint = '/jampa-trip/api/v1/payments/pix';
  static const String cardPaymentEndpoint = '/jampa-trip/api/v1/payments/card';
  
  // Endpoints de upload
  static const String uploadEndpoint = '/jampa-trip/api/v1/upload';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Configurações de token
  static const int tokenRefreshBufferMinutes = 5; // Renovar 5 minutos antes de expirar
  
  // URLs completas
  static String get fullLoginUrl => baseUrl + loginEndpoint;
  static String get fullRefreshUrl => baseUrl + refreshEndpoint;
  static String get fullRegisterClientUrl => baseUrl + registerClientEndpoint;
  static String get fullRegisterCompanyUrl => baseUrl + registerCompanyEndpoint;
  static String get fullProfileUrl => baseUrl + profileEndpoint;
  static String get fullToursUrl => baseUrl + toursEndpoint;
  static String get fullMyToursUrl => baseUrl + myToursEndpoint;
  static String get fullReservationsUrl => baseUrl + reservationsEndpoint;
  static String get fullPixPaymentUrl => baseUrl + pixPaymentEndpoint;
  static String get fullCardPaymentUrl => baseUrl + cardPaymentEndpoint;
  static String get fullUploadUrl => baseUrl + uploadEndpoint;
  
  // Métodos auxiliares
  static String getTourUrl(int id) => '$baseUrl$toursEndpoint/$id';
  static String getReservationUrl(int id) => '$baseUrl$reservationsEndpoint/$id';
  static String getPaymentUrl(int id) => '$baseUrl/jampa-trip/api/v1/payments/$id';
  static String getTourReservationsUrl(int tourId) => '$baseUrl$toursEndpoint/$tourId/reservations';
}
