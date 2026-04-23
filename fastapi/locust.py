import random
from locust import HttpUser, task, between

class FastApiUser(HttpUser):
    # Wait between 1 and 2 seconds between tasks to simulate human behavior
    wait_time = between(1, 2)

    @task(5) # High weight to ensure CPU usage stays up
    def trigger_cpu(self):
        self.client.get("/cpu-intensive")

    @task(3)
    def browse_trends(self):
        """Simulate a user looking at trending items (higher weight)"""
        self.client.get("/trending-items")

    @task(1)
    def place_order(self):
        """Simulate a user placing an order"""
        customer_id = f"user_{random.randint(1, 1000)}"
        order_data = {
            "item_id": random.randint(100, 500),
            "quantity": random.randint(1, 5),
            "customer_id": customer_id
        }

        with self.client.post("/orders", json=order_data, catch_response=True) as response:
            if response.status_code == 201:
                response.success()
            elif response.status_code == 500:
                # The app fails 10% of the time, so mark this as an expected failure
                response.failure("Simulated Inventory Timeout")
