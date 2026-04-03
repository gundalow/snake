import pygame
import sys
import os
import random
import math

# Ensure the root of the project is in the Python path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

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
    audio_manager = AudioManager()
    hud = HUD(score_manager)
    name_prompt = NamePrompt(score_manager)

    # Game initialization
    snake = None
    food_spawner = None
    ufo = None
    world_stomper = None
    event_timer = 0
    screen_shake = 0
    is_paused = False
    is_game_started = False
    is_game_over_submitted = False

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
                    # Initialize first game
                    snake = Snake(GameConstants.BOARD_WIDTH // 2, GameConstants.BOARD_HEIGHT // 2)
                    food_spawner = FoodSpawner()
                    food_spawner.spawn_food(snake)
                    audio_manager.play("whoosh")
                    world_stomper = WorldStomper()
                    event_timer = random.randint(30, 50)
                continue

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE or event.key == pygame.K_q:
                    running = False
                elif event.key == pygame.K_r:
                    # Reset Game
                    snake = Snake(GameConstants.BOARD_WIDTH // 2, GameConstants.BOARD_HEIGHT // 2)
                    food_spawner = FoodSpawner()
                    food_spawner.spawn_food(snake)
                    audio_manager.play("whoosh")
                    ufo = None
                    world_stomper = WorldStomper()
                    event_timer = random.randint(30, 50)
                    is_game_over_submitted = False
                    is_paused = False
                elif event.key == pygame.K_p:
                    is_paused = not is_paused

        if not is_game_started:
            name_prompt.draw(screen)
            pygame.display.flip()
            continue

        if snake.is_alive and not is_paused:
            keys = pygame.key.get_pressed()
            snake.handle_input(keys)
            snake.update(delta_time)

            # Check for food collection
            head_rect = pygame.Rect(snake.pos.x, snake.pos.y, GameConstants.GRID_SIZE, GameConstants.GRID_SIZE)
            for food in food_spawner.foods[:]:
                food_rect = pygame.Rect(food.pos.x, food.pos.y, GameConstants.GRID_SIZE, GameConstants.GRID_SIZE)
                if head_rect.colliderect(food_rect):
                    fully_eaten = food.take_bite()
                    snake.score += 1
                    snake.add_segment()
                    snake.base_move_speed += GameConstants.SPEED_INCREMENT

                    if snake.score % 10 == 0:
                        hud.show_pun_achievement(snake.score)

                    if food.food_type == FoodType.MEGA:
                        audio_manager.play("mega_chew")
                        snake.speed_multiplier = GameConstants.MEGA_FOOD_SPEED_MULTIPLIER
                        if fully_eaten:
                            audio_manager.play("burp")
                            snake.speed_multiplier = 1.0
                    else:
                        audio_manager.play("eat")

                    if fully_eaten:
                        food_spawner.foods.remove(food)
                        food_spawner.spawn_food(snake)
                        audio_manager.play("whoosh")

            food_spawner.update(current_time)
            hud.update(delta_time, snake)

            # Event Timer
            event_timer -= delta_time
            if event_timer <= 0:
                if random.choice(["UFO", "STOMPER"]) == "UFO" and not ufo:
                    if food_spawner.foods:
                        ufo = UFO()
                        ufo.start_hunt(random.choice(food_spawner.foods))
                        audio_manager.play("whoosh")
                else:
                    world_stomper.start_stomp()
                event_timer = random.randint(30, 50)

            # Update events
            if ufo:
                result = ufo.update(delta_time)
                if result == "STOLEN":
                    if ufo.target_food in food_spawner.foods:
                        food_spawner.foods.remove(ufo.target_food)
                        food_spawner.spawn_food(snake)
                        audio_manager.play("whoosh")
                        snake.score = max(0, snake.score - GameConstants.UFO_SCORE_PENALTY)
                        hud.add_achievement("Food Stolen by UFO!")
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

        # Drawing
        screen.fill(GameConstants.COLOR_GRASS)
        shake_offset = (random.randint(-screen_shake, screen_shake), random.randint(-screen_shake, screen_shake))

        # Grid lines
        for x in range(0, GameConstants.BOARD_WIDTH, GameConstants.GRID_SIZE):
            pygame.draw.line(screen, (40, 150, 40), (x + shake_offset[0], 0 + shake_offset[1]), (x + shake_offset[0], GameConstants.BOARD_HEIGHT + shake_offset[1]))
        for y in range(0, GameConstants.BOARD_HEIGHT, GameConstants.GRID_SIZE):
            pygame.draw.line(screen, (40, 150, 40), (0 + shake_offset[0], y + shake_offset[1]), (GameConstants.BOARD_WIDTH + shake_offset[0], y + shake_offset[1]))

        food_spawner.draw(screen)
        snake.draw(screen)
        if ufo: ufo.draw(screen)
        if world_stomper: world_stomper.draw(screen)

        hud.draw(screen, snake, is_paused)

        pygame.display.flip()

    pygame.quit()

if __name__ == "__main__":
    main()
