# steps to setup keycloak with argocd

1. Create a _Client_ with these values and nothing else:
<img alt="Screenshot of keycloak showing how to configure a client with clientID: argocd, rootURL: https://argocd.example.com, homeURL: https://argocd.example.com/applications, validRedirectURIs: https://argocd.example.com/auth/callback, webOrigins: +, capabilityConfig.clientAuthentication: on, authenticationFlow.standardFlow: checked, authenticationFlow.directAccessGrant: checked. There is a note pointing to Web Origin noting that it should be set to + (plus sign) for allowed CORS origins, which means it permits all origins of Valid Redirect URIs" src="./step_1_create_client.png">

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

See more [here](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/keycloak/#configuring-argocd-oidc) for the ArgoCD ConfigMap and Secret that need to be updated. Those are already configured via the helm values.yaml in small-hack/argocd, and the secrets live in this repo.
