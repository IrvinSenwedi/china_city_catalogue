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

        self.products["name"] = (
            self.products["name"].fillna("")
        )

        self.products["category"] = (
            self.products["category"].fillna("")
        )

        self.products["description"] = (
            self.products["description"].fillna("")
        )

        # Category is included twice to give it
        # slightly more influence.
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
        Return products most similar to a selected product.
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

        scores = sorted(
            scores,
            key=lambda item: item[1],
            reverse=True,
        )

        recommendations = []

        for index, score in scores:
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

    def _get_top_user_category(
        self,
        interactions: list[dict],
    ) -> str | None:
        category_scores = {}

        for interaction in interactions:
            category = interaction.get("category") or ""
            weight = interaction.get("weight", 0)

            if not category:
                continue

            category_scores[category] = (
                category_scores.get(category, 0)
                + weight
            )

        if not category_scores:
            return None

        return max(
            category_scores,
            key=category_scores.get,
        )

    def recommend_for_user(
        self,
        interactions: list[dict],
        limit: int = 5,
    ) -> list[dict]:
        if self.similarity_matrix is None:
            raise ValueError(
                "Recommendation model has not been trained."
            )

        if not interactions:
            return []

        # Aggregate interaction weight by product.
        product_weights = {}

        # Products that have been reserved should
        # not be recommended again.
        reserved_product_ids = set()

        for interaction in interactions:
            product_id = interaction["product_id"]
            weight = interaction["weight"]
            interaction_type = interaction["interaction_type"]

            product_weights[product_id] = (
                product_weights.get(product_id, 0)
                + weight
            )

            if interaction_type == "RESERVATION":
                reserved_product_ids.add(product_id)

        weighted_vectors = []
        total_weight = 0

        for product_id, total_product_weight in product_weights.items():
            matches = self.products.index[
                self.products["id"] == product_id
            ].tolist()

            if not matches:
                continue

            product_index = matches[0]

            product_features = self.products.iloc[
                product_index
            ]["features"]

            product_vector = self.vectorizer.transform(
                [product_features]
            )

            # Prevent repeated testing/views from completely
            # dominating the user profile.
            capped_weight = min(
                total_product_weight,
                10,
            )

            weighted_vectors.append(
                product_vector * capped_weight
            )

            total_weight += capped_weight

        if not weighted_vectors:
            return []

        user_profile = weighted_vectors[0]

        for vector in weighted_vectors[1:]:
            user_profile = user_profile + vector

        user_profile = user_profile / total_weight

        product_vectors = self.vectorizer.transform(
            self.products["features"]
        )

        scores = cosine_similarity(
            user_profile,
            product_vectors,
        )[0]

        ranked = sorted(
            enumerate(scores),
            key=lambda item: item[1],
            reverse=True,
        )

        top_category = self._get_top_user_category(
            interactions
        )

        recommendations = []

        for index, score in ranked:
            product = self.products.iloc[index]

            # Reserved products are excluded.
            if product["id"] in reserved_product_ids:
                continue

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
                    "reason": (
                        f"Recommended based on your interest "
                        f"in {top_category} products."
                        if top_category
                        else "Recommended based on your recent activity."
                    ),
                }
            )

            if len(recommendations) >= limit:
                break

        return recommendations
