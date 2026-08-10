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
SUPABASE_KEY = os.getenv("SUPABASE_KEY") or os.getenv(
    "SUPABASE_PUBLISHABLE_KEY"
)

if not SUPABASE_URL or not SUPABASE_KEY:
    raise ValueError(
        "SUPABASE_URL and either SUPABASE_KEY or "
        "SUPABASE_PUBLISHABLE_KEY must be set in .env"
    )

supabase: Client = create_client(
    SUPABASE_URL,
    SUPABASE_KEY,
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
