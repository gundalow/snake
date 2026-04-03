import pygame
import os
import random

class AudioManager:
    def __init__(self, base_path):
        pygame.mixer.init()
        self.sounds = {}
        self.burps = []
        self.base_path = base_path # Root directory of the project
        self.load_sounds()

    def load_sounds(self):
        # Base paths relative to project root
        sounds_path = os.path.join(self.base_path, "assets", "sounds")
        audio_path = os.path.join(self.base_path, "assets", "audio")

        # Specific sounds
        self.add_sound("whoosh", os.path.join(audio_path, "whoosh.wav"))
        self.add_sound("eat", os.path.join(sounds_path, "foods", "apple.ogg"))
        self.add_sound("mega_chew", os.path.join(sounds_path, "foods", "mega_melon", "chew.ogg"))

        # Load all burps for variety
        burps_dir = os.path.join(sounds_path, "foods", "mega_burps")
        if os.path.exists(burps_dir):
            for file in os.listdir(burps_dir):
                if file.endswith(".ogg") or file.endswith(".wav"):
                    path = os.path.join(burps_dir, file)
                    try:
                        self.burps.append(pygame.mixer.Sound(path))
                    except Exception as e:
                        print(f"Error loading burp {file}: {e}")

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
        elif name == "burp" and self.burps:
            random.choice(self.burps).play()
