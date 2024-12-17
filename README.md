# AppInsightsWithKeysToCSV

# Objective
List all the App Insights Resources on Azure that have Access Keys assigned to it.<br /><br />

On 30 September 2025, API keys used to stream live metrics telemetry into application insights will be retired. After that date, applications which use API keys will no longer won’t be able to send telemetry data to your application insights resource. <br />

https://azure.microsoft.com/en-us/updates?id=switch-to-azure-ad-authentication-for-application-insights-by-30-september-2025<br />

# Recommended action
To continue streaming live metrics telemetry into your application insights resource , switch to Azure AD authentication for application insights by 30 September 2025.<br />

# How to execute
1- Save the code in your computer<br />
2- Run the code with PowerShell (.\<path to code>)<br />
3- The code will create a CSV file in the folder provided on line 38 of the code (Variable filename)
