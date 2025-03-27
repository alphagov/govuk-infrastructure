{
  "rabbit_version": "3.6.15",
  "users": [
    {
      "name": "content_data_api",
      "password": "${publishing_amazonmq_passwords["content_data_api"]}",
      "tags": ""
    },
    {
      "name": "publishing_api",
      "password": "${publishing_amazonmq_passwords["publishing_api"]}",
      "tags": ""
    },
    {
      "name": "email_alert_service",
      "password": "${publishing_amazonmq_passwords["email_alert_service"]}",
      "tags": ""
    },
    {
      "name": "govuk_chat",
      "password": "${publishing_amazonmq_passwords["govuk_chat"]}",
      "tags": ""
    },
    {
      "name": "monitoring",
      "password": "${publishing_amazonmq_passwords["monitoring"]}",
      "tags": "monitoring"
    },
    {
      "name": "search_api",
      "password": "${publishing_amazonmq_passwords["search_api"]}",
      "tags": ""
    },
    {
      "name": "search_api_v2",
      "password": "${publishing_amazonmq_passwords["search_api_v2"]}",
      "tags": ""
    }
  ],
  "vhosts": [
    {
      "name": "publishing"
    }
  ],
  "permissions": [
    {
      "user": "email_alert_service",
      "vhost": "publishing",
      "configure": "^(amq\\.gen.*|email_alert_service|email_unpublishing|subscriber_list_details_update_minor|subscriber_list_details_update_major)$",
      "write": "^(amq\\.gen.*|email_alert_service|email_unpublishing|subscriber_list_details_update_minor|subscriber_list_details_update_major)$",
      "read": "^(amq\\.gen.*|email_alert_service|email_unpublishing|subscriber_list_details_update_minor|subscriber_list_details_update_major|published_documents)$"
    },
    {
      "user": "govuk_chat",
      "vhost": "publishing",
      "configure": "^$",
      "write": "^$",
      "read": "^govuk_chat_published_documents$"
    },
    {
      "user": "content_data_api",
      "vhost": "publishing",
      "configure": "^$",
      "write": "^$",
      "read": "^content_data_api|content_data_api_govuk_importer|content_data_api_dead_letter_queue$"
    },
    {
      "user": "search_api",
      "vhost": "publishing",
      "configure": "^(amq\\.gen.*|search_api_to_be_indexed|search_api_govuk_index)$",
      "write": "^(amq\\.gen.*|search_api_to_be_indexed|search_api_govuk_index)$",
      "read": "^(amq\\.gen.*|search_api_to_be_indexed|search_api_govuk_index|search_api_bulk_reindex|published_documents)$"
    },
    {
      "user": "search_api_v2",
      "vhost": "publishing",
      "configure": "^(amq\\.gen.*|search_api_v2_published_documents)$",
      "write": "^(amq\\.gen.*|search_api_v2_published_documents)$",
      "read": "^(amq\\.gen.*|search_api_v2_published_documents|published_documents)$"
    },
    {
      "user": "monitoring",
      "vhost": "publishing",
      "configure": "''",
      "write": "''",
      "read": ".*"
    },
    {
      "user": "publishing_api",
      "vhost": "publishing",
      "configure": "^amq\\.gen.*$",
      "write": "^(amq\\.gen.*|published_documents)$",
      "read": "^(amq\\.gen.*|published_documents)$"
    },
    {
      "user": "root",
      "vhost": "publishing",
      "configure": ".*",
      "write": ".*",
      "read": ".*"
    }
  ],
  "parameters": [],
  "global_parameters": [
    {
      "name": "cluster_name",
      "value": "${publishing_amazonmq_broker_name}"
    }
  ],
  "policies": [
    {
      "vhost": "publishing",
      "name": "content_data_api-dlx",
      "pattern": "^content_data_api.*",
      "apply-to": "queues",
      "definition": {
        "dead-letter-exchange": "content_data_api_dlx",
        "ha-mode": "all",
        "ha-sync-mode": "automatic"
      },
      "priority": 0
    },
    {
      "vhost": "publishing",
      "name": "govuk_chat_retry_dlx",
      "pattern": "govuk_chat_published_documents",
      "apply-to": "queues",
      "definition": {
        "dead-letter-exchange": "govuk_chat_retry_dlx",
        "ha-mode": "all",
        "ha-sync-mode": "automatic"
      },
      "priority": 0
    },
    {
      "vhost": "publishing",
      "name": "govuk_chat_retry",
      "pattern": "govuk_chat_retry",
      "apply-to": "queues",
      "definition": {
        "dead-letter-exchange": "govuk_chat_dlx",
        "message-ttl":${govuk_chat_retry_message_ttl},
        "ha-mode": "all",
        "ha-sync-mode": "automatic"
      },
      "priority": 0
    },
    {
      "vhost": "publishing",
      "name": "search_api_to_be_indexed_retry",
      "pattern": "^search_api_to_be_indexed$",
      "apply-to": "queues",
      "definition": {
        "dead-letter-exchange": "search_api_to_be_indexed_retry_dlx",
        "ha-mode": "all",
        "ha-sync-mode": "automatic"
      },
      "priority": 0
    },
    {
      "vhost": "publishing",
      "name": "search_api_to_be_indexed_wait_to_retry_discarded",
      "pattern": "search_api_to_be_indexed_wait_to_retry",
      "apply-to": "queues",
      "definition": {
        "dead-letter-exchange": "search_api_to_be_indexed_discarded_dlx",
        "message-ttl": 60000,
        "ha-mode": "all",
        "ha-sync-mode": "automatic"
      },
      "priority": 0
    },
    {
      "vhost": "publishing",
      "name": "ha-all",
      "pattern": ".*",
      "apply-to": "all",
      "definition": {
        "ha-mode": "all",
        "ha-sync-mode": "automatic"
      },
      "priority": 0
    }
  ],
  "queues": [
    {
      "name": "email_alert_service",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "content_data_api_dead_letter_queue",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "subscriber_list_details_update_major",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "search_api_to_be_indexed",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "search_api_to_be_indexed_wait_to_retry",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "content_data_api_govuk_importer",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "subscriber_list_details_update_minor",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "search_api_bulk_reindex",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "content_data_api",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "search_api_govuk_index",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "search_api_v2_published_documents",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "govuk_chat_published_documents",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "govuk_chat_retry",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    },
    {
      "name": "email_unpublishing",
      "vhost": "publishing",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    }
  ],
  "exchanges": [
    {
      "name": "published_documents",
      "vhost": "publishing",
      "type": "topic",
      "durable": true,
      "auto_delete": false,
      "internal": false,
      "arguments": {}
    },
    {
      "name": "govuk_chat_retry_dlx",
      "vhost": "publishing",
      "type": "topic",
      "durable": true,
      "auto_delete": false,
      "internal": false,
      "arguments": {}
    },
    {
      "name": "govuk_chat_dlx",
      "vhost": "publishing",
      "type": "topic",
      "durable": true,
      "auto_delete": false,
      "internal": false,
      "arguments": {}
    },
    {
      "name": "content_data_api_dlx",
      "vhost": "publishing",
      "type": "topic",
      "durable": true,
      "auto_delete": false,
      "internal": false,
      "arguments": {}
    },
    {
      "name": "search_api_to_be_indexed_discarded_dlx",
      "vhost": "publishing",
      "type": "topic",
      "durable": true,
      "auto_delete": false,
      "internal": false,
      "arguments": {}
    },
    {
      "name": "search_api_to_be_indexed_retry_dlx",
      "vhost": "publishing",
      "type": "topic",
      "durable": true,
      "auto_delete": false,
      "internal": false,
      "arguments": {}
    }
  ],
  "bindings": [
    {
      "source": "content_data_api_dlx",
      "vhost": "publishing",
      "destination": "content_data_api_dead_letter_queue",
      "destination_type": "queue",
      "routing_key": "#",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "search_api_govuk_index",
      "destination_type": "queue",
      "routing_key": "*.*",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "search_api_v2_published_documents",
      "destination_type": "queue",
      "routing_key": "*.*",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "search_api_v2_published_documents",
      "destination_type": "queue",
      "routing_key": "*.bulk.search_api_v2_sync",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "content_data_api_govuk_importer",
      "destination_type": "queue",
      "routing_key": "*.bulk.data-warehouse",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "search_api_bulk_reindex",
      "destination_type": "queue",
      "routing_key": "*.bulk.reindex",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "govuk_chat_published_documents",
      "destination_type": "queue",
      "routing_key": "*.bulk.govuk_chat_sync",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "content_data_api",
      "destination_type": "queue",
      "routing_key": "*.links",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "govuk_chat_published_documents",
      "destination_type": "queue",
      "routing_key": "*.links",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "search_api_to_be_indexed",
      "destination_type": "queue",
      "routing_key": "*.links",
      "arguments": {}
    },
    {
      "source": "search_api_to_be_indexed_discarded_dlx",
      "vhost": "publishing",
      "destination": "search_api_to_be_indexed",
      "destination_type": "queue",
      "routing_key": "#",
      "arguments": {}
    },
    {
      "source": "search_api_to_be_indexed_retry_dlx",
      "vhost": "publishing",
      "destination": "search_api_to_be_indexed_wait_to_retry",
      "destination_type": "queue",
      "routing_key": "#",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "content_data_api",
      "destination_type": "queue",
      "routing_key": "*.major",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "govuk_chat_published_documents",
      "destination_type": "queue",
      "routing_key": "*.major",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "email_alert_service",
      "destination_type": "queue",
      "routing_key": "*.major.#",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "subscriber_list_details_update_major",
      "destination_type": "queue",
      "routing_key": "*.major.#",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "content_data_api",
      "destination_type": "queue",
      "routing_key": "*.minor",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "govuk_chat_published_documents",
      "destination_type": "queue",
      "routing_key": "*.minor",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "subscriber_list_details_update_minor",
      "destination_type": "queue",
      "routing_key": "*.minor.#",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "content_data_api",
      "destination_type": "queue",
      "routing_key": "*.republish",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "govuk_chat_published_documents",
      "destination_type": "queue",
      "routing_key": "*.republish",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "content_data_api",
      "destination_type": "queue",
      "routing_key": "*.unpublish",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "govuk_chat_published_documents",
      "destination_type": "queue",
      "routing_key": "*.unpublish",
      "arguments": {}
    },
    {
      "source": "published_documents",
      "vhost": "publishing",
      "destination": "email_unpublishing",
      "destination_type": "queue",
      "routing_key": "*.unpublish.#",
      "arguments": {}
    },
    {
      "source": "govuk_chat_retry_dlx",
      "vhost": "publishing",
      "destination": "govuk_chat_retry",
      "destination_type": "queue",
      "routing_key": "#",
      "arguments": {}
    },
    {
      "source": "govuk_chat_dlx",
      "vhost": "publishing",
      "destination": "govuk_chat_published_documents",
      "destination_type": "queue",
      "routing_key": "#",
      "arguments": {}
    }
  ]
}
