The requirements in this section are applicable to both consumer-facing and B2B apps and the servers that support them.

Before FHIR data requests can be made, Client application operators **SHALL** register each of their applications with the Authorization Servers identified by the FHIR servers with which they wish to exchange data.  Client applications **SHALL** use the client_id assigned by an Authorization Server in subsequent authorization and token requests to that server.

Authorization Servers **SHALL** support dynamic registration as specified in the [UDAP Dynamic Client Registration](https://www.udap.org/udap-dynamic-client-registration-stu1.html) profile with the additional options and constraints defined in this guide. Confidential clients that can secure a secret **MAY** use this dynamic client registration protocol as discussed further below to obtain a `client_id`. Other client types **SHOULD** follow the manual registration processes for each Authorization Server. Future versions of this guide may add support for dynamic client registration by public clients which cannot protect a private key.

The dynamic registration workflow is summarized in the following diagram:
<br>
<div>
{% include registration.svg %}
</div>

### Software Statement

To register dynamically, the client application first constructs a software statement as per [section 2](https://www.udap.org/udap-dynamic-client-registration-stu1.html#section-2) of UDAP Dynamic Client Registration.

The software statement **SHALL** contain the required header elements specified in [Section 1.2.3] of this guide and the JWT claims listed in the table below.  The software statement **SHALL** be signed by the client application operator using the signature algorithm identified in the `alg` header of the software statement and with the private key that corresponds to the public key listed in the client's X.509 certificate identified in the `x5c` header of the software statement.

<table class="table">
  <thead>
    <th colspan="3">Software Statement JWT Claims</th>
  </thead>
  <tbody>
    <tr>
      <td><code>iss</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Issuer of the JWT -- unique identifying client URI. This <strong>SHALL</strong> match the value of a uniformResourceIdentifier entry in the Subject Alternative Name extension of the client's certificate included in the <code>x5c</code> JWT header and <strong>SHALL</strong> uniquely identify a single client app operator and application over time.
      </td>
    </tr>
    <tr>
      <td><code>sub</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Same as <code>iss</code>. In typical use, the client application will not yet have a <code>client_id</code> from the Authorization Server
      </td>
    </tr>
    <tr>
      <td><code>aud</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The Authorization Server's "registration URL" (the same URL to which the registration request will be posted)
      </td>
    </tr>
    <tr>
      <td><code>exp</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Expiration time integer for this software statement, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC). The <code>exp</code> time <strong>SHALL</strong> be no more than 5 minutes after the value of the <code>iat</code> claim.
      </td>
    </tr>
    <tr>
      <td><code>iat</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Issued time integer for this software statement, expressed in seconds since the "Epoch"
      </td>
    </tr>
    <tr>
      <td><code>jti</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A nonce string value that uniquely identifies this software statement. See <a href="index.html#jwt-claims">Section 1.2.4</a> for additional requirements regarding reuse of values.
      </td>
    </tr>
    <tr>
      <td><code>client_name</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A string containing the human readable name of the client application
      </td>
    </tr>
    <tr>
      <td><code>redirect_uris</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        An array of one or more redirection URIs used by the client application. This claim SHALL be present if <code>grant_types</code> includes <code>"authorization_code"</code> and this claim SHALL be absent otherwise. Each URI SHALL use the https scheme.
      </td>
    </tr>
    <tr>
      <td><code>contacts</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        An array of URI strings indicating how the data holder can contact the app operator regarding the application. The array <strong>SHALL</strong> contain at least one valid email address using the <code>mailto</code> scheme, e.g.<br>
        <code>["mailto:operations@example.com"]</code>
      </td>
    </tr>
    <tr>
      <td><code>logo_uri</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        A URL string referencing an image associated with the client application, i.e. a logo. If <code>grant_types</code> includes <code>"authorization_code"</code>, client applications <strong>SHALL</strong> include this field, and the Authorization Server <strong>MAY</strong> display this logo to the user during the authorization process. The URL <strong>SHALL</strong> use the https scheme and reference a PNG, JPG, or GIF image file, e.g. <code>"https://myapp.example.com/MyApp.png"</code>
      </td>
    </tr>
    <tr>
      <td><code>grant_types</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Array of strings, each representing a requested grant type, from the following list: <code>"authorization_code"</code>, <code>"refresh_token"</code>, <code>"client_credentials"</code>. The array <strong>SHALL</strong> include either <code>"authorization_code"</code> or <code>"client_credentials"</code>, but not both. The value <code>"refresh_token"</code> <strong>SHALL NOT</strong> be present in the array unless <code>"authorization_code"</code> is also present.
      </td>
    </tr>
    <tr>
      <td><code>response_types</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        Array of strings. If <code>grant_types</code> contains <code>"authorization_code"</code>, then this element <strong>SHALL</strong> have a fixed value of <code>["code"]</code>, and <strong>SHALL</strong> be omitted otherwise
      </td>
    </tr>
    <tr>
      <td><code>token_endpoint_auth_method</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Fixed string value: <code>"private_key_jwt"</code>
      </td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        String containing a space delimited list of scopes requested by the client application for use in subsequent requests. The Authorization Server <strong>MAY</strong> consider this list when deciding the scopes that it will allow the application to subsequently request. Note for client apps that also support the SMART App Launch framework: apps requesting the <code>"client_credentials"</code> grant type <strong>SHOULD</strong> request system scopes; apps requesting the <code>"authorization_code"</code> grant type <strong>SHOULD</strong> request user or patient scopes.
      </td>
    </tr>
  </tbody>
</table>


<div class="stu-note" markdown="1">
1. This guide does not currently constrain the URI scheme used to identify clients in the `iss` claim of the Authentication Token. The `https` scheme is used to identify FHIR servers, and can generally also be used for clients. However, other URI schemes can be used by communities where client app operators are not well represented by unique URLs. Communities supporting emerging concepts such as decentralized identifiers to represent client app operators may also consider using the `did` scheme for issuers of UDAP assertions.
</div>

### Example

#### Client Credentials

Example software statement, prior to Base64URL encoding and signature, for a B2B app that is requesting the use of the client credentials grant type (non-normative, the "." between the header and claims objects is a convenience notation only):

```
{
  "alg": "RS256",
  "x5c": ["MIEF.....remainder omitted for brevity"]
}.{
  "iss": "http://example.com/my-b2b-app",
  "sub": "http://example.com/my-b2b-app",
  "aud": "https://oauth.example.net/register",
  "exp": 1597186041,
  "iat": 1597186341,
  "jti": "random-value-109a3bd72"
  "client_name": "Acme B2B App",
  "contacts": ["mailto:b2b-operations@example.com"],
  "grant_types": ["client_credentials"],
  "token_endpoint_auth_method": "private_key_jwt",
  "scope": "system/Patient.read system/Procedure.read"
}
```

#### Authorization Code

Example software statement, prior to Base64URL encoding and signature, for a B2B app that is requesting the use of the client credentials grant type (non-normative, the "." between the header and claims objects is a convenience notation only):

```
{
  "alg": "RS256",
  "x5c": ["MIEF.....remainder omitted for brevity"]
}.{
  "iss": "http://example.com/my-user-b2b-app",
  "sub": "http://example.com/my-user-b2b-app",
  "aud": "https://oauth.example.net/register",
  "exp": 1597186054,
  "iat": 1597186354,
  "jti": "random-value-f83f37a29"
  "client_name": "Acme B2B User App",
  "redirect_uris": ["https://b2b-app.example.com/redirect"],
  "contacts": ["mailto:b2b-operations@example.com"],
  "logo_uri": "https://b2b-app.example.com/B2BApp.png",
  "grant_types": ["authorization_code", "refresh_token"],
  "response_types": ["code"],
  "token_endpoint_auth_method": "private_key_jwt",
  "scope": "user/Patient.read user/Procedure.read"
}
```

#### Request Body

The registration request for use of either grant type is submitted by the client to the Authorization Server's registration endpoint.

```
POST /register HTTP/1.1
Host: oauth.example.net
Content-Type: application/json

{
   "software_statement": "...the signed software statement JWT...",
   "certifications": ["...a signed certification JWT..."]
   "udap": "1"
}
```

The Authorization Server **SHALL** validate the registration request as per [Section 4](https://www.udap.org/udap-dynamic-client-registration-stu1.html#section-4) of UDAP Dynamic Client Registration. This includes validation of the JWT payload and signature, validation of the X.509 certificate chain, and validation of the requested application registration parameters.

If a new registration is successful, the Authorization Server **SHALL** return a registration response with a `201 Created` HTTP response code as per [Section 5.1](https://www.udap.org/udap-dynamic-client-registration-stu1.html#section-5.1) of UDAP Dynamic Client Registration, including the unique `client_id` assigned by the Authorization Server to that client app. Since the UDAP Dynamic Client Registration profile specifies that a successful registration response is returned as per [Section 3.2.1 of RFC 7591], the authorization server **MAY** reject or replace any of the client's requested metadata values submitted during the registration and substitute them with suitable values.

If a new registration is not successful, e.g. it is rejected by the server for any reason, the Authorization Server **SHALL** return an error response as per [Section 5.2](https://www.udap.org/udap-dynamic-client-registration-stu1.html#section-5.2) of UDAP Dynamic Client Registration.

### Inclusion of Certifications and Endorsements

Authorization Servers **MAY** support the inclusion of certifications and endorsements by client application operators using the certifications framework outlined in [UDAP Certifications and Endorsements for Client Applications](https://www.udap.org/udap-certifications-and-endorsements-stu1.html). Authorization Servers **SHALL** ignore unsupported or unrecognized certifications.

Authorization Servers **MAY** require registration requests to include one or more certifications. If an Authorization Server requires the inclusion of a certain certification, then the Authorization Server **SHALL** communicate this by including the corresponding certification URI in the `udap_certifications_required` element of its UDAP metadata.

An example template application to declare additional information about the client application at the time of registration is described in [Section 8.3] of this guilde.

### Modifying and Cancelling Registrations

Within a trust community, the client URI in the Subject Alternative Name of an X.509 certificate uniquely identifies a single application and its operator over time. Thus, a registered client application **MAY** request a modification of its registration with an Authorization Server by submitting another registration request to the same Authorization Server's registration endpoint with a software statement containing a certificate corresponding to the same trust community and with the same `iss` value as was used in the original registration request. An Authorization Server accepting such a request **SHALL** only update the registration previously made in the context of the corresponding trust community, as detailed in the next paragraph, and **SHALL NOT** overwrite an existing registration made in the context of a different trust community.

If an Authorization Server receives a valid registration request with a software statement containing a certificate corresponding to the same trust community and with the same `iss` value as an earlier software statement but with a different set of claims or claim values, or with a different (possibly empty) set of optional certifications and endorsements, the server **SHALL** treat this as a request to modify the registration parameters for the client application by replacing the information from the previous registration request with the information included in the new request. For example, an Application operator could use this mechanism to update a redirection URI or to remove or update a certification. If the registration modification request is accepted, the Authorization Server **SHOULD** return the same `client_id` in the registration response as for the previous registration. If it returns a different `client_id`, it **SHALL** cancel the registration for the previous `client_id`.

If an Authorization Server receives a valid registration request with a software statement that contains an empty `grant_types` array from a previously registered application as per the previous paragraph, the server **SHOULD** interpret this as a request to cancel the previous registration. A client application **SHALL** interpret a registration response that contains an empty `grant_types` array as a confirmation that the registration for the `client_id` listed in the response has been cancelled by the Authorization Server.

If the Authorization Server returns the same `client_id` in the registration response for a modification request, it SHOULD also return a `200 OK` HTTP response code. If the Authorization Server returns a new `client_id` in the registration response, the client application **SHALL** use only the new `client_id` in subsequent transactions with the Authorization Server.

{% include link-list.md %}