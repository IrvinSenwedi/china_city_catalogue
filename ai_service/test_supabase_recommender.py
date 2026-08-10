from product_service import get_products
from recommender import ProductRecommender


products = get_products()

print(
    f"\nLoaded {len(products)} products "
    "from Supabase."
)

if not products:
    raise ValueError(
        "No products were returned from Supabase."
    )


print("\nProducts:")

for product in products:
    print(
        f"- {product['name']} "
        f"({product['category']})"
    )


speaker = next(
    (
        product
        for product in products
        if product["name"] == "Bluetooth Speaker"
    ),
    None,
)

if speaker is None:
    raise ValueError(
        "Bluetooth Speaker was not found."
    )


recommender = ProductRecommender()

recommender.train(products)

recommendations = recommender.recommend(
    product_id=speaker["id"],
    limit=5,
)


print(
    "\nRecommendations for "
    "Bluetooth Speaker:\n"
)

for recommendation in recommendations:
    print(
        f"{recommendation['name']} "
        f"- Score: "
        f"{recommendation['similarity_score']}"
    )