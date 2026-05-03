/// iOS InquiryDTOs.swift 대응

class InquiryRequest {
  final String title;
  final String content;
  final String userEmail;

  const InquiryRequest({
    required this.title,
    required this.content,
    required this.userEmail,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'userEmail': userEmail,
      };
}

class InquiryResponse {
  final String message;
  final bool success;

  const InquiryResponse({required this.message, required this.success});

  factory InquiryResponse.fromJson(Map<String, dynamic> json) =>
      InquiryResponse(
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool? ?? false,
      );
}
