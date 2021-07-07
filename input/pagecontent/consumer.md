Consumer-facing client applications **SHALL** obtain an access token for access to FHIR resources by following the OAuth 2.0 authorization code grant flow, as extended by the SMART App Launch Framework, and with the additional options and constraints discussed below.

### Obtaining an authorization code

Client applications **SHALL** request an authorization code as per [section 7.1.1](http://hl7.org/fhir/smart-app-launch/1.0.0/index.html#step-1-app-asks-for-authorization) of the HL7 SMART App Launch Framework, with the following additional constraints. Client applications are **NOT REQUIRED** to include a launch scope or launch context requirement scope. Client applications and servers **MAY** optionally support UDAP Tiered OAuth for User Authentication to allow for cross-organizational or third party user authentication.

Servers **SHALL** handle and respond to authorization code requests as per [section 7.1.2](http://hl7.org/fhir/smart-app-launch/1.0.0/index.html#step-2-ehr-evaluates-authorization-request-asking-for-end-user-input) of the HL7 SMART App Launch Framework.

### Obtaining an access token

Client applications **SHALL** exchange authorization codes for access tokens as per [section 7.1.3](http://hl7.org/fhir/smart-app-launch/1.0.0/index.html#step-3-app-exchanges-authorization-code-for-access-token) of the HL7 SMART App Launch Framework, with the following additional options and constraints.

#### Constructing Authentication Token

If the client app has registered to authenticate using a private key rather than a shared client_secret, then the client **SHALL** use its private key to sign an Authentication Token as described in this section, and include this JWT in the `client_assertion` parameter of its token request as described in section 5.1 of UDAP JWT-Based Client Authentication and detailed further in [Section 4.2.2] of this guide. This overrides the requirement for the client to use HTTP Basic Authentication with a client_secret in [Section 7.1.3](http://hl7.org/fhir/smart-app-launch/1.0.0/index.html#step-3-app-exchanges-authorization-code-for-access-token) of the SMART App Launch Framework.

Authentication Tokens submitted by client apps **SHALL** conform to the general JWT header requirements above and **SHALL** include the following parameters in the JWT claims defined in Section 4 of UDAP JWT-Based Client Authentication:

<table class="table">
  <thead>
    <th colspan="3">Authentication JWT Claims</th>
  </thead>
  <tbody>
    <tr>
      <td><code>iss</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The unique identifying URI client for this client application and client app operator. This URI <strong>SHALL</strong> match the value of a <code>uniformResourceIdentifier</code> entry in the Subject Alternative Name extension of the client's certificate included
        in the <code>x5c</code> JWT header.
      </td>
    </tr>
    <tr>
      <td><code>sub</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The application's <code>client_id</code> as assigned by the authorization server during the registration process
      </td>
    </tr>
    <tr>
      <td><code>aud</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The FHIR authorization server's token endpoint URL
      </td>
    </tr>
    <tr>
      <td><code>exp</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Expiration time integer for this authentication JWT, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC).
      </td>
    </tr>
    <tr>
      <td><code>iat</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Issued time integer for this authentication JWT, expressed in seconds since the "Epoch"
      </td>
    </tr>
    <tr>
      <td><code>jti</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A nonce string value that uniquely identifies this authentication JWT. This value <strong>SHALL NOT</strong> be reused by the client app in another authentication JWT before the time specified in the <code>exp</code> claim has passed
      </td>
    </tr>
  </tbody>
</table>

The maximum lifetime for an Authentication Token **SHALL** be 5 minutes, i.e. the value of `exp` minus the value of `iat` **SHALL NOT** exceed 300 seconds. The Authorization Server **MAY** ignore any unrecognized claims in the Authentication Token. The Authentication Token **SHALL** be signed and serialized using the JSON compact serialization method.

#### Submitting a token request

For client applications authenticating with a shared secret, the client application and server **SHALL** follow the token request and response protocol in Section 7.1.3 of the HL7 SMART App Launch Framework.

Client applications authenticating with a private key and Authentication Token as per [Section 4.2.1] **SHALL** submit a POST request to the Authorization Server's token endpoint containing the following parameters as per Section 5.1 of UDAP JWT-Based Client Authentication. Client apps authenticating in this manner **SHALL NOT** include an HTTP Authorization header or client secret in its token endpoint request. The token request **SHALL** include the following parameters:

<table class="table">
  <thead>
    <th colspan="3">Token request parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>grant_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Fixed value: <code>authorization_code</code>
      </td>
    </tr>
    <tr>
      <td><code>code</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The code that the app received from the authorization server
      </td>
    </tr>
    <tr>
      <td><code>redirect_uri</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The client application's redirection URI matching the <code>redirect_uri</code> value included in the initial authorization endpoint request
      </td>
    </tr>
    <tr>
      <td><code>client_assertion_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Fixed value: <code>urn:ietf:params:oauth:client-assertion-type:jwt-bearer</code>
      </td>
    </tr>
    <tr>
      <td><code>client_assertion</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The signed Authentication Token JWT
      </td>
    </tr>
    <tr>
      <td><code>udap</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Fixed value: <code>1</code>
      </td>
    </tr>
  </tbody>
</table>

Authorization servers receiving token requests containing Authentication Tokens as above **SHALL** validate and respond to the request as per Sections 6 and 7 of UDAP JWT-Based Client Authentication.

For all successful token requests, the Authorization Server **SHALL** issue access tokens with a lifetime no longer than 60 minutes.

{% include link-list.md %}