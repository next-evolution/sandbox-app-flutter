const _poolId = String.fromEnvironment('COGNITO_POOL_ID');
const _appClientId = String.fromEnvironment('COGNITO_APP_CLIENT_ID');
const _region = String.fromEnvironment('COGNITO_REGION', defaultValue: 'ap-northeast-1');

const amplifyconfig = '''{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "$_poolId",
            "AppClientId": "$_appClientId",
            "Region": "$_region"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "loginMechanisms": ["EMAIL"]
          }
        }
      }
    }
  }
}''';
