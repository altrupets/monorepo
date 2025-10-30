# Arquitectura Medallion para Data Engineering - AltruPets

Este documento define los principios y patrones para implementar la Arquitectura Medallion usando Databricks en proyectos de ingeniería de datos, considerando diferentes arquitecturas de aplicación y plataformas cloud.

## Principios Fundamentales de Medallion

### Capas de Calidad de Datos
- **Bronce (Raw)**: Datos en su forma original, sin procesar
- **Plata (Validated)**: Datos limpiados, validados y enriquecidos
- **Oro (Enriched)**: Datos agregados y optimizados para consumo de negocio

### Garantías ACID
La arquitectura debe garantizar:
- **Atomicidad**: Las operaciones se completan totalmente o no se ejecutan
- **Consistencia**: Los datos mantienen integridad referencial
- **Aislamiento**: Las transacciones concurrentes no interfieren entre sí
- **Durabilidad**: Los cambios confirmados persisten permanentemente

## Implementación por Arquitectura de Aplicación

### Aplicaciones Monolíticas
```sql
-- Estructura de esquemas para monolito
CREATE SCHEMA IF NOT EXISTS altrupets_bronze;
CREATE SCHEMA IF NOT EXISTS altrupets_silver;
CREATE SCHEMA IF NOT EXISTS altrupets_gold;

-- Ejemplo: Tabla unificada de eventos
CREATE TABLE altrupets_bronze.app_events (
  event_id STRING,
  event_type STRING,
  user_id STRING,
  timestamp TIMESTAMP,
  payload STRING,
  source_system STRING DEFAULT 'altrupets_monolith'
) USING DELTA
PARTITIONED BY (DATE(timestamp));
```

### Aplicaciones Modulares
```sql
-- Esquemas por módulo de negocio
CREATE SCHEMA IF NOT EXISTS rescate_bronze;
CREATE SCHEMA IF NOT EXISTS rescate_silver;
CREATE SCHEMA IF NOT EXISTS rescate_gold;

CREATE SCHEMA IF NOT EXISTS adopcion_bronze;
CREATE SCHEMA IF NOT EXISTS adopcion_silver;
CREATE SCHEMA IF NOT EXISTS adopcion_gold;

-- Ejemplo: Módulo de rescate
CREATE TABLE rescate_bronze.solicitudes_raw (
  solicitud_id STRING,
  auxiliar_id STRING,
  animal_data STRING,
  ubicacion_gps STRING,
  timestamp TIMESTAMP,
  modulo STRING DEFAULT 'rescate'
) USING DELTA
PARTITIONED BY (DATE(timestamp));
```

### Arquitectura de Microservicios
```sql
-- Esquemas por microservicio
CREATE SCHEMA IF NOT EXISTS ms_auxilio_bronze;
CREATE SCHEMA IF NOT EXISTS ms_auxilio_silver;
CREATE SCHEMA IF NOT EXISTS ms_auxilio_gold;

CREATE SCHEMA IF NOT EXISTS ms_rescate_bronze;
CREATE SCHEMA IF NOT EXISTS ms_rescate_silver;
CREATE SCHEMA IF NOT EXISTS ms_rescate_gold;

-- Ejemplo: Microservicio de auxilio
CREATE TABLE ms_auxilio_bronze.eventos_auxilio (
  event_id STRING,
  aggregate_id STRING,
  event_type STRING,
  event_data STRING,
  version BIGINT,
  timestamp TIMESTAMP,
  microservice STRING DEFAULT 'auxilio-service'
) USING DELTA
PARTITIONED BY (DATE(timestamp), microservice);
```

## Configuración por Plataforma Cloud

### AWS con Databricks
```python
# Configuración de almacenamiento
aws_config = {
    "bronze_path": "s3://altrupets-datalake/bronze/",
    "silver_path": "s3://altrupets-datalake/silver/",
    "gold_path": "s3://altrupets-datalake/gold/",
    "checkpoint_path": "s3://altrupets-datalake/checkpoints/",
    "catalog": "altrupets_catalog",
    "metastore": "unity_catalog"
}

# Configuración de streaming desde Kinesis
kinesis_config = {
    "streamName": "altrupets-events",
    "region": "us-east-1",
    "initialPosition": "TRIM_HORIZON"
}
```

### GCP con Databricks
```python
# Configuración de almacenamiento
gcp_config = {
    "bronze_path": "gs://altrupets-datalake/bronze/",
    "silver_path": "gs://altrupets-datalake/silver/",
    "gold_path": "gs://altrupets-datalake/gold/",
    "checkpoint_path": "gs://altrupets-datalake/checkpoints/",
    "catalog": "altrupets_catalog",
    "project_id": "altrupets-project"
}

# Configuración de streaming desde Pub/Sub
pubsub_config = {
    "subscription": "projects/altrupets-project/subscriptions/events-sub",
    "project": "altrupets-project"
}
```

### Azure con Databricks
```python
# Configuración de almacenamiento
azure_config = {
    "bronze_path": "abfss://bronze@altrupetsdl.dfs.core.windows.net/",
    "silver_path": "abfss://silver@altrupetsdl.dfs.core.windows.net/",
    "gold_path": "abfss://gold@altrupetsdl.dfs.core.windows.net/",
    "checkpoint_path": "abfss://checkpoints@altrupetsdl.dfs.core.windows.net/",
    "catalog": "altrupets_catalog"
}

# Configuración de streaming desde Event Hubs
eventhub_config = {
    "connectionString": "Endpoint=sb://altrupets-eh.servicebus.windows.net/",
    "eventHubName": "altrupets-events",
    "consumerGroup": "$Default"
}
```

## Patrones de Ingesta por Capa

### Capa Bronce - Ingesta Raw
```python
# Streaming continuo para datos en tiempo real
def ingest_to_bronze_streaming(source_config, target_path):
    return (spark.readStream
            .format("kinesis")  # o "kafka", "eventhubs", "pubsub"
            .options(**source_config)
            .load()
            .select(
                col("data").cast("string").alias("raw_data"),
                col("partitionKey").alias("partition_key"),
                col("timestamp").alias("ingestion_timestamp"),
                lit("streaming").alias("ingestion_method")
            )
            .writeStream
            .format("delta")
            .option("checkpointLocation", f"{target_path}/_checkpoints")
            .option("path", target_path)
            .trigger(processingTime="30 seconds")
            .start())

# Batch para datos históricos o archivos
def ingest_to_bronze_batch(source_path, target_path):
    return (spark.read
            .option("multiline", "true")
            .json(source_path)
            .withColumn("ingestion_timestamp", current_timestamp())
            .withColumn("ingestion_method", lit("batch"))
            .write
            .format("delta")
            .mode("append")
            .save(target_path))
```

### Capa Plata - Limpieza y Validación
```python
# Transformación de Bronze a Silver
def bronze_to_silver_transform():
    return (spark.readStream
            .format("delta")
            .table("altrupets_bronze.raw_events")
            .select(
                col("raw_data"),
                from_json(col("raw_data"), event_schema).alias("parsed_data"),
                col("ingestion_timestamp")
            )
            .select(
                col("parsed_data.event_id").alias("event_id"),
                col("parsed_data.event_type").alias("event_type"),
                col("parsed_data.user_id").alias("user_id"),
                col("parsed_data.timestamp").cast("timestamp").alias("event_timestamp"),
                col("parsed_data.payload").alias("payload"),
                col("ingestion_timestamp")
            )
            .filter(col("event_id").isNotNull())  # Validación básica
            .dropDuplicates(["event_id"])  # Deduplicación
            .writeStream
            .format("delta")
            .outputMode("append")
            .option("checkpointLocation", "/checkpoints/silver/events")
            .table("altrupets_silver.events"))

# Enriquecimiento con datos de referencia
def enrich_silver_data():
    events_df = spark.table("altrupets_silver.events")
    users_df = spark.table("altrupets_silver.users")
    
    return (events_df
            .join(users_df, "user_id", "left")
            .select(
                col("event_id"),
                col("event_type"),
                col("user_id"),
                col("user_type"),
                col("user_location"),
                col("event_timestamp"),
                col("payload")
            )
            .write
            .format("delta")
            .mode("overwrite")
            .saveAsTable("altrupets_silver.events_enriched"))
```

### Capa Oro - Agregaciones de Negocio
```python
# Métricas de negocio para dashboards
def create_gold_metrics():
    # KPIs de rescate por región
    rescue_metrics = (spark.table("altrupets_silver.events_enriched")
                     .filter(col("event_type") == "rescue_completed")
                     .groupBy(
                         window(col("event_timestamp"), "1 day").alias("date_window"),
                         col("user_location").alias("region")
                     )
                     .agg(
                         count("*").alias("total_rescues"),
                         countDistinct("user_id").alias("active_rescuers"),
                         avg("processing_time").alias("avg_response_time")
                     )
                     .select(
                         col("date_window.start").alias("date"),
                         col("region"),
                         col("total_rescues"),
                         col("active_rescuers"),
                         col("avg_response_time")
                     ))
    
    rescue_metrics.write.format("delta").mode("overwrite").saveAsTable("altrupets_gold.rescue_daily_metrics")
    
    # Funnel de adopción
    adoption_funnel = (spark.sql("""
        SELECT 
            DATE(event_timestamp) as date,
            COUNT(CASE WHEN event_type = 'adoption_request' THEN 1 END) as requests,
            COUNT(CASE WHEN event_type = 'adoption_approved' THEN 1 END) as approvals,
            COUNT(CASE WHEN event_type = 'adoption_completed' THEN 1 END) as completions
        FROM altrupets_silver.events_enriched
        WHERE event_type IN ('adoption_request', 'adoption_approved', 'adoption_completed')
        GROUP BY DATE(event_timestamp)
    """))
    
    adoption_funnel.write.format("delta").mode("overwrite").saveAsTable("altrupets_gold.adoption_funnel")
```

## Integración con Herramientas de BI

### Configuración para Looker Studio
```python
# Crear vistas optimizadas para Looker Studio
def create_looker_views():
    # Vista para dashboard ejecutivo
    spark.sql("""
        CREATE OR REPLACE VIEW altrupets_gold.executive_dashboard AS
        SELECT 
            date,
            region,
            total_rescues,
            active_rescuers,
            avg_response_time,
            CASE 
                WHEN avg_response_time < 30 THEN 'Excelente'
                WHEN avg_response_time < 60 THEN 'Bueno'
                ELSE 'Necesita Mejora'
            END as performance_category
        FROM altrupets_gold.rescue_daily_metrics
    """)
    
    # Configurar conector JDBC para Looker Studio
    jdbc_config = {
        "url": "jdbc:databricks://your-workspace.cloud.databricks.com:443/default",
        "driver": "com.databricks.client.jdbc.Driver",
        "user": "token",
        "password": "your-access-token"
    }
```

### Configuración para Tableau Desktop
```python
# Crear extracts optimizados para Tableau
def create_tableau_extracts():
    # Configurar particionamiento para mejor performance
    spark.sql("""
        CREATE TABLE IF NOT EXISTS altrupets_gold.tableau_rescue_data (
            date DATE,
            region STRING,
            rescue_type STRING,
            total_rescues INT,
            avg_response_time DOUBLE,
            success_rate DOUBLE
        ) USING DELTA
        PARTITIONED BY (date)
        TBLPROPERTIES (
            'delta.autoOptimize.optimizeWrite' = 'true',
            'delta.autoOptimize.autoCompact' = 'true'
        )
    """)
    
    # Configurar Tableau Server/Online connection
    tableau_config = {
        "server_url": "https://your-tableau-server.com",
        "site_id": "altrupets",
        "project_name": "Data Analytics"
    }
```

### Configuración para Power BI
```python
# Crear datasets optimizados para Power BI
def create_powerbi_datasets():
    # Configurar tablas con relaciones claras
    spark.sql("""
        CREATE OR REPLACE VIEW altrupets_gold.powerbi_fact_rescues AS
        SELECT 
            r.rescue_id,
            r.date_key,
            r.region_key,
            r.rescuer_key,
            r.animal_key,
            r.response_time_minutes,
            r.success_flag,
            d.date,
            d.year,
            d.month,
            d.quarter
        FROM altrupets_gold.rescue_facts r
        JOIN altrupets_gold.date_dimension d ON r.date_key = d.date_key
    """)
    
    # Configurar DirectQuery para datos en tiempo real
    powerbi_config = {
        "connection_mode": "DirectQuery",
        "server": "your-databricks-workspace.cloud.databricks.com",
        "http_path": "/sql/1.0/warehouses/your-warehouse-id",
        "catalog": "altrupets_catalog"
    }
```

## Patrones de Optimización

### Optimización de Performance
```python
# Z-Ordering para consultas frecuentes
spark.sql("""
    OPTIMIZE altrupets_gold.rescue_daily_metrics
    ZORDER BY (date, region)
""")

# Vacuum para limpieza de archivos antiguos
spark.sql("""
    VACUUM altrupets_silver.events RETAIN 168 HOURS
""")

# Auto-compactación para escrituras pequeñas frecuentes
spark.sql("""
    ALTER TABLE altrupets_bronze.raw_events 
    SET TBLPROPERTIES (
        'delta.autoOptimize.optimizeWrite' = 'true',
        'delta.autoOptimize.autoCompact' = 'true'
    )
""")
```

### Gestión de Costos
```python
# Configurar retención de datos por capa
retention_policies = {
    "bronze": "2 years",    # Datos raw para auditoria
    "silver": "1 year",     # Datos procesados
    "gold": "5 years"       # Métricas de negocio
}

# Configurar compute clusters por workload
cluster_configs = {
    "bronze_ingestion": {
        "node_type": "i3.xlarge",
        "min_workers": 2,
        "max_workers": 8,
        "auto_termination_minutes": 30
    },
    "silver_processing": {
        "node_type": "r5.2xlarge", 
        "min_workers": 1,
        "max_workers": 4,
        "auto_termination_minutes": 60
    },
    "gold_analytics": {
        "node_type": "c5.4xlarge",
        "min_workers": 1,
        "max_workers": 2,
        "auto_termination_minutes": 120
    }
}
```

## Monitoreo y Observabilidad

### Métricas de Calidad de Datos
```python
# Implementar data quality checks
def data_quality_checks():
    # Completitud de datos
    completeness_check = spark.sql("""
        SELECT 
            'completeness' as metric_type,
            table_name,
            column_name,
            COUNT(*) as total_records,
            COUNT(column_name) as non_null_records,
            (COUNT(column_name) * 100.0 / COUNT(*)) as completeness_percentage
        FROM information_schema.columns
        WHERE table_schema IN ('altrupets_silver', 'altrupets_gold')
    """)
    
    # Freshness de datos
    freshness_check = spark.sql("""
        SELECT 
            'freshness' as metric_type,
            table_name,
            MAX(ingestion_timestamp) as last_update,
            DATEDIFF(hour, MAX(ingestion_timestamp), current_timestamp()) as hours_since_update
        FROM altrupets_silver.events
        GROUP BY table_name
    """)
    
    return completeness_check.union(freshness_check)

# Alertas automáticas
def setup_data_alerts():
    # Configurar alertas en Databricks SQL
    alerts_config = {
        "data_freshness": {
            "query": "SELECT hours_since_update FROM data_quality_metrics WHERE metric_type = 'freshness'",
            "condition": "hours_since_update > 2",
            "notification": "slack://altrupets-data-team"
        },
        "data_completeness": {
            "query": "SELECT completeness_percentage FROM data_quality_metrics WHERE metric_type = 'completeness'",
            "condition": "completeness_percentage < 95",
            "notification": "email://data-team@altrupets.org"
        }
    }
```

## Mejores Prácticas por Arquitectura

### Para Monolitos
- Usar un solo catálogo con esquemas separados por capa
- Implementar versionado de esquemas para cambios graduales
- Centralizar la lógica de transformación en notebooks compartidos

### Para Aplicaciones Modulares  
- Crear esquemas por módulo de negocio
- Implementar contratos de datos entre módulos
- Usar Unity Catalog para governance centralizada

### Para Microservicios
- Implementar Event Sourcing en la capa Bronze
- Usar esquemas separados por microservicio
- Implementar CDC (Change Data Capture) para sincronización
- Crear agregaciones cross-service en la capa Gold

## Governance y Seguridad

### Control de Acceso
```sql
-- Configurar permisos por capa
GRANT SELECT ON SCHEMA altrupets_bronze TO `data-engineers`;
GRANT SELECT ON SCHEMA altrupets_silver TO `data-analysts`;
GRANT SELECT ON SCHEMA altrupets_gold TO `business-users`;

-- Row-level security para datos sensibles
CREATE OR REPLACE FUNCTION mask_sensitive_data(user_role STRING, data STRING)
RETURNS STRING
LANGUAGE SQL
RETURN CASE 
    WHEN user_role IN ('admin', 'data-engineer') THEN data
    ELSE 'MASKED'
END;
```

### Lineage y Auditoria
```python
# Implementar tracking de lineage
def track_data_lineage():
    lineage_info = {
        "source_table": "altrupets_bronze.raw_events",
        "target_table": "altrupets_silver.events",
        "transformation_logic": "parse_json_and_validate",
        "execution_timestamp": current_timestamp(),
        "job_id": dbutils.notebook.entry_point.getDbutils().notebook().getContext().jobId().get()
    }
    
    spark.createDataFrame([lineage_info]).write.mode("append").saveAsTable("system.data_lineage")
```

Esta arquitectura Medallion proporciona una base sólida para proyectos de data engineering que pueden escalar desde aplicaciones monolíticas hasta arquitecturas de microservicios complejas, manteniendo la calidad, governance y performance de los datos.