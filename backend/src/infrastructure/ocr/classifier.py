import re


class MovementClassifier:

    CATEGORY_KEYWORDS: dict[str, list[str]] = {
        "food": [
            "restaurant", "supermarket", "grocery", "comida", "supermercado",
            "abarrote", "mercado", "cafetería", "cafe", "panadería", "tortillería",
            "pollería", "cevichería", "chifa", "fast food", "delivery",
        ],
        "transport": [
            "gasoline", "gas", "fuel", "uber", "taxi", "bus", "metro", "combustible",
            "gasolina", "transporte", "estacionamiento", "parking", "toll", "peaje",
            "indriver", "cabify", "beat", "pasaje",
        ],
        "housing": [
            "rent", "renta", "mortgage", "hipoteca", "electricity", "electricidad",
            "water", "agua", "internet", "cable", "maintenance", "mantenimiento",
            "luz", "alquiler", "arrendamiento", "enel", "sedapal",
        ],
        "health": [
            "pharmacy", "farmacia", "doctor", "hospital", "medical", "médico",
            "dentist", "dentista", "seguro", "insurance", "medicine", "medicina",
            "clínica", "botica", "inkafarma", "mifarma", "essalud",
        ],
        "entertainment": [
            "cine", "movie", "netflix", "spotify", "streaming", "entertainment",
            "entretenimiento", "game", "juego", "concert", "concierto",
            "videojuego", "steam", "playstation", "xbox",
        ],
        "education": [
            "school", "escuela", "university", "universidad", "course", "curso",
            "tuition", "colegiatura", "book", "libro", "education", "educación",
            "colegio", "instituto", "academia", "matrícula", "pensión",
        ],
        "shopping": [
            "amazon", "walmart", "target", "costco", "store", "tienda", "shop",
            "clothing", "ropa", "electronic", "electrónico", "saga", "ripley",
            "oechsle", "tottus", "plaza vea", "wong", "metro",
        ],
        "salary": [
            "salary", "salario", "sueldo", "payroll", "nómina", "wage", "income",
            "deposit", "depósito", "abono", "transferencia recibida", "honorarios",
        ],
        "transfer": [
            "transfer", "transferencia", "envío", "envio", "send", "wire",
            "yape", "plin", "izipay", "tunki", "lukita", "bim",
            "enviaste", "enviaron", "recibiste", "recibido",
        ],
    }

    @staticmethod
    def classify(text: str, amount_cents: int | None = None) -> dict:
        lower = text.lower()
        scores: dict[str, float] = {}

        for category, keywords in MovementClassifier.CATEGORY_KEYWORDS.items():
            score = 0.0
            for keyword in keywords:
                if keyword in lower:
                    score += 1.0
                    if re.search(rf"\b{re.escape(keyword)}\b", lower):
                        score += 0.5
            if score > 0:
                scores[category] = score

        if not scores:
            if amount_cents and amount_cents > 0:
                if amount_cents > 100_000_00:
                    return {"category": "transfer", "confidence": 0.5}
                return {"category": "other", "confidence": 0.3}
            return {"category": "other", "confidence": 0.3}

        best = max(scores, key=scores.get)
        max_score = scores[best]

        total = sum(scores.values())
        confidence = min(max_score / (total or 1), 1.0)
        confidence = round(confidence * min(0.5 + max_score * 0.1, 0.95), 2)

        return {"category": best, "confidence": confidence, "all_scores": scores}
