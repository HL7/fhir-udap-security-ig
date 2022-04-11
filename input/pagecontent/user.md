The requirements in this section are applicable to both consumer-facing and B2B apps and the servers that support them.

Client applications registered to use the authorization code grant MAY utilize the user authentication workflow described in [UDAP Tiered OAuth for User Authentication], as profiled below. The UDAP Tiered OAuth workflow allows the client application to include the base URL of a preferred OpenID Connect Identity Provider (IdP) service in the initial request to the data holder's OAuth authorization endpoint. If Tiered OAuth is supported by the data holder and the data holder trusts the IdP indicated by the client, then the data holder will request that the IdP authenticate the user, and return authentication results and optional identity information directly to the data holder using standard OIDC workflows. Note that the client application does not interact directly with the IdP as part of this workflow.

### Client Authorization Request to Data Holder

The client app indicates the preferred Identity Provider to the data holder as per Section 2 of the [UDAP Tiered OAuth] specification by modifying the authorization endpoint request described in [Section 4.1] for consumer-facing apps or [Section 5.1] for business-to-business apps as follows:
1. Add `udap` to the list of scopes provided in the value of the `scope` query parameter, and
1. Add the extension query parameter `idp` with a value equal to the base URL of the preferred OIDC IdP.

The meaning of the extension parameter `idp` is undefined if `udap` is absent from the list of requested scopes. The IdP's base URL is the URL listed in the `iss` claim of ID tokens issued by the IdP as detailed in [Section 2](https://openid.net/specs/openid-connect-core-1_0.html#IDToken) of the OpenID Connect Core 1.0 specification (OIDC Core).

### Data Holder Authentication Request to IdP

For the purposes of the interactions between the data holder and the IdP, the data holder takes on the role of client app and the IdP takes on the role of server/data holder and interacts as per Section 3 of [UDAP Tiered OAuth], as detailed below.

This section describes the interactions between a data holder and an IdP where both parties support this implementation guide and where trust can be established via UDAP certificates. Note that this does not preclude data holders from validating trust with an IdP via other non-UDAP means that are outside the scope of this document, or from making authentication requests to IdPs that do not support UDAP workflows.
{:.bg-info}

Upon receiving an authorization request with a preferred IdP, the data holder first determines whether or not it trusts the IdP to perform user authentication, by retrieving and validating the IdP's UDAP metadata from `{baseURL}/.well-known/udap`, as discussed in [Section 2.2]. At a minimum, IdPs that support this guide **SHALL** include `"openid"` and `"udap"` in the array of scopes returned for the `scopes_supported` parameter. 

If the IdP is trusted and the data holder is not yet registered as a client with the IdP and the IdP supports UDAP Dynamic Registration, then the data holder **SHALL** register as a client with the IdP as per [Section 3] of this guide.

If the IdP is not trusted by the data holder, or if the data holder does not have and cannot obtain a client_id to use with the IdP, the data holder **MAY** reject the client app's authorization request by returning an error as per [Section 4.1.2.1 of RFC 6749], using the extension error code of `invalid_idp`. Alternatively, the data holder **MAY** attempt to authenticate the user with a different trusted IdP or its own IdP, and **MAY** interact with the user to determine a suitable alternative. A client app that receives an error code of `invalid_idp` **MAY** attempt to obtain authorization again by specifying a different IdP base URL in the `idp` authorization request parameter, or by making a new authorization request without using the Tiered OAuth workflow.

 If the IdP is trusted by the data holder, and the data holder is registered as a client with the IdP, then the data holder, acting as an OIDC client, **SHALL** make an authentication request to the IdP's authorization endpoint as per [Section 3.1.2.1 of OIDC Core] and Section 3.4 of [UDAP Tiered OAuth]. The `scope` query parameter of the authentication request **SHALL** contain at least the following two values: `openid` and `udap`. The IdP **SHALL** authenticate the user as per [Sections 3.1.2.2 - 3.1.2.6 of OIDC Core](https://openid.net/specs/openid-connect-core-1_0.html#AuthRequestValidation) and Sections 4.1 - 4.2 of [UDAP Tiered OAuth]. 

The data holder **SHALL** validate the `state` parameter value returned in the response from the IdP. If the IdP does not return a valid `state` parameter value in its authentication response, the data holder **SHALL** return a `server_error` error response to the client app and terminate this workflow as per Section 4.1 of [UDAP Tiered OAuth]. If the IdP returns an error response with a valid `state` parameter value, the data holder **SHALL** return a suitable error response to the client app and terminated this workflow as per Section 4.2 of [UDAP Tiered OAuth].

If the IdP returns a successful authentication response with valid `state` parameter value and an authorization code, the data holder **SHALL** exchange the code for an access token and ID Token by making a request to the IdP's token endpoint as per [Section 3.1.3.1 of OIDC Core] and Section 4.3 of [UDAP Tiered OAuth]. For this request, the data holder as client app **SHALL** utilize the JWT-based authentication process as described in [Section 4.2.2] of this guide. ID Tokens issued by the IdP **SHALL** conform to the requirements of [Section 1.2] of this guide and Section 4.3 of [UDAP Tiered OAuth].

If the IdP returns an ID Token, the data holder **SHALL** then validate the ID Token as per [Section 3.1.3.5 of OIDC Core]. If the IdP does not return an ID Token, or the ID Token cannot be successfully validated, or an error response is retured by the IdP, the data holder **MAY** return an `invalid_idp` error code to the client app or attempt an alternate user authentication as described above.

### Data holder interaction with user after authentication

When an ID Token has been returned and validated, the data holder **SHOULD** use the ID Token to attempt to match the authenticated user to a user or role in its own system, as appropriate for the resources requested. As discussed in Sections 4.4 and 4.5 of [UDAP Tiered OAuth], the `iss` and `sub` values of the ID Token can be used together by the data holder to identify a single person over time, i.e. the data holder can attempt to map the pair (`iss`,`sub`) to a known users in the data holder's system. If the data holder has previously performed this mapping or has otherwise bound the pair (`iss`,`sub`) to a local user or role, it **MAY** rely on this previous mapping for subsequent authentications. If the ID Token does not contain sufficient information to perform the mapping, the data holder **MAY** attempt to retrieve additional information for the IdP's UserInfo endpoint as described in [Section 5.3 of OIDC Core]. In many cases, the information provided by the IdP will allow the data holder to resolve the authenticated user to a single local user or role with high confidence. If necessary, the data holder **MAY** interact with the user following the redirection from the IdP back to the data holders redirection URI to increase confidence in the resolution process. For example, if there is more than one possible match, the data holder may transmit a one-time code to an electronic address of record known to the data holder to confirm a specific match. If the data holder is unable to resolve the authenticated user to a local user or role, as appropriate for the resources requested, it **SHALL** return an `access_denied` error response to the client app's authorization request and terminate the workflow.

If the data holder successfully maps the authenticated user to a user or role in its own system, as appropriate for the resources requested, it **SHALL** also obtain authorization from the user for the scopes requested by the client app, if such authorization is required, as per Section 4.5 of [UDAP Tiered OAuth], returning to the workflow defined in [Section 4.1] or [Section 5.1] of this guide, for consumer-facing or B2B apps, respectively.

### Examples

Note: These examples are non-normative. Line breaks and indentations have been added for readability and would not be part of an actual request or response. Additional examples can be found in the [UDAP Tiered OAuth] specification.

#### Example client app authorization request

```
GET /authorize?
  response_type=code&
  state=client_random_state&
  client_id=myIdIssuedByResourceHolder&
  scope=udap+user/*.read&
  idp=https://preferred-idp.example.com/optionalPathComponent&
  redirect_uri=https://client.example.net/redirect HTTP/1.1
Host: resourceholder.example.com
```


#### Example data holder error response

```
HTTP/1.1 302 Found
Location: https://client.example.net/clientredirect?
  error=invalid_idp&
  error_description=The+requested+identity+provider+cannot+be+used+to+sign+in+to+this+system
  state=client_random_state
```


#### Example data holder authentication request to IdP

```
HTTP/1.1 302 Found
Location: https://idp.example.com/optionalpath/authorize?
  response_type=code&
  state=resource_holder_random_state&
  client_id=resourceHolderClientIDforIdP&
  scope=openid+udap&
  nonce=resource_holder_nonce&
  redirect_uri=https://resourceholder.example.net/redirect
```


#### Example data holder token request to IdP

```
POST /optionalpath/token HTTP/1.1
Host: idp.example.com
Content-type: application/x-www-form-urlencoded

grant_type=authorization_code&
  code=authz_code_from_idp&
  client_assertion_type=urn:ietf:params:oauth:grant-type:jwt-bearer&
  client_assertion=eyJh[…remainder of AnT omitted for brevity…]&
  udap=1
```

{% include link-list.md %}