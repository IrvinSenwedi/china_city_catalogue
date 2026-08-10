from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import pandas as pd


class ProductRecommender:
    def __init__(self):
        self.products = pd.DataFrame()
        self.similarity_matrix = None
        self.vectorizer = TfidfVectorizer(
            stop_words="english"
        )

    def train(self, products: list[dict]):
        """
        Build the recommendation model from product data.
        """

        self.products = pd.DataFrame(products)

        if self.products.empty:
            raise ValueError("Product dataset is empty.")

        required_columns = [
            "id",
            "name",
            "category",
            "description",
        ]

        for column in required_columns:
            if column not in self.products.columns:
                raise ValueError(
                    f"Missing required column: {column}"
                )

        # Prevent null values from breaking TF-IDF.
        self.products["name"] = (
            self.products["name"].fillna("")
        )

        self.products["category"] = (
            self.products["category"].fillna("")
        )

        self.products["description"] = (
            self.products["description"].fillna("")
        )

        # Give category slightly more influence by
        # including it twice.
        self.products["features"] = (
            self.products["name"]
            + " "
            + self.products["category"]
            + " "
            + self.products["category"]
            + " "
            + self.products["description"]
        )

        tfidf_matrix = self.vectorizer.fit_transform(
            self.products["features"]
        )

        self.similarity_matrix = cosine_similarity(
            tfidf_matrix
        )

    def recommend(
        self,
        product_id: str,
        limit: int = 5,
    ) -> list[dict]:
        """
        Return products most similar to the selected product.
        """

        if self.similarity_matrix is None:
            raise ValueError(
                "Recommendation model has not been trained."
            )

        matches = self.products.index[
            self.products["id"] == product_id
        ].tolist()

        if not matches:
            raise ValueError(
                f"Product not found: {product_id}"
            )

        product_index = matches[0]

        scores = list(
            enumerate(
                self.similarity_matrix[product_index]
            )
        )

        # Highest similarity first.
        scores = sorted(
            scores,
            key=lambda item: item[1],
            reverse=True,
        )

        recommendations = []

        for index, score in scores:
            # Don't recommend the selected product itself.
            if index == product_index:
                continue

            product = self.products.iloc[index]

            recommendations.append(
                {
                    "id": product["id"],
                    "name": product["name"],
                    "category": product["category"],
                    "description": product["description"],
                    "similarity_score": round(
                        float(score),
                        4,
                    ),
                }
            )

            if len(recommendations) >= limit:
                break

        return recommendations