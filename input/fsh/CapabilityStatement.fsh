Alias: UDAP = http://fhir.udap.org/CodeSystem/capability-rest-security-ServiceRequest

Profile: UDAPSecurityCapabilityStatement
Parent: CapabilityStatement
Id: udap-security-capabilitystatement
Title: "UDAP Security CapabilityStatement profile"
Description: "CapabilityStatement profile indicating server support for UDAP workflows"

* rest.security.service ^slicing.discriminator.type = #pattern
* rest.security.service ^slicing.discriminator.path = "$this"
* rest.security.service ^slicing.rules = #open
* rest.security.service ^slicing.description = "Used to indicate support for UDAP workflows"

* rest.mode = #server
* rest.security.service contains udapService 1..1
* rest.security.service[udapService] = UDAP#UDAP