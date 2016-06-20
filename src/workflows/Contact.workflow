<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Contact_Employer_Group_Portal_Activated</fullName>
        <ccEmails>sfdcTeam@carefirst.com</ccEmails>
        <description>Contact Employer Group Portal Activated</description>
        <protected>false</protected>
        <recipients>
            <recipient>alex.friedman@carefirst.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Administration/Contact_Employer_Group_Portal_Activated</template>
    </alerts>
    <alerts>
        <fullName>Contact_Employer_Group_Portal_Deactivated</fullName>
        <ccEmails>EmployerPortalUseraccountrequest@carefirst.com</ccEmails>
        <ccEmails>sfdcTeam@carefirst.com</ccEmails>
        <description>Contact Employer Group Portal Deactivated</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Administration/Contact_Employer_Group_Portal_Deactivated</template>
    </alerts>
</Workflow>
