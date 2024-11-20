import 'package:flutter_dotenv/flutter_dotenv.dart';


class Environment {

  static initEnvironment() async{
    await dotenv.load(fileName: '.env');
  }

  static String apiURL = dotenv.env['API_URL'] ?? 'No hay api key';
  static String supabaseURL = dotenv.env['SUPABASE_URL'] ?? 'No hay api key';
  static String supabaseKEY = dotenv.env['SUPABASE_KEY'] ?? 'No hay api key';


}