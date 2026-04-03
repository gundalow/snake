import pygame
import sys
import os
import random
import math

# Project Root (root of repo)
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

# Add python_snake/src to sys.path
SRC_DIR = os.path.abspath(os.path.dirname(__file__))
if SRC_DIR not in sys.path:
    sys.path.insert(0, SRC_DIR)

from core.snake import Snake, Direction
from core.food import Food, FoodSpawner, FoodType
from core.events import UFO, WorldStomper
from utils.constants import GameConstants
from utils.score_manager import ScoreManager
from utils.audio_manager import AudioManager
from ui.hud import HUD, NamePrompt

def main():
    pygame.init()
    screen = pygame.display.set_mode((GameConstants.SCREEN_WIDTH, GameConstants.SCREEN_HEIGHT))
    pygame.display.set_caption("Python 2D Snake")
    clock = pygame.time.Clock()

    score_manager = ScoreManager()
    audio_manager = AudioManager(PROJECT_ROOT)
    hud = HUD(score_manager)
    name_prompt = NamePrompt(score_manager)

    snake = None
    food_spawner = None
    ufo = None
    world_stomper = None
    event_timer = 0
    screen_shake = 0
    is_paused = False
    is_game_started = False
    is_game_over_submitted = False
    burp_timer = -1

    running = True
    while running:
        delta_time = clock.tick(60) / 1000.0
        current_time = pygame.time.get_ticks() / 1000.0

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

            if not is_game_started:
                name_prompt.handle_input(event)
                if name_prompt.is_done:
                    is_game_started = True
                    snake = Snake(GameConstants.BOARD_WIDTH // 2, GameConstants.BOARD_HEIGHT // 2)
                    food_spawner = FoodSpawner()
                    food_spawner.spawn_food(snake)
                    audio_manager.play("whoosh")
                    world_stomper = WorldStomper()
                    event_timer = random.randint(GameConstants.UFO_SPAWN_INTERVAL_RANGE[0], GameConstants.UFO_SPAWN_INTERVAL_RANGE[1])
                continue

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE or event.key == pygame.K_q:
                    running = False
                elif event.key == pygame.K_r:
                    snake = Snake(GameConstants.BOARD_WIDTH // 2, GameConstants.BOARD_HEIGHT // 2)
                    food_spawner = FoodSpawner()
                    food_spawner.spawn_food(snake)
                    audio_manager.play("whoosh")
                    ufo = None
                    world_stomper = WorldStomper()
                    event_timer = random.randint(GameConstants.UFO_SPAWN_INTERVAL_RANGE[0], GameConstants.UFO_SPAWN_INTERVAL_RANGE[1])
                    is_game_over_submitted = False
                    is_paused = False
                    burp_timer = -1
                elif event.key == pygame.K_p:
                    is_paused = not is_paused

        if not is_game_started:
            name_prompt.draw(screen)
            pygame.display.flip()
            continue

        if snake.is_alive and not is_paused:
            keys = pygame.key.get_pressed()
            snake.handle_input(keys)
            snake.update(delta_time, food_spawner.foods) # Added foods for hinged jaw logic

            if burp_timer > 0:
                burp_timer -= delta_time
                if burp_timer <= 0:
                    audio_manager.play("burp")
                    snake.speed_multiplier = 1.0
                    burp_timer = -1

            head_rect = pygame.Rect(snake.pos.x, snake.pos.y, GameConstants.GRID_SIZE, GameConstants.GRID_SIZE)
            for food in food_spawner.foods[:]:
                food_rect = pygame.Rect(food.pos.x, food.pos.y, GameConstants.GRID_SIZE, GameConstants.GRID_SIZE)
                if head_rect.colliderect(food_rect):
                    bite_taken, fully_eaten = food.take_bite()

                    if not bite_taken:
                        continue

                    snake.score += 1
                    snake.add_segment()
                    snake.base_move_speed += GameConstants.SPEED_INCREMENT
                    if food.food_name:
                        snake.food_counts[food.food_name] = snake.food_counts.get(food.food_name, 0) + 1

                    hud.check_achievements(snake, food)

                    if food.food_type == FoodType.MEGA:
                        audio_manager.play("mega_chew")
                        snake.speed_multiplier = GameConstants.MEGA_FOOD_SPEED_MULTIPLIER
                        if fully_eaten:
                            burp_timer = 0.5
                    else:
                        audio_manager.play("eat")

                    if fully_eaten:
                        food_spawner.foods.remove(food)
                        food_spawner.spawn_food(snake)
                        audio_manager.play("whoosh")

            food_spawner.update(current_time, delta_time)
            hud.update(delta_time, snake)

            event_timer -= delta_time
            if event_timer <= 0:
                if random.choice(["UFO", "STOMPER"]) == "UFO" and not ufo:
                    if food_spawner.foods:
                        ufo = UFO()
                        ufo.start_hunt(random.choice(food_spawner.foods))
                        audio_manager.play("whoosh")
                else:
                    world_stomper.start_stomp()
                event_timer = random.randint(GameConstants.UFO_SPAWN_INTERVAL_RANGE[0], GameConstants.UFO_SPAWN_INTERVAL_RANGE[1])

            if ufo:
                result = ufo.update(delta_time)
                if result == "STOLEN":
                    if ufo.target_food in food_spawner.foods:
                        food_spawner.foods.remove(ufo.target_food)
                        food_spawner.spawn_food(snake)
                        audio_manager.play("whoosh")
                        snake.score = max(0, snake.score - GameConstants.UFO_SCORE_PENALTY)
                        hud.add_achievement("Food Stolen by UFO!")
                        hud.flash_score()
                    ufo.state = "LEAVING"
                if not ufo.is_active:
                    ufo = None

            if world_stomper.is_active:
                result = world_stomper.update(delta_time)
                if result == "STOMP_IMPACT":
                    screen_shake = 20
                    food_spawner.relocate_all(snake)
                    hud.add_achievement("World Stomp! Look out!")

            if screen_shake > 0:
                screen_shake -= 1

        elif not snake.is_alive and not is_game_over_submitted:
            score_manager.submit_score(snake.score)
            is_game_over_submitted = True

        screen.fill(GameConstants.COLOR_GRASS)
        shake_off = (0, 0)
        if screen_shake > 0:
            shake_off = (random.randint(-screen_shake, screen_shake), random.randint(-screen_shake, screen_shake))

        for x in range(0, GameConstants.BOARD_WIDTH, GameConstants.GRID_SIZE):
            pygame.draw.line(screen, (40, 150, 40), (x + shake_off[0], 0 + shake_off[1]), (x + shake_off[0], GameConstants.BOARD_HEIGHT + shake_off[1]))
        for y in range(0, GameConstants.BOARD_HEIGHT, GameConstants.GRID_SIZE):
            pygame.draw.line(screen, (40, 150, 40), (0 + shake_off[0], y + shake_off[1]), (GameConstants.BOARD_WIDTH + shake_off[0], y + shake_off[1]))

        food_spawner.draw(screen)
        snake.draw(screen, shake_off)
        if ufo: ufo.draw(screen)
        if world_stomper: world_stomper.draw(screen)
        hud.draw(screen, snake, is_paused)
        pygame.display.flip()

    pygame.quit()

if __name__ == "__main__":
    main()
