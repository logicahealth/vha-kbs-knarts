# VHA KBS KNARTs

This stand-alone content repository contains deliverables and reports of VHA Knowledge-Based Systems HL7 CDS Knowledge Artifacts. The fastest way to browse it is to load the manifest into the 3rd-party KNARTwork tool, here:

http://knartwork.healthcreek.org/browser?repository=http://vha-kbs-knarts.healthcreek.org

The editor will allow you to make changes to the KNARTs, but you'll need to download the updated artifact(s) to save them. 

# KNART XML CWP Verification Checklists

## Pre-Verification Checklist
- [ ] "Final" deliverables are committed and pushed to the GitHub repository in the appropriate folder(s).
- [ ] Manifest file is updated to include newly introduced content.
- [ ] GitHub issue is created for the review task and assigned to the appropriate reviewer(s), which will notify them automatically via email.

## KNART XML CWP Verification Checklist 

- [ ] All metadata fields are present, with no glaring err of ommission nor comission.
- [ ] Action tree structure is fully and justifiably represents the clinical intent. 
- [ ] Content is consistent with the conventions used in other documents.
- [ ] ELM is:
	- [ ] Well formed XML (no syntactic errors)
	- [ ] Valid XML
	- [ ] Appears to capture the semantic intent of the logic by visual inspection only
- [ ] ANF statements:
	- [ ] Match what is specified in the TSR, and:
		- [ ] No concepts have been ommitted nor committed from the request.
		- [ ] No copy/paste-type issues have been introduced.
		- [ ] No discrepencies of models are apparent.
	- [ ] Sufficiently reference dynamically bound values.
	- [ ] Include a valid UUIDv4.
- [ ] All issues have been captured in GitHub, tagged with deliverable ID and artifact type labels, and automatically assigned an id number.
- [ ] Review task/issue has updated by the reviewer(s) with a search/filter link showing all the noted issues, and assigned to a program lead that will be notified automatically via email.

## Post-Verification Checklist
- [ ] Must-fix issues are aggregated and communicated to B3.
- [ ] Resolution(s) are updated in the review task/issue.
- [ ] Review task/issue is "closed".

## Out of Scope Tasks
* Verification of TSR output versus whitepaper. The TSRs have already been reviewed: assume they are correct!
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
