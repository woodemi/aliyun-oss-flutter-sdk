import 'dart:io';

import 'package:aliyun_oss/common.dart';
import 'package:aliyun_oss/sign.dart';
import 'package:flutter_test/flutter_test.dart';

var _accessKeyId = 'STS.NJL73vuxoDZDx4448RoWsUcgt';
var _accessKeySecret = 'BbdKzWvbDcR1uvhX75FDXFAY6vwLx7DCaatkyAxGi6ym';
var _securityToken = 'CAIShgl1q6Ft5B2yfSjIr4n5fInCmKdO85ivehKF0DgHY9hfuqbMljz2IH9EdHNhBOkdt/wxmGtV6PwTlqdoTdobABWcNZMosMULqFtWi3ALGonng4YfgbiJREI8ZHyShb0tCoeUZdfZfejXKjKgvyRvwLz8WCy/Vli+S/OggoJmadJlJ2vfaiFdVvNXPRdlos0XPmfKT6rPVCTnmW3NFkFllxNhgGdkk8SFz9ab9wDVgS+KqJEcrJ+jJYO/PYs+fsVkVt6vwOpxaqfZqmsyjyNW7qZwg4Fd5D7Dpav/BEJKsS2cPuTV4q8WTmgkOqI3XPcc9KCky6wk46uhVu2Vpj9JOeZKKRW9IKmr3MrDHs6wK989bsyVEn/R09eJRLCX1gQ/eiAjKR9tcdgsIWMSbBs3UWP1J7OA8lLHaRvBM6+ey/Ma3J5401jP99iHLETtJLKCynQ8O4QgaEkqOhUKxhbMEMk8fhdLbklsCpuMUIx3d2o+k67zuhDIXSASjxMYtvblNfTNofJdO8etRZdPy5YbY4hLqyx3E176DOv20h9MKj05GPEUolWEW/KW7LuC35/SA4rvAewGvVN3aC3YqzH3J1pbMSz24K9aCz2f4N+D6K3X75RqEgYl+sslVGPjS9t2qEF86Kaf9gma9PSZMkqn5W0l4NLVjfQtkkJvZaWjmPTA/Gyc7meQaLM0g8GtHQ8Legitenp27emPj3Yc3XIGiHrmAwwS5VWBpx/SG5BH2PHMnyscWv8NyLiBDEVulwcNINaN5KlxaIEGVetSU/G68Bh0z/n81XOZsJHAthEXToyRcKA9MbZVHzX54qnmcbNznvR5XRDzZYlWqIZV23vv2C8wjekBc9knCm1SBosufdXzppWs5bMOhrJdmsqcN4OiP56YmOPyWHT3MW9apKs95gR1DwD0/fzVBhvTatxkyUmEs2MmFBS91Zb70DJHDv3cANpe87F7ZnrL0ChcN/U3D/Y47pTVxr8DWi0OLJppMx7LWsBwyOlUJRdr5q4yOs65NjzZ9VLCanZmUsFHjvC7ZssT+DTwnbss6uXhKPSJiB3S/73ztdFVpTsHBmiI/+ugbB3uP15jRnUDydfDTZtw3Pdi7nkCOLbgMtXPpu3t+YFQTAf09W2pQsytkROVPEnBPhbeJEMVuABAi6QW5uMIfzIzMzQTUZrheI5/Ekv/kX7TIDCyTmqvNXzdBS1Xkpd+kjzDqg6qor8rU3c3R3JJbpXhzpWbq4+/hofVfnrHceyT7OteedPsT4VPl8eVMvkM0IotkItGUUQiOWGx3fsy1f2zOK4rAhqQOWWP5Z/N1cuBrRrFNOp7sDMY16vqC6TfriKGNYBSPuij1TANkn6KOYy7tN9zow8WC1W3/LgZn/Zral1Rvnvs0OTGvSYzBL+DgADBY+JsHonQ0+ijuVYoknYSq5PIozKCssN1EOoy384LLSwC/6kbDNgsycCcA+X9x9zQLDmBRsSe1joRBCgrTsKTVcLh9BjIkZkmztyRw78NMFu7oKfoygymOH6+jPfSB3vhABMrg1wagAE+1wjszgw5TcsTarYNWPIBDpaG6sgyayzRBBilNIhj99ZR8vhK5WOvyhgGmxDMGFdEbh6ro3gAw43sXNN3pkzs12cpeFiKfC93rgdvd9NjkqgRRNtvwkvsaITi+4x9Cxs2ZLMgb3MQXpa55eeLOnhAHYTX2SCrRuV0KT/nuQHoSQ==';

final _credentials = Credentials(_accessKeyId, _accessKeySecret, _securityToken);

void main() {
  test('test sign', () {
    var signer = Signer(_credentials);
    var signedHeaders = signer.sign(
      httpMethod: 'GET',
      resourcePath: '/smartnotep/a.log',
      dateTime: HttpDate.parse('Thu, 15 Aug 2019 07:23:49 GMT'),
    );
    expect(signedHeaders['Authorization'], 'OSS STS.NJL73vuxoDZDx4448RoWsUcgt:utdhPGcP3vLGjkWTnD1+10Tg7rI=');
  });

  test('test sign v2', () {
    // TODO
  });
}