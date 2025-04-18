<cfset debug = true>
<cfif isDefined("debug") and debug>Running the installer/insertData.cfm template.<br/></cfif>
<!---<cfsilent>--->
<!--- This is consumed from the Application.cfm template after ORM creates the initial database. --->

<!--- Setting this to true will delete data from the tables and reseed the index. Only use in development. This only works with SQL Server. I may use ORM's truncate statement if this causes any issues. --->
<cfset resetTables = false>
	
<!---
Note: you may turn debugging on for just this template like so:
<cfset debug = true>
--->
	
<!---
Do not keep on running this if the blog is installed
Determine if the blog has been installed
--->
<cfset blogInstalled = getProfileString(application.blogIniPath, "default", "installed")>
	
<!--- 
You can manually run the installer multiple times by hardcoding the reinstallDb to true and limitting the number of tables to populate like so:
<cfset tablesToPopulate = 'Blog,BlogOption,Capability,Font,KendoTheme,MapProvider,MapType,MediaType,MimeType,Role,RoleCapability,Theme,User'>. 
Be sure to check your database for the tables that were successfully populated. 

For example, if the user table did not populate, you can populate it like so:
<cfset tablesToPopulate = 'User'>

If moving from 3.57 to 3.85 use
<cfset tablesToPopulate = 'version3_85'>
--->
<cfset tablesToPopulate = 'version3_85'>
	
<cfif not isDefined("tablesToPopulate")>
	<cfif isBoolean(blogInstalled) and not blogInstalled>
		<!--- Don't do anything --->
		<cfset tablesToPopulate = 'none'>
	<cfelse>
		<!--- Populate the database. --->
		<cfset tablesToPopulate = 'all'>
	</cfif>
</cfif>
	
<cfset dir = "/galaxie/installer/dataFiles/">
	
<!--- Let's insert the data. First we need to populate the database. --->
	
<!--- ******************************************************************************************
Populate the blog table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'Blog' or tablesToPopulate eq 'all'>	
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM Blog;
			DBCC CHECKIDENT ('[Blog]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getBlog.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<cfquery name="getData" dbtype="hql" ormoptions="#{maxresults=1}#">
		SELECT BlogId FROM Blog
	</cfquery>
	<!---<cfdump var="#getData#">--->
		
	<!--- Get the blog url from the ini file --->
	<cfset thisBlogUrl = getProfileString(application.blogIniPath, "default", "blogUrl")>
	<!--- Get the blog title from the ini file --->
	<cfset thisBlogTitle = getProfileString(application.blogIniPath, "default", "blogTitle")>

	<!--- Save the records into the table. --->
	<cftransaction>
		<cfif arrayLen(getData) eq 0>
			<cfset BlogDbObj = EntityNew("Blog")>
		<cfelse>
			<cfset BlogDbObj = EntityLoadByPk("Blog", getData[1])>
		</cfif>
		<!---<cfdump var="#BlogDbObj#">--->
		<!--- Set blog meta data --->
		<cfoutput query="Data" maxrows="1">
			<!--- Make the name unique. --->
			<cfset BlogDbObj.setBlogName('GalaxieBlog3_' & BlogDbObj.getBlogId())>
			<cfset BlogDbObj.setBlogTitle(thisBlogTitle)>
			<cfset BlogDbObj.setBlogDescription(blogDescription)>
			<cfset BlogDbObj.setBlogUrl(thisBlogUrl)>
			<!--- This is an optional field. --->
			<cfset BlogDbObj.setBlogMetaKeywords('')>
			<!--- Parent site (optional) --->
			<cfset BlogDbObj.setBlogParentSiteName('')>
			<cfset BlogDbObj.setBlogParentSiteUrl('')>
			<!--- Time zone --->
			<cfset BlogDbObj.setBlogTimeZone('')>
			<cfset BlogDbObj.setBlogServerTimeZoneOffset(0)>
			<!--- DSN (this is also saved in the ini file) --->
			<cfset BlogDbObj.setBlogDsn(dsn)>
			<!--- Mail server settings --->
			<cfset BlogDbObj.setBlogMailServer('')>
			<cfset BlogDbObj.setBlogMailServerUserName('')>
			<cfset BlogDbObj.setBlogMailServerPassword('')>
			<cfset BlogDbObj.setBlogEmailFailToAddress('')>	
			<cfset BlogDbObj.setBlogEmail('')>
			<!--- Encryption --->
			<cfset BlogDbObj.setSaltAlgorithm('AES')>
			<cfset BlogDbObj.setSaltAlgorithmSize('256')>
			<cfset BlogDbObj.setHashAlgorithm('SHA-512')>
			<cfset BlogDbObj.setServiceKeyEncryptionPhrase(generateRandomPhrase())>	
			<!--- IP Block list --->
			<cfset BlogDbObj.setIpBlockList(ipBlockList)>
			<cfset BlogDbObj.setBlogVersionName('3.0')>
			<cfset BlogDbObj.setBlogVersionName('Galaxie Blog 3.0')>
			<!--- Installed --->
			<cfset BlogDbObj.setBlogInstalled(true)>
			<!--- Date --->
			<cfset BlogDbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(BlogDbObj)>
		</cfoutput>

	</cftransaction>

	<cfset blogId = BlogDbObj.getBlogId()>
	<cfif isDefined("debug") and debug>Blog Table succesfully populated.<br/></cfif>
</cfif>	
				
<!--- ******************************************************************************************
Populate the blog option table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'BlogOption' or tablesToPopulate eq 'all'>		
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM BlogOption;
			DBCC CHECKIDENT ('[BlogOption]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getBlogOption.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->
		
	<!--- Get the useSsl var from the ini file --->
	<cfset thisUseSsl = getProfileString(application.blogIniPath, "default", "useSsl")>

	<cfquery name="getData" dbtype="hql" ormoptions="#{maxresults=1}#">
		SELECT BlogOptionId FROM BlogOption
	</cfquery>

	<!--- Save the records into the table. --->
	<cftransaction>
		<cfif arrayLen(getData) eq 0>
			<cfset OptionDbObj = EntityNew("BlogOption")>
		<cfelse>
			<cfset OptionDbObj = EntityLoadByPk("BlogOption", getData[1])>
		</cfif>
		<!--- Set blog meta data --->
		<cfoutput query="Data" maxrows="1">

			<cfset OptionDbObj.setUseSsl(thisUseSsl)>
			<cfset OptionDbObj.setDeferScriptsAndCss(deferScriptsAndCss)>
			<cfset OptionDbObj.setMinimizeCode(minimizeCode)>
			<!--- Set disable cache to be true when installing --->
			<cfset OptionDbObj.setDisableCache(true)>
			<cfset OptionDbObj.setKendoCommercial(kendoCommercial)>
			<cfset OptionDbObj.setIncludeDisqus(includeDisqus)>
			<cfset OptionDbObj.setIncludeGsap(includeGsap)>
			<!--- These are strings coming from textboxes. --->
			<cfset OptionDbObj.setJQueryCDNPath(jQueryCDNPath)>
			<cfset OptionDbObj.setKendoFolderPath(kendoFolderPath)>
			<cfset OptionDbObj.setAddThisApiKey(addThisApiKey)>
			<cfset OptionDbObj.setAddThisToolboxString(addThisToolboxString)>
			<cfset OptionDbObj.setAddThisApiKey(addThisApiKey)>
			<cfset OptionDbObj.setDisqusBlogIdentifier(disqusBlogIdentifier)>
			<cfset OptionDbObj.setDisqusApiKey(disqusApiKey)>
			<cfset OptionDbObj.setDisqusApiSecret(disqusApiSecret)>
			<cfset OptionDbObj.setDisqusAuthTokenKey(disqusAuthTokenKey)>
			<cfset OptionDbObj.setDisqusAuthUrl(disqusAuthUrl)>
			<cfset OptionDbObj.setDisqusAuthTokenUrl(disqusAuthTokenUrl)>
			<cfset OptionDbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(OptionDbObj)>
		</cfoutput>

	</cftransaction>

	<cfset blogOptionId = OptionDbObj.getBlogOptionId()>
	<cfif isDefined("debug") and debug>Blog Option Table succesfully populated.<br/></cfif>
</cfif>

				
<!--- ******************************************************************************************
Populate the capability table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'Capability' or tablesToPopulate eq 'all'>	
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM Capability;
			DBCC CHECKIDENT ('[Capability]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getCapability.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<cfoutput query="Data">

		<cftransaction>

			<cfquery name="getData" dbtype="hql">
				SELECT CapabilityId FROM Capability WHERE CapabilityName = <cfqueryparam value="#capabilityName#" cfsqltype="varchar">
			</cfquery>

			<!--- Save the records into the table. --->
			<cfif arrayLen(getData) eq 0>
				<cfset CapabilityDbObj = EntityNew("Capability")>
			<cfelse>
				<cfset CapabilityDbObj = EntityLoadByPk("Capability", getData[1])>
			</cfif>

			<!--- Set the values. --->
			<!--- Remove this when using multiple blogs: 
			<cfset CapabilityDbObj.setBlogRef(BlogDbObj)> --->
			<cfset CapabilityDbObj.setCapabilityUuid(capabilityUuid)>
			<cfset CapabilityDbObj.setCapabilityName(capabilityName)>
			<cfset CapabilityDbObj.setCapabilityUiLabel(capabilityUiLabel)>
			<cfset CapabilityDbObj.setCapabilityDescription(capabilityDescription)>
			<cfset CapabilityDbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(CapabilityDbObj)>

		</cftransaction>

	</cfoutput>

	<cfset CapabilityId = CapabilityDbObj.getCapabilityId()>
	<cfif isDefined("debug") and debug>Capability Table succesfully populated.<br/></cfif>	
</cfif>
				
<!--- ******************************************************************************************
Populate the Font table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'Font' or tablesToPopulate eq 'all'>	
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM Font;
			DBCC CHECKIDENT ('[Font]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getFont.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<!--- Save the records into the table. --->
	<cftransaction>
		<cfoutput query="Data">

			<cfquery name="getData" dbtype="hql">
				SELECT FontId FROM Font WHERE Font = <cfqueryparam value="#font#" cfsqltype="varchar">
			</cfquery>

			<cfif arrayLen(getData) eq 0>
				<cfset FontDbObj = EntityNew("Font")>
			<cfelse>
				<cfset FontDbObj = EntityLoadByPk("Font", getData[1])>
			</cfif>

			<!--- Set the values. --->
			<cfset FontDbObj.setFont(Font)>
			<cfset FontDbObj.setFontWeight(fontWeight)>
			<cfset FontDbObj.setItalic(italic)>
			<cfset FontDbObj.setFontType(fontType)>
			<cfset FontDbObj.setFileName(fileName)>
			<cfset FontDbObj.setWebSafeFont(webSafeFont)>
			<cfset FontDbObj.setWebSafeFallback(webSafeFallback)>
			<cfset FontDbObj.setGoogleFont(googleFont)>
			<cfset FontDbObj.setSelfHosted(selfHosted)>
			<cfset FontDbObj.setWoff(woff)>
			<cfset FontDbObj.setWoff2(woff2)>
			<cfset FontDbObj.setUseFont(useFont)>
			<cfset FontDbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(FontDbObj)>
		</cfoutput>

	</cftransaction>

	<cfset FontId = FontDbObj.getFontId()>
	<cfif isDefined("debug") and debug>Font Table succesfully populated.<br/></cfif>
</cfif>	
				
<!--- ******************************************************************************************
Populate the Kendo Theme table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'KendoTheme' or tablesToPopulate eq 'all'>
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM KendoTheme;
			DBCC CHECKIDENT ('[KendoTheme]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getKendoTheme.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfquery name="getData" dbtype="hql">
				SELECT KendoThemeId FROM KendoTheme WHERE KendoTheme = <cfqueryparam value="#kendoTheme#" cfsqltype="varchar">
			</cfquery>

			<cfif arrayLen(getData) eq 0>
				<cfset KendoThemeDbObj = EntityNew("KendoTheme")>
			<cfelse>
				<cfset KendoThemeDbObj = EntityLoadByPk("KendoTheme", getData[1])>
			</cfif>

			<!--- Set the values. --->
			<cfset KendoThemeDbObj.setKendoTheme(kendoTheme)>
			<cfset KendoThemeDbObj.setKendoCommonCssFileLocation(kendoCommonCssFileLocation)>
			<cfset KendoThemeDbObj.setKendoThemeCssFileLocation(kendoThemeCssFileLocation)>
			<cfset KendoThemeDbObj.setKendoThemeMobileCssFileLocation(kendoThemeMobileCssFileLocation)>
			<cfset KendoThemeDbObj.setDarkTheme(darkTheme)>
			<cfset KendoThemeDbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(KendoThemeDbObj)>

		</cftransaction>

	</cfoutput>

	<cfset KendoThemeId = KendoThemeDbObj.getKendoThemeId()>
	<cfif isDefined("debug") and debug>Kendo Theme Table succesfully populated.<br/></cfif>
</cfif>	
			
<!--- ******************************************************************************************
Populate the Map Provider table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'MapProvider' or tablesToPopulate eq 'all'>
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM MapProvider;
			DBCC CHECKIDENT ('[MapProvider]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getMapProvider.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfquery name="getData" dbtype="hql">
				SELECT MapProviderId FROM MapProvider WHERE MapProvider= <cfqueryparam value="#mapProvider#" cfsqltype="varchar">
			</cfquery>

			<cfif arrayLen(getData) eq 0>
				<cfset MapProviderDbObj = EntityNew("MapProvider")>
			<cfelse>
				<cfset MapProviderDbObj = EntityLoadByPk("MapProvider", getData[1])>
			</cfif>

			<!--- Set the values. --->
			<cfset MapProviderDbObj.setMapProvider(mapProvider)>
			<cfset MapProviderDbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(MapProviderDbObj)>

		</cftransaction>

	</cfoutput>

	<cfset mapProviderId = MapProviderDbObj.getMapProviderId()>
	<cfif isDefined("debug") and debug>Map Provider Table succesfully populated.<br/></cfif>
</cfif>
			
<!--- ******************************************************************************************
Populate the Map Type table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'MapType' or tablesToPopulate eq 'all'>	
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM MapType;
			DBCC CHECKIDENT ('[MapType]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getMapType.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfquery name="getData" dbtype="hql">
				SELECT MapTypeId FROM MapType WHERE MapType = <cfqueryparam value="#mapType#" cfsqltype="varchar">
			</cfquery>

			<cfif arrayLen(getData) eq 0>
				<cfset MapTypeDbObj = EntityNew("MapType")>
			<cfelse>
				<cfset MapTypeDbObj = EntityLoadByPk("MapType", getData[1])>
			</cfif>

			<!--- Load the MapProvider object --->
			<cfset MapProviderObj = entityLoad("MapProvider", { MapProvider = mapProvider }, "true" )>
			<!--- Set the values. --->
			<cfset MapTypeDbObj.setMapType(mapType)>
			<!--- Pass the Map Provider obj --->
			<cfset MapTypeDbObj.setMapProviderRef(MapProviderObj)>
			<cfset MapTypeDbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(MapTypeDbObj)>

		</cftransaction>

	</cfoutput>

	<cfset mapTypeId = MapTypeDbObj.getMapTypeId()>
	<cfif isDefined("debug") and debug>Map Type Table succesfully populated.<br/></cfif>
</cfif>
				
<!--- ******************************************************************************************
Populate the Media Type table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'MediaType' or tablesToPopulate eq 'all'>
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM MediaType;
			DBCC CHECKIDENT ('[MediaType]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getMediaType.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfquery name="getData" dbtype="hql">
				SELECT MediaTypeId FROM MediaType WHERE MediaType = <cfqueryparam value="#mediaType#" cfsqltype="varchar">
			</cfquery>

			<cfif arrayLen(getData) eq 0>
				<cfset MediaTypeDbObj = EntityNew("MediaType")>
			<cfelse>
				<cfset MediaTypeDbObj = EntityLoadByPk("MediaType", getData[1])>
			</cfif>

			<!--- Set the values. --->
			<cfset MediaTypeDbObj.setMediaTypeStrId(mediaTypeStrId)>
			<cfset MediaTypeDbObj.setMediaType(mediaType)>
			<cfset MediaTypeDbObj.setDescription(description)>
			<cfset MediaTypeDbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(MediaTypeDbObj)>

		</cftransaction>

	</cfoutput>

	<cfset mediaTypeId = MediaTypeDbObj.getMediaTypeId()>
	<cfif isDefined("debug") and debug>Media Type Table succesfully populated.<br/></cfif>
</cfif>
				
<!--- ******************************************************************************************
Populate the Mime Type table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'MimeType' or tablesToPopulate eq 'all'>	
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM MimeType;
			DBCC CHECKIDENT ('[MimeType]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getMimeType.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfquery name="getData" dbtype="hql">
				SELECT MimeTypeId FROM MimeType WHERE MimeType = <cfqueryparam value="#mimeType#" cfsqltype="varchar">
			</cfquery>

			<cfif arrayLen(getData) eq 0>
				<cfset MimeTypeDbObj = EntityNew("MimeType")>
			<cfelse>
				<cfset MimeTypeDbObj = EntityLoadByPk("MimeType", getData[1])>
			</cfif>

			<!--- Set the values. --->
			<cfset MimeTypeDbObj.setMimeType(mimeType)>
			<cfset MimeTypeDbObj.setExtension(extension)>
			<cfset MimeTypeDbObj.setDescription(description)>
			<cfset MimeTypeDbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(MimeTypeDbObj)>

		</cftransaction>

	</cfoutput>

	<cfset mimeTypeId = MimeTypeDbObj.getMimeTypeId()>
	<cfif isDefined("debug") and debug>Mime Type Table succesfully populated.<br/></cfif>
</cfif>	
			
<!--- ******************************************************************************************
Populate the Role table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'Role' or tablesToPopulate eq 'all'>
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM Role;
			DBCC CHECKIDENT ('[Role]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getRole.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

		<cfquery name="getData" dbtype="hql">
			SELECT RoleId FROM Role WHERE RoleName = <cfqueryparam value="#roleName#" cfsqltype="varchar">
		</cfquery>

		<cfif arrayLen(getData) eq 0>
			<cfset RoleDbObj = EntityNew("Role")>
		<cfelse>
			<cfset RoleDbObj = EntityLoadByPk("Role", getData[1])>
		</cfif>

			<!--- Set the values. --->
			<cfset RoleDbObj.setBlogRef(BlogDbObj)>
			<cfset RoleDbObj.setRoleUuid(roleUuid)>
			<cfset RoleDbObj.setRoleName(roleName)>
			<cfset RoleDbObj.setDescription(description)>
			<cfset RoleDbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(RoleDbObj)>


		</cftransaction>

	</cfoutput>

	<cfset roleId = RoleDbObj.getRoleId()>
	<cfif isDefined("debug") and debug>Role Table succesfully populated.<br/></cfif>
</cfif>	
				
<!--- ******************************************************************************************
Populate the Role Capability table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'RoleCapability' or tablesToPopulate eq 'all'>	
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM RoleCapability;
			DBCC CHECKIDENT ('[RoleCapability]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getRoleCapability.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfquery name="getRole" dbtype="hql">
				SELECT RoleId FROM Role 
				WHERE RoleName = <cfqueryparam value="#roleName#" cfsqltype="varchar">
			</cfquery>
			<!---<cfdump var="#getRole#">--->

			<cfquery name="getCapability" dbtype="hql">
				SELECT CapabilityId FROM Capability 
				WHERE CapabilityName = <cfqueryparam value="#capabilityName#" cfsqltype="varchar">
			</cfquery>
			<!---<cfdump var="#getCapability#">--->

			<!--- Note: using cfqueryparam will not work here due to an ORM expecting an object. --->
			<cfquery name="getData" dbtype="hql">
				SELECT RoleCapabilityId FROM RoleCapability 
				WHERE CapabilityRef = #getCapability[1]#
				AND RoleRef = #getRole[1]#
			</cfquery>

			<!---Load the RoleCapability object--->
			<cfif arrayLen(getData) eq 0>
				<cfset RoleCapabilityDbObj = EntityNew("RoleCapability")>
			<cfelse>
				<cfset RoleCapabilityDbObj = EntityLoadByPk("RoleCapability", getData[1])>
			</cfif>

			<!--- Load the RoleDb Object --->
			<cfset RoleDbObj = entityLoad("Role", { RoleName = trim(roleName) }, "true" )>
			<!---<cfdump var="#RoleDbObj#">--->

			<!--- And load the Capability object --->
			<cfset CapabilityDbObj = entityLoad("Capability", { CapabilityName = capabilityName }, "true" )>
			<!---<cfdump var="#CapabilityDbObj#">--->

			<!--- Set the values. --->
			<cfset RoleCapabilityDbObj.setBlogRef(BlogDbObj)>
			<cfset RoleCapabilityDbObj.setRoleRef(RoleDbObj)>
			<cfset RoleCapabilityDbObj.setCapabilityRef(CapabilityDbObj)>
			<cfset RoleCapabilityDbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(RoleCapabilityDbObj)>

		</cftransaction>

	</cfoutput>

	<cfset roleCapabilityId = RoleCapabilityDbObj.getRoleCapabilityId()>
	<cfif isDefined("debug") and debug>Role Capability Table succesfully populated.<br/></cfif>
</cfif>	
			
<!--- ******************************************************************************************
Populate the Theme and Theme Setting tables at the same time. This one is tricky...
********************************************************************************************--->
<cfif tablesToPopulate eq 'Theme' or tablesToPopulate eq 'all'>	
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM Theme;
			DBCC CHECKIDENT ('[Theme]', RESEED, 0);
			DELETE FROM ThemeSetting;
			DBCC CHECKIDENT ('[ThemeSetting]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the theme data stored in the ini file. --->
	<cfset themeFileName = "getTheme.txt">
	<cffile action="read" file="#dir##themeFileName#" variable="ThemeQueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #ThemeQueryObj# output = "ThemeData">
	<!---<cfdump var="#ThemeData#">--->

	<!--- Now get the theme setting data stored in the ini file. --->
	<cfset themeSettingFileName = "getThemeSetting.txt">
	<cffile action="read" file="#dir##themeSettingFileName#" variable="ThemeSettingQueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #ThemeSettingQueryObj# output = "ThemeSettingData">
	<!---<cfdump var="#ThemeSettingData#">--->

	<!--- The Theme and ThemeSetting must have the same number of records. We can use the Theme query object to drive the query. --->
	<cfoutput query="ThemeData">

		<!--- Save the records into the table. --->
		<cftransaction>
			
			<!---We are querying the query here in order to get the right theme setting by the theme.--->
			<cfquery name="getThemeSettingByTheme" dbtype="query">
				SELECT * FROM ThemeSettingData WHERE ThemeName = <cfqueryparam value="#themeName#" cfsqltype="varchar">
			</cfquery>
			<!---<cfdump var="#getThemeSettingByTheme#" label="getThemeSettingByTheme">--->

			<!--- Get the new fontId's from the current database. We used an ORDER on the data files and the orignal ID is not going to be the new Id.--->
			<!--- Get the new menu FontId from the current database --->
			<cfquery name="getMenuFontId" dbtype="hql">
				SELECT FontId FROM Font
				WHERE Font = <cfqueryparam value="#getThemeSettingByTheme.MenuFont#" cfsqltype="varchar">
			</cfquery>

			<!--- Get the new blog name FontId from the current database --->
			<cfquery name="getBlogNameFontId" dbtype="hql">
				SELECT FontId FROM Font
				WHERE Font = <cfqueryparam value="#getThemeSettingByTheme.BlogNameFont#" cfsqltype="varchar">
			</cfquery>

			<!--- Try to get the themeId.  --->
			<cfquery name="getThemeId" dbtype="hql">
				SELECT ThemeId FROM Theme
				WHERE ThemeName = <cfqueryparam value="#themeName#" cfsqltype="varchar">
			</cfquery>

			<!--- Instantiate the ThemeObj --->
			<cfif arrayLen(getThemeId) eq 0>
				<!--- Load the Theme obj --->
				<cfset ThemeDbObj = EntityNew("Theme")>
				<!--- Load the theme setting entity --->
				<cfset ThemeSettingDbObj = EntityNew("ThemeSetting")>
			<cfelse>
				<cfset ThemeDbObj = EntityLoadByPk("Theme", getThemeId[1])>
				<!--- The indexes should be the same between both tables --->
				<cfset ThemeSettingDbObj = EntityLoadByPk("ThemeSetting", getThemeId[1])>
			</cfif>
				
			<!--- Load the blog object if we are only populating the theme oriented tables --->
			<cfif tablesToPopulate eq 'Theme'>
				<cfset BlogDbObj = entityLoadByPk("Blog", 1)>
			</cfif>

			<!--- Populate the Theme table --->
			<!--- Load the Kendo Theme object --->
			<cfset KendoThemeDbObj = entityLoad("KendoTheme", { KendoTheme = kendoTheme }, "true" )>

			<!--- Set the values. --->
			<cfset ThemeDbObj.setBlogRef(BlogDbObj)>
			<cfset ThemeDbObj.setKendoThemeRef(KendoThemeDbObj)>
			<!---Save the theme setting. --->
			<cfset ThemeDbObj.setThemeSettingRef(ThemeSettingDbObj)>
			<cfset ThemeDbObj.setThemeAlias(themeAlias)>
			<cfset ThemeDbObj.setThemeGenre(themeGenre)>
			<!--- Always set the selected theme to false. --->
			<cfset ThemeDbObj.setSelectedTheme(0)>
			<!--- And set UseTheme to true --->
			<cfset ThemeDbObj.setUseTheme(1)>
			<cfset ThemeDbObj.setThemeName(themeName)>
			<cfset ThemeDbObj.setDarkTheme(darkTheme)>
			<cfset ThemeDbObj.setDate(now())>

			<!--- Now set the values for the Theme Setting table. --->
			<!--- Load the Font object --->
			<cfset FontDbObj = entityLoad("Font", { Font = getThemeSettingByTheme.BodyFont }, "true" )>

			<!--- Set the values. --->
			<cfset ThemeSettingDbObj.setFontRef(FontDbObj)>
			<cfset ThemeSettingDbObj.setFontSize(getThemeSettingByTheme.FontSize)>
			<cfset ThemeSettingDbObj.setFontSizeMobile(getThemeSettingByTheme.FontSizeMobile)>
			<cfset ThemeSettingDbObj.setBreakpoint(getThemeSettingByTheme.Breakpoint)>
			<cfset ThemeSettingDbObj.setContentWidth(getThemeSettingByTheme.ContentWidth)>
			<cfset ThemeSettingDbObj.setMainContainerWidth(getThemeSettingByTheme.MainContainerWidth)>
			<cfset ThemeSettingDbObj.setSideBarContainerWidth(getThemeSettingByTheme.SideBarContainerWidth)>
			<cfset ThemeSettingDbObj.setBlogBackgroundImage(getThemeSettingByTheme.BlogBackgroundImage)>
			<cfset ThemeSettingDbObj.setBlogBackgroundImageMobile(getThemeSettingByTheme.BlogBackgroundImageMobile)>
			<cfset ThemeSettingDbObj.setIncludeBackgroundImages(getThemeSettingByTheme.IncludeBackgroundImages)>
			<cfset ThemeSettingDbObj.setBlogBackgroundImageRepeat(getThemeSettingByTheme.BlogBackgroundImageRepeat)>
			<cfset ThemeSettingDbObj.setBlogBackgroundImagePosition(getThemeSettingByTheme.BlogBackgroundImagePosition)>
			<cfset ThemeSettingDbObj.setBlogBackgroundColor(getThemeSettingByTheme.BlogBackgroundColor)>
			<cfset ThemeSettingDbObj.setStretchHeaderAcrossPage(getThemeSettingByTheme.StretchHeaderAcrossPage)>
			<cfset ThemeSettingDbObj.setHeaderBackgroundImage(getThemeSettingByTheme.HeaderBackgroundImage)>
			<cfif arraylen(getMenuFontId)>
				<cfset ThemeSettingDbObj.setMenuFontRef(getMenuFontId[1])>
			</cfif>
			<cfset ThemeSettingDbObj.setCoverKendoMenuWithMenuBackgroundImage(getThemeSettingByTheme.CoverKendoMenuWithMenuBackgroundImage)>
			<cfset ThemeSettingDbObj.setLogoImageMobile(getThemeSettingByTheme.LogoImageMobile)>
			<cfset ThemeSettingDbObj.setLogoMobileWidth(getThemeSettingByTheme.LogoMobileWidth)>
			<cfset ThemeSettingDbObj.setLogoImage(getThemeSettingByTheme.LogoImage)>
			<cfset ThemeSettingDbObj.setLogoPaddingTop(getThemeSettingByTheme.LogoPaddingTop)>
			<cfset ThemeSettingDbObj.setLogoPaddingRight(getThemeSettingByTheme.LogoPaddingRight)>
			<cfset ThemeSettingDbObj.setLogoPaddingLeft(getThemeSettingByTheme.LogoPaddingLeft)>
			<cfset ThemeSettingDbObj.setLogoPaddingBottom(getThemeSettingByTheme.LogoPaddingBottom)>
			<cfset ThemeSettingDbObj.setDefaultLogoImageForSocialMediaShare(getThemeSettingByTheme.DefaultLogoImageForSocialMediaShare)>
			<cfset ThemeSettingDbObj.setBlogNameTextColor(getThemeSettingByTheme.BlogNameTextColor)>
			<cfif arrayLen(getBlogNameFontId)>
				<cfset ThemeSettingDbObj.setBlogNameFontRef(getBlogNameFontId[1])><!--- This field does not require an object --->
			</cfif>
			<cfset ThemeSettingDbObj.setBlogNameFontSize(getThemeSettingByTheme.BlogNameFontSize)>
			<cfset ThemeSettingDbObj.setBlogNameFontSizeMobile(getThemeSettingByTheme.BlogNameFontSizeMobile)>
			<cfset ThemeSettingDbObj.setHeaderBackgroundColor(getThemeSettingByTheme.HeaderBackgroundColor)>
			<cfset ThemeSettingDbObj.setMenuBackgroundImage(getThemeSettingByTheme.MenuBackgroundImage)>
			<cfset ThemeSettingDbObj.setAlignBlogMenuWithBlogContent(getThemeSettingByTheme.AlignBlogMenuWithBlogContent)>
			<cfset ThemeSettingDbObj.setTopMenuAlign(getThemeSettingByTheme.TopMenuAlign)>
			<cfset ThemeSettingDbObj.setFooterImage(getThemeSettingByTheme.FooterImage)>
			<!--- For distribution, set the WebPImagesIncluded to false otherwise they will have to upload webp versions of any new background images. I'll add a better interface to handle this in the next version. --->
			<cfset ThemeSettingDbObj.setWebPImagesIncluded(false)>
			<cfset ThemeSettingDbObj.setDate(now())>
			<!--- Save the theme setting --->
			<cfset EntitySave(ThemeSettingDbObj)>
			<!--- Save the theme --->
			<cfset EntitySave(ThemeDbObj)>

		</cftransaction>

	</cfoutput>
	<cfset themeId = ThemeDbObj.getThemeId()>
	<cfset themeSettingId = ThemeSettingDbObj.getThemeSettingId()> 
	<cfif isDefined("debug") and debug>Theme Setting Table succesfully populated.<br/></cfif>
</cfif>
	
<!--- ******************************************************************************************
Populate the User table using the form values sent in
********************************************************************************************--->
<cfif tablesToPopulate eq 'User' or tablesToPopulate eq 'all'>
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM UserRole;
			DBCC CHECKIDENT ('[UserRole]', RESEED, 0);
			DELETE FROM Users;
			DBCC CHECKIDENT ('[Users]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data from the .ini file --->
	<cfset firstName = getProfileString(application.blogIniPath, "default", "firstName")>
	<cfset lastName = getProfileString(application.blogIniPath, "default", "lastName")>
	<cfset profileDisplayName = getProfileString(application.blogIniPath, "default", "profileDisplayName")>
	<cfset email = getProfileString(application.blogIniPath, "default", "email")>
	<cfset website = getProfileString(application.blogIniPath, "default", "website")>
	<cfset userName = getProfileString(application.blogIniPath, "default", "userName")>
	<cfset password = getProfileString(application.blogIniPath, "default", "password")>
	<cfset securityAnswer1 = getProfileString(application.blogIniPath, "default", "securityAnswer1")>
	<cfset securityAnswer2 = getProfileString(application.blogIniPath, "default", "securityAnswer2")>
	<cfset securityAnswer3 = getProfileString(application.blogIniPath, "default", "securityAnswer3")>
		
	<cfset salt = generateSecretKey('AES', 256)>
	<cfset uuid = createUUID()>
		
	<cfif isDefined("debug") and debug>Captured profile information for <cfoutput>#firstName#</cfoutput>.<br/></cfif>
			
	<!--- Use a transaction --->
	<cftransaction>
		<!--- ******************** Save the user ******************** --->
		<!--- Load the blog table and get the first record (there only should be one record at this time). This will pass back an object with the value of the blogId. This is needed as the setBlogRef is a foreign key and for some odd reason ColdFusion or Hybernate must have an object passed as a reference instead of a hardcoded value. --->
		<cfset BlogDbObj = entityLoadByPk("Blog", 1)>

		<cfquery name="getUserId" dbtype="hql">
			SELECT new Map ( 
				UserId as UserId 
			)
			FROM Users 
			WHERE UserName = <cfqueryparam value="#userName#">
			AND Active = <cfqueryparam cfsqltype="cf_sql_bit" value="1">
		</cfquery>
		<!---<cfdump var="#getUserId#" label="getUserId">--->

		<!--- Load the entity. --->
		<cfif arrayLen(getUserId)>
			<cfset userId = getUserId[1]["UserId"]>
			<!--- Load the entity by the username --->
			<cfset UserDbObj = entityLoadByPk("Users", userId)>
		<cfelse>
			<!--- Create a new entity --->
			<cfset UserDbObj = entityNew("Users")>
		</cfif>
		<!--- Use the entity objects to set the data. --->
		<cfset UserDbObj.setBlogRef(BlogDbObj)>
		<!--- Create the UUID for new records. --->
		<cfif not arrayLen(getUserId)>
			<cfset UserDbObj.setUserToken(uuid)>
		</cfif>
		<cfset UserDbObj.setFirstName(firstName)>
		<cfset UserDbObj.setLastName(lastName)>
		<cfset UserDbObj.setDisplayName(profileDisplayName)>
		<cfset UserDbObj.setFullName("#firstName# #lastName#")>	
		<cfset UserDbObj.setEmail(email)>
		<cfset UserDbObj.setWebsite(website)>
		<cfset UserDbObj.setUserName(userName)>
		<cfset UserDbObj.setPassword(#hash(salt & password, "SHA-512")#)>
		<cfset UserDbObj.setSalt(salt)>
		<cfif len(securityAnswer1) and len(securityAnswer2) and len(securityAnswer3)>
			<cfset UserDbObj.setSecurityAnswer1(securityAnswer1)>
			<cfset UserDbObj.setSecurityAnswer2(securityAnswer2)>
			<cfset UserDbObj.setSecurityAnswer3(securityAnswer3)>
		</cfif>
		<cfset UserDbObj.setChangePasswordOnLogin(false)>
		<cfset UserDbObj.setLastLogin("")>
		<cfset UserDbObj.setActive(true)>
		<cfset UserDbObj.setDate(now())>
			
		<cfif isDefined("debug") and debug>User Table succesfully populated.<br/></cfif>

		<!--- ******************** Save the user role ******************** --->
			
		<!--- When inserting the original data, always load the administrator role --->
		<cfset RoleDbObj = entityLoad("Role", { RoleName = 'Administrator' }, "true" )>
		<cfif arrayLen(getUserId)>
			<cfset UserRoleDbObj = entityLoadByPK("UserRole", 1)>
		<cfelse><!---<cfif arrayLen(getUserId)>--->
			<!--- Create a new entity --->
			<cfset UserRoleDbObj = entityNew("UserRole")>
		</cfif><!---<cfif arrayLen(getUserId)>--->
		<cfset UserRoleDbObj.setBlogRef(BlogDbObj)>
		<cfset UserRoleDbObj.setRoleRef(RoleDbObj)>
		<cfset UserRoleDbObj.setUserRef(UserDbObj)>
		<cfset UserRoleDbObj.setDate(now())>

		<!--- Save the entities in reverse order that they were instantiated --->
		<cfset EntitySave(UserRoleDbObj)>
		<cfset EntitySave(RoleDbObj)>
		<cfset EntitySave(UserDbObj)>

	</cftransaction>

	<!--- Mark the blog as installed in the ini file--->
	<cfset setProfileString(application.blogIniPath, "default", "installed", true)>
		
	<!--- And reset the user information  other than the profile display name (to indicate who installed the blog originally) --->
	<cfset setProfileString(application.iniFile, "default", "firstName", 'xxx')>
	<cfset setProfileString(application.iniFile, "default", "lastName", 'xxx')>
	<cfset setProfileString(application.iniFile, "default", "email", 'xxx')>
	<cfset setProfileString(application.iniFile, "default", "website", 'xxx')>
	<cfset setProfileString(application.iniFile, "default", "userName", 'xxx')>
	<cfset setProfileString(application.iniFile, "default", "password", 'xxx')>
	<cfset setProfileString(application.iniFile, "default", "securityAnswer1", 'xxx')>
	<cfset setProfileString(application.iniFile, "default", "securityAnswer2", 'xxx')>
	<cfset setProfileString(application.iniFile, "default", "securityAnswer3", 'xxx')>
		
	<cfif isDefined("debug") and debug>Completed installation.<br/></cfif>

</cfif>

<!--- ******************************************************************************************
Populate the Content Template Type table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'ContentTemplateType' or tablesToPopulate eq 'version3_85' or tablesToPopulate eq 'all'>	
	<cfif debug>Populating ContentTemplateType</cfif>
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM ContentTemplateType;
			DBCC CHECKIDENT ('[ContentTemplateType]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getContentTemplateType.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfquery name="getData" dbtype="hql">
				SELECT ContentTemplateTypeId FROM ContentTemplateType 
				WHERE ContentTemplateType = <cfqueryparam value="#contentTemplateType#" cfsqltype="varchar">
			</cfquery>
			<!---<cfdump var="#getData#">--->

			<!---Load the object--->
			<cfif arrayLen(getData) eq 0>
				<cfset DbObj = EntityNew("ContentTemplateType")>
			<cfelse>
				<cfset DbObj = EntityLoadByPk("ContentTemplateType", getData[1])>
			</cfif>
			<!---<cfdump var="#DbObj#">--->

			<!--- Set the values. --->
			<cfset DbObj.setContentTemplateType(contentTemplateType)>
			<cfset DbObj.setContentTemplateTypeDesc(contentTemplateTypeDesc)>
			<cfset DbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(DbObj)>

		</cftransaction>

	</cfoutput>

	<cfset contentTemplateTypeId = DbObj.getContentTemplateTypeId()>
	<cfif isDefined("debug") and debug>Content template type Table succesfully populated.<br/></cfif>
</cfif>	

<!--- ******************************************************************************************
Populate the Content Template table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'ContentTemplate' or tablesToPopulate eq 'version3_85' or tablesToPopulate eq 'all'>	
	<cfif debug>Populating ContentTemplate</cfif>
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM ContentTemplate;
			DBCC CHECKIDENT ('[ContentTemplate]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getContentTemplate.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfquery name="getData" dbtype="hql">
				SELECT ContentTemplateId FROM ContentTemplate 
				WHERE ContentTemplateName = <cfqueryparam value="#contentTemplateName#" cfsqltype="varchar">
			</cfquery>
			<!---<cfdump var="#getData#">--->

			<!---Load the object--->
			<cfif arrayLen(getData) eq 0>
				<cfset DbObj = EntityNew("ContentTemplate")>
			<cfelse>
				<cfset DbObj = EntityLoadByPk("ContentTemplate", getData[1])>
			</cfif>
			<!---<cfdump var="#DbObj#">--->

			<!--- Get the content template type --->
			<cfset contentTemplateTypeDbObj = entityLoadByPk("ContentTemplateType", contentTemplateTypeRef)>

			<!--- Set the values. --->
			<cfset DbObj.setContentTemplateTypeRef(contentTemplateTypeDbObj)>
			<cfset DbObj.setContentTemplateDesc(contentTemplateDesc)>
			<cfset DbObj.setParentTemplatePath(parentTemplatePath)>
			<cfset DbObj.setContentTemplateName(contentTemplateName)>
			<cfset DbObj.setContentTemplatePath(contentTemplatePath)>
			<cfset DbObj.setContentTemplateUrl(contentTemplateUrl)>
			<cfset DbObj.setCustomOutput(false)>
			<cfset DbObj.setActive(true)>
			<cfset DbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(DbObj)>

		</cftransaction>

	</cfoutput>

	<cfset contentTemplateType = DbObj.getContentTemplateId()>
	<cfif isDefined("debug") and debug>Content template Table succesfully populated.<br/></cfif>
</cfif>

<!--- ******************************************************************************************
Populate the Content Zone table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'ContentZone' or tablesToPopulate eq 'version3_85' or tablesToPopulate eq 'all'>	
	<cfif debug>Populating ContentZone</cfif>
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM ContentZone;
			DBCC CHECKIDENT ('[ContentZone]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getContentZone.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<!--- Load the blog table and get the first record (there only should be one record at this time). This will pass back an object with the value of the blogId. This is needed as the setBlogRef is a foreign key and for some odd reason ColdFusion or Hybernate must have an object passed as a reference instead of a hardcoded value. --->
	<cfset BlogDbObj = entityLoadByPk("Blog", 1)>

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfquery name="getData" dbtype="hql">
				SELECT ContentZoneId FROM ContentZone
				WHERE ContentZoneName = <cfqueryparam value="#ContentZoneName#" cfsqltype="varchar">
			</cfquery>
			<!---<cfdump var="#getData#">--->

			<!---Load the object--->
			<cfif arrayLen(getData) eq 0>
				<cfset DbObj = EntityNew("ContentZone")>
			<cfelse>
				<cfset DbObj = EntityLoadByPk("ContentZone", getData[1])>
			</cfif>
			<!---<cfdump var="#DbObj#">--->

			<!--- Set the values. --->
			<cfset DbObj.setBlogRef(BlogDbObj)>
			<cfset DbObj.setContentZoneName(contentZoneName)>
			<cfset DbObj.setContentZoneDesc(contentZoneDesc)>
			<cfset DbObj.setDefaultZone(defaultZone)>
			<cfset DbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(DbObj)>

		</cftransaction>

	</cfoutput>

	<cfset contentZoneId = DbObj.getContentZoneId()>
	<cfif isDefined("debug") and debug>Content Zone Table succesfully populated.<br/></cfif>
</cfif>	

<!--- ******************************************************************************************
Populate the Content Template Content Zone table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'ContentTemplateContentZone' or tablesToPopulate eq 'version3_85' or tablesToPopulate eq 'all'>	
	<cfif debug>Populating ContentTemplateContentZone</cfif>
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM ContentTemplateContentZone;
			DBCC CHECKIDENT ('[ContentTemplateContentZone]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getContentTemplateContentZone.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfif isNumeric(contentTemplateRef) and isNumeric(contentZoneRef)>
				<!--- Load both the content template and content zone objects --->
				<cfset ContentTemplateDbObj = entityLoadByPK('ContentTemplate', contentTemplateRef)>
				<cfset ContentZoneDbObj = entityLoadByPK('ContentZone', contentZoneRef)>

				<cfquery name="getData" dbtype="hql">
					SELECT ContentTemplateContentZoneId FROM ContentTemplateContentZone
					WHERE ContentTemplateRef = #contentTemplateRef#
					AND ContentZoneRef = #contentZoneRef#
				</cfquery>
				<!---<cfdump var="#getData#">--->

				<!---Load the object--->
				<cfif arrayLen(getData) eq 0>
					<cfset DbObj = EntityNew("ContentTemplateContentZone")>
				<cfelse>
					<cfset DbObj = EntityLoadByPk("ContentTemplateContentZone", getData[1])>
				</cfif>
				<!---<cfdump var="#DbObj#">--->

				<!--- Set the values. --->
				<cfset DbObj.setContentTemplateRef(ContentTemplateDbObj)>
				<cfset DbObj.setContentZoneRef(ContentZoneDbObj)>
				<cfset DbObj.setDate(now())>
				<!--- Save it --->
				<cfset EntitySave(DbObj)>

			</cfif><!---<cfif isNumeric(contentTemplateRef) and isNumeric(contentZoneRef)>--->

		</cftransaction>

	</cfoutput>

	<cfset contentTemplateContentZoneId = DbObj.getContentTemplateContentZoneId()>
	<cfif isDefined("debug") and debug>Content Tempate Content Zone Table succesfully populated.<br/></cfif>
</cfif>

<!--- ******************************************************************************************
Populate the Page Type table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'PageType' or tablesToPopulate eq 'version3_85' or tablesToPopulate eq 'all'>	
	<cfif debug>Populating PageType</cfif>
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM PageType;
			DBCC CHECKIDENT ('[PageType]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getPageType.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<!--- Load the blog table and get the first record (there only should be one record at this time). This will pass back an object with the value of the blogId. This is needed as the setBlogRef is a foreign key and for some odd reason ColdFusion or Hybernate must have an object passed as a reference instead of a hardcoded value. --->
	<cfset BlogDbObj = entityLoadByPk("Blog", 1)>

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfquery name="getData" dbtype="hql">
				SELECT PageTypeId FROM PageType
				WHERE PageTypeName = <cfqueryparam value="#pageTypeName#" cfsqltype="varchar">
			</cfquery>
			<!---<cfdump var="#getData#">--->

			<!---Load the object--->
			<cfif arrayLen(getData) eq 0>
				<cfset DbObj = EntityNew("PageType")>
			<cfelse>
				<cfset DbObj = EntityLoadByPk("PageType", getData[1])>
			</cfif>
			<!---<cfdump var="#DbObj#">--->

			<!--- Set the values. --->
			<cfset DbObj.setBlogRef(BlogDbObj)>
			<cfset DbObj.setPageTypeName(pageTypeName)>
			<cfset DbObj.setPageTypeDescription(pageTypeDescription)>
			<cfset DbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(DbObj)>

		</cftransaction>

	</cfoutput>

	<cfset pageTypeId = DbObj.getPageTypeId()>
	<cfif isDefined("debug") and debug>Page Type Table succesfully populated.<br/></cfif>
</cfif>	

<!--- ******************************************************************************************
Populate the Page table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'Page' or tablesToPopulate eq 'version3_85' or tablesToPopulate eq 'all'>	
	<cfif debug>Populating Page</br/></cfif>
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM Page;
			DBCC CHECKIDENT ('[Page]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getPage.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<!--- Load the blog table and get the first record (there only should be one record at this time). This will pass back an object with the value of the blogId. This is needed as the setBlogRef is a foreign key and for some odd reason ColdFusion or Hybernate must have an object passed as a reference instead of a hardcoded value. --->
	<cfset BlogDbObj = entityLoadByPk("Blog", 1)>

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfset PageTypeDbObj = entityLoadByPk("PageType", pageTypeRef)>

			<cfquery name="getData" dbtype="hql">
				SELECT PageId FROM Page
				WHERE PageName = <cfqueryparam value="#pageName#" cfsqltype="varchar">
			</cfquery>
			<!---<cfdump var="#getData#">--->

			<!---Load the object--->
			<cfif arrayLen(getData) eq 0>
				<cfset DbObj = EntityNew("Page")>
			<cfelse>
				<cfset DbObj = EntityLoadByPk("Page", getData[1])>
			</cfif>
			<!---<cfdump var="#DbObj#">--->

			<!--- Set the values. --->
			<cfset DbObj.setBlogRef(BlogDbObj)>
			<cfset DbObj.setPageTypeRef(PageTypeDbObj)>
			<cfset DbObj.setPageName(pageName)>
			<cfset DbObj.setPageDescription(pageDescription)>
			<cfset DbObj.setPagePath(pagePath)>
			<cfset DbObj.setPageUrl(pageUrl)>
			<cfset DbObj.setActive(active)>
			<cfset DbObj.setDate(now())>
			<!--- Save it --->
			<cfset EntitySave(DbObj)>

		</cftransaction>

	</cfoutput>

	<cfset pageId = DbObj.getPageId()>
	<cfif isDefined("debug") and debug>Page table succesfully populated.<br/></cfif>
</cfif>	

<!--- ******************************************************************************************
Populate the Page Content Template table.
********************************************************************************************--->
<cfif tablesToPopulate eq 'PageContentTemplate' or tablesToPopulate eq 'version3_85' or tablesToPopulate eq 'all'>	
	<cfif debug>Populating PageContentTemplate table</br/></cfif>
	<cfif resetTables>
		<cfquery name="reset">
			DELETE FROM PageContentTemplate;
			DBCC CHECKIDENT ('[PageContentTemplate]', RESEED, 0);
		</cfquery>
	</cfif>

	<!--- Get the data stored in the ini file. --->
	<cfset fileName = "getPageContentTemplate.txt">
	<cffile action="read" file="#dir##fileName#" variable="QueryObj">

	<!--- Convert the wddx to a ColdFusion query object --->
	<cfwddx action = "wddx2cfml" input = #QueryObj# output = "Data">
	<!---<cfdump var="#Data#">--->

	<!--- Load the blog table and get the first record (there only should be one record at this time). This will pass back an object with the value of the blogId. This is needed as the setBlogRef is a foreign key and for some odd reason ColdFusion or Hybernate must have an object passed as a reference instead of a hardcoded value. --->
	<cfset BlogDbObj = entityLoadByPk("Blog", 1)>

	<cfoutput query="Data">

		<!--- Save the records into the table. --->
		<cftransaction>

			<cfif isNumeric(pageRef) and isNumeric(contentTemplateRef)>

				<!--- Load the page and content template objects --->
				<cfset PageDbObj = entityLoadByPk("Page", pageRef)>
				<cfset ContentTemplateDbObj = entityLoadByPk("ContentTemplate", contentTemplateRef)>

				<cfquery name="getData" dbtype="hql">
					SELECT PageContentTemplateId FROM PageContentTemplate
					WHERE PageRef = #pageRef#
					AND ContentTemplateRef = #contentTemplateRef#
				</cfquery>
				<!---<cfdump var="#getData#">--->

				<!---Load the object--->
				<cfif arrayLen(getData) eq 0>
					<cfset DbObj = EntityNew("PageContentTemplate")>
				<cfelse>
					<cfset DbObj = EntityLoadByPk("PageContentTemplate", getData[1])>
				</cfif>
				<!---<cfdump var="#DbObj#">--->

				<!--- Set the values. --->
				<cfset DbObj.setPageRef(PageDbObj)>
				<cfset DbObj.setContentTemplateRef(ContentTemplateDbObj)>
				<cfset DbObj.setDate(now())>
				<!--- Save it --->
				<cfset EntitySave(DbObj)>

			</cfif>

		</cftransaction>

	</cfoutput>

	<cfset pageId = DbObj.getPageContentTemplateId()>
	<cfif isDefined("debug") and debug>Page Content Template table succesfully populated.<br/></cfif>
</cfif>	
			
<!--- Note: this is a copy of the blog.cfc's generateRandomString() --->
<cffunction name="generateRandomPhrase" returntype="string" access="public" output="false">
	<cfargument name="numCharacters" type="numeric" required="false" default="8" />

	<cfset var chars = "abcdefghijklmnopqrstuvwxyz1234567890" />
	<cfset var random = createObject("java", "java.util.Random").init() />
	<cfset var result = createObject("java", "java.lang.StringBuffer").init(javaCast("int", arguments.numCharacters)) />
	<cfset var index = 0 />

	<cfloop from="1" to="#arguments.numCharacters#" index="index">
		<cfset result.append(chars.charAt(random.nextInt(chars.length()))) />
	</cfloop>

	<cfreturn result.toString() />
</cffunction>
<!---</cfsilent>--->