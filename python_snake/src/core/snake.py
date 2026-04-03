import pygame
from enum import Enum
import math
from .utils.constants import GameConstants

class Direction(Enum):
    NORTH = (0, -1)
    SOUTH = (0, 1)
    EAST = (1, 0)
    WEST = (-1, 0)

    def opposite(self):
        if self == Direction.NORTH: return Direction.SOUTH
        if self == Direction.SOUTH: return Direction.NORTH
        if self == Direction.EAST: return Direction.WEST
        if self == Direction.WEST: return Direction.EAST
        return self

class Snake:
    def __init__(self, x, y):
        self.is_alive = True
        self.invulnerability_timer = GameConstants.INVULNERABILITY_TIME
        self.score = 0
        self.food_counts = {}
        self.heading = Direction.NORTH
        self.next_heading = Direction.NORTH
        self.base_move_speed = GameConstants.INITIAL_MOVE_SPEED
        self.speed_multiplier = 1.0

        # Position in pixels (float)
        self.pos = pygame.Vector2(x, y)
        self.grid_distance = 0.0
        self.distance_traveled = 0.0

        # History of transforms (pos and rot)
        self.position_history = []
        self._initialize_history()

        # Number of segments
        self.num_segments = 2

    def _initialize_history(self):
        needed = 2 * GameConstants.SEGMENT_SPACING + 1
        for i in range(needed):
            # Each history entry is (position, rotation)
            pos = pygame.Vector2(self.pos.x, self.pos.y + i * GameConstants.HISTORY_RESOLUTION)
            self.position_history.append((pos, 0))

    def handle_input(self, keys):
        if keys[pygame.K_UP] or keys[pygame.K_w]:
            requested = Direction.NORTH
        elif keys[pygame.K_DOWN] or keys[pygame.K_s]:
            requested = Direction.SOUTH
        elif keys[pygame.K_LEFT] or keys[pygame.K_a]:
            requested = Direction.WEST
        elif keys[pygame.K_RIGHT] or keys[pygame.K_d]:
            requested = Direction.EAST
        else:
            return

        if requested != self.heading.opposite():
            self.next_heading = requested

    def update(self, delta_time):
        if not self.is_alive:
            return

        if self.invulnerability_timer > 0:
            self.invulnerability_timer -= delta_time

        self.move_forward(delta_time)
        self.check_collision()

    def move_forward(self, delta_time):
        forward = pygame.Vector2(self.heading.value[0], self.heading.value[1])
        move_speed = self.base_move_speed * self.speed_multiplier
        move_vec = forward * move_speed * delta_time

        self.pos += move_vec
        step = move_vec.length()
        self.distance_traveled += step
        self.grid_distance += step

        # Grid snapping and direction change
        if self.grid_distance >= GameConstants.GRID_SIZE:
            self.grid_distance -= GameConstants.GRID_SIZE
            self.pos.x = round(self.pos.x / GameConstants.GRID_SIZE) * GameConstants.GRID_SIZE
            self.pos.y = round(self.pos.y / GameConstants.GRID_SIZE) * GameConstants.GRID_SIZE

            if self.next_heading != self.heading:
                self.heading = self.next_heading

        # History recording
        if self.distance_traveled >= GameConstants.HISTORY_RESOLUTION:
            self.distance_traveled -= GameConstants.HISTORY_RESOLUTION
            # Rotation is simple 2D angle (degrees)
            rotation = 0
            if self.heading == Direction.NORTH: rotation = 0
            elif self.heading == Direction.SOUTH: rotation = 180
            elif self.heading == Direction.EAST: rotation = 90
            elif self.heading == Direction.WEST: rotation = 270

            self.position_history.insert(0, (pygame.Vector2(self.pos), rotation))

            max_history = (self.num_segments + 1) * GameConstants.SEGMENT_SPACING + 1
            if len(self.position_history) > max_history:
                self.position_history = self.position_history[:max_history]

    def check_collision(self):
        # Wall collision
        if (self.pos.x < 0 or self.pos.x >= GameConstants.BOARD_WIDTH or
            self.pos.y < 0 or self.pos.y >= GameConstants.BOARD_HEIGHT):
            self.die("Wall collision")
            return

        # Self collision (only if not invulnerable)
        if self.invulnerability_timer <= 0:
            head_rect = pygame.Rect(self.pos.x, self.pos.y, GameConstants.GRID_SIZE, GameConstants.GRID_SIZE)
            for i in range(1, self.num_segments + 1):
                idx = i * GameConstants.SEGMENT_SPACING
                if idx < len(self.position_history):
                    seg_pos, _ = self.position_history[idx]
                    seg_rect = pygame.Rect(seg_pos.x, seg_pos.y, GameConstants.GRID_SIZE, GameConstants.GRID_SIZE)
                    # Inflate/deflate rect for better feel
                    seg_rect.inflate_ip(-4, -4)
                    if head_rect.colliderect(seg_rect):
                        self.die("Self collision")
                        return

    def die(self, reason):
        if not self.is_alive: return
        self.is_alive = False
        print(f"Snake died: {reason}")

    def add_segment(self):
        self.num_segments += 1

    def draw(self, screen):
        # Draw segments from back to front
        for i in range(self.num_segments, 0, -1):
            idx = i * GameConstants.SEGMENT_SPACING
            if idx < len(self.position_history):
                pos, rot = self.position_history[idx]
                # Cartoonish segment
                pygame.draw.rect(screen, GameConstants.COLOR_SNAKE,
                                 (pos.x, pos.y, GameConstants.GRID_SIZE, GameConstants.GRID_SIZE),
                                 border_radius=8)
                # Add eyes or detail if needed for head

        # Draw head
        pygame.draw.rect(screen, GameConstants.COLOR_SNAKE,
                         (self.pos.x, self.pos.y, GameConstants.GRID_SIZE, GameConstants.GRID_SIZE),
                         border_radius=12)
        # Head Eyes
        eye_color = (255, 255, 255)
        pupil_color = (0, 0, 0)

        # Eye positions based on heading
        offset_l, offset_r = pygame.Vector2(5, 5), pygame.Vector2(20, 5)
        if self.heading == Direction.SOUTH:
            offset_l, offset_r = pygame.Vector2(5, 20), pygame.Vector2(20, 20)
        elif self.heading == Direction.EAST:
            offset_l, offset_r = pygame.Vector2(20, 5), pygame.Vector2(20, 20)
        elif self.heading == Direction.WEST:
            offset_l, offset_r = pygame.Vector2(5, 5), pygame.Vector2(5, 20)

        pygame.draw.circle(screen, eye_color, self.pos + offset_l, 4)
        pygame.draw.circle(screen, eye_color, self.pos + offset_r, 4)
        pygame.draw.circle(screen, pupil_color, self.pos + offset_l, 2)
        pygame.draw.circle(screen, pupil_color, self.pos + offset_r, 2)
