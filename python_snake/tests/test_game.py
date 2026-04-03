import unittest
import pygame
import sys
import os

# Ensure src is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))

# Mock pygame before importing modules that use it
import pygame
pygame.init()
pygame.display.set_mode((1, 1), pygame.HIDDEN)

from core.snake import Snake, Direction
from core.food import Food, FoodType, FoodSpawner
from utils.constants import GameConstants
from utils.score_manager import ScoreManager

class TestSnake(unittest.TestCase):
    def setUp(self):
        # Use grid-aligned coords for movement tests to avoid rounding issues
        self.snake = Snake(120, 120)

    def test_initialization(self):
        self.assertTrue(self.snake.is_alive)
        self.assertEqual(self.snake.num_segments, 2)
        self.assertEqual(self.snake.score, 0)

    def test_movement(self):
        initial_pos = pygame.Vector2(self.snake.pos)
        # Move North for a very small step
        self.snake.update(0.01)
        self.assertLess(self.snake.pos.y, initial_pos.y)
        self.assertEqual(self.snake.pos.x, initial_pos.x)

    def test_segment_addition(self):
        initial_segments = self.snake.num_segments
        self.snake.add_segment()
        self.assertEqual(self.snake.num_segments, initial_segments + 1)
        self.assertEqual(self.snake.head_scale, 1.3)

    def test_wall_collision(self):
        self.snake.pos = pygame.Vector2(-10, -10)
        self.snake.check_collision()
        self.assertFalse(self.snake.is_alive)

class TestFood(unittest.TestCase):
    def test_mega_food_bites(self):
        food = Food(0, 0, FoodType.MEGA)
        self.assertEqual(food.bites_remaining, GameConstants.MEGA_FOOD_BITES_TO_FINISH)

        # Take first bite
        taken, fully = food.take_bite()
        self.assertTrue(taken)
        self.assertFalse(fully)
        self.assertEqual(food.bites_remaining, GameConstants.MEGA_FOOD_BITES_TO_FINISH - 1)

        # Immediate second bite should fail due to cooldown
        taken, fully = food.take_bite()
        self.assertFalse(taken)

        # Advance time for cooldown
        food.bite_cooldown = 0
        taken, fully = food.take_bite()
        self.assertTrue(taken)

    def test_food_spawner(self):
        spawner = FoodSpawner()
        snake = Snake(120, 120)
        food = spawner.spawn_food(snake)
        self.assertIn(food, spawner.foods)
        # Random position won't be snake head
        self.assertNotEqual(food.pos, snake.pos)

class TestScoreManager(unittest.TestCase):
    def setUp(self):
        ScoreManager.HIGHSCORES_PATH = "test_highscores.json"
        self.sm = ScoreManager()

    def tearDown(self):
        if os.path.exists("test_highscores.json"):
            os.remove("test_highscores.json")

    def test_submission(self):
        self.sm.set_player_name("Tester")
        self.sm.submit_score(100)
        top = self.sm.get_top_scores()
        self.assertEqual(len(top), 1)
        self.assertEqual(top[0]["name"], "Tester")
        self.assertEqual(top[0]["score"], 100)

if __name__ == "__main__":
    unittest.main()
