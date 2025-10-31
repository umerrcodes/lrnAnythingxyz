import json
import os
from dataclasses import dataclass, asdict
from typing import List, Optional


@dataclass
class Article:
    id: str
    topic: str
    title: str
    summary: str
    body: str


class RecentsStore:
    """JSON file store for recent articles."""

    def __init__(self, path: Optional[str] = None, max_count: int = 10):
        base = os.path.dirname(__file__)
        self.path = path or os.path.join(base, "recents.json")
        self.max_count = max_count
        self._items: List[Article] = []
        self.load()

    @property
    def items(self) -> List[Article]:
        return list(self._items)

    def add(self, article: Article) -> None:
        self._items = [a for a in self._items if a.id != article.id]
        self._items.insert(0, article)
        self._items = self._items[: self.max_count]
        self.save()

    def load(self) -> None:
        if not os.path.exists(self.path):
            self._items = []
            return
        try:
            with open(self.path, "r", encoding="utf-8") as f:
                raw = json.load(f)
            self._items = [Article(**a) for a in raw]
        except Exception:
            self._items = []

    def save(self) -> None:
        try:
            data = [asdict(a) for a in self._items]
            with open(self.path, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
        except Exception:
            pass
