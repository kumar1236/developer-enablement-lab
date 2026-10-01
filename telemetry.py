import os
from functools import lru_cache

from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import (
    OTLPSpanExporter,
)
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import (
    BatchSpanProcessor,
    ConsoleSpanExporter,
)


@lru_cache(maxsize=1)
def configure_provider():
    resource = Resource.create({
        "service.name": os.getenv(
            "OTEL_SERVICE_NAME", "developer-service"
        ),
        "service.version": os.getenv("APP_VERSION", "local"),
        "deployment.environment.name": os.getenv(
            "APP_ENV", "lab"
        ),
    })

    provider = TracerProvider(resource=resource)

    exporter_name = os.getenv(
        "OTEL_TRACES_EXPORTER", "console"
    )

    if exporter_name == "console":
        exporter = ConsoleSpanExporter()
    elif exporter_name == "otlp":
        exporter = OTLPSpanExporter()
    else:
        raise ValueError(
            f"Unsupported trace exporter: {exporter_name}"
        )

    provider.add_span_processor(
        BatchSpanProcessor(exporter)
    )

    trace.set_tracer_provider(provider)
    return provider


def configure_telemetry(app):
    if os.getenv("ENABLE_TELEMETRY", "false").lower() != "true":
        return

    provider = configure_provider()

    FlaskInstrumentor().instrument_app(
        app,
        tracer_provider=provider,
        excluded_urls="/health",
    )