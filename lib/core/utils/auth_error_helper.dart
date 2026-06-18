class Autherrorhelper {



  static String authErrorMessage(String code){
    String message;
    switch(code){

      case "invalid-email":
        message =  "Please enter valid email!";
        break;
      case "user-disabled":
        message = "Email you have entered is disabled.";
        break;
      case "user-not-found":
        message = "Email you have entered does not exist!";
        break;
      case "wrong-password":
        message = "Wrong password!";
        break;
      case "too-many-requests":
        message = "Please wait before trying again";
        break;
      case "user-token-expired":
        message = "Please try again";
        break;
      case "network-request-failed":
        message = "Network error, please check you internet connection!";
        break;
      case "invalid-credential":
        message = "Please enter correct email and password!";
        break;
      case "operation-not-allowed":
        message =  "Error - Email/Password account not enabled";
        break;

      case "email-already-in-use":
        message  = "Email already exists!";
        break;

      case "weak-password":
        message = "Please enter a strong password!";
        break;
      default:
        message = "Unknown Error!";
        break;


    }

    return message;
  }
}