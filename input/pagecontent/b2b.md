B2B client applications registered to use the authorization code grant **SHALL** obtain an access token for access to FHIR resources by following the OAuth 2.0 authorization code grant flow described in [Section 4.1](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1) of RFC 6749, as extended by the SMART App Launch Framework, and with the additional options and constraints discussed below. 

Client applications registered to use the client credentials grant **SHALL** obtain an access token for access to FHIR resources by following the OAuth 2.0 client credentials grant flow described in [Section 4.4](https://datatracker.ietf.org/doc/html/rfc6749#section-4.4) of RFC 6749, and with the additional options and constraints discussed below. As noted in [Section 3], the Requestor is responsible for ensuring that the Requestor's User, if applicable, is using the app only as authorized by the Requestor.

### Obtaining an authorization code

The section does not apply to client applications registered to use the client credentials grant.

Client applications registered to use the authorization code grant **SHALL** request an authorization code as per [section 7.1.1](http://hl7.org/fhir/smart-app-launch/1.0.0/index.html#step-1-app-asks-for-authorization) of the HL7 SMART App Launch Framework, with the following additional constraints. Client applications are **NOT REQUIRED** to include a launch scope or launch context requirement scope. Client applications and servers **MAY** optionally support UDAP Tiered OAuth for User Authentication to allow for cross-organizational or third party user authentication.

Servers **SHALL** handle and respond to authorization code requests as per [section 7.1.2](http://hl7.org/fhir/smart-app-launch/1.0.0/index.html#step-2-ehr-evaluates-authorization-request-asking-for-end-user-input) of the HL7 SMART App Launch Framework.

### Obtaining an access token

Client applications using the authorization code flow **SHALL** exchange authorization codes for access tokens as per section [7.1.3](http://hl7.org/fhir/smart-app-launch/1.0.0/index.html#step-3-app-exchanges-authorization-code-for-access-token) of the HL7 SMART App Launch Framework, with the following additional options and constraints. Client applications using the client credentials flow do not use authorization codes.

#### Constructing Authentication Token

Client app following this guide will have registered to authenticate using a private key rather than a shared `client_secret`. Thus, the client **SHALL** use its private key to sign an Authentication Token as described in this section, and include this JWT in the `client_assertion` parameter of its token request as described in section 5.1 of UDAP JWT-Based Client Authentication and detailed further in [Section 5.2.2] of this guide.

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
        Expiration time integer for this authentication JWT, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC)
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
    <tr>
      <td><code>extensions</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        An array of JSON objects containing the HL7 B2B Authorization Extension Object defined below; required for B2B client apps using the <code>client_credentials</code> flow; omit for client apps using the <code>authorization_code</code> flow
      </td>
    </tr>
  </tbody>
</table>

The maximum lifetime for an Authentication Token **SHALL** be 5 minutes, i.e. the value of `exp` minus the value of `iat` **SHALL** NOT exceed 300 seconds. The Authorization Server **MAY** ignore any unrecognized claims in the Authentication Token. The Authentication Token **SHALL** be signed and serialized using the JSON compact serialization method.

##### B2B Authorization Extension Object

The B2B Authorization Extension Object is used by client apps following the `client_credentials` flow to provide additional information regarding the context under the request for data is authorized. The client app constructs a JSON object containing the following keys and values and includes this object in the `extensions` array of the Authentication JWT as the value associated with the key name `hl7-b2b`.

<table class="table">
  <thead>
    <th colspan="3">B2B Authorization Extension Object<br>Key Name: "hl7-b2b"</th>
  </thead>
  <tbody>
    <tr>
      <td><code>version</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        String with fixed value: <code>"1"</code>
      </td>
    </tr>
    <tr>
      <td><code>subject_name</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        String containing the human readable name of the human requestor; required when applicable; omit if request was not triggered by human action. 
      </td>
    </tr>
    <tr>
      <td><code>subject_id</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        String containing a unique identifier for subject; required if known when the <code>subject_name</code> parameter is present. For US Realm, the value of the string <strong>SHALL</strong> be the subject's individual National Provider Identifier (NPI); omit for subjects who have not been assigned an NPI.
      </td>
    </tr>
    <tr>
      <td><code>subject_role</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        String containing a code identifying the role of the subject; required if known when the <code>subject_name</code> parameter is present. For US Realm, the value of the string <strong>SHALL</strong> be a code from the National Uniform Claim Committee (NUCC) Provider Taxonomy.
      </td>
    </tr>
    <tr>
      <td><code>organization_name</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        String containing the human readable name of the organizational requestor. If a subject is named, the organizational requestor is the organization represented by the subject.
      </td>
    </tr>
    <tr>
      <td><code>organization_id</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        String containing a unique identifier for the organization. The identifier <strong>SHALL</strong> be a Uniform Resource Identifier (URI). Trust communities <strong>SHALL</strong> define the allowed URI scheme(s). If a URL is used, the issuer <strong>SHALL</strong> include a URL that is resolvable by the receiving party.
      </td>
    </tr>
    <tr>
      <td><code>purpose_of_use</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        An array of one or more strings, each containing a code identifying a purpose for which the data is being requested. For US Realm, trust communities <strong>SHOULD</strong> constrain the allowed values, and are encouraged to draw from the HL7 <a href="http://terminology.hl7.org/ValueSet/v3-PurposeOfUse">PurposeOfUse</a> value set, but are not required to do so to be considered conformant.
      </td>
    </tr>
    <tr>
      <td><code>consent_policy</code></td>
      <td><span class="label label-warning">optional</span></td>
      <td>
        An array of one or more strings, each containing a URI identifiying a privacy consent directive policy or other policy consistent with the value of the <code>purpose_of_use</code> parameter.
      </td>
    </tr>
    <tr>
      <td><code>consent_reference</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        An array of one or more strings, each containing the absolute URL of a FHIR [Consent] or [DocumentReference] resource containing or referencing a privacy consent directive relevant to a purpose identified by the <code>purpose_of_use</code> parameter and the policy or policies identified by the <code>consent_policy</code> parameter. The issuer of this Authorization Extension Object <strong>SHALL</strong> only include URLs that are resolvable by the receiving party. If a referenced resource does not include the raw document data inline in the resource or as a contained resource, then it <strong>SHALL</strong> include a URL to the attachment data that is resolvable by the receiving party. Omit if <code>consent_policy</code> is not present.
      </td>
    </tr>
  </tbody>
</table>

#### Submitting a token request

##### Authorization code grant

Client applications using the authorization code grant and authenticating with a private key and Authentication Token as per [Section 5.2.1] **SHALL** submit a POST request to the Authorization Server's token endpoint containing the following parameters as per Section 5.1 of UDAP JWT-Based Client Authentication. Client apps authenticating in this manner **SHALL NOT** include an HTTP Authorization header or client secret in its token endpoint request. The token request **SHALL** include the following parameters:

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

##### Client credentials grant

Client applications using the client credentials grant and authenticating with a private key and Authentication Token as per [Section 5.2.1] **SHALL** submit a POST request to the Authorization Server's token endpoint containing the following parameters as per Section 5.2 of UDAP JWT-Based Client Authentication. Client apps authenticating in this manner **SHALL NOT** include an HTTP Authorization header or client secret in its token endpoint request. The token request **SHALL** include the following parameters:

<table class="table">
  <thead>
    <th colspan="3">Token request parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>grant_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Fixed value: <code>client_credentials</code>
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
