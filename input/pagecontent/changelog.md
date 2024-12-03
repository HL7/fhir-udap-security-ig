Changes from the previous version are summarized below with links to the corresponding HL7 ticket. The summaries below are non-normative.

### Version 2.0.0-ballot - STU2 Ballot

|Ticket|Ticket Description|
|---------|----------|
|[FHIR-41520](https://jira.hl7.org/browse/FHIR-41520)|Clarify "state" parameter required for authorization code flow|
|[FHIR-42958](https://jira.hl7.org/browse/FHIR-42958)|Add guidance for use of PKCE|
|[FHIR-43005](https://jira.hl7.org/browse/FHIR-43005)|Clarify server may grant a subset of "scopes_supported"|
|[FHIR-45173](https://jira.hl7.org/browse/FHIR-45173)|Add certification example for privacy disclosures|
|[FHIR-46113](https://jira.hl7.org/browse/FHIR-46113)|Add certification example for exchange purposes|
|[FHIR-46448](https://jira.hl7.org/browse/FHIR-46448)|Add scope guidance based on TEFCA SOP|

### Version 1.1.0 - STU1 Update 1

|Ticket|Ticket Description|
|---------|----------|
|[FHIR-40459](https://jira.hl7.org/browse/FHIR-40459)|Clarify client is required to validate signed_metadata as per the UDAP server metadata profile|
|[FHIR-40579](https://jira.hl7.org/browse/FHIR-40579)|Correct inactive link in Required UDAP Metadata|
|[FHIR-40601](https://jira.hl7.org/browse/FHIR-40601)|Correct invalid link to HL7 SMART App Launch IG history|
|[FHIR-40791](https://jira.hl7.org/browse/FHIR-40791)|Clarify "aud" value in authentication JWTs|
|[FHIR-41517](https://jira.hl7.org/browse/FHIR-41517)|Clarify algorithm used by servers to sign UDAP metadata|
|[FHIR-43002](https://jira.hl7.org/browse/FHIR-43002)|Clarify that support for B2B extension is required for servers that support client credentials grants|
|[FHIR-43007](https://jira.hl7.org/browse/FHIR-43007)|Clarify conformance strength of algorithms by listing as a table|
|[FHIR-43008](https://jira.hl7.org/browse/FHIR-43008)|Clarify "jti" reuse is permitted after expiration of any previous JWTs using same value|
|[FHIR-43014](https://jira.hl7.org/browse/FHIR-43014)|Correct status code to be returned by server when community is not recognized or not supported|
|[FHIR-43021](https://jira.hl7.org/browse/FHIR-43021)|Add missing hyperlinks for certain UDAP profiles|
|[FHIR-43048](https://jira.hl7.org/browse/FHIR-43048)|Clarify servers must respond to GET requests for metadata|
|[FHIR-43116](https://jira.hl7.org/browse/FHIR-43116)|Clarify that registration updates are requested within the context of the client's trust community|
|[FHIR-43121](https://jira.hl7.org/browse/FHIR-43121)|Remove duplicated requirements for "iss" parameter in software statement|
|[FHIR-43554](https://jira.hl7.org/browse/FHIR-43554)|Clarify allowed registration claims returned by server may be different than claims submitted in software statement|

<style>
table, th, td 
{
  border: 1px solid Silver; 
  padding: 5px
}
th {
  background: Azure; 
}
</style>