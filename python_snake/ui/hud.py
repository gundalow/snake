import pygame
import random
import math
from utils.constants import GameConstants

class HUD:
    def __init__(self, score_manager):
        self.score_manager = score_manager
        self.font = pygame.font.SysFont("Arial", 24)
        self.large_font = pygame.font.SysFont("Arial", 48)
        self.achievements_queue = []
        self.achievement_timer = 0
        self.current_achievement = ""
        self.score_flash_timer = 0

        self.fruit_puns = [
            "Orange you glad you're playing?",
            "You're one in a melon!",
            "That was berry good!",
            "Lime feeling great about this!",
            "Peachy performance!",
            "A-peel-ing moves!",
            "Grape job!",
            "Cherry-ific!",
            "You're the top banana!",
            "Simply sub-lime!"
        ]
        self.snake_puns = [
            "Sssss-pectacular!",
            "Un-boa-lievable!",
            "Hiss-terical!",
            "Fangs for playing!",
            "Scale-ing new heights!",
            "Slither-in' like a pro!",
            "Quite s-s-s-smooth!",
            "Snake it 'til you make it!",
            "You're a total rattle-star!",
            "Totally hiss-tastic!"
        ]

    def add_achievement(self, text):
        if text not in self.achievements_queue:
            self.achievements_queue.append(text)

    def update(self, delta_time, snake):
        if self.achievement_timer > 0:
            self.achievement_timer -= delta_time
        elif self.achievements_queue:
            self.current_achievement = self.achievements_queue.pop(0)
            self.achievement_timer = 2.0

        if self.score_flash_timer > 0:
            self.score_flash_timer -= delta_time

    def check_achievements(self, snake, food):
        apples = snake.food_counts.get("apple", 0)
        if food.food_name == "apple":
            if apples == 10:
                self.add_achievement("An apple a day keeps the doctor away!")
            elif apples == 20:
                self.add_achievement("Really keeping those doctors away now!")
            elif apples == 30:
                self.add_achievement("The doctors have gone into hiding!")
            elif apples == 50:
                self.add_achievement("Apple Overlord!")

        if snake.score > 0 and snake.score % 10 == 0:
            if snake.score == 20:
                self.add_achievement("Snaaake Master!")
            else:
                puns = self.fruit_puns + self.snake_puns
                pun = random.choice(puns)
                self.add_achievement(f"{snake.score} Points: {pun}")

    def flash_score(self):
        self.score_flash_timer = 1.0

    def draw(self, screen, snake, is_paused=False):
        hud_bg = pygame.Surface((GameConstants.SCREEN_WIDTH, 40))
        hud_bg.set_alpha(150)
        hud_bg.fill((0, 0, 0))
        screen.blit(hud_bg, (0, 0))

        player_text = self.font.render(f"Player: {self.score_manager.current_player_name}", True, (255, 255, 255))
        screen.blit(player_text, (10, 10))

        score_color = (255, 255, 255)
        if self.score_flash_timer > 0:
            if (int(self.score_flash_timer * 10) % 2) == 0:
                score_color = (255, 0, 0)

        score_text = self.font.render(f"Score: {snake.score}", True, score_color)
        screen.blit(score_text, (GameConstants.SCREEN_WIDTH - 150, 10))

        if snake.speed_multiplier < 1.0:
            status_text = self.font.render("Too much melon! SLOWED DOWN!", True, (255, 100, 100))
            screen.blit(status_text, (GameConstants.SCREEN_WIDTH // 2 - 150, 10))

        if self.achievement_timer > 0:
            ach_surface = self.large_font.render(self.current_achievement, True, (255, 255, 0))
            ach_rect = ach_surface.get_rect(center=(GameConstants.SCREEN_WIDTH // 2, GameConstants.SCREEN_HEIGHT // 2 - 200))
            scale = 1.0 + 0.1 * math.sin(self.achievement_timer * 10)
            scaled_surface = pygame.transform.scale(ach_surface, (int(ach_rect.width * scale), int(ach_rect.height * scale)))
            scaled_rect = scaled_surface.get_rect(center=ach_rect.center)
            screen.blit(scaled_surface, scaled_rect)

        if is_paused:
            pause_surface = self.large_font.render("PAUSED", True, (255, 255, 255))
            pause_rect = pause_surface.get_rect(center=(GameConstants.SCREEN_WIDTH // 2, GameConstants.SCREEN_HEIGHT // 2))
            screen.blit(pause_surface, pause_rect)

        if not snake.is_alive:
            self.draw_game_over(screen, snake)

    def draw_game_over(self, screen, snake):
        overlay = pygame.Surface((GameConstants.SCREEN_WIDTH, GameConstants.SCREEN_HEIGHT))
        overlay.set_alpha(180)
        overlay.fill((0, 0, 0))
        screen.blit(overlay, (0, 0))

        over_text = self.large_font.render("GAME OVER", True, (255, 50, 50))
        over_rect = over_text.get_rect(center=(GameConstants.SCREEN_WIDTH // 2, 100))
        screen.blit(over_text, over_rect)

        score_text = self.font.render(f"Final Score: {snake.score}", True, (255, 255, 255))
        score_rect = score_text.get_rect(center=(GameConstants.SCREEN_WIDTH // 2, 160))
        screen.blit(score_text, score_rect)

        if self.score_manager.is_new_high_score:
            pb_text = self.large_font.render("NEW HIGH SCORE!", True, (255, 215, 0))
            pb_rect = pb_text.get_rect(center=(GameConstants.SCREEN_WIDTH // 2, 210))
            scale = 1.0 + 0.1 * math.sin(pygame.time.get_ticks() * 0.01)
            scaled_pb = pygame.transform.scale(pb_text, (int(pb_rect.width * scale), int(pb_rect.height * scale)))
            scaled_pb_rect = scaled_pb.get_rect(center=pb_rect.center)
            screen.blit(scaled_pb, scaled_pb_rect)
            for _ in range(20):
                pygame.draw.circle(screen, random.choice([(255,0,0), (0,255,0), (0,0,255), (255,255,0)]), (random.randint(0, GameConstants.SCREEN_WIDTH), random.randint(0, GameConstants.SCREEN_HEIGHT)), random.randint(3, 7))

        lb_text = self.font.render("--- TOP SCORES ---", True, (255, 255, 255))
        lb_rect = lb_text.get_rect(center=(GameConstants.SCREEN_WIDTH // 2, 280))
        screen.blit(lb_text, lb_rect)

        top_scores = self.score_manager.get_top_scores()
        for i, entry in enumerate(top_scores):
            entry_text = self.font.render(f"{i+1}. {entry['name']}: {entry['score']}", True, (200, 200, 200))
            entry_rect = entry_text.get_rect(center=(GameConstants.SCREEN_WIDTH // 2, 320 + i * 30))
            screen.blit(entry_text, entry_rect)

        restart_text = self.font.render("Press R to Restart or Q to Quit", True, (255, 255, 255))
        restart_rect = restart_text.get_rect(center=(GameConstants.SCREEN_WIDTH // 2, GameConstants.SCREEN_HEIGHT - 50))
        screen.blit(restart_text, restart_rect)

class NamePrompt:
    def __init__(self, score_manager):
        self.score_manager = score_manager
        self.font = pygame.font.SysFont("Arial", 36)
        self.name = ""
        self.is_done = False
        self.selected_name_idx = -1

    def handle_input(self, event):
        prev_names = self.score_manager.unique_names
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_RETURN:
                if self.selected_name_idx != -1:
                    self.name = prev_names[self.selected_name_idx]
                if self.name.strip():
                    self.score_manager.set_player_name(self.name)
                    self.is_done = True
            elif event.key == pygame.K_BACKSPACE:
                if self.selected_name_idx == -1:
                    self.name = self.name[:-1]
            elif event.key == pygame.K_UP:
                self.selected_name_idx = max(-1, self.selected_name_idx - 1)
            elif event.key == pygame.K_DOWN:
                self.selected_name_idx = min(len(prev_names) - 1, self.selected_name_idx + 1)
            else:
                if self.selected_name_idx == -1:
                    if len(self.name) < 15 and event.unicode.isprintable():
                        self.name += event.unicode

    def draw(self, screen):
        overlay = pygame.Surface((GameConstants.SCREEN_WIDTH, GameConstants.SCREEN_HEIGHT))
        overlay.fill((50, 50, 50))
        screen.blit(overlay, (0, 0))
        prompt_text = self.font.render("Enter Your Name:", True, (255, 255, 255))
        prompt_rect = prompt_text.get_rect(center=(GameConstants.SCREEN_WIDTH // 2, GameConstants.SCREEN_HEIGHT // 2 - 50))
        screen.blit(prompt_text, prompt_rect)
        display_name = self.name
        if self.selected_name_idx != -1:
            display_name = self.score_manager.unique_names[self.selected_name_idx]
        color = (0, 255, 0) if self.selected_name_idx == -1 else (150, 255, 150)
        name_text = self.font.render(display_name + ("_" if self.selected_name_idx == -1 else ""), True, color)
        name_rect = name_text.get_rect(center=(GameConstants.SCREEN_WIDTH // 2, GameConstants.SCREEN_HEIGHT // 2 + 20))
        screen.blit(name_text, name_rect)
        prev_text = pygame.font.SysFont("Arial", 20).render("Previous Names (Use Arrow Keys to Select):", True, (150, 150, 150))
        screen.blit(prev_text, (GameConstants.SCREEN_WIDTH // 2 - 150, GameConstants.SCREEN_HEIGHT // 2 + 100))
        for i, name in enumerate(self.score_manager.unique_names[:5]):
            is_selected = (i == self.selected_name_idx)
            color = (255, 255, 0) if is_selected else (100, 100, 100)
            n_text = pygame.font.SysFont("Arial", 20).render(("> " if is_selected else "") + name, True, color)
            screen.blit(n_text, (GameConstants.SCREEN_WIDTH // 2 - 150, GameConstants.SCREEN_HEIGHT // 2 + 130 + i * 25))
