class ContactParams {
  const ContactParams({this.email, this.phone})
      : assert(email != null || phone != null,
            'Either email or phone must be provided');

  final String? email;
  final String? phone;
}

class SendOtpParams extends ContactParams {
  const SendOtpParams({super.email, super.phone});
}

class ConfirmOtpParams extends ContactParams {
  const ConfirmOtpParams({
    super.email,
    super.phone,
    required this.otp,
  });

  final String otp;
}

class RegistrationFinalizeParams extends ContactParams {
  const RegistrationFinalizeParams({
    super.email,
    super.phone,
    required this.regionId,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
  });

  final int regionId;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
}

class LoginParams extends ContactParams {
  const LoginParams({
    super.email,
    super.phone,
    required this.password,
  });

  final String password;
}

class ForgotPasswordParams extends ContactParams {
  const ForgotPasswordParams({super.email, super.phone});
}

class ResetPasswordParams extends ContactParams {
  const ResetPasswordParams({
    super.email,
    super.phone,
    required this.otp,
    required this.password,
    required this.confirmPassword,
  });

  final String otp;
  final String password;
  final String confirmPassword;
}

class GoogleCompleteParams {
  const GoogleCompleteParams({
    required this.sessionId,
    required this.regionId,
    required this.firstName,
    required this.lastName,
  });

  final String sessionId;
  final int regionId;
  final String firstName;
  final String lastName;
}

class UpdateProfileParams {
  const UpdateProfileParams({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;
}

class ChangeRegionParams {
  const ChangeRegionParams({required this.regionId});
  final int regionId;
}

class ChangePasswordParams {
  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
  });

  final String oldPassword;
  final String newPassword;
}

class UpdateContactParams extends ContactParams {
  const UpdateContactParams({super.email, super.phone});
}

class ConfirmUpdateContactParams {
  const ConfirmUpdateContactParams({required this.otp});
  final String otp;
}

