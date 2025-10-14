This guide supports B2B client applications using either the client credentials or authorization code grant types. The B2B transactions in this guide occur between a requesting organization (the Requestor operating the client application) and a responding organization (the Responder operating the OAuth Server and Resource Server holding the data of interest to the Requestor). In some cases, the Requestor's client app operates in an automated manner. In other cases, there will also be a local user from the requesting organization (the User interacting with the Requestor's client application). The client credentials grant type is always used for automated (aka "headless") client apps. However, when a User is involved, either the client credentials or authorization code grant may be used, as discussed below.

For client credentials flow, any necessary User authentication and authorization is performed by the Requestor as a prerequisite, before the Requestor's client app interacts with the Responder's servers, i.e. the Requestor is responsible for ensuring that only its authorized Users access the client app and only make requests allowed by the Requestor. How the Requestor performs this is out of scope for this guide but will typically rely on internal user authentication and access controls.

<div class="stu-note" markdown="1">
 Examples of automated client apps that use the client credentials grant type include SMART App Launch Backend Services and certain IUA Authorization Clients.
</div>

For authorization code flow, the User is expected to be interacting with the Requestor's client app in real time, at least during the initial authorization of the client app with the Responder's OAuth Server. Typically, the User must authenticate to the Responder's system at the time of initial authorization. If the local user has been issued credentials by the Responder to use for this purpose, the authorization code flow will typically involve use of those credentials. However, it is anticipated that in some workflows, the local user will not have their own credentials on the Responder's system, but will instead have credentials on their "home" system. In these cases, the UDAP Tiered OAuth workflow is used so that the Responder's OAuth Server can interact with the Requestor's OIDC Server in an automated manner to authenticate the User, as described in [Section 6].

Thus, this guide provides two different paths (client credentials grants and authorization code grants with Tiered OAuth) that a user affiliated with the Requestor without credentials on the Responder's system may use to obtain access to data held by the Responder.

B2B client applications registered to use the authorization code grant **SHALL** obtain an access token for access to FHIR resources by following the OAuth 2.0 authorization code grant flow described in [Section 4.1](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1) of RFC 6749, with the additional options and constraints discussed below. 

Client applications registered to use the client credentials grant **SHALL** obtain an access token for access to FHIR resources by following the OAuth 2.0 client credentials grant flow described in [Section 4.4](https://datatracker.ietf.org/doc/html/rfc6749#section-4.4) of RFC 6749, and with the additional options and constraints discussed below. As noted in [Section 3], the Requestor is responsible for ensuring that the Requestor's User, if applicable, is using the app only as authorized by the Requestor.

### Obtaining an authorization code

The section does not apply to client applications registered to use the client credentials grant.

The workflow for obtaining an authorization code is summarized in the following diagram:
<br>
<div>
{% include authz.svg %}
</div>

Client applications registered to use the authorization code grant **SHALL** request an authorization code as per [Section 4.1.1](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.1) of RFC 6749, with the following additional constraints. Client applications and servers **MAY** optionally support UDAP Tiered OAuth for User Authentication to allow for cross-organizational or third party user authentication as described in [Section 6].

Servers **SHALL** handle and respond to authorization code requests as per [Section 4.1.2](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.2) of RFC 6749.

Client applications and Authorization Servers using the authorization code flow **SHALL** conform to the additional constraints for authorization code flow found in [Section 7.2] of this guide.

### Obtaining an access token

The workflow for obtaining an access token is summarized in the following diagram:
<br>
<div>
{% include token.svg %}
</div>

Client applications using the authorization code flow **SHALL** exchange authorization codes for access tokens as per [Section 4.1.3](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.3) of RFC 6749, with the following additional options and constraints. Client applications using the client credentials flow do not use authorization codes when requesting an access token.

Client applications using the authorization code flow **SHALL** include a `code_verifier` parameter and value in the token request as per Section 4.5 of RFC 7636.

#### Constructing Authentication Token

Client apps following this guide will have registered to authenticate using a private key rather than a shared `client_secret`. Thus, the client **SHALL** use its private key to sign an Authentication Token as described in this section, and include this JWT in the `client_assertion` parameter of its token request as described in [Section 5.1](https://www.udap.org/udap-jwt-client-auth-stu1.html#section-5.1) of UDAP JWT-Based Client Authentication and detailed further in [Section 5.2.2] of this guide.

Authentication Tokens submitted by client apps **SHALL** conform to the general JWT header requirements in [Section 7.1] of this guide and **SHALL** include the following parameters in the JWT claims, as defined in [Section 4](https://www.udap.org/udap-jwt-client-auth-stu1.html#section-4) of UDAP JWT-Based Client Authentication and [Section 4](https://www.udap.org/udap-client-authorization-grants-stu1.html#section-4) of UDAP Client Authorization Grants using JSON Web Tokens:

<table class="table">
  <thead>
    <th colspan="3">Authentication JWT Claims</th>
  </thead>
  <tbody>
    <tr>
      <td><code>iss</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The application's <code>client_id</code> as assigned by the Authorization Server during the registration process
      </td>
    </tr>
    <tr>
      <td><code>sub</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The application's <code>client_id</code> as assigned by the Authorization Server during the registration process
      </td>
    </tr>
    <tr>
      <td><code>aud</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The FHIR Authorization Server's token endpoint URL
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
        A nonce string value that uniquely identifies this authentication JWT. See <a href="general.html#jwt-claims">Section 7.1.4</a> for additional requirements regarding reuse of values.
      </td>
    </tr>
    <tr>
      <td><code>extensions</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        A JSON object containing one or more extensions. The HL7 B2B Authorization Extension Object defined below is required for B2B client apps using the <code>client_credentials</code> flow; omit for client apps using the <code>authorization_code</code> flow
      </td>
    </tr>
  </tbody>
</table>

The maximum lifetime for an Authentication Token **SHALL** be 5 minutes, i.e. the value of `exp` minus the value of `iat` **SHALL** NOT exceed 300 seconds. The Authorization Server **MAY** ignore any unrecognized claims in the Authentication Token. The Authentication Token **SHALL** be signed and serialized using the JSON compact serialization method.

##### B2B Authorization Extension Object

The B2B Authorization Extension Object is used by client apps following the `client_credentials` flow to provide additional information regarding the context under which the request for data would be authorized. The client app constructs a JSON object containing the following keys and values and includes this object in the `extensions` object of the Authentication JWT as the value associated with the key name `hl7-b2b`.

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
        String containing the human readable name of the human or non-human requestor; required if known.
      </td>
    </tr>
    <tr>
      <td><code>subject_id</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        String containing a unique identifier for the requestor; required if known for human requestors when the <code>subject_name</code> parameter is present and the human requestor has been assigned an applicable identifier. Omit for non-human requestors and for human requestors who have not been assigned an applicable identifier. See Section 5.2.1.3 below for the preferred format of the identifier value string.
      </td>
    </tr>
    <tr>
      <td><code>subject_role</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        String containing a code identifying the role of the requestor; required if known for human requestors when the <code>subject_name</code> parameter is present. See Section 5.2.1.3 below for the preferred format of the code value string.
      </td>
    </tr>
    <tr>
      <td><code>organization_name</code></td>
      <td><span class="label label-warning">optional</span></td>
      <td>
        String containing the human readable name of the organizational requestor. If a subject is named, the organizational requestor is the organization represented by the subject.
      </td>
    </tr>
    <tr>
      <td><code>organization_id</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        String containing a unique identifier for the organizational requestor. If a subject is named, the organizational requestor is the organization represented by the subject. The identifier <strong>SHALL</strong> be a Uniform Resource Identifier (URI). Trust communities <strong>SHALL</strong> define the allowed URI scheme(s). If a URL is used, the issuer <strong>SHALL</strong> include a URL that is resolvable by the receiving party.
      </td>
    </tr>
    <tr>
      <td><code>purpose_of_use</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        An array of one or more strings, each containing a code identifying a purpose for which the data is being requested. See Section 5.2.1.3 below for the preferred format of each code value string array element.
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
        An array of one or more strings, each containing an absolute URL consistent with a <a href="https://www.hl7.org/fhir/R4/references.html#literal">literal reference</a> to a FHIR <a href="https://www.hl7.org/fhir/R4/consent.html">Consent</a> or <a href="https://www.hl7.org/fhir/R4/documentreference.html">DocumentReference</a> resource containing or referencing a privacy consent directive relevant to a purpose identified by the <code>purpose_of_use</code> parameter and the policy or policies identified by the <code>consent_policy</code> parameter. The issuer of this Authorization Extension Object <strong>SHALL</strong> only include URLs that are resolvable by the receiving party. If a referenced resource does not include the raw document data inline in the resource or as a contained resource, then it <strong>SHALL</strong> include a URL to the attachment data that is resolvable by the receiving party. Omit if <code>consent_policy</code> is not present.
      </td>
    </tr>
  </tbody>
</table>

Servers that support the B2B client credentials flow described in this guide **SHALL** support this B2B Authorization Extension Object. Other implementation guides **MAY** define additional Authorization Extension Objects to use together with this object for B2B client credentials workflows.

##### Preferred code systems and naming systems for US Realm

For `subject_id`, trust communities <strong>SHALL</strong> constrain the allowed naming system or systems, and are encouraged to require the individual National Provider Identifier (NPI) when known for human requestors who have been assigned an individual NPI.

For `subject_role`, trust communities <strong>SHOULD</strong> constrain the allowed values and formats, and are encouraged to draw from the National Uniform Claim Committee (NUCC) Provider Taxonomy Code Set, but are not required to do so to be considered conformant. 

For `purpose_of_use`, trust communities <strong>SHOULD</strong> constrain the allowed values, and are encouraged to draw from the HL7 <a href="http://terminology.hl7.org/ValueSet/v3-PurposeOfUse">PurposeOfUse</a> value set, but are not required to do so to be considered conformant.

##### Preferred format for identifiers and codes

The preferred format to represent an identifier or code as a string value within an authorization extension object is as a Uniform Resource Identifier (URI) as defined in [RFC 3986]. Trust communities are encouraged to use this preferred format, but are not required to do so to be considered conformant with this guide. 

If the identifier or code is itself a URI, then the native representation is preferred. Otherwise, the preferred method to construct a URI is as follows:

For identifiers, concatenate a URI identifying the namespace, the '#' character, and the unique identifier assigned within the namespace. 

For codes, concatenate a URI identifying the code system, the '#' character, and a code taken from the code system.

For example, the U.S. NPI number 1234567890 can be represented as `urn:oid:2.16.840.1.113883.4.6#1234567890` and the purpose of use treatment can be represented as `urn:oid:2.16.840.1.113883.5.8#TREAT`.

#### Submitting a token request

##### Authorization code grant

Client applications using the authorization code grant and authenticating with a private key and Authentication Token as per [Section 5.2.1] **SHALL** submit a POST request to the Authorization Server's token endpoint containing the following parameters as per [Section 5.1](https://www.udap.org/udap-jwt-client-auth-stu1.html#section-5.1) of UDAP JWT-Based Client Authentication. Client apps authenticating in this manner **SHALL NOT** include an HTTP Authorization header or client secret in its token endpoint request. The token request **SHALL** include the following parameters:

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
        The code that the app received from the Authorization Server
      </td>
    </tr>
    <tr>
      <td><code>redirect_uri</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        The client application's redirection URI. This parameter <strong>SHALL</strong> be present only if the <code>redirect_uri</code> parameter was included in the authorization request in Section 5.1, and their values <strong>SHALL</strong> be identical.
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

Client applications using the client credentials grant and authenticating with a private key and Authentication Token as per [Section 5.2.1] **SHALL** submit a POST request to the Authorization Server's token endpoint containing the following parameters as per [Section 5.2](https://www.udap.org/udap-jwt-client-auth-stu1.html#section-5.2) of UDAP JWT-Based Client Authentication. Client apps authenticating in this manner **SHALL NOT** include an HTTP Authorization header or client secret in its token endpoint request. The token request **SHALL** include the following parameters:

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
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Space-delimited list of requested scopes of access.
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

#### Server processing of token requests

An Authorization Server receiving token requests containing Authentication Tokens as above **SHALL** validate and respond to the request as per [Sections 6 and 7](https://www.udap.org/udap-jwt-client-auth-stu1.html#section-6) of UDAP JWT-Based Client Authentication.

For client applications using an authorization code grant, the Authorization Server **SHALL** return an error as per Section 4.6 of RFC 7636 if the client included a `code_challenge` in its authorization request but did not include the correct `code_verfier` value in the corresponding token request.

For all successful token requests, the Authorization Server **SHALL** issue access tokens with a lifetime no longer than 60 minutes.

<div class="stu-note" markdown="1">
This guide does not currently constrain the type or format of access tokens issued by Authorization Servers. Note that other implementation guides (e.g. SMART App Launch, IUA, etc.), when used together with this guide, may limit the allowed access token types (e.g. Bearer) and/or formats (e.g. JWT).
</div>

#### Client application use of access tokens

A client application **SHALL** only use an access token in a manner consistent with any assertions made when requesting that token. For example, if a client asserted a `subject_id` and `purpose_of_use` in the B2B Authorization Extension Object included in its token request, then the access token granted in response to that request can only be used in that authorization context, i.e. for that requestor and for that purpose. If the same client application subsequently needs to retrieve a resource for a different requestor and/or for a different purpose from the same resource server, it cannot reuse the same access token. Instead, it must obtain a new access token by submitting another token request with an updated B2B Authorization Extension Object asserting the new authorization context.

### Refresh tokens

This guide supports the use of refresh tokens, as described in [Section 1.5 of RFC 6749]. Authorization Servers **MAY** issue refresh tokens to B2B client applications that use the authorization code grant type as per [Section 5 of RFC 6749]. Refresh tokens are not used with the client credentials grant type. Client apps that have been issued refresh tokens **MAY** make refresh requests to the token endpoint as per [Section 6 of RFC 6749]. Client apps authenticate to the Authorization Server for refresh requests by constructing and including an Authentication Token in the same manner as for initial token requests.

{% include link-list.md %}
