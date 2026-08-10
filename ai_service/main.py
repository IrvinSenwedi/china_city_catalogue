from fastapi import FastAPI, HTTPException

from product_service import get_products
from recommender import ProductRecommender

app = FastAPI(
    title="China City Recommendation API",
    version="1.0.0",
)

recommender = ProductRecommender()


def train_model():
    products = get_products()

    if not products:
        raise ValueError("No products available.")

    recommender.train(products)

    return len(products)


@app.get("/")
def root():
    return {
        "message": "China City Recommendation API",
        "status": "running",
    }


@app.post("/train")
def train():
    try:
        product_count = train_model()

        return {
            "message": "Model trained successfully.",
            "products": product_count,
        }

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=str(error),
        )


@app.get("/recommendations/{product_id}")
def get_recommendations(
    product_id: str,
    limit: int = 5,
):
    try:
        # For this demonstration prototype,
        # retrain using the latest catalogue data.
        train_model()

        recommendations = recommender.recommend(
            product_id=product_id,
            limit=limit,
        )

        return {
            "product_id": product_id,
            "count": len(recommendations),
            "recommendations": recommendations,
        }

    except ValueError as error:
        raise HTTPException(
            status_code=404,
            detail=str(error),
        )

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=str(error),
        )