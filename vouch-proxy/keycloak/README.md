# steps to setup keycloak with argocd

1. Create a _Client_ with these values and nothing else:
<img alt="Screenshot of keycloak showing how to configure a client with clientID: vouch, rootURL: https://vouch.example.com, homeURL is blank, validRedirectURIs: https://vouch.example.com/auth and https://oidcdebugger.com/debug, there is a note pointing to oidcdebugger saying optional for debugging the rest of the fields and values are webOrigins: +, Valid post logout redirect URIs: +, capabilityConfig.clientAuthentication: on, authenticationFlow.standardFlow: checked, authenticationFlow.directAccessGrant: checked. adminURL: https://vouch.example.com/" src="./step_1_create_client.png">

2. Create a _Client Scope_ for groups:
<img alt="Screenshot of keycloak showing configuration of a client scope settings tab: name: groups, type: default, display on consent: on, include in token scope: on. All other fields are blank." src="./step_2_create_client_scope.png">

3. Create a token mapper using _Group Membership_. You can find the menu to create that here after clicking the "Add Mapper" button:
<img alt="Screenshot of keycloak showing the client scope configuration mappers tab after clicking the Add Mapper button. It shows a pop up window that says Configure a new mapper, choose any of the mappings from this table. There is an arrow pointing to the Group Membership mapper which shows a description of: Map user group membership." src="./step_3.1.png">

And then make sure you fill out the Mapper details here like this:
<img alt="Screenshot of keycloak showing confgiuration of the mapper which shows token claim name: groups, add to ID token: on, add to access token: on, add to userinfo: on" src="./mapper_details.png">

<img alt="Screenshot of keycloak showing configuration of the same client scope but the mappers tab this time. It shows a single mapper called groups." src="./step_3.png">

4. Assign the new _**groups**_ _Client Scope_ to the argocd _Client_ we created earlier
<img alt="Screenshot of keycloak showing the Clients page with the Client Scopes tab selected. There are two 'Assigned client scopes' highlighted: email and groups, and both have assigned type of Default." src="./step_4.png">

5. create a group for use in the client
<img alt="Screenshot of keycloak showing a group called ArgoCDAdmins crated on the Groups page" src="./step_5_create_groups.png">

Here's a Kubernetes Secret containing a Vouch config that uses keycloak as the OIDC provider:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: vouch-existing-secret
stringData:
  config.yaml: |
    vouch:
      logLevel: debug
      testing: false
      domains:
      - example.com
      whiteList:
      - myuser@myemaildomain.com
      allowAllUsers: false
      cookie:
        maxAge: 900
        secure: true
        domain: example.com
    oauth:
      provider: oidc
      client_id: vouch
      client_secret: 8943hncds9aavy89hn39ncdsa89y79vh79as 
      auth_url: https://iam.example.com/realms/example-realm/protocol/openid-connect/auth
      token_url: https://iam.example.com/realms/example-realm/protocol/openid-connect/token
      user_info_url: https://iam.example.com/realms/example-realm/protocol/openid-connect/userinfo
      scopes:
        - openid
        - email
        - profile
      callback_urls:
        - https://vouch.example.com/auth
      preferredDomain:
```
