import json
import os

class ScoreManager:
    HIGHSCORES_PATH = "highscores.json"
    MAX_SAVED_NAMES = 10
    MAX_LEADERBOARD_ENTRIES = 10

    def __init__(self):
        self.current_player_name = ""
        self.high_scores = [] # list of {"name": str, "score": int}
        self.unique_names = [] # Previous player names
        self.load_scores()

    def load_scores(self):
        if not os.path.exists(self.HIGHSCORES_PATH):
            return

        try:
            with open(self.HIGHSCORES_PATH, 'r') as f:
                data = json.load(f)
                self.high_scores = data.get("high_scores", [])
                self.unique_names = data.get("unique_names", [])
        except Exception as e:
            print(f"Error loading scores: {e}")

    def save_scores(self):
        data = {
            "high_scores": self.high_scores,
            "unique_names": self.unique_names
        }
        try:
            with open(self.HIGHSCORES_PATH, 'w') as f:
                json.dump(data, f)
        except Exception as e:
            print(f"Error saving scores: {e}")

    def set_player_name(self, name):
        self.current_player_name = name
        if name in self.unique_names:
            self.unique_names.remove(name)
        self.unique_names.insert(0, name)
        self.unique_names = self.unique_names[:self.MAX_SAVED_NAMES]
        self.save_scores()

    def submit_score(self, score):
        if score <= 0: return
        entry = {"name": self.current_player_name, "score": score}
        self.high_scores.append(entry)
        self.high_scores.sort(key=lambda x: x["score"], reverse=True)
        # Pruning is optional per requirements but recommended for display
        self.save_scores()

    def get_top_scores(self):
        return self.high_scores[:self.MAX_LEADERBOARD_ENTRIES]

    def is_personal_best(self, score):
        pb = 0
        for entry in self.high_scores:
            if entry["name"] == self.current_player_name:
                pb = max(pb, entry["score"])
        return score > pb
