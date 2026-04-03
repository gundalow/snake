import pygame
import random
import math
from utils.constants import GameConstants

class FoodType:
    NORMAL = 1
    MEGA = 2

class Food:
    def __init__(self, x, y, food_type=FoodType.NORMAL, food_name=""):
        self.pos = pygame.Vector2(x, y)
        self.food_type = food_type
        self.food_name = food_name
        self.bites_remaining = 1
        self.bite_cooldown = 0

        if self.food_type == FoodType.MEGA:
            self.bites_remaining = GameConstants.MEGA_FOOD_BITES_TO_FINISH

        self.rect = pygame.Rect(self.pos.x, self.pos.y, GameConstants.GRID_SIZE, GameConstants.GRID_SIZE)
        self.spawn_time = pygame.time.get_ticks() / 1000.0
        self.scale_anim = 0.0

    def update(self, current_time, delta_time):
        dt = current_time - self.spawn_time
        if dt < 0.75:
            p = dt / 0.75
            self.scale_anim = math.sin(p * math.pi * 1.5) * (1 - p) + p
        else:
            self.scale_anim = 1.0

        if self.bite_cooldown > 0:
            self.bite_cooldown -= delta_time

    def take_bite(self):
        if self.bite_cooldown > 0:
            return False, False # (Bite taken, Fully eaten)

        self.bites_remaining -= 1
        self.bite_cooldown = 0.5
        is_fully_eaten = (self.bites_remaining <= 0)
        return True, is_fully_eaten

    def draw(self, screen):
        size = GameConstants.GRID_SIZE * self.scale_anim
        if self.food_type == FoodType.MEGA:
            size *= (1.5 + (self.bites_remaining - 1) * 0.5)

        center = self.pos + pygame.Vector2(GameConstants.GRID_SIZE // 2, GameConstants.GRID_SIZE // 2)
        draw_rect = pygame.Rect(0, 0, size, size)
        draw_rect.center = center

        color = (255, 0, 0)
        if self.food_name == "lychee": color = (255, 182, 193)
        elif self.food_name == "sweet_potato": color = (128, 0, 128)
        elif self.food_type == FoodType.MEGA: color = (255, 165, 0)

        pygame.draw.ellipse(screen, color, draw_rect)
        stem_rect = pygame.Rect(center.x - 2, center.y - size//2 - 2, 4, 6)
        pygame.draw.rect(screen, (0, 100, 0), stem_rect)

class FoodSpawner:
    def __init__(self):
        self.foods = []
        self.spawn_count = 0

    def spawn_food(self, snake):
        board_width = GameConstants.BOARD_WIDTH
        board_height = GameConstants.BOARD_HEIGHT
        grid_size = GameConstants.GRID_SIZE
        self.spawn_count += 1

        attempts = 0
        valid_pos = False
        x, y = 0, 0

        while not valid_pos and attempts < 50:
            attempts += 1
            x = random.randint(0, (board_width // grid_size) - 1) * grid_size
            y = random.randint(0, (board_height // grid_size) - 1) * grid_size

            valid_pos = True
            if snake and pygame.Vector2(x, y).distance_to(snake.pos) < grid_size * 2:
                valid_pos = False
                continue

            if snake:
                for i in range(1, snake.num_segments + 1):
                    idx = i * GameConstants.SEGMENT_SPACING
                    if idx < len(snake.position_history):
                        seg_pos, _ = snake.position_history[idx]
                        if pygame.Vector2(x, y).distance_to(seg_pos) < grid_size:
                            valid_pos = False
                            break
            if not valid_pos: continue

            for food in self.foods:
                if pygame.Vector2(x, y).distance_to(food.pos) < grid_size:
                    valid_pos = False
                    break

        food_type = FoodType.NORMAL
        if self.spawn_count % 5 == 0:
            food_type = FoodType.MEGA

        names = ["apple", "lychee", "sweet_potato"]
        name = random.choice(names)

        new_food = Food(x, y, food_type, name)
        self.foods.append(new_food)
        return new_food

    def relocate_all(self, snake):
        old_foods = self.foods
        self.foods = []
        for f in old_foods:
            self.spawn_food(snake)

    def update(self, current_time, delta_time):
        for food in self.foods:
            food.update(current_time, delta_time)

    def draw(self, screen):
        for food in self.foods:
            food.draw(screen)
