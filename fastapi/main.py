from fastapi import FastAPI, HTTPException, Response, status
from prometheus_fastapi_instrumentator import Instrumentator
from pydantic import BaseModel
import random
import time

app = FastAPI(
    title="Alpha-Service",
    description="A production-ready FastAPI template with observability.",
    version="1.0.0"
)

# --- State Management (Simulating Readiness) ---
APP_START_TIME = time.time()
IS_READY = True

# --- Prometheus Metrics Setup ---
Instrumentator().instrument(app).expose(app)

# --- Data Models ---
class Order(BaseModel):
    item_id: int
    quantity: int
    customer_id: str

# --- Observability Routes ---

@app.get("/healthz", status_code=status.HTTP_200_OK, tags=["Observability"])
async def liveness_probe():
    """Liveness: Confirms the container is running."""
    return {"status": "alive", "timestamp": time.time()}

@app.get("/ready", tags=["Observability"])
async def readiness_probe():
    """Readiness: Confirms the app is ready to receive traffic (e.g., DB is up)."""
    if not IS_READY:
        raise HTTPException(status_code=503, detail="Service not ready")
    return {"status": "ready"}

# --- Business Logic Routes ---

@app.post("/orders", status_code=status.HTTP_201_CREATED, tags=["Business"])
async def create_order(order: Order):
    """
    Simulates an interesting business process: Order Validation & Processing.
    Includes a random failure chance to see how metrics react.
    """
    # Simulate some processing "work"
    time.sleep(random.uniform(0.1, 0.5))

    # Randomly fail 10% of the time for "realistic" monitoring
    if random.random() < 0.1:
        raise HTTPException(status_code=500, detail="Inventory system timeout")

    total_price = order.quantity * random.randint(10, 100)

    return {
        "order_id": random.randint(1000, 9999),
        "status": "processed",
        "total_price": f"${total_price}",
        "estimated_delivery": "2-3 business days"
    }

@app.get("/trending-items", tags=["Business"])
async def get_trends():
    """Returns 'calculated' business insights."""
    return {
        "trending_now": ["Mechanical Keyboard", "USB-C Hub", "Ergonomic Chair"],
        "region": "North America",
        "last_updated": time.strftime("%Y-%m-%d %H:%M:%S")
    }

@app.get("/cpu-intensive", tags=["Debug"])
async def do_calc():
    """Returns 'looped' the last value. This is needed for pod autoscaler load tests"""
    x = 0
    for i in range(1000000):
        x += i
    return {
        "result": x
    }

@app.get("/version", tags=["Debug"])
async def get_version():
    """Returns current version"""
    return {
        "version": "v1.0.2"
    }
