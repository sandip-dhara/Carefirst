<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Benefit_Design_Approval_Requested</fullName>
        <description>Benefit Design Approval Requested</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_Benefit_Design_Approval_Requested</template>
    </alerts>
    <alerts>
        <fullName>Benefit_Design_Approved_Email</fullName>
        <description>Benefit Design Approved Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_Benefit_Design_Approved</template>
    </alerts>
    <alerts>
        <fullName>Benefit_Design_Rejected_Email</fullName>
        <description>Benefit Design Rejected Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_Benefit_Design_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Benefit_Design_ApprovalStatus_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Benefit Design ApprovalStatus - Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Benefit_Design_Status_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Benefit Design Status - Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approval_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Initiating Benefit Design Restart</literalValue>
        <name>Set Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Waiting for Benefit Design Meeting Approval</literalValue>
        <name>Update Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
