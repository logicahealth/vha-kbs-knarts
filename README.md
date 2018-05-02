# VHA KBS KNARTs

This stand-alone content repository contains deliverables and reports of VHA Knowledge-Based Systems HL7 CDS Knowledge Artifacts. The fastest way to browse it is to load the manifest into the 3rd-party KNARTwork tool, here:

http://knartwork.healthcreek.org/browser?repository=http://vha-kbs-knarts.healthcreek.org

The editor will allow you to make changes to the KNARTs, but you'll need to download the updated artifact(s) to save them. 

# KNART XML CWP Verification Checklists

## Pre-Verification Checklist
- [ ] "Final" deliverables are committed and pushed to the GitHub repository in the appropriate folder(s) by Juanita.
- [ ] Manifest file is updated to include newly introduced content by Preston on a M/W/F schedule.
- [ ] Verify KNART XML is fully valid and well formed, including embedded ELM, by Preston on a M/W/F schedule.
- [ ] Preston to confirm all metadata fields are present within the XML file, with no glaring err of ommission nor comission.
- [ ] Preston to confirm that the ANF new terms include a valid UUIDv4. [present and 36 characters long including dashes]
- [ ] GitHub issue is created for the review task and assigned to the appropriate reviewer(s), which will notify them automatically via email.  Apurva wil make the assignments.

## KNART XML CWP Verification Checklist 
NOTE: To conduct the review, the Reviewer will need to download/have open the following files:
	-1. Clinical Content Whitepaper (CCWP) file (pdf) 
	-2. Conceptual Structure Document (CSD) file (pdf)
	-3. KNART Validation Report file (pdf)
	-4. KNART XML file (viewable in browser on Github.com)
	-5. TSR file (excel)
	
Reviewer will be required to review the content of the KNART (either in the XML or in the CSD file) vs. the CCWP to confirm the semantic correctedness of the KNART.

- [ ] Reviewer opens the KNART file (XML file) and scroll to "<title value=" to find the name of the KNART under review.
- [ ] Reviewer finds the same Chapter in the Clinical Content White Paper (CCWP) to review the semantic, substantive content of the XML vs. the CCWP.
- [ ] Reviewer to confirm that the content of the KNART (the plain text found within the "< and />" tags in the XML file or if using the  CSD, captured in the respective CSD chapters)  captures the semantic intent (the clinical meaning) of the matching Chapter in the CCWP.
- [ ] If the Reviewer identifies that the content is not consistently written across similar artifacts (e.g., Order Sets vs. Order Sets or ECA vs. ECA) or at different sections of the same KNART, Reviewer is to create an Issue using the tag "StyleGuide".
- [ ] If Reviewer finds the tag "responseBinding= "X"" in the file, Reviewer is to confirm that the same variable is called/referenced elsewhere in the xml file.
- [ ] Analysis Normal Form (ANF)/Terminology statements:
	- [ ] Match what is specified in the TSR, and:
		- [ ] No concepts have been ommitted nor committed from the request.
		- [ ] No copy/paste-type issues have been introduced.
		- [ ] No discrepencies of models are apparent.
	- NOTE: If any issues are identified related to ANF and/or the TSR, the reviewer is to create an issue ticket; assign it to 		Catherine Staes / Scott Wood and continue their review of the KNART.
- [ ] Reviewer confirms that all issues they identified for the KNART under review have been captured in GitHub, tagged with deliverable ID and artifact type labels.
- [ ] On completion of review of assigned KNARTs associated with a CCWP, reviewer will add comment to that fact and re-assign the Issue to Program Lead (Apurva) and Juanita with a search/filter link showing all the noted issues.

## Post-Verification Checklist
- [ ] Must-fix issues are aggregated and communicated to B3.
- [ ] Resolution(s) are updated in the review task/issue.
- [ ] Review task/issue is "closed".

## Out of Scope Tasks
* Verification that concept in the white paper is modelled correctly during the TSR process. The TSRs have already been reviewed based on terms extracted from the white papers: assume the modelling is correct or a 'future implementation issue' has been logged! [NOTE: it is possible that concepts did not get included in the TSR request, or they were not transcribed correctly from the TSR spreadsheet to the KNART xml.]
* Anything with CQL.
* Runtime validation in general.
* Full semantic validation. 


# Comsumption Remarks

## Making Your Own Repository

While KNARTwork is currently the only tool that supports this knowledge artifact manifest browsing format, it's easy to create your own repository, or add support into your existing Knowledge Management System. Either:

1. Clone this repository and replace the manifest.json and content folder with your own stuff, or
1. Create your own manifest.json, manually or via your app, and put it somewhere on the Internet.

Whatever you do, make sure CORS is allowed, as users _must_ be able to download this file via other apps. A Dockerfile is provided for convenience, but you are in no way required to use it. Any web server or CDN allowing for cross-domain requests (aka CORS) will work fine.

## Contact

The Office of Knowledge-Based Systems, Veterans Health Administration.

* Preston Lee, Biomedical Informatics, College of Health Solutions, Arizona State University <preston@asu.edu>
