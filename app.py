import os

from flask import Flask, jsonify
from opentelemetry import trace

from telemetry import configure_telemetry


def create_app():
    app = Flask(__name__)
    app.config["APP_VERSION"] = os.getenv(
        "APP_VERSION", "local"
    )

    configure_telemetry(app)
    tracer = trace.get_tracer("developer-service.work")

    @app.get("/health")
    def health():
        return jsonify(status="ok"), 200

    @app.get("/version")
    def version():
        return jsonify(
            service="developer-service",
            version=app.config["APP_VERSION"],
        ), 200

    @app.get("/work")
    def work():
        numbers = [10, 20, 30]

        with tracer.start_as_current_span(
            "calculate_sum"
        ) as span:
            result = sum(numbers)

            span.set_attribute("work.operation", "sum")
            span.set_attribute("work.item_count", len(numbers))
            span.set_attribute("work.result", result)

        return jsonify(
            operation="sum",
            numbers=numbers,
            result=result,
        ), 200

    return app