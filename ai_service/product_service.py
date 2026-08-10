import os
from pathlib import Path

from dotenv import load_dotenv
from supabase import create_client, Client

# Load backend-specific variables first, then fall back to the Flutter project
# root. This works regardless of the directory Python is launched from.
AI_SERVICE_DIR = Path(__file__).resolve().parent
load_dotenv(AI_SERVICE_DIR / ".env")
load_dotenv(AI_SERVICE_DIR.parent / ".env")

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_ROLE_KEY = os.getenv(
    "SUPABASE_SERVICE_ROLE_KEY"
)

if not SUPABASE_URL or not SUPABASE_SERVICE_ROLE_KEY:
    raise ValueError(
        "Supabase environment variables are missing."
    )

supabase: Client = create_client(
    SUPABASE_URL,
    SUPABASE_SERVICE_ROLE_KEY,
)


def get_products() -> list[dict]:
    response = (
        supabase
        .table("products")
        .select(
            """
            id,
            name,
            description,
            price,
            stock_quantity,
            categories(name),
            stores(name)
            """
        )
        .execute()
    )

    products = []

    for item in response.data:
        category = item.get("categories") or {}
        store = item.get("stores") or {}

        products.append(
            {
                "id": item["id"],
                "name": item["name"],
                "description":
                    item.get("description") or "",
                "category":
                    category.get("name") or "",
                "store":
                    store.get("name") or "",
                "price":
                    float(item.get("price") or 0),
                "stock_quantity":
                    item.get("stock_quantity") or 0,
            }
        )

    return products

def get_user_interactions(user_id: str) -> list[dict]:
    response = (
        supabase
        .table("product_interactions")
        .select(
            """
            product_id,
            interaction_type,
            weight,
            products(
                id,
                name,
                description,
                categories(name)
            )
            """
        )
        .eq("user_id", user_id)
        .execute()
    )

    interactions = []

    for item in response.data:
        product = item.get("products") or {}
        category = product.get("categories") or {}

        interactions.append(
            {
                "product_id": item["product_id"],
                "interaction_type": item["interaction_type"],
                "weight": item["weight"],
                "name": product.get("name") or "",
                "description": product.get("description") or "",
                "category": category.get("name") or "",
            }
        )

    return interactions
