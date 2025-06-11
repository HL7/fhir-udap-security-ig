Changes from the previous version are summarized below with links to the corresponding HL7 ticket. The summaries below are non-normative.

### Version 2.0.0

|Ticket|Ticket Description|
|---------|----------|
|[FHIR-40510](https://jira.hl7.org/browse/FHIR-40510)|Update client and server requirements for "community" parameter|
|[FHIR-41520](https://jira.hl7.org/browse/FHIR-41520)|Clarify "state" parameter required for authorization code flow|
|[FHIR-42958](https://jira.hl7.org/browse/FHIR-42958)|Add guidance for use of PKCE|
|[FHIR-43003](https://jira.hl7.org/browse/FHIR-43003)|Update server metadata requirements for extensions and certifications |
|[FHIR-43005](https://jira.hl7.org/browse/FHIR-43005)|Clarify server may grant a subset of "scopes_supported"|
|[FHIR-43020](https://jira.hl7.org/browse/FHIR-43020)|Clarify where client requests scopes in each workflow|
|[FHIR-43022](https://jira.hl7.org/browse/FHIR-43022)|Clarify use of a client secret is not permitted|
|[FHIR-43024](https://jira.hl7.org/browse/FHIR-43024)|Add STU Note regarding concurrent use with SMART|
|[FHIR-43120](https://jira.hl7.org/browse/FHIR-43120)|Clarify JWT conformance requirements|
|[FHIR-45173](https://jira.hl7.org/browse/FHIR-45173)|Add certification example for privacy disclosures|
|[FHIR-46113](https://jira.hl7.org/browse/FHIR-46113)|Add certification example for exchange purposes|
|[FHIR-46448](https://jira.hl7.org/browse/FHIR-46448)|Add scope guidance based on TEFCA SOP|
|[FHIR-49143](https://jira.hl7.org/browse/FHIR-49143)|Representation/formatting of word may be confused as conformance language|
|[FHIR-49179](https://jira.hl7.org/browse/FHIR-49179)|Remove reference to SMART configuration for scope negotiation|
|[FHIR-49633](https://jira.hl7.org/browse/FHIR-49633)|Example narrative should be for B2C and authorization code in 3.2.2|
|[FHIR-49142](https://jira.hl7.org/browse/FHIR-49142)|Invalid conformance language corrected|
|[FHIR-49174](https://jira.hl7.org/browse/FHIR-49174)|Clarify token use must be consistent with authorization context|
|[FHIR-49177](https://jira.hl7.org/browse/FHIR-49177)|Require supported signing algorithms for registration in server metadata|
|[FHIR-49178](https://jira.hl7.org/browse/FHIR-49178)|Move US Realm requirements from 5.2.1.1; Change subject_id to recommend NPI|
|[FHIR-49185](https://jira.hl7.org/browse/FHIR-49185)|Add guidance on how to use this IG and SMART App Launch framework together|
|[FHIR-49239](https://jira.hl7.org/browse/FHIR-49239)|Clarify signed metadata has precedence over plain JSON elements|
|[FHIR-50929](https://jira.hl7.org/browse/FHIR-50929)|Remove dependency of hl7.fhir.us.core: 3.1.1|
|[FHIR-50963](https://jira.hl7.org/browse/FHIR-50963)|Specify the IG standards status|

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