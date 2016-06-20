<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Contract_Internal_Approval_Complete</fullName>
        <description>Contract - Internal Approval Complete</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>AIA_Email_Templates/AIA_Contract_Approved_Internal</template>
    </alerts>
    <alerts>
        <fullName>Contract_Sales_Approval_Complete</fullName>
        <description>Contract - Sales Approval Complete</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_Contract_Approved_Sales</template>
    </alerts>
    <alerts>
        <fullName>Contract_Sales_Approval_Rejected</fullName>
        <description>Contract - Sales Approval Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_Contract_Rejected_Sales</template>
    </alerts>
</Workflow>
