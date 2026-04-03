import pygame
import os

class AudioManager:
    def __init__(self):
        pygame.mixer.init()
        self.sounds = {}
        self.load_sounds()

    def load_sounds(self):
        # Base paths
        assets_base = os.path.join(os.path.dirname(__file__), "..", "..", "assets")
        sounds_path = os.path.join(assets_base, "sounds")
        audio_path = os.path.join(assets_base, "audio")

        # Specific sounds
        self.add_sound("whoosh", os.path.join(audio_path, "whoosh.wav"))
        self.add_sound("eat", os.path.join(sounds_path, "foods", "apple.ogg"))
        self.add_sound("mega_chew", os.path.join(sounds_path, "foods", "mega_melon", "chew.ogg"))
        self.add_sound("burp", os.path.join(sounds_path, "foods", "mega_burps", "burp1_alex_jauk-funny-burp-sound-effect-440267.ogg"))

        # If any of these are missing, we should handle gracefully
        # In a real environment, I'd check file existence

    def add_sound(self, name, path):
        if os.path.exists(path):
            try:
                self.sounds[name] = pygame.mixer.Sound(path)
            except Exception as e:
                print(f"Error loading sound {name} at {path}: {e}")
        else:
            print(f"Sound file not found: {path}")

    def play(self, name):
        if name in self.sounds:
            self.sounds[name].play()
