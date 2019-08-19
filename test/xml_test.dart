
import 'package:aliyun_oss/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test parkerDecode', () {
    const xmlString = '''<?xml version="1.0" encoding="UTF-8"?>
<Error>
  <Code>InvalidAccessKeyId</Code>
  <Message>The OSS Access Key Id you provided does not exist in our records.</Message>
  <RequestId>5D5A2249F43DB7BCDD04E4E3</RequestId>
  <HostId>smartnotep.oss-cn-beijing.aliyuncs.com</HostId>
  <OSSAccessKeyId>STS.NHHdfht46k9Uf445YUaLQ3MAp</OSSAccessKeyId>
</Error>
''';

    var jsonObject = parkerDecode(xmlString);
    Map<String, Object> error = jsonObject['Error'];
    expect(error['Code'], 'InvalidAccessKeyId');
  });
}
