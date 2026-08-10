from recommender import ProductRecommender


products = [
    {
        "id": "1",
        "name": "Bluetooth Speaker",
        "category": "Electronics",
        "description":
            "Portable wireless Bluetooth speaker "
            "with rechargeable battery",
    },
    {
        "id": "2",
        "name": "Wireless Earbuds",
        "category": "Electronics",
        "description":
            "Wireless earbuds with charging case "
            "and touch controls",
    },
    {
        "id": "3",
        "name": "Power Bank",
        "category": "Electronics",
        "description":
            "Portable rechargeable power bank "
            "for smartphones and USB devices",
    },
    {
        "id": "4",
        "name": "Electric Kettle",
        "category": "Home & Kitchen",
        "description":
            "Electric kettle for everyday "
            "home and office use",
    },
    {
        "id": "5",
        "name": "Laundry Basket",
        "category": "Home & Kitchen",
        "description":
            "Lightweight household laundry "
            "basket with handles",
    },
    {
        "id": "6",
        "name": "Crossbody Bag",
        "category": "Fashion",
        "description":
            "Compact fashion bag for "
            "everyday use",
    },
]


recommender = ProductRecommender()

recommender.train(products)

recommendations = recommender.recommend(
    product_id="1",
    limit=3,
)

print("\nRecommendations for Bluetooth Speaker:\n")

for product in recommendations:
    print(
        f"{product['name']} "
        f"- Score: {product['similarity_score']}"
    )