# resource "aws_dms_replication_subnet_group" "content_data_api" {
#   replication_subnet_group_description = "Subnet group for testing DMS replication"
#   replication_subnet_group_id          = "jfharden-test-dms"

#   subnet_ids = [
#     aws_subnet.dms_a.id,
#     aws_subnet.dms_b.id,
#   ]

#   tags = {
#     Name = "jfharden-test-dms"
#   }

#   depends_on = [aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole]
# }

# # Create a new replication instance
# resource "aws_dms_replication_instance" "content_data_api" {
#   allocated_storage           = 200
#   apply_immediately           = true
#   multi_az                    = true
#   engine_version              = "3.6.1"
#   replication_instance_class  = "dms.r5.2xlarge"
#   replication_instance_id     = "jfharden-content-data-api"
#   replication_subnet_group_id = aws_dms_replication_subnet_group.content_data_api.id

#   tags = {
#     Name = "jfharden-content-data-api"
#   }

#   vpc_security_group_ids = [aws_security_group.dms.id]

#   depends_on = [
#     aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
#     aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
#     aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
#   ]
# }

# resource "aws_dms_endpoint" "content_data_api_source" {
#   endpoint_id   = "jfharden-test-content-data-api-001-postgres"
#   endpoint_type = "source"
#   engine_name   = "postgres"
#   server_name   = "jfharden-test-content-data-api-001-postgres.ceu7s3y9xx35.eu-west-1.rds.amazonaws.com"
#   port          = 5432
#   database_name = "content_performance_manager_production"
#   username      = "aws_db_admin"
#   password      = random_password.content_data_api_source.result
#   postgres_settings {
#     authentication_method = "password"
#     capture_ddls          = true
#     plugin_name           = "pglogical"
#   }
# }

# resource "aws_dms_endpoint" "content_data_api_target" {
#   endpoint_id   = "jfharden-test-content-data-api-empty-001-postgres"
#   endpoint_type = "target"
#   engine_name   = "postgres"
#   server_name   = "jfharden-test-content-data-api-empty-001-postgres.ceu7s3y9xx35.eu-west-1.rds.amazonaws.com"
#   port          = 5432
#   database_name = "content_performance_manager_production"
#   username      = "aws_db_admin"
#   password      = random_password.content_data_api_target.result
#   postgres_settings {
#     authentication_method = "password"
#     capture_ddls          = true
#     plugin_name           = "pglogical"
#   }
# }

# resource "aws_dms_replication_task" "content_data_api" {
#   migration_type           = "full-load-and-cdc"
#   replication_instance_arn = aws_dms_replication_instance.content_data_api.replication_instance_arn
#   replication_task_id      = "jfharden-replicate-test-content-data-api"
#   table_mappings = jsonencode({
#     rules = [
#       {
#         filters = []
#         object-locator = {
#           schema-name = "%"
#           table-name  = "%"
#         }
#         rule-action = "include"
#         rule-id     = 1299416966
#         rule-name   = "mgqvt62r-b4ue88"
#         rule-type   = "selection"
#       },
#     ]
#   })
#   replication_task_settings = jsonencode({
#     BeforeImageSettings = null
#     ChangeProcessingDdlHandlingPolicy = {
#       HandleSourceTableAltered   = true
#       HandleSourceTableDropped   = true
#       HandleSourceTableTruncated = true
#     }
#     ChangeProcessingTuning = {
#       BatchApplyMemoryLimit         = 500
#       BatchApplyPreserveTransaction = true
#       BatchApplyTimeoutMax          = 30
#       BatchApplyTimeoutMin          = 1
#       BatchSplitSize                = 0
#       CommitTimeout                 = 1
#       MemoryKeepTime                = 60
#       MemoryLimitTotal              = 1024
#       MinTransactionSize            = 1000
#       RecoveryTimeout               = -1
#       StatementCacheSize            = 50
#     }
#     CharacterSetSettings = null
#     ControlTablesSettings = {
#       ControlSchema                 = ""
#       FullLoadExceptionTableEnabled = false
#       HistoryTableEnabled           = false
#       HistoryTimeslotInMinutes      = 5
#       StatusTableEnabled            = false
#       SuspendedTablesTableEnabled   = false
#       historyTimeslotInMinutes      = 5
#     }
#     ErrorBehavior = {
#       ApplyErrorDeletePolicy                      = "IGNORE_RECORD"
#       ApplyErrorEscalationCount                   = 0
#       ApplyErrorEscalationPolicy                  = "LOG_ERROR"
#       ApplyErrorFailOnTruncationDdl               = false
#       ApplyErrorInsertPolicy                      = "LOG_ERROR"
#       ApplyErrorUpdatePolicy                      = "LOG_ERROR"
#       DataErrorEscalationCount                    = 0
#       DataErrorEscalationPolicy                   = "SUSPEND_TABLE"
#       DataErrorPolicy                             = "LOG_ERROR"
#       DataMaskingErrorPolicy                      = "STOP_TASK"
#       DataTruncationErrorPolicy                   = "LOG_ERROR"
#       EventErrorPolicy                            = "IGNORE"
#       FailOnNoTablesCaptured                      = true
#       FailOnTransactionConsistencyBreached        = false
#       FullLoadIgnoreConflicts                     = true
#       RecoverableErrorCount                       = -1
#       RecoverableErrorInterval                    = 5
#       RecoverableErrorStopRetryAfterThrottlingMax = false
#       RecoverableErrorThrottling                  = true
#       RecoverableErrorThrottlingMax               = 1800
#       TableErrorEscalationCount                   = 0
#       TableErrorEscalationPolicy                  = "STOP_TASK"
#       TableErrorPolicy                            = "SUSPEND_TABLE"
#     }
#     FailTaskWhenCleanTaskResourceFailed = false
#     FullLoadSettings = {
#       CommitRate                      = 10000
#       CreatePkAfterFullLoad           = false
#       MaxFullLoadSubTasks             = 8
#       StopTaskCachedChangesApplied    = true
#       StopTaskCachedChangesNotApplied = false
#       TargetTablePrepMode             = "DO_NOTHING"
#       TransactionConsistencyTimeout   = 600
#     }
#     Logging = {
#       EnableLogContext = true
#       EnableLogging    = true
#       LogComponents = [
#         {
#           Id       = "TRANSFORMATION"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "SOURCE_UNLOAD"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "RESYNC_APPLY"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "IO"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "TARGET_LOAD"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "PERFORMANCE"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "SOURCE_CAPTURE"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "SORTER"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "REST_SERVER"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "RESYNC_UNLOAD"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "VALIDATOR_EXT"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "TARGET_APPLY"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "TASK_MANAGER"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "TABLES_MANAGER"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "METADATA_MANAGER"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "DATA_RESYNC"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "FILE_FACTORY"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "COMMON"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "ADDONS"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "DATA_STRUCTURE"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "COMMUNICATION"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#         {
#           Id       = "FILE_TRANSFER"
#           Severity = "LOGGER_SEVERITY_DEFAULT"
#         },
#       ]
#     }
#     LoopbackPreventionSettings = null
#     PostProcessingRules        = null
#     StreamBufferSettings = {
#       CtrlStreamBufferSizeInMB = 5
#       StreamBufferCount        = 3
#       StreamBufferSizeInMB     = 8
#     }
#     TTSettings = {
#       EnableTT         = false
#       TTRecordSettings = null
#       TTS3Settings     = null
#     }
#     TargetMetadata = {
#       BatchApplyEnabled            = false
#       FullLobMode                  = true
#       InlineLobMaxSize             = 0
#       LimitedSizeLobMode           = false
#       LoadMaxFileSize              = 0
#       LobChunkSize                 = 64
#       LobMaxSize                   = 32
#       ParallelApplyBufferSize      = 0
#       ParallelApplyQueuesPerThread = 0
#       ParallelApplyThreads         = 0
#       ParallelLoadBufferSize       = 0
#       ParallelLoadQueuesPerThread  = 0
#       ParallelLoadThreads          = 0
#       SupportLobs                  = true
#       TargetSchema                 = ""
#       TaskRecoveryTableEnabled     = true
#     }
#   })
#   # resource_identifier    = "jfharden-dms-replication-test"
#   source_endpoint_arn    = aws_dms_endpoint.content_data_api_source.endpoint_arn
#   target_endpoint_arn    = aws_dms_endpoint.content_data_api_target.endpoint_arn
#   start_replication_task = false
# }
