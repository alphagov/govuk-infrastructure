### TO DO
### Docstring
### Add time partitioning and time argument features
### Add logic to evaluate whether the query has been successful
### Document format of date
### Change project name variable name to project id 
### MERGE INTO 
### Both Sql scripts for Search (different ways of getting content_ids) - only need if we need 90 days data

import functions_framework
@functions_framework.http
def function_analytics_events_transfer(request):
    """
    """
    from google.cloud import bigquery
    import os
    
    env_project_name = os.environ.get("PROJECT_NAME")
    env_dataset_name = os.environ.get("DATASET_NAME")
    env_analytics_project_name = os.environ.get("ANALYTICS_PROJECT_NAME")
    bq_location = os.environ.get("BQ_LOCATION")

    def datedelta(days):
        from datetime import datetime, timedelta
        date = datetime.now() - timedelta(days=days)
        return date.strftime('%Y%m%d')


    from datetime import date

    request_json = request.get_json(silent=True)

    source_date = datedelta(days=1) if request_json.get("date") is None else request_json.get("date")
    event_type = request_json.get("event_type")

    client = bigquery.Client(project=env_project_name)

    all_queries = {
        'view-item' : {
        'query' : f'''
                merge into `{env_project_name}.{env_dataset_name}.view-item-event` T
                using (SELECT
                TIMESTAMP_TRUNC(TIMESTAMP_MICROS(ga.event_timestamp),DAY) as _PARTITIONTIME,
                'view-item' AS eventType,
                ga.user_pseudo_id AS userPseudoId,
                FORMAT_TIMESTAMP("%FT%TZ",TIMESTAMP_MICROS(ga.event_timestamp)) AS eventTime,
                (case when params.value.string_value is not null then [STRUCT(params.value.string_value AS id, CAST(NULL as string) as name)] end) AS documents
                FROM `{env_analytics_project_name}.analytics_330577055.events_{source_date}` ga ,
                UNNEST(event_params) AS params
                WHERE
                ga.event_name='page_view' AND
                params.key='content_id') S
                on T._PARTITIONTIME = S._PARTITIONTIME and T.eventType = S.eventType and T.userPseudoId = S.userPseudoId and T.eventTime = S.eventTime and to_json_string(T.documents) = to_json_string(S.documents)
                -- and T.documents.id = S.documents.id and T.documents.name = S.documents.name
                WHEN NOT MATCHED THEN 
                INSERT (_PARTITIONTIME, eventType, userPseudoId, eventTime, documents) VALUES (_PARTITIONTIME, eventType, userPseudoId, eventTime, documents)'''
                        },
        'view-item-external-link' : {
        'query' : f'''
                merge into `{env_project_name}.{env_dataset_name}.view-item-external-link-event` T using (
                SELECT 
                TIMESTAMP_TRUNC(TIMESTAMP_MICROS(ga.event_timestamp),DAY) as _PARTITIONTIME,
                'view-item' AS eventType,
                ga.user_pseudo_id AS userPseudoId,
                FORMAT_TIMESTAMP("%FT%TZ",TIMESTAMP_MICROS(ga.event_timestamp)) AS eventTime,
                (case when (SELECT value.string_value FROM UNNEST(items),UNNEST(item_params) WHERE key = 'item_content_id') is not null then [STRUCT((SELECT value.string_value FROM UNNEST(items),UNNEST(item_params) WHERE key = 'item_content_id') AS id, CAST(NULL as string) as name)] end) AS documents,
                FROM `{env_analytics_project_name}.analytics_330577055.events_{source_date}` ga
                WHERE
                ga.event_name='select_item'
                AND (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'outbound') = "true"
                AND (SELECT value.string_value FROM UNNEST(items),UNNEST(item_params) WHERE key = 'item_content_id') is not null) S
                on T._PARTITIONTIME = S._PARTITIONTIME and T.eventType = S.eventType and T.userPseudoId = S.userPseudoId and T.eventTime = S.eventTime and to_json_string(T.documents) = to_json_string(S.documents)
                WHEN NOT MATCHED THEN 
                INSERT (_PARTITIONTIME, eventType, userPseudoId, eventTime, documents) VALUES (_PARTITIONTIME, eventType, userPseudoId, eventTime, documents)'''
                        },
        'search': {'query': f'''
                merge into `{env_project_name}.{env_dataset_name}.search-event` T using (
                with events AS
                (
                    SELECT
                        TIMESTAMP_TRUNC(TIMESTAMP_MICROS(ga.event_timestamp),DAY) AS eventDate,
                        'search' AS eventType,
                        ga.user_pseudo_id AS userPseudoId,
                        FORMAT_TIMESTAMP("%FT%TZ",TIMESTAMP_MICROS(ga.event_timestamp)) AS eventTime,
                        (SELECT COALESCE(value.string_value,SAFE_CAST(value.int_value AS STRING),SAFE_CAST(value.double_value AS STRING),SAFE_CAST(value.float_value AS STRING)) FROM UNNEST(event_params) WHERE key = 'search_term') AS searchQuery,
                        safe_cast(regexp_extract((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), "page=(\\\\d+)" ) as int64)-1 as `offset`,
                        regexp_extract((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), "order=([a-zA-Z\\\\-]+)" ) as orderBy,
                        ARRAY_TO_STRING(regexp_extract_all((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), "((?:level_one_taxon|level_two_taxon|content_purpose_supergroup%5B%5D|public_timestamp%5Bfrom%5D|public_timestamp%5Bto%5D)=(?:%20&%20|[^&])*)" ), "&") as filter,
                        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'ab_test') AS ab_test,
                        item_params.value.string_value as id,
                        max(item.item_id),
                        item.item_list_index
                    FROM `{env_analytics_project_name}.analytics_330577055.events_{source_date}`  ga
                    ,
                    UNNEST(items) AS item,
                    UNNEST(item.item_params) as item_params
                    WHERE
                        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'publishing_app') = "search-api" AND
                        EXISTS (SELECT 1 FROM UNNEST(event_params) WHERE key = 'search_term') AND
                        event_name='view_item_list' AND
                        (((safe_cast(regexp_extract((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), "page=(\\\\d+)" ) as int64)-1) <10) OR
                        ((safe_cast(regexp_extract((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), "page=(\\\\d+)" ) as int64)-1) IS NULL))
                    GROUP BY eventDate, eventTime,userPseudoId,eventType,searchQuery, `offset`,orderBy, id, item_list_index, filter, ab_test
                )
                SELECT 
                    eventDate as _PARTITIONTIME,
                    eventType,
                    userPseudoId,
                    eventTime,
                    case 
                        when `offset` is null then STRUCT(searchQuery, case when orderBy = "relevance" then null else orderBy end as orderBy , 0 as `offset`) 
                        else STRUCT(searchQuery, case when orderBy = "relevance" then null else orderBy end as orderBy, `offset`) 
                    end as searchInfo,
                    case when filter = '' then null else filter end as filter,
                    case when ab_test is not null then ARRAY[ab_test] end as tagIds,
                    ARRAY_AGG(STRUCT(id as id, CAST(NULL as string) as name) ORDER BY SAFE_CAST(item_list_index AS INT64) ) as documents
                FROM events
                WHERE id IS NOT NULL AND
                    searchQuery IS NOT NULL
                group by eventDate, eventTime,userPseudoId,eventType,searchQuery, `offset`, orderBy, filter, ab_test) S
                on T._PARTITIONTIME = S._PARTITIONTIME and T.eventType = S.eventType and T.userPseudoId = S.userPseudoId and T.eventTime = S.eventTime and to_json_string(T.documents) = to_json_string(S.documents) and to_json_string(S.searchInfo) = to_json_string(T.searchInfo) and ifnull(S.filter,"") = ifnull(T.filter,"")
                when not matched then
                insert (_PARTITIONTIME, eventType, userPseudoId, eventTime, searchInfo, filter, tagIds, documents) values (_PARTITIONTIME, eventType, userPseudoId, eventTime, searchInfo, filter, tagIds, documents)
                   '''},
        'view-item-intraday' : {
        'query' : f'''
                merge into `{env_project_name}.{env_dataset_name}.view-item-intraday-event` T
                using (SELECT
                TIMESTAMP_TRUNC(TIMESTAMP_MICROS(ga.event_timestamp),DAY) as _PARTITIONTIME,
                'view-item' AS eventType,
                ga.user_pseudo_id AS userPseudoId,
                FORMAT_TIMESTAMP("%FT%TZ",TIMESTAMP_MICROS(ga.event_timestamp)) AS eventTime,
                (case when params.value.string_value is not null then [STRUCT(params.value.string_value AS id, CAST(NULL as string) as name)] end) AS documents
                FROM `{env_analytics_project_name}.analytics_330577055.events_intraday_{datedelta(days=0)}` ga ,
                UNNEST(event_params) AS params
                WHERE
                ga.event_name='page_view' AND
                params.key='content_id') S
                on T._PARTITIONTIME = S._PARTITIONTIME and T.eventType = S.eventType and T.userPseudoId = S.userPseudoId and T.eventTime = S.eventTime and to_json_string(T.documents) = to_json_string(S.documents)
                -- and T.documents.id = S.documents.id and T.documents.name = S.documents.name
                WHEN NOT MATCHED THEN 
                INSERT (_PARTITIONTIME, eventType, userPseudoId, eventTime, documents) VALUES (_PARTITIONTIME, eventType, userPseudoId, eventTime, documents)'''
                        },
        'view-item-external-link-intraday' : {
        'query' : f'''
                merge into `{env_project_name}.{env_dataset_name}.view-item-external-link-intraday-event` T
                using (
                SELECT 
                TIMESTAMP_TRUNC(TIMESTAMP_MICROS(ga.event_timestamp),DAY) as _PARTITIONTIME,
                'view-item' AS eventType,
                ga.user_pseudo_id AS userPseudoId,
                FORMAT_TIMESTAMP("%FT%TZ",TIMESTAMP_MICROS(ga.event_timestamp)) AS eventTime,
                (case when (SELECT value.string_value FROM UNNEST(items),UNNEST(item_params) WHERE key = 'item_content_id') is not null then [STRUCT((SELECT value.string_value FROM UNNEST(items),UNNEST(item_params) WHERE key = 'item_content_id') AS id, CAST(NULL as string) as name)] end) AS documents,
                FROM `{env_analytics_project_name}.analytics_330577055.events_intraday_{datedelta(days=0)}` ga
                WHERE
                ga.event_name='select_item'
                AND (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'outbound') = "true"
                AND (SELECT value.string_value FROM UNNEST(items),UNNEST(item_params) WHERE key = 'item_content_id') is not null) S
                on T._PARTITIONTIME = S._PARTITIONTIME and T.eventType = S.eventType and T.userPseudoId = S.userPseudoId and T.eventTime = S.eventTime and to_json_string(T.documents) = to_json_string(S.documents)
                -- and T.documents.id = S.documents.id and T.documents.name = S.documents.name
                WHEN NOT MATCHED THEN 
                INSERT (_PARTITIONTIME, eventType, userPseudoId, eventTime, documents) VALUES (_PARTITIONTIME, eventType, userPseudoId, eventTime, documents)'''
                        },
        'search-intraday': {'query': f'''
                merge into `{env_project_name}.{env_dataset_name}.search-intraday-event` T using (
                with events AS
                (
                    SELECT
                        TIMESTAMP_TRUNC(TIMESTAMP_MICROS(ga.event_timestamp),DAY) AS eventDate,
                        'search' AS eventType,
                        ga.user_pseudo_id AS userPseudoId,
                        FORMAT_TIMESTAMP("%FT%TZ",TIMESTAMP_MICROS(ga.event_timestamp)) AS eventTime,
                        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'search_term') AS searchQuery,
                        safe_cast(regexp_extract((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), "page=(\\\\d+)" ) as int64)-1 as `offset`,
                        regexp_extract((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), "order=([a-zA-Z\\\\-]+)" ) as orderBy,
                        ARRAY_TO_STRING(regexp_extract_all((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), "((?:level_one_taxon|level_two_taxon|content_purpose_supergroup%5B%5D|public_timestamp%5Bfrom%5D|public_timestamp%5Bto%5D)=(?:%20&%20|[^&])*)" ), "&") as filter,
                        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'ab_test') AS ab_test,
                        item_params.value.string_value as id,
                        max(item.item_id),
                        item.item_list_index
                    FROM `{env_analytics_project_name}.analytics_330577055.events_intraday_{datedelta(days=0)}`  ga
                    ,
                    UNNEST(items) AS item,
                    UNNEST(item.item_params) as item_params
                    WHERE
                        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'publishing_app') = "search-api" AND
                        EXISTS (SELECT 1 FROM UNNEST(event_params) WHERE key = 'search_term') AND
                        event_name='view_item_list' AND
                        (((safe_cast(regexp_extract((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), "page=(\\\\d+)" ) as int64)-1) <10) OR
                        ((safe_cast(regexp_extract((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), "page=(\\\\d+)" ) as int64)-1) IS NULL))
                    GROUP BY eventDate, eventTime,userPseudoId,eventType,searchQuery, `offset`,orderBy, id, item_list_index, filter, ab_test
                )
                SELECT 
                    eventDate as _PARTITIONTIME,
                    eventType,
                    userPseudoId,
                    eventTime,
                    case 
                        when `offset` is null then STRUCT(searchQuery, case when orderBy = "relevance" then null else orderBy end as orderBy , 0 as `offset`) 
                        else STRUCT(searchQuery, case when orderBy = "relevance" then null else orderBy end as orderBy, `offset`) 
                    end as searchInfo,
                    case when filter = '' then null else filter end as filter,
                    case when ab_test is not null then ARRAY[ab_test] end as tagIds,
                    ARRAY_AGG(STRUCT(id as id, CAST(NULL as string) as name) ORDER BY SAFE_CAST(item_list_index AS INT64) ) as documents
                FROM events
                WHERE id IS NOT NULL AND
                    searchQuery IS NOT NULL
                group by eventDate, eventTime,userPseudoId,eventType,searchQuery, `offset`, orderBy, filter, ab_test) S
                on T._PARTITIONTIME = S._PARTITIONTIME and T.eventType = S.eventType and T.userPseudoId = S.userPseudoId and T.eventTime = S.eventTime and to_json_string(T.documents) = to_json_string(S.documents) and to_json_string(S.searchInfo) = to_json_string(T.searchInfo) and ifnull(S.filter,"") = ifnull(T.filter,"")
                when not matched then
                insert (_PARTITIONTIME, eventType, userPseudoId, eventTime, searchInfo, filter, tagIds, documents) values (_PARTITIONTIME, eventType, userPseudoId, eventTime, searchInfo, filter, tagIds, documents)
                   '''}
    }

    try:
        job = client.query(all_queries.get(event_type).get('query'), location=bq_location)
        output = job.result()
        print(job.done())
        return 'Success'
    except Exception as e:
        raise(e)
