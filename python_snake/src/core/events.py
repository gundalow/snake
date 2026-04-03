import pygame
import random
from .utils.constants import GameConstants

class UFO:
    def __init__(self):
        self.pos = pygame.Vector2(GameConstants.BOARD_WIDTH * 1.5, GameConstants.BOARD_HEIGHT * 0.1)
        self.target_food = None
        self.state = "APPROACHING" # APPROACHING, ABDUCTING, LEAVING
        self.speed = GameConstants.UFO_SPEED
        self.abduction_timer = 0
        self.is_active = True

    def start_hunt(self, food):
        self.target_food = food

    def update(self, delta_time):
        if self.state == "APPROACHING":
            if not self.target_food:
                self.state = "LEAVING"
                return

            target_pos = self.target_food.pos
            dir = (target_pos - self.pos).normalized()
            dist = self.pos.distance_to(target_pos)

            if dist < 5:
                self.pos = target_pos
                self.state = "ABDUCTING"
                self.abduction_timer = 1.0 # 1 second to abduct
            else:
                self.pos += dir * self.speed * delta_time

        elif self.state == "ABDUCTING":
            self.abduction_timer -= delta_time
            if self.abduction_timer <= 0:
                if self.target_food:
                    # Signal to main to remove food and penalize score
                    return "STOLEN"
                self.state = "LEAVING"

        elif self.state == "LEAVING":
            exit_pos = pygame.Vector2(-GameConstants.BOARD_WIDTH * 0.5, -GameConstants.BOARD_HEIGHT * 0.5)
            dir = (exit_pos - self.pos).normalized()
            self.pos += dir * self.speed * 2.0 * delta_time
            if self.pos.distance_to(exit_pos) < 10:
                self.is_active = False

        return None

    def draw(self, screen):
        # Draw UFO (Oval)
        ufo_rect = pygame.Rect(0, 0, 60, 20)
        ufo_rect.center = self.pos
        pygame.draw.ellipse(screen, (150, 150, 150), ufo_rect)
        # Cockpit
        cockpit_rect = pygame.Rect(0, 0, 30, 15)
        cockpit_rect.center = (self.pos.x, self.pos.y - 5)
        pygame.draw.ellipse(screen, (0, 255, 255), cockpit_rect)
        # Tractor beam
        if self.state == "ABDUCTING":
            beam_rect = pygame.Rect(self.pos.x - 15, self.pos.y, 30, 100)
            pygame.draw.rect(screen, (0, 255, 0, 100), beam_rect)

class WorldStomper:
    def __init__(self):
        self.pos = pygame.Vector2(0, 0)
        self.state = "IDLE" # IDLE, WARNING, STOMPING, LEAVING
        self.timer = 0
        self.is_active = False

    def start_stomp(self):
        self.is_active = True
        self.state = "WARNING"
        self.timer = 2.0 # 2 seconds of shadow warning
        self.pos = pygame.Vector2(random.randint(0, GameConstants.BOARD_WIDTH),
                                  random.randint(0, GameConstants.BOARD_HEIGHT))

    def update(self, delta_time):
        if not self.is_active: return None

        self.timer -= delta_time
        if self.state == "WARNING":
            if self.timer <= 0:
                self.state = "STOMPING"
                self.timer = 0.5 # Impact time
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
            # Shadow
            pygame.draw.circle(screen, (0, 0, 0, 100), self.pos, 50)
        elif self.state == "STOMPING":
            # Giant cartoon foot (Big Brown Rectangle)
            foot_rect = pygame.Rect(0, 0, 200, 300)
            foot_rect.center = self.pos
            pygame.draw.rect(screen, (139, 69, 19), foot_rect, border_radius=20)
            # Toes
            for i in range(3):
                pygame.draw.circle(screen, (139, 69, 19), (self.pos.x - 60 + i*60, self.pos.y - 140), 40)
