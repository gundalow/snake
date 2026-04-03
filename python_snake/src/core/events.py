import pygame
import random
import math
from utils.constants import GameConstants

class UFO:
    def __init__(self):
        board_size = GameConstants.BOARD_WIDTH
        self.pos = pygame.Vector2(board_size * 1.5, GameConstants.BOARD_HEIGHT * 0.1)
        if random.random() > 0.5: self.pos.x *= -1

        self.target_food = None
        self.state = "APPROACHING"
        self.speed = GameConstants.UFO_SPEED
        self.abduction_timer = 0
        self.is_active = True

    def start_hunt(self, food):
        self.target_food = food

    def update(self, delta_time):
        current_time = pygame.time.get_ticks() / 1000.0

        if self.state == "APPROACHING":
            if not self.target_food:
                self.state = "LEAVING"
                return None

            target_pos = self.target_food.pos
            dir_vec = (target_pos - self.pos).normalized()
            dist = self.pos.distance_to(target_pos)

            if dist < 5:
                self.pos = pygame.Vector2(target_pos)
                self.state = "ABDUCTING"
                self.abduction_timer = 2.0
            else:
                self.pos += dir_vec * self.speed * delta_time

        elif self.state == "ABDUCTING":
            self.abduction_timer -= delta_time
            if self.abduction_timer <= 1.0:
                if self.target_food:
                    self.target_food.scale_anim = max(0, self.abduction_timer)
            if self.abduction_timer <= 0:
                if self.target_food:
                    return "STOLEN"
                self.state = "LEAVING"

        elif self.state == "LEAVING":
            exit_pos = pygame.Vector2(GameConstants.BOARD_WIDTH * 2, GameConstants.BOARD_HEIGHT * 0.1)
            if self.pos.x < 0: exit_pos.x = -GameConstants.BOARD_WIDTH * 2

            dir_vec = (exit_pos - self.pos).normalized()
            side_dir = pygame.Vector2(-dir_vec.y, dir_vec.x)
            zig_zag = side_dir * math.sin(current_time * 10.0) * 100.0

            self.pos += (dir_vec * self.speed * 2.0 * delta_time + zig_zag * delta_time)

            if self.pos.x > GameConstants.BOARD_WIDTH * 2.5 or self.pos.x < -GameConstants.BOARD_WIDTH * 2.5:
                self.is_active = False

        return None

    def draw(self, screen):
        ufo_rect = pygame.Rect(0, 0, 80, 30)
        ufo_rect.center = self.pos
        pygame.draw.ellipse(screen, (150, 150, 150), ufo_rect)
        cockpit_rect = pygame.Rect(0, 0, 40, 20)
        cockpit_rect.center = (self.pos.x, self.pos.y - 10)
        pygame.draw.ellipse(screen, (0, 255, 255), cockpit_rect)
        if self.state == "ABDUCTING":
            beam_surface = pygame.Surface((60, 200), pygame.SRCALPHA)
            pygame.draw.polygon(beam_surface, (0, 255, 0, 100), [(0, 200), (60, 200), (40, 0), (20, 0)])
            screen.blit(beam_surface, (self.pos.x - 30, self.pos.y))

class WorldStomper:
    def __init__(self):
        self.pos = pygame.Vector2(0, 0)
        self.state = "IDLE"
        self.timer = 0
        self.is_active = False

    def start_stomp(self):
        self.is_active = True
        self.state = "WARNING"
        self.timer = 2.0
        grid = GameConstants.GRID_SIZE
        self.pos = pygame.Vector2(random.randint(2, (GameConstants.BOARD_WIDTH // grid) - 3) * grid,
                                  random.randint(2, (GameConstants.BOARD_HEIGHT // grid) - 3) * grid)

    def update(self, delta_time):
        if not self.is_active: return None

        self.timer -= delta_time
        if self.state == "WARNING":
            if self.timer <= 0:
                self.state = "STOMPING"
                self.timer = 0.3
                return "STOMP_IMPACT"
        elif self.state == "STOMPING":
            if self.timer <= 0:
                self.state = "LEAVING"
                self.timer = 1.0
        elif self.state == "LEAVING":
            if self.timer <= 0:
                self.is_active = False
                self.state = "IDLE"
        return None

    def draw(self, screen):
        if not self.is_active: return

        if self.state == "WARNING":
            alpha = int(100 + 50 * math.sin(pygame.time.get_ticks() * 0.01))
            shadow_surface = pygame.Surface((200, 200), pygame.SRCALPHA)
            pygame.draw.circle(shadow_surface, (0, 0, 0, alpha), (100, 100), 80)
            screen.blit(shadow_surface, (self.pos.x - 100, self.pos.y - 100))
        elif self.state == "STOMPING":
            foot_rect = pygame.Rect(0, 0, 200, 300)
            foot_rect.center = self.pos
            pygame.draw.rect(screen, (139, 69, 19), foot_rect, border_radius=20)
            for i in range(3):
                pygame.draw.circle(screen, (139, 69, 19), (self.pos.x - 60 + i*60, self.pos.y - 140), 40)
