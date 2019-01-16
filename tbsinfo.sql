/* 
 *  NAME    
 *      tbsinfo.sql     
 *     
 *  DESCRIPTION
 *      Tablespaces usage amount statistics script
 *
 *      DFC                 - Counter datafiles by each tablespace
 *      MB_MAX_SIZE         - Size of the max file (in bytes)
 *      MB_SIZE             - Size of the file (in bytes)
 *      MB_USER_SIZE        - Size of the useful portion of the file (in bytes), not open
 *      MB_MAX_AVAIL        - Total max avail space
 *      MB_FREE_SIZE        - Current free space
 *      MB_MAX_FREE_SIZE    - Current max free space
 *      MB_USED_SIZE        - Actual use space
 *      PRE_MAX_AVAIL       - Total max avail space pre
 *      PRE_FREE            - Actual free space pre
 *
 *  NOTES
 *      If the autoextend on and maxsize parameters are not set,
 *      an 'OAR-01476 divisor is equal to zero' error will occur.        
 *
 *  MODIFIED    (DD/MM/YY)
 *  wesley       16/01/19    -   frist created
**/
--  set linesize 300
--  col TS_NAME for a10
SELECT ddf.tablespace_name TS_NAME,
    COUNT(*) DFC,
    ROUND(SUM(ddf.maxbytes/1024/1024)) MB_MAX_SIZE,
    ROUND(SUM(ddf.bytes/1024/1024)) MB_SIZE,
--  ROUND(SUM(ddf.user_bytes/1024/1024)) MB_USER_SIZE,
    ROUND(SUM(ddf.maxbytes/1024/1024)) - ROUND(SUM(ddf.bytes/1024/1024)) MB_MAX_AVAIL,
    ROUND(SUM(dfs.bytes/1024/1024)) MB_FREE_SIZE,
    ROUND(SUM(dfs.maxbytes/1024/1024)) MB_MAX_FREE_SIZE,
    ROUND(SUM(ddf.bytes/1024/1024)) - ROUND(SUM(dfs.BYTES/1024/1024)) MB_USED_SIZE,
    ROUND((100 * SUM(ddf.maxbytes) - SUM(ddf.bytes)) / SUM(ddf.maxbytes),2) PRE_MAX_AVAIL,
    ROUND(100 * SUM(dfs.bytes) / SUM(ddf.BYTES)) PRE_FREE
FROM dba_data_files ddf,(
    SELECT tablespace_name,file_id,
        SUM(bytes) bytes,
        MAX(bytes) maxbytes
    FROM dba_free_space 
    GROUP BY tablespace_name,file_id) dfs
    WHERE ddf.tablespace_name = dfs.tablespace_name
        AND ddf.file_id = dfs.file_id
    GROUP BY ddf.tablespace_name;
