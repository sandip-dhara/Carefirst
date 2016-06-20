<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AIA_Sales_Data_Analyst_Request</fullName>
        <description>AIA Bid Meeting Document type Sales Data Analyst Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>goutham.rapolu@carefirst.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_Sales_Data_Analyst_Request</template>
    </alerts>
    <alerts>
        <fullName>AIA_Step_6_Account_Approval_Account_Implementation</fullName>
        <ccEmails>testaia@carefirst.com</ccEmails>
        <description>AIA Step 6: Account Approval (Account Implementation)</description>
        <protected>false</protected>
        <recipients>
            <recipient>Implementation Coordinator</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_Step_6_Account_Approval_Account_Implementation</template>
    </alerts>
    <alerts>
        <fullName>AIA_Step_7_Account_Approval_Sales_Service_Rep</fullName>
        <ccEmails>testaia@carefirst.com</ccEmails>
        <description>AIA Step 7: Account Approval (Sales Service Rep)</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales Service Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_Step_7_Account_Approval_Sales_Service_Rep</template>
    </alerts>
    <alerts>
        <fullName>Approval_Rejection_Email</fullName>
        <description>Approval Rejection Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>QA Auditor</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/Quality_Audit_Approval_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Mock_ID_Card_Approved</fullName>
        <description>Mock ID Card Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_MockID_Card_Approved</template>
    </alerts>
    <alerts>
        <fullName>Mock_ID_Card_Rejected</fullName>
        <description>Mock ID Card Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_MockID_Card_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Producction_ID_Card_Rejected</fullName>
        <description>Producction ID Card Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_ProductionID_Card_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Production_ID_Card_Approved</fullName>
        <description>Production ID Card Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_ProductionID_Card_Approved</template>
    </alerts>
    <alerts>
        <fullName>Quote_Rejection_Process</fullName>
        <description>Quote Rejection Process</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_User_email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_BRF_Quote_Rejection_Process</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_BRF_Owner</fullName>
        <description>Send Email to BRF Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_User_email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_BRF_Quote_Upload</template>
    </alerts>
    <fieldUpdates>
        <fullName>AIA_Update_Approval_Status_In_Approval</fullName>
        <description>AIA - Update Approval Status to In Approval</description>
        <field>Approval_Status__c</field>
        <literalValue>In Approval</literalValue>
        <name>AIA - Update Approval Status=In Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AIA_Update_Approval_Status_To_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>AIA - Update Approval Status To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AIA_Update_Approval_Status_To_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>AIA - Update Approval Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Reject_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Approval Reject Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>In Approval</literalValue>
        <name>Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval Status - Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Pending</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Approval Status - Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Approval Status - Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Document_Final_Status_Update</fullName>
        <field>Document_Status__c</field>
        <literalValue>Final</literalValue>
        <name>Document Final Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Document_Status_Final</fullName>
        <field>Document_Status__c</field>
        <literalValue>Final</literalValue>
        <name>Document Status - Final</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Final_Approval_Update</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Final Approval Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sales_User_Email</fullName>
        <field>Sales_User_email__c</field>
        <formula>Owner:User.Email</formula>
        <name>Update Sales User Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sales_User_Email1</fullName>
        <field>Sales_User_email__c</field>
        <formula>Owner:User.Email</formula>
        <name>Update_Sales_User_Email1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AIA BRF Quote Upload</fullName>
        <actions>
            <name>Send_Email_to_BRF_Owner</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Sales_User_Email1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( Document_Name__c !=NULL &amp;&amp;   ISPICKVAL(Document_Type__c , &apos;Quote&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AIA Sales Data Analyst Request Filenet</fullName>
        <actions>
            <name>AIA_Sales_Data_Analyst_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AIA_Document__c.Document_Type__c</field>
            <operation>equals</operation>
            <value>Sales Data Analyst Request</value>
        </criteriaItems>
        <description>When Document type is &quot;Sales Data Analyst Request Filenet&quot; Email notification to networkaccess@carefirst.com</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AIA Update Sales User Email</fullName>
        <actions>
            <name>Update_Sales_User_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>AIA_Document__c.Document_Type__c</field>
            <operation>equals</operation>
            <value>Unsigned Quote</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
