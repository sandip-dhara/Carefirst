<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Proposed_Product_is_prepopulated_Risk</fullName>
        <description>If Funding Arrangement on the Benefit Request Form = “Risk”, then the Funding Arrangement on the Proposed Product is prepopulated as “Risk”</description>
        <field>Funding_Arrangement__c</field>
        <literalValue>Risk</literalValue>
        <name>Proposed Product is prepopulated “Risk&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Proposed_Product_is_prepopulated_as_ASO</fullName>
        <description>If Funding Arrangement on the Benefit Request Form = “ASO”, then the Funding Arrangement on the Proposed Product is prepopulated as “ASO”</description>
        <field>Funding_Arrangement__c</field>
        <literalValue>ASO</literalValue>
        <name>Proposed Product is prepopulated “ASO&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Proposed_Products_with_Non_Grand</fullName>
        <description>If Benefit Request Form is of type Non-Grandfathered then PP should be populated with &quot;Non-Grandfatherd&quot;</description>
        <field>Grandfathered_Status__c</field>
        <literalValue>Non-Grandfathered</literalValue>
        <name>Update Proposed Products with Non-Grand</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_of_Grandfatherd_Status_On_PP</fullName>
        <description>If the Benefit Request Form is of type &quot;Grandfathered&quot; then Proposed Products should be populated as Grandfathered</description>
        <field>Grandfathered_Status__c</field>
        <literalValue>Grandfathered</literalValue>
        <name>Update of Grandfatherd Status On PP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Proposed Product is populated with GrandFathered Status</fullName>
        <actions>
            <name>Update_of_Grandfatherd_Status_On_PP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Benfit_Request_Form__c.Grandfathered_Status__c</field>
            <operation>equals</operation>
            <value>Grandfathered</value>
        </criteriaItems>
        <description>If Grandfathered status on Benefit Request form is &quot;Grandfathered&quot; then the Grandfathered status on Proposed Products should be populated as &quot;Grandfatehred&quot;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Proposed Product is populated with Non-GrandFathered Status</fullName>
        <actions>
            <name>Update_Proposed_Products_with_Non_Grand</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Benfit_Request_Form__c.Grandfathered_Status__c</field>
            <operation>equals</operation>
            <value>Non-Grandfathered</value>
        </criteriaItems>
        <description>If Grandfathered status on Benefit Request form is &quot;Non-Grandfathered&quot; then the Grandfathered status on Proposed Products should be populated as &quot;Grandfatehred&quot;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Proposed Product is prepopulated as ASO</fullName>
        <actions>
            <name>Proposed_Product_is_prepopulated_as_ASO</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Benfit_Request_Form__c.Funding_Arrangements__c</field>
            <operation>equals</operation>
            <value>ASO</value>
        </criteriaItems>
        <description>If Funding Arrangement on the Benefit Request Form = “ASO”, then the Funding Arrangement on the Proposed Product is prepopulated as “ASO”</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Proposed Product is prepopulated as Risk</fullName>
        <actions>
            <name>Proposed_Product_is_prepopulated_Risk</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Benfit_Request_Form__c.Funding_Arrangements__c</field>
            <operation>equals</operation>
            <value>Risk</value>
        </criteriaItems>
        <description>If Funding Arrangement on the Benefit Request Form = “Risk”, then the Funding Arrangement on the Proposed Product is prepopulated as “Risk”</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
