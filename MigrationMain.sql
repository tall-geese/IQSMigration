SELECT src.DOCUMENT_ID [Doc_Num], max(src.NAME) [Doc_Name], max(dt.NAME) [Doc_Type], min(src.state) [Doc_Status], max(src.CREATE_DATE) [Doc_Date], max(src.MODIFIED_DATE) [Release_Date], max(src.obsDATE) [ObseleteDate], 
(UPPER((SUBSTRING(max(em.FIRST_NAME) , 1, 1) +  max(em.LAST_NAME)))) [Doc_Manager] , 'Yes' [ForceRevControl], SRC.REVISION_LEVEL [Revision],
REPLACE(STUFF((SELECT ',' + hst.CHANGE_HISTORY
		FROM IQSWeb.dbo.DOCM_CHNG_HIST hst
		WHERE (hst.REVISION_LEVEL = src.REVISION_LEVEL AND hst.DOCUMENT_ID = src.DOCUMENT_ID)
		FOR XML PATH ('')), 1, 1, ''),'&#x0D;', CHAR(13))  [RevisionNotes], NULL [Reference], NULL [Customer], NULL [Vendor], NULL [Part], 
		(SELECT rc.DESCRIPTION 
		 FROM IQSWeb.dbo.REFERENCE_CODE rc
		 WHERE rc.CODE_SYSID = max(src.deptCode)) [Department]
FROM (SELECT do.DOCUMENT_ID , do.NAME, do.REVISION_LEVEL, do.DOCUMENT_TYPE_ID, do.CREATE_DATE, do.MODIFIED_DATE, do.EMPLOYEE_ID, 
		CASE do.REVISION_LEVEL 
			when 'OBSOLETE' then 'OBSOLETE'
			when '0' then 'PENDING'
			else 'ACTIVE'
		END AS state,
		CASE do.REVISION_LEVEL 
			when 'OBSOLETE' then do.REVISION_DATE 
			else NULL 
		END AS obsDATE, do.FUNCTION_CODE_SYSID deptCode
	from IQSWeb.dbo.DOCUMENT do
	union all
	SELECT  da.DOCUMENT_ID DOCUMENT_ID , da.NAME NAME, da.REVISION_LEVEL REVISION_LEVEL , da.DOCUMENT_TYPE_ID DOCUMENT_TYPE_ID , 
		da.CREATE_DATE CREATE_BY , da.MODIFIED_DATE MODIFIED_DATE , da.EMPLOYEE_ID EMPLOYEE_ID , 'OBSOLETE' state, da.ARCHIVE_DATE obsDATE, da.FUNCTION_CODE_SYSID deptCode
	FROM IQSWeb.dbo.DOCUMENT_ARCH da) src
left outer join IQSWeb.dbo.DOCUMENT_TYPE dt on src.DOCUMENT_TYPE_ID = dt.DOCUMENT_TYPE_ID 
left outer join IQSWeb.dbo.EMPLOYEE em on src.EMPLOYEE_ID = em.EMPLOYEE_ID 
--where src.DOCUMENT_ID = 'fo-82-006'
group by src.REVISION_LEVEL, src.DOCUMENT_ID
order by  src.DOCUMENT_ID, src.REVISION_LEVEL ASC 