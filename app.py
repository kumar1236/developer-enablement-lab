import os

from flask import Flask, jsonify


def create_app():
    app = Flask(__name__)

    app.config["APP_VERSION"] = os.getenv("APP_VERSION", "local")

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

        return jsonify(
            operation="sum",
            numbers=numbers,
            result=sum(numbers),
            #result=999,
        ), 200

    return app